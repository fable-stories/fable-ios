import Foundation
import AppFoundation
import ReactiveSwift
import ReactiveFoundation
import FirebaseCore
import FirebaseCrashlytics
import GoogleSignIn

private let kEmailKey = "UserSessionFirebaseAdapter.email"
private let kPasswordKey = "UserSessionFirebaseAdapter.password"

public func configureFirebaseManager() {
  let environment: String = Environment.sourceEnvironment() == .prod ? "Prod" : "Dev"
  guard let filePath = Bundle.main.path(forResource: "GoogleService-Info-\(environment)", ofType: "plist"),
        let options = FirebaseOptions(contentsOfFile: filePath)
  else { fatalError("Unable to initialize Firebase") }
  FirebaseApp.configure(options: options)
  GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
}

public protocol FirebaseManager {
}

public class FirebaseManagerImpl: FirebaseManager {
  private let eventManager: EventManager
  private let authManager: AuthManager

  public init(eventManager: EventManager, authManager: AuthManager) {
    self.eventManager = eventManager
    self.authManager = authManager

    eventManager.onEvent.sinkDisposed(receiveCompletion: nil) { eventContext in
      switch eventContext {
      case AuthManagerEvent.userDidSignIn:
        if let userId = authManager.authenticatedUserId {
          Crashlytics.crashlytics().setUserID("\(userId)")
        }
      case AuthManagerEvent.userDidSignOut:
        Crashlytics.crashlytics().setUserID("")
      default:
        break
      }
    }
  }
}

