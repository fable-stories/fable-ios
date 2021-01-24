//
//  AuthManager+AppleSignIn.swift
//  AppFoundation
//
//  Created by Edmund Ng on 2020-06-29.
//
import AuthenticationServices
import CryptoKit
import Foundation
import KeychainAccess
import FableSDKEnums

private var currentNonce: String?
private let charSetString: Array = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")


extension AuthManagerImpl: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
  public func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    var result = ""
    var remainingLength = length

    while remainingLength > 0 {
      let randoms: [UInt8] = (0 ..< 16).map { _ in
        var random: UInt8 = 0
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
        if errorCode != errSecSuccess {
          fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        return random
      }

      randoms.forEach { random in
        if length == 0 {
          return
        }

        if random < charSetString.count {
          result.append(charSetString[Int(random)])
          remainingLength -= 1
        }
      }
    }
    return result
  }

  @available(iOS 13, *)
  public func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
      String(format: "%02x", $0)
    }.joined()

    return hashString
  }

  
  public func authenticateWithApple() {
    let nonce = randomNonceString()
    currentNonce = nonce
    let provider = ASAuthorizationAppleIDProvider()
    let request = provider.createRequest()
    request.requestedScopes = [.email]
    request.nonce = sha256(nonce)

    let appleSignInController = ASAuthorizationController(authorizationRequests: [request])
    appleSignInController.delegate = self
    appleSignInController.presentationContextProvider = self
    appleSignInController.performRequests()
  }

  public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
      let keychain = Keychain(service: "com.fable.stories")
      let key = "appleIDCredential.user:\(appleIDCredential.user)"
      guard
        let email = appleIDCredential.email ?? keychain[key],
        email.isNotEmpty
        else { return }
      self.authenticateWithApple(
        appleSub: appleIDCredential.user,
        email: email
      ).on(value: { user in
        keychain[key] = email
      }).start()
    }
  }

  public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    print(error)
    self.analyticsManager.trackEvent(AnalyticsEvent.appleSignInFailed, properties: ["error": error.localizedDescription])
  }

  public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    guard let window = UIWindow().topViewController()?.view.window else {
      fatalError("Failed to show Apple Sign-in modal")
    }
    return window
  }
}
