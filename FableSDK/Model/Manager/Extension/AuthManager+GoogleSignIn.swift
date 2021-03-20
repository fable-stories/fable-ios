//
//  AuthManager+GoogleSignIn.swift
//  AppFoundation
//
//  Created by Edmund Ng on 2020-06-29.
//
import Foundation
import GoogleSignIn
import ReactiveSwift
import FableSDKEnums

extension AuthManagerImpl: GIDSignInDelegate {

  public func presentGoogleAuthViewController(presentingController: UIViewController) {
    // Authentication screen opening
    self.isAuthenticatingObserver.send(value: true)

    GIDSignIn.sharedInstance()?.presentingViewController = presentingController
    GIDSignIn.sharedInstance()?.delegate = self
    GIDSignIn.sharedInstance()?.signIn()
  }

  public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
    if let error = error {
      self.analyticsManager.trackEvent(AnalyticsEvent.googleSignInFailed, properties: ["error": error.localizedDescription])
      self.eventManager.sendEvent(AuthManagerEvent.didFailWithError(error))
      // Authentication screen closing
      self.isAuthenticatingObserver.send(value: false)
    } else if let auth = user.authentication {
      authenticateWithGoogle(idToken: auth.idToken).start()
    }
  }
}
