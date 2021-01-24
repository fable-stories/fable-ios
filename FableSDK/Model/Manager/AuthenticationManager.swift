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

public enum AuthManagerEvent: EventContext {
  case userDidSignIn
  case userDidSignOut
}

private let kAuthCheckInterval: TimeInterval = 30.0


public protocol AuthManagerDelegate: class {
  func authManager(authStateDidChange authState: AuthState?, authManager: AuthManager)
}

public protocol AuthManager {
  var isAuthenticating: Signal<Bool, Never> { get }
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
  private let eventManager: EventManager
  public let analyticsManager: AnalyticsManager
  
  public let isAuthenticating: Signal<Bool, Never>
  internal let isAuthenticatingObserver: Signal<Bool, Never>.Observer
  
  public weak var delegate: AuthManagerDelegate?

  public init(
    stateManager: StateManager,
    environmentManager: EnvironmentManager,
    networkManager: NetworkManager,
    eventManager: EventManager,
    analyticsManager: AnalyticsManager,
    delegate: AuthManagerDelegate
  ) {
    self.stateManager = stateManager
    self.environmentManager = environmentManager
    self.networkManager = networkManager
    self.eventManager = eventManager
    self.analyticsManager = analyticsManager
    self.delegate = delegate
    (self.isAuthenticating, self.isAuthenticatingObserver) = Signal<Bool, Never>.pipe()
    super.init()
    
    /// Local development tooling
    if let userId = envInt("user_id"), let accessToken = envString("access_token") {
      self.setAuthState(AuthState(userId: userId, accessToken: accessToken))
    }
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
  
  public func authenticateWithApple(
    appleSub: String,
    email: String
  ) -> SignalProducer<Int, SignInError> {
    networkManager.request(
      SignInWithApple(),
      parameters: SignInWithApple.Request(
        appleSub: appleSub,
        email: email
      )
    )
    .mapError { .networkError($0) }
    .materializeResults()
    .flatMap(.latest) { [weak self] in
      self?.processResult($0) ?? .empty
    }
    .on(failed: { [weak self] error in
      self?.analyticsManager.trackEvent(AnalyticsEvent.appleSignInFailed, properties: ["error": error.localizedDescription])
    }, value: { [weak self] _ in
      self?.analyticsManager.trackEvent(AnalyticsEvent.appleSignInSucceeded)
    })
  }

  public func signOut() {
    self.delegate?.authManager(authStateDidChange: nil, authManager: self)
    self.eventManager.sendEvent(AuthManagerEvent.userDidSignOut)
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

      return SignalProducer<Int, SignInError>(value: user.userId)
    }
  }
  
  private func setAuthState(_ authState: AuthState?) {
    self.delegate?.authManager(authStateDidChange: authState, authManager: self)
  }
}
