//
//  AuthenticationHelper.swift
//  FableTests
//
//  Created by Steven Andrews on 2020-05-30.
//

import XCTest
import AppFoundation
import FableSDKResolver
import FableSDKModelObjects
import FableSDKResourceTargets
import FableSDKWireObjects

@propertyWrapper
struct CallbackOnNil<T> {
  var wrappedValue: T?
}

/// Used to authenticate a user for tests that require it
class AuthenticationHelper: XCTestCase {

  struct UserInfo: Codable {
    let userId: Int
    let email: String
    let password: String
  }
  
  static private(set) var loggedIn = false
  
  private(set) var _userInfo: UserInfo!
  var userInfo: UserInfo {
    get {
      if _userInfo == nil {
        fetchUserInfo()
      }
      return _userInfo
    }
  }
  
  private func fetchUserInfo() {
    guard let path = Bundle(for: type(of: self)).path(forResource: "TestCredentials", ofType: "plist"),
      let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
      let decodedUserInfo = try? PropertyListDecoder().decode(UserInfo.self, from: data) else {
        fatalError("TestCredentials.plist could not be found. Please ensure it exists in the resources folder on disk")
    }
    _userInfo = decodedUserInfo
  }
  
  /// This tests the `/auth/email` endpoint
  func loginUser() {
    guard AuthenticationHelper.loggedIn == false else { return }
    fetchUserInfo()
    let expectation = self.expectation(description: "async request")
    NetworkTestsHelper.shared.networkManager.request(
      SignInUser(),
      parameters: SignInRequest(
        email: userInfo.email,
        password: userInfo.password,
        refreshToken: nil
      )
    ).startWithResult({ result in
      switch result {
        case let .failure(error):
          XCTFail("Sign in user endpoint failed: \(error.localizedDescription)")
        case let .success(wire):
          guard let user = wire else {
            XCTFail("Returned wire is nil")
            return
          }
          XCTAssertNotNil(user, "User returned nil")
          AuthenticationHelper.loggedIn = true
      }
      expectation.fulfill()
    })
    self.wait(for: [expectation], timeout: NetworkTestsHelper.expectationTimeout)
  }

}
