//
//  ChapterTests.swift
//  FableTests
//
//  Created by Will on 8/16/20.
//

import XCTest
import FableSDKModelObjects
import FableSDKResourceTargets
import FableSDKWireObjects

class ChapterTests: XCTestCase {
  
  let authHelper = AuthenticationHelper()
  var testChapter = WireChapter(chapterId: 2, storyId: 2, title: "Chapter 1")
  var testStory = WireStory(userId: 1, title: "Post Story Title", synopsis: "Story Synopsis")
  var wireChapter: WireChapter!
  var wireStory: WireStory!
  
  override func setUp() {
    continueAfterFailure = false
  }
  
  func testChapterEndpoints() {
    
    /// Test `GET /chapter/`
    let chapterFetchexpectation = expectation(description: "chapter GET request")
    testGetChapter(chapterId: testChapter.chapterId!, expectation: chapterFetchexpectation)
    wait(for: [chapterFetchexpectation], timeout: NetworkTestsHelper.expectationTimeout)
    
    /// Test `GET /chapter/chapterID`
    let chapterByIdFetchexpectation = expectation(description: "chapter GET request")
    testGetChapterById(chapterId: testChapter.chapterId!, expectation: chapterByIdFetchexpectation)
    wait(for: [chapterByIdFetchexpectation], timeout: NetworkTestsHelper.expectationTimeout)
    
    /// `GET /story/storyID/chapter`
    let getStoryChapterByIdExpectation = expectation(description: "async story refresh request")
    getStoryChapterById(storyId: testChapter.storyId!, expectation: getStoryChapterByIdExpectation )
    wait(for: [getStoryChapterByIdExpectation ], timeout: NetworkTestsHelper.expectationTimeout)
    
  }
  
  /// `GET /chapter`
  private func testGetChapter(chapterId: Int, expectation: XCTestExpectation){
    NetworkTestsHelper.shared.networkManager.request(
        GetDraftChapter(chapterId: chapterId)
    ).startWithResult { [weak self] result in
        switch result {
        case let .failure(error):
            XCTFail("Refresh story failed: \(error.localizedDescription)")
        case let .success(chapter):
            guard let `self` = self, let chapter = chapter else {
                XCTFail("Returned story is nil")
                return
            }
            self.failIfAttributesAreNil(for: chapter)
            expectation.fulfill()
        }
    }
  }
  
  /// `GET /chapter/chapterID`
  private func testGetChapterById(chapterId: Int, expectation: XCTestExpectation){
    NetworkTestsHelper.shared.networkManager.request(
        GetDraftChapter(chapterId: chapterId)
    ).startWithResult { [weak self] result in
        switch result {
        case let .failure(error):
            XCTFail("Refresh story failed: \(error.localizedDescription)")
        case let .success(chapter):
            guard let `self` = self, let chapter = chapter else {
                XCTFail("Returned story is nil")
                return
            }
            self.failIfAttributesAreNil(for: chapter)
            expectation.fulfill()
        }
    }
  }
  
  /// `GET /story/storyID/chapter`
  private func getStoryChapterById(storyId: Int, expectation: XCTestExpectation) {
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
  
  private func failIfAttributesAreNil(for chapter: WireChapter) {
    XCTAssertNotNil(chapter.chapterId)
    XCTAssertNotNil(chapter.storyId)
    XCTAssertNotNil(chapter.title)
  }
  private func failIfAttributesAreNil(for story: WireStory) {
      XCTAssertNotNil(story.storyId)
      XCTAssertNotNil(story.userId)
      XCTAssertNotNil(story.title)
  }
}
