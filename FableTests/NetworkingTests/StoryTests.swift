//
//  CharacterTests.swift
//  FableTests
//
//  Created by Steven Andrews on 2020-05-30.
//  Updated by Giordany Orellana oon 2020-7-22

import XCTest
import FableSDKModelObjects
import FableSDKResourceTargets
import FableSDKWireObjects
import FableSDKModelManagers

/// Test the `/story` endpoint
class StoryTests: XCTestCase {

    let authHelper = AuthenticationHelper()
    let updateSynopsis = "Updated Story Synopsis"
    var testStory = WireStory(userId: 1, title: "Post Story Title", synopsis: "Story Synopsis")
    
    var wireStory: WireStory!
    
    override func setUp() {
        continueAfterFailure = false
    }
    
    /// Main function to control the order of tests and manage data flow between them
    func testStoryEndpoints() {
        
        let storyPostExpectation = expectation(description: "async story post request")
        testStoryPost(wireStory: testStory, expectation: storyPostExpectation)
        wait(for: [storyPostExpectation], timeout: NetworkTestsHelper.expectationTimeout)
        
        let storiesFetchexpectation = expectation(description: "async stories fetch request")
        testUserStoriesFetch(expectation: storiesFetchexpectation)
        wait(for: [storiesFetchexpectation], timeout: NetworkTestsHelper.expectationTimeout)
        
        let storyRefreshExpectation = expectation(description: "async story refresh request")
        testStoryRefresh(storyId: wireStory.storyId!, expectation: storyRefreshExpectation)
        wait(for: [storyRefreshExpectation], timeout: NetworkTestsHelper.expectationTimeout)
        
//        let storyUpdateExpectation = expectation(description: "async story update request")
//        testStoryUpdate(wireStory: wireStory, expectation: storyUpdateExpectation)
//        wait(for: [storyUpdateExpectation], timeout: NetworkTestsHelper.expectationTimeout)
        
        let storyDeleteExpectation = expectation(description: "async story delete request")
        testStoryDelete(expectation: storyDeleteExpectation)
        wait(for: [storyDeleteExpectation], timeout: NetworkTestsHelper.expectationTimeout)
    }
    
    /// Test `POST /story`
    private func testStoryPost(wireStory: WireStory, expectation: XCTestExpectation) {
        
        
        let storyTitle = "Post Story Title"
        guard let userID = wireStory.userId else { return  XCTFail("Unable to find user ID") }
        guard let title = wireStory.title else { return  XCTFail("Unable to find story title") }
        guard let synopsis = wireStory.synopsis else { return  XCTFail("Unable to find story synopsis") }
        
        NetworkTestsHelper.shared.networkManager.request(
            CreateStory(),
            parameters: CreateStoryRequestBody(userId: userID, title: title, synopsis: synopsis)
        ).startWithResult { [weak self] result in
            switch result {
            case let .failure(error):
                XCTFail("Post story failed: \(error.localizedDescription)")
            case let .success(story):
                guard let `self` = self, let story = story else {
                    XCTFail("Returned story is nil")
                    return
                }
                self.failIfAttributesAreNil(for: story)
                XCTAssertEqual(story.title, storyTitle, "Synopsis update failed, returned story doesn't match")
                expectation.fulfill()
            }
        }
    }
    
    /// Test `GET /user/\(userId)/story`
    private func testUserStoriesFetch(expectation: XCTestExpectation) {
        guard let userId = testStory.userId else { return  XCTFail("Unable to find user ID") }
        NetworkTestsHelper.shared.networkManager.request(
            GetStoriesByUser(userId: userId)
        ).startWithResult { [weak self] result in
            switch result {
            case let .failure(error):
                XCTFail("Get user's stories failed: \(error.localizedDescription)")
            case let .success(wire):
                guard let wire = wire else {
                    XCTFail("Returned wire is nil")
                    return
                }
                let stories = wire.items
                guard let `self` = self, let lastStory = stories.last else {
                    XCTFail("No stories returned from endpoint. Please ensure test account has at least one story for tests.")
                    return
                }
                self.failIfAttributesAreNil(for: lastStory)
                self.wireStory = lastStory
                expectation.fulfill()
            }
        }
    }
    //
    /// Test `GET /story/{storyId}`
    private func testStoryRefresh(storyId: Int, expectation: XCTestExpectation) {
        NetworkTestsHelper.shared.networkManager.request(
            GetStory(storyId: storyId)
        ).startWithResult { [weak self] result in
            switch result {
            case let .failure(error):
                XCTFail("Refresh story failed: \(error.localizedDescription)")
            case let .success(story):
                guard let `self` = self, let story = story else {
                    XCTFail("Returned story is nil")
                    return
                }
                self.failIfAttributesAreNil(for: story)
                expectation.fulfill()
            }
        }
    }
    
//    /// Test `PUT /story/{storyId}`
//    private func testStoryUpdate(wireStory: WireStory, expectation: XCTestExpectation) {
//
//        NetworkTestsHelper.shared.networkManager.request(
//            UpdateStory(storyId: wireStory.storyId!),
//            parameters: UpdateStoryRequestBody(categoryId: nil, title: nil, synopsis: updateSynopsis, published: false)
//        ).startWithCompleted {
//
//            NetworkTestsHelper.shared.networkManager.request(
//                GetStory(storyId: wireStory.storyId!)
//            ).startWithResult { [weak self] result in
//                switch result {
//                case let .failure(error):
//                    XCTFail("Refresh story failed: \(error.localizedDescription)")
//                case let .success(story):
//                    guard let `self` = self, let story = story else {
//                        XCTFail("Returned story is nil")
//                        return
//                    }
//                    self.failIfAttributesAreNil(for: story)
//                    XCTAssertEqual(story.synopsis, self.updateSynopsis, "Synopsis update failed, returned story doesn't match")
//                    expectation.fulfill()
//                }
//            }
//        }
//    }
    
    /// Test `DELETE /story`
    private func testStoryDelete(expectation: XCTestExpectation) {
        
        let noContent = "No Content, status code: 204"
        
        NetworkTestsHelper.shared.networkManager.request(
            RemoveStory(storyId: wireStory.storyId!)
        ).startWithCompleted {
            NetworkTestsHelper.shared.networkManager.request(
                GetStory(storyId: self.wireStory.storyId!)
            ).startWithResult { result in
               
                switch result {
                case let .failure(error):
                    XCTAssertEqual(error.description, noContent, file: "Story was not deleted")
                    expectation.fulfill()
                case let .success(story):
                    XCTAssertNil(story, "Story was not deleted")
                }
            }
        }
    }
    
    private func failIfAttributesAreNil(for story: WireStory) {
        XCTAssertNotNil(story.storyId)
        XCTAssertNotNil(story.userId)
        XCTAssertNotNil(story.title)
    }
    
}
