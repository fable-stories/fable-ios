//
//  CategoryTests.swift
//  FableTests
//
//  Created by Enrique Florencio on 7/1/20.
//

import XCTest
import AppFoundation
import FableSDKResolver
import FableSDKModelObjects
import FableSDKResourceTargets
import FableSDKModelManagers
import FableSDKWireObjects

class CategoryTests: XCTestCase {
    
    /// Tests the `POST` request on the /category endpoint which follows a `POST`, `GET`, `DELETE` order
    func testPOSTRequestOnCategoryEndpoint() {
        let category = UUID().uuidString /// Should be UUID().uuidString for stress testing
        var categoryObject: WireKategory? /// WireKategory object that will be used to store the wire response which will be referenced when making a GET request
        
        /// Create Expectations for each POST, GET, and DELETE request
        let postCategoryExpectation = XCTestExpectation(description: "Posting a category asynchronously")
        let getCategoryExpectation = XCTestExpectation(description: "Fetching a category asynchronously")
        let deleteCategoryExpectation = XCTestExpectation(description: "Deleting a category asynchronously")
        
        /// Make the POST request with the category declared at the beginning of this function (UUID().uuidstring)
        makePOSTRequest(category, postCategoryExpectation) { wire in
            /// Store the wire object which will be used later
            categoryObject = wire
        }
        
        /// Wait for the expectation to be fulfilled or timeout if the request is taking too long
        wait(for: [postCategoryExpectation], timeout: NetworkTestsHelper.expectationTimeout)
        
        
        /// Make the GET request on the /category/{categoryId} endpoint to make sure our POST request was reflected on the server
        /// We will be using the categoryId from the categoryObject declared at the beginning of this function in order to access the /category/{categoryId} endpoint
        makeGETRequest((categoryObject?.categoryId)!, getCategoryExpectation) { wire in
            /// This verifies that the Kategory Object that was sent back from the server is equal to the category that we sent earlier
            XCTAssertEqual(categoryObject?.title, wire?.title)
        }
        wait(for: [getCategoryExpectation], timeout: NetworkTestsHelper.expectationTimeout)

        /// Now that we know that its true we need to delete it from the server because we don't want to pollute the server with testing data
        /// Make the delete request
        makeDELETERequest((categoryObject?.categoryId)!, deleteCategoryExpectation)
        wait(for: [deleteCategoryExpectation], timeout: NetworkTestsHelper.expectationTimeout)
    }
    
    /// Tests the DELETE request on the /category endpoint which follows a POST, GET, DELETE, GET order (borrows code from the previous test)
    func testDELETERequestOnCategoryEndpoint() {
        let category = UUID().uuidString /// Should be UUID().uuidString for stress testing
        var categoryObject: WireKategory? /// Response object returned from a POST request
        
        /// Create Expectations for each POST, GET, and DELETE request
        let postCategoryExpectation = XCTestExpectation(description: "Posting a category asynchronously")
        var getCategoryExpectation = XCTestExpectation(description: "Fetching a category asynchronously")
        let deleteCategoryExpectation = XCTestExpectation(description: "Deleting a category asynchronously")
        
        /// Make the POST request with the category declared at the beginning of this function
        makePOSTRequest(category, postCategoryExpectation) { wire in
            categoryObject = wire
        }
        
        /// Wait for the expectation to be fulfilled or timeout if the request is taking too long
        wait(for: [postCategoryExpectation], timeout: NetworkTestsHelper.expectationTimeout)
        
        
        /// Make the GET request on the /category/{categoryId} endpoint to make sure our POST request was reflected on the server
        makeGETRequest((categoryObject?.categoryId)!, getCategoryExpectation) { wire in
            /// This verifies that the Kategory Object that was sent back from the server is equal to the category that we sent earlier
            XCTAssertEqual(categoryObject?.title, wire?.title)
        }
        wait(for: [getCategoryExpectation], timeout: NetworkTestsHelper.expectationTimeout)

        /// Now that we know that its true we need to delete it from the server because we don't want to pollute the server with testing data
        /// Make the delete request
        makeDELETERequest((categoryObject?.categoryId)!, deleteCategoryExpectation)
        wait(for: [deleteCategoryExpectation], timeout: NetworkTestsHelper.expectationTimeout)
        
        /// Make another GET request to make sure that it was deleted from the server
        getCategoryExpectation = XCTestExpectation(description: "Fetching a category again to make sure it was deleted")
        makeGETRequest((categoryObject?.categoryId)!, getCategoryExpectation) { (wire) in
            /// If the category was deleted from the server then the returned wire should be nil and thus the category was in fact deleted.
            XCTAssertNil(wire, "The category was not deleted from the /category/{categoryID} endpoint")
        }
        wait(for: [getCategoryExpectation], timeout: NetworkTestsHelper.expectationTimeout)
    }
    
    ///Tests the PUT request on the /category/{categoryid} endpoint. It follows a POST,PUT,GET, DELETE pattern in order to make sure that the category name was updated
    func testPUTRequestOnCategoryEndpoint() {
        let originalCategory = UUID().uuidString /// Should be UUID().uuidString for stress testing
        let updatedCategory = "Romance" /// The category we'd like to update on the server
        var categoryObject: WireKategory? /// Response object returned from a POST request
        
        /// Create Expectations for each POST, GET, and DELETE request
        let postCategoryExpectation = XCTestExpectation(description: "Posting a category asynchronously")
        let putCategoryExpectation = XCTestExpectation(description: "Updating a category asynchronously")
        let getCategoryExpectation = XCTestExpectation(description: "Fetching a category asynchronously")
        let deleteCategoryExpectation = XCTestExpectation(description: "Deleting a category asynchronously")
        
        /// Make the POST request with the originalCategory declared at the beginning of this function
        makePOSTRequest(originalCategory, postCategoryExpectation) { wire in
            categoryObject = wire
        }
        /// Wait for the expectation to be fulfilled or timeout if the request is taking too long
        wait(for: [postCategoryExpectation], timeout: NetworkTestsHelper.expectationTimeout)
        
        /// Make the PUT request to update UUID().uuidString to Romance on the server
        makePUTRequest((categoryObject?.categoryId)!, category: updatedCategory, putCategoryExpectation)
        wait(for: [putCategoryExpectation], timeout: NetworkTestsHelper.expectationTimeout)
        
        
        /// Make the GET request on the /category/{categoryId} endpoint to make sure our PUT request was reflected on the server
        makeGETRequest((categoryObject?.categoryId)!, getCategoryExpectation) { wire in
            /// This verifies that the category on the server is equal to Romance
            XCTAssertEqual(updatedCategory, wire?.title)
        }
        wait(for: [getCategoryExpectation], timeout: NetworkTestsHelper.expectationTimeout)
        
        /// Now that we know that its true we need to delete it from the server because we don't want to pollute the server with testing data
        /// Make the delete request
        makeDELETERequest((categoryObject?.categoryId)!, deleteCategoryExpectation)
        wait(for: [deleteCategoryExpectation], timeout: NetworkTestsHelper.expectationTimeout)
    }
    
    /// This POST request is a helper function which sends a category to the /category endpoint
    func makePOSTRequest(_ category: String, _ expecation: XCTestExpectation, callback: @escaping (WireKategory) -> Void) {
        /// Make a network request to the /category endpoint by calling CreateCategoryResourceTarget which requires a category name as its parameter
        NetworkTestsHelper.shared.networkManager.request(CreateCategoryResourceTarget(), parameters: WireCreateCategoryRequestBody(
            name: category)
        ).startWithResult({ result in
            switch result {
            case let .failure(error):
                XCTFail("Post category endpoint failed: \(error.localizedDescription)")
            case let .success(wire):
                /// Response bodies from a POST request on the /category endpoint should never be nil
                guard let wire = wire else {
                    XCTFail("Returned wire is nil")
                    return
                }
                
                callback(wire)
                
            }
            expecation.fulfill()
        })
        
    }
    
    ///This method makes a GET request with a category id to query the server for a specific category
    func makeGETRequest(_ categoryID: Int, _ expectation: XCTestExpectation, callback: @escaping (WireKategory?) -> Void) {
        
        /// Make a network request to the /category/{categoryId} endpoint by calling GetSingleCategoryResourceTarget
        NetworkTestsHelper.shared.networkManager.request(GetSingleCategoryResourceTarget(categoryId: categoryID))
            .startWithResult { result in
                switch result {
                case let .failure(error):
                    XCTFail("Get category endpoint failed: \(error.localizedDescription)")
                case let .success(wire):
                    /// These wires shouldn't be unwrapped because we won't be able to test our DELETE function
                    callback(wire)
                    
                    
                }
                expectation.fulfill()
        }
        
    }
    
    /// This DELETE request is a helper function which deletes a category from the /category/{categoryid} endpoint
    func makeDELETERequest(_ categoryID: Int, _ expectation: XCTestExpectation) {
        /// Make a network request to the /category/{categoryid} endpoint by calling RemoveCategoryResourceTarget which requires a categoryid
        
        ///Not sure what to do after the request is sent since a response object isn't sent back
        NetworkTestsHelper.shared.networkManager.request(RemoveCategoryResourceTarget(categoryId: categoryID))
            .startWithResult { (result) in
                switch result {
                case let .failure(error):
                    /*There's a bug in alamofire that sends you a message in this failure block as a result of no response body from the server.
                     It happens in our case since a DELETE request to the /category endpoint doesn't send a response body.
                     Deletion actually works and is reflected on the server. Its up to us to decide how we want to handle this "error" when in fact it actually isn't*/
                    print(error.localizedDescription)
                case let .success(_):
                    print("Success!")
                }
                
                expectation.fulfill()
        }
        
    }
    
    /// This PUT request is a helper function which sends a category to the /category/{categoryID} endpoint
    func makePUTRequest(_ categoryID: Int, category: String, _ expectation: XCTestExpectation) {
        /// Similar to making a post request and delete request
        NetworkTestsHelper.shared.networkManager.request(UpdateCategoryResourceTarget(categoryId: categoryID), parameters: WireUpdateCategoryRequestBody(
            name: category)
        ).startWithResult { (result) in
            switch result {
            case let .failure(error):
                print(error.localizedDescription)
            case let .success(_):
                print("Success!")
            }
            expectation.fulfill()
        }
    }
    
}
