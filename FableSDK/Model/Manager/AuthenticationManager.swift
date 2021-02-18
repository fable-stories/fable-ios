//
//  AuthManager.swift
//  Fable
//
//  Created by Andrew Aquino on 12/13/19.
//

import FableSDKFoundation
import FableSDKErrorObjects
import FableSDKModelObjects
import FableSDKResourceTargets
import FableSDKWireObjects
import FableSDKEnums
import AppFoundation
import ReactiveFoundation
import ReactiveSwift
import UIKit
import Combine

public enum AuthManagerEvent: EventContext {
  case userDidSignIn
  case userDidSignOut
}

private let kAuthCheckInterval: TimeInterval = 30.0


public protocol AuthManagerDelegate: class {
  func authManager(authStateDidChange authState: AuthState?, authManager: AuthManager)
}

public protocol AuthManager {
  var isAuthenticating: Signal<Bool, Exception> { get }
  var isLoggedIn: Bool { get }
  var authenticatedUserId: Int? { get }

  func authenticate(email: String, password: String) -> SignalProducer<Int, SignInError>
  func authenticateWithGoogle(idToken: String) -> SignalProducer<Int, SignInError>
  func authenticateWithApple()

  func signOut()
  
  func presentGoogleAuthViewController(presentingController: UIViewController)
}

public class AuthManagerImpl: NSObject, AuthManager {

  public var isLoggedIn: Bool {
    environmentManager.authState != nil
  }
  
  public var authenticatedUserId: Int? {
    environmentManager.authState?.userId
  }

  private let stateManager: StateManager
  private let environmentManager: EnvironmentManager
  private let networkManager: NetworkManager
  private let networkManagerV2: NetworkManagerV2
  private let eventManager: EventManager
  public let analyticsManager: AnalyticsManager
  
  public let isAuthenticating: Signal<Bool, Exception>
  internal let isAuthenticatingObserver: Signal<Bool, Exception>.Observer
  
  public weak var delegate: AuthManagerDelegate?

  public init(
    stateManager: StateManager,
    environmentManager: EnvironmentManager,
    networkManager: NetworkManager,
    networkManagerV2: NetworkManagerV2,
    eventManager: EventManager,
    analyticsManager: AnalyticsManager,
    delegate: AuthManagerDelegate
  ) {
    self.stateManager = stateManager
    self.environmentManager = environmentManager
    self.networkManager = networkManager
    self.networkManagerV2 = networkManagerV2
    self.eventManager = eventManager
    self.analyticsManager = analyticsManager
    self.delegate = delegate
    (self.isAuthenticating, self.isAuthenticatingObserver) = Signal<Bool, Exception>.pipe()
    super.init()

    /// Local development tooling
    if let userId = envInt("user_id"), let accessToken = envString("access_token") {
      self.setAuthState(AuthState(userId: userId, accessToken: accessToken))
    }
    
    print(self.environmentManager.authState?.prettyJSONString ?? "No Auth State")
  }

  public func authenticate(email: String, password: String) -> SignalProducer<Int, SignInError> {
    networkManager.request(
      SignInUser(),
      parameters: SignInRequest(
        email: email,
        password: password,
        refreshToken: nil
      )
    )
    .mapError { .networkError($0) }
    .materializeResults()
    .flatMap(.latest) { [weak self] in
      self?.processResult($0) ?? .empty
    }
    .on(failed: { [weak self] error in
      self?.analyticsManager.trackEvent(AnalyticsEvent.emailSignInFailed, properties: ["error": error.localizedDescription])
    }, value: { [weak self] _ in
      self?.analyticsManager.trackEvent(AnalyticsEvent.emailignInSucceeded)
    })
  }

  public func authenticateWithGoogle(idToken: String) -> SignalProducer<Int, SignInError> {
    networkManager.request(
      SignInWithGoogle(),
      parameters: GoogleSignInRequest(rawIdToken: idToken)
    )
    .mapError { .networkError($0) }
    .materializeResults()
    .flatMap(.latest) { [weak self] in
      self?.processResult($0) ?? .empty
    }
    .on(failed: { [weak self] error in
      self?.analyticsManager.trackEvent(AnalyticsEvent.googleSignInFailed, properties: ["error": error.localizedDescription])
    }, value: { [weak self] _ in
      self?.analyticsManager.trackEvent(AnalyticsEvent.googleignInSucceeded)
    })
  }
  
  public func receiveAppleAuth(
    appleSub: String,
    email: String
  ) -> AnyPublisher<Int, Exception> {
    networkManagerV2.request(
      path: "/auth/apple",
      method: .post,
      parameters: SignInWithApple.Request(
        appleSub: appleSub,
        email: email
      ),
      expect: WireAuthenticationResponse.self
    )
    .tryMap { [weak self] value in
      guard let self = self else { throw SignInError.invalidResponseError }
      return try self.processResultV2(.success(value))
    }
    .mapError { Exception($0) }
    .eraseToAnyPublisher()
  }

  public func signOut() {
    self.delegate?.authManager(authStateDidChange: nil, authManager: self)
    self.eventManager.sendEvent(AuthManagerEvent.userDidSignOut)
  }
  
  private func processResultV2(_ result: Result<WireAuthenticationResponse?, SignInError>) throws -> Int {
    switch result {
    
    case let .failure(error):
      self.isAuthenticatingObserver.send(value: false)
      throw error

    case let .success(wire):
      guard
        let wire = wire,
        let accessToken = wire.accessToken,
        let user = wire.user.flatMap(User.init(wire:))
      else { throw SignInError.invalidResponseError }
      
      self.setAuthState(AuthState(userId: user.userId, accessToken: accessToken))
      self.eventManager.sendEvent(AuthManagerEvent.userDidSignIn)
      self.isAuthenticatingObserver.send(value: false)

      return user.userId
    }
  }

  private func processResult(_ result: Result<WireAuthenticationResponse?, SignInError>) -> SignalProducer<Int, SignInError> {
    switch result {
      
    case let .failure(error):
      // Authentication screen closing with err, allow further login attempt
      self.isAuthenticatingObserver.send(value: false)
      return SignalProducer<Int, SignInError>(error: error)
      
    case let .success(wire):
      guard
        let wire = wire,
        let accessToken = wire.accessToken,
        let user = wire.user.flatMap(User.init(wire:))
        else { return SignalProducer<Int, SignInError>(error: .invalidResponseError) }
      
      self.setAuthState(AuthState(userId: user.userId, accessToken: accessToken))
      self.eventManager.sendEvent(AuthManagerEvent.userDidSignIn)
      self.eventManager.sendEvent(AuthManagerEvent.userDidSignIn)
      
      return SignalProducer<Int, SignInError>(value: user.userId)
    }
  }
  
  private func setAuthState(_ authState: AuthState?) {
    RemoteLogger.shared.setMachineName(authState.flatMap { $0.userId.toString() })
    self.delegate?.authManager(authStateDidChange: authState, authManager: self)
  }
}
