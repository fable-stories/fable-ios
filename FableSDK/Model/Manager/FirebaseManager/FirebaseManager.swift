import Foundation
import AppFoundation
import ReactiveSwift
import ReactiveFoundation
import FirebaseCore
import FirebaseCrashlytics
import FirebaseAnalytics
import FableSDKEnums
import GoogleSignIn

private let kEmailKey = "UserSessionFirebaseAdapter.email"
private let kPasswordKey = "UserSessionFirebaseAdapter.password"

public class FirebaseSDK {
  static public func configure() {
    let environment: String = Environment.sourceEnvironment() == .prod ? "Prod" : "Dev"
    guard let filePath = Bundle.main.path(forResource: "GoogleService-Info-\(environment)", ofType: "plist"),
          let options = FirebaseOptions(contentsOfFile: filePath)
    else { fatalError("Unable to initialize Firebase") }
    FirebaseApp.configure(options: options)
    GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
  }
}

public protocol FirebaseManager {
  func configure()
}

public class FirebaseManagerImpl: FirebaseManager {
  private let eventManager: EventManager
  private let authManager: AuthManager
  private let analyticsManager: AnalyticsManager

  public init(
    eventManager: EventManager,
    authManager: AuthManager,
    analyticsManager: AnalyticsManager
  ) {
    self.eventManager = eventManager
    self.authManager = authManager
    self.analyticsManager = analyticsManager

    eventManager.onEvent.sinkDisposed(receiveCompletion: nil) { eventContext in
      switch eventContext {
      case AuthManagerEvent.userDidSignIn:
        if let userId = authManager.authenticatedUserId {
          self.setUserId(userId)
        }
      case AuthManagerEvent.userDidSignOut:
        self.setUserId(nil)
      default:
        break
      }
    }
    
    self.analyticsManager.onTrackEvent.eraseToAnyPublisher()
      .sinkDisposed(receiveCompletion: nil) { (event, parameters) in
        switch event {
        case AnalyticsEvent.didLogin:
          Analytics.logEvent(AnalyticsEventLogin, parameters: parameters)
        case AnalyticsEvent.didSignUp:
          Analytics.logEvent(AnalyticsEventSignUp, parameters: parameters)
        case AnalyticsEvent.appDidEnterForeground:
          Analytics.logEvent(AnalyticsEventAppOpen, parameters: parameters)
        case AnalyticsEvent.didCopyShareLink:
          Analytics.logEvent(AnalyticsEventShare, parameters: parameters)
        default:
          Analytics.logEvent(event.rawValue, parameters: parameters)
        }
      }
  }
  
  public func configure() {
    if let userId = authManager.authenticatedUserId {
      self.setUserId(userId)
    } else {
      self.setUserId(nil)
    }
  }
  
  private func setUserId(_ userId: Int?) {
    if let userId = userId?.toString() {
      Crashlytics.crashlytics().setUserID(userId)
      Analytics.setUserID(userId)
    } else {
      Crashlytics.crashlytics().setUserID("")
      Analytics.setUserID(nil)
    }
  }
}
