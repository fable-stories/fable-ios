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
    guard error == nil, let auth = user.authentication else {
      self.analyticsManager.trackEvent(AnalyticsEvent.googleSignInFailed, properties: ["error": error.localizedDescription])
      // Authentication screen closing
      self.isAuthenticatingObserver.send(value: false)
      return
    }
    authenticateWithGoogle(idToken: auth.idToken).start()
  }
}
