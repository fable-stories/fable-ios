//
//  ConfigTests.swift
//  FableTests
//
//  Created by Steven Andrews on 2020-05-24.
//

import XCTest
import AppFoundation
import FableSDKResourceTargets
import FableSDKModelManagers

/// Test the `/config` endpoint
class ConfigTests: XCTestCase {
  
  override func setUp() {
    continueAfterFailure = false
  }
  
  func testConfigEndpoint() {
    let expectation = self.expectation(description: "async request")
    
    NetworkTestsHelper.shared.networkManager.request(
      GetConfig()
    )
      .startWithResult { result in
        switch result {
          case let .failure(error):
            XCTFail("Config endpoint failed: \(error.localizedDescription)")
          case let .success(wire):
            guard let wire = wire else {
              XCTFail("Returned wire is nil")
              return
            }
            XCTAssertNotNil(wire.configId, "config_id is nil")
//            XCTAssertNotNil(wire.categories, "No categories were returned")
            XCTAssertNotNil(wire.colorHexStrings, "No color array was returned")
            XCTAssert((wire.colorHexStrings?.count ?? 0) > 0, "No hex colors were returned")
            expectation.fulfill()
        }
    }
    self.wait(for: [expectation], timeout: NetworkTestsHelper.expectationTimeout)
  }

}
