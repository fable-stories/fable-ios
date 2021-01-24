//
//  UserTests.swift
//  FableTests
//
//  Created by Steven Andrews on 2020-05-24.
//

import XCTest
import AppFoundation
import FableSDKResolver
import FableSDKModelObjects
import FableSDKResourceTargets
import FableSDKWireObjects
import FableSDKModelManagers

/// Test the `/user` endpoint
class UserTests: XCTestCase {
  
  let authHelper = AuthenticationHelper()
  
  override func setUp() {
    continueAfterFailure = false
  }
  
  /// Test `/user/{userId}`
  func testUserRefresh() {
    let userId = 1
    let expectation = self.expectation(description: "async request")
    NetworkTestsHelper.shared.networkManagerV2.request(
      GetUser(userId: userId)
    ).sinkDisposed(receiveCompletion: nil, receiveValue: { wire in
      guard let wire = wire else {
        XCTFail("Returned wire is nil")
        return
      }
      XCTAssertNotNil(wire.userId, "User's ID is nil")
      XCTAssertNotNil(wire.email, "User's email is nil")
      expectation.fulfill()
    })
    self.wait(for: [expectation], timeout: NetworkTestsHelper.expectationTimeout)
  }
}
