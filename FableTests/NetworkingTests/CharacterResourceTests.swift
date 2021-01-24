//
//  CharacterResourceTests.swift
//  FableTests
//
//  Created by Enrique Florencio on 7/15/20.
//

import XCTest
import AppFoundation
import NetworkFoundation
import FableSDKResolver
import FableSDKModelObjects
import FableSDKResourceTargets
import FableSDKModelManagers
import FableSDKWireObjects

class CharacterResourceTests: XCTestCase {
    
    /// This function will test a `POST` request on the /character endpoint. It will make a `POST` request followed by a `GET` request to make sure the data is reflected on the server and finally a `DELETE` request in order to clean up testing data
    func testPOSTRequestOnCharacterEndpoint() {
        ///Create a character object that should be sent to the server for testing. We'll be using the characterID from the response body of the `POST` request to make the `GET` and `DELETE` requests
        let character = CreateCharacterRequestBody(storyId: 1, userId: 4, name: UUID().uuidString, colorHexString: "#000CCC", messageAlignment: "center")
        var characterObject: WireCharacter? /// This will be set equal to the response wire of making a `POST` request
        
        /// Setup the expectations for each `POST`, `GET`, and `DELETE`request
        let postCharacterExpectation = XCTestExpectation(description: "Running a post request asynchronously")
        let getCharacterExpectation = XCTestExpectation(description: "Running a get request asynchronously")
        let deleteCharacterExpectation = XCTestExpectation(description: "Running a delete request asynchronously")
        
        /// Send a `POST` request with the character defined earlier
        makePOSTRequest(expectation: postCharacterExpectation, character: character) { wire in
            /// Set our character object equal to the response wire
            characterObject = wire
        }
        
        wait(for: [postCharacterExpectation], timeout: NetworkTestsHelper.expectationTimeout)
        
        /// Make the `GET` request to the /character/{characterId} endpoint to make sure that the character object from earlier was sent
        makeGETRequest(expectation: getCharacterExpectation, characterID: (characterObject?.characterId)!, callback: { (wire) in
            /// If the name attribute of the response wire is equal to the name of the character sent from earlier, then the`POST` request was successful
            XCTAssertEqual(character.name, wire?.name)
        }) { (error) in
            /// If there was an error from the server, then everything should fail
            guard let error = error else {
                return
            }
            
            XCTFail()
        }
        
        wait(for: [getCharacterExpectation], timeout: NetworkTestsHelper.expectationTimeout)
        
        /// Finally, make a `DELETE` request to the server with the characterId just to clean up testing data.
        makeDELETERequest(expectation: deleteCharacterExpectation, characterID: (characterObject?.characterId)!)
        
        wait(for: [deleteCharacterExpectation], timeout: NetworkTestsHelper.expectationTimeout)
        
    }
    
    /// This function will test a `DELETE` request on the /character endpoint. It will follow a `POST`, `GET`, `DELETE`,  and `GET` order.
    func testDELETERequestOnCharacterEndpoint() {
        let character = CreateCharacterRequestBody(storyId: 1, userId: 5, name: UUID().uuidString, colorHexString: "#000CCC", messageAlignment: "center")
        var characterObject: WireCharacter? /// This will be set equal to the response wire in order to store the characterId we'll need to delete
        
        /// Setup the expectations for each `POST`, `GET`, and `DELETE` request
        let postCharacterExpectation = XCTestExpectation(description: "Running a post request asynchronously")
        var getCharacterExpectation = XCTestExpectation(description: "Running a get request asynchronously")
        let deleteCharacterExpectation = XCTestExpectation(description: "Running a delete request asynchronously")
        
        /// Send a `POST` request with the character defined earlier
        makePOSTRequest(expectation: postCharacterExpectation, character: character) { wire in
            /// Set our character object equal to the response wire
            characterObject = wire
        }
        
        wait(for: [postCharacterExpectation], timeout: NetworkTestsHelper.expectationTimeout)
        
        /// Make the `GET` request to the /character/{characterId} endpoint to make sure that the character object from earlier was sent
        makeGETRequest(expectation: getCharacterExpectation, characterID: (characterObject?.characterId)!, callback: { (wire) in
            /// If the name attribute of the response wire is equal to the name of the character sent from earlier, then the`POST` request was successful
            XCTAssertEqual(characterObject?.name, wire?.name)
        }) { (error) in
            /// If there was an error from the server, then everything should fail
            guard let error = error else {
                return
            }
            
            XCTFail()
        }
        
        wait(for: [getCharacterExpectation], timeout: NetworkTestsHelper.expectationTimeout)
        
        /// Make a `DELETE` request to the server with the characterId from the response wire
        makeDELETERequest(expectation: deleteCharacterExpectation, characterID: (characterObject?.characterId)!)
        
        wait(for: [deleteCharacterExpectation], timeout: NetworkTestsHelper.expectationTimeout)
        
//        /// Reset our expectation to make another `GET` request
//        getCharacterExpectation = XCTestExpectation(description: "Fetching a category again to make sure it was deleted")
//        
//        /// Finally, make another `GET` request in order to make sure that the character object sent earlier was indeed deleted. Making a `GET` request with a characterId that was deleted should throw an error
//        makeGETRequest(expectation: getCharacterExpectation, characterID: (characterObject?.characterId)!, callback: { (wire) in
//            guard let wire = wire else {
//                return
//            }
//            /// If the response wire we retrieve is not nil, then our `DELETE` request did not work and the test should fail altogether.
//            XCTFail()
//        }) { (error) in
//            /// We want to receive an error when you make a `GET`request to the /character/{characterId} endpoint because that means that the character was in fact, deleted.
//            XCTAssertNotNil(error)
//            
//        }
//        
//        wait(for: [getCharacterExpectation], timeout: NetworkTestsHelper.expectationTimeout)
    }
    
    /// Tests a PUT request on the /character/{characterId} endpoint. This follows a POST, PUT, GET, and DELETE order.
    func testPUTRequestOnCharacterEndpoint() {
        let originalCharacter = CreateCharacterRequestBody(storyId: 1, userId: 3, name: UUID().uuidString, colorHexString: "#000CCC", messageAlignment: "center") /// This will be the original character that gets sent to the server through a `POST`request.
        var characterObject: WireCharacter? /// Response wire returned from a POST request
        
        /// Create Expectations for each POST, PUT, GET, and DELETE request
        let postCharacterExpectation = XCTestExpectation(description: "Posting a character asynchronously")
        let putCharacterExpectation = XCTestExpectation(description: "Updating a character asynchronously")
        let getCharacterExpectation = XCTestExpectation(description: "Fetching a character asynchronously")
        let deleteCharacterExpectation = XCTestExpectation(description: "Deleting a character asynchronously")
        
        /// Make the POST request with the originalCharacter declared at the beginning of this function
        makePOSTRequest(expectation: postCharacterExpectation, character: originalCharacter) { (wire) in
            /// Set the character object equal to the response wire since we'd like the characterId.
            characterObject = wire
        }
        
        /// Wait for the expectation to be fulfilled or timeout if the request is taking too long
        wait(for: [postCharacterExpectation], timeout: NetworkTestsHelper.expectationTimeout)
        
        /// This character object will be used to update the previous character that was sent to the server earlier. This will be done through the `PUT` request.
        let updatedCharacter = UpdateCharacterRequestBody(name: UUID().uuidString, colorHexString: "#111CCC", messageAlignment: "leading")
        
        /// Make the PUT request to update UUID().uuidString to another UUID().uuidString sequence
        makePUTRequest(expectation: putCharacterExpectation, character: updatedCharacter, characterID: (characterObject?.characterId)!)
        wait(for: [putCharacterExpectation], timeout: NetworkTestsHelper.expectationTimeout)
        
        
        /// Make the GET request on the /character/{characterId} endpoint to make sure our PUT request was reflected on the server
        makeGETRequest(expectation: getCharacterExpectation, characterID: (characterObject?.characterId)!, callback: { (wire) in
            /// If the reponse wire's name attribute is equal to the name of the updated character object (updatedCharacter), then the `PUT` request does indeed work.
            XCTAssertEqual(updatedCharacter.name, wire?.name)
        }) { (error) in
            guard let error = error else {
                return
            }
            
            /// If there was an error making the `GET` request, then this test case should fail. This would probably happen if the `PUT` request didn't work or there was an error making the `GET` request.
            
            XCTFail()
        }
        wait(for: [getCharacterExpectation], timeout: NetworkTestsHelper.expectationTimeout)

        /// Now that we know that its true we need to delete it from the server because we don't want to pollute the server with testing data
        /// Make the delete request
        makeDELETERequest(expectation: deleteCharacterExpectation, characterID: (characterObject?.characterId)!)
        wait(for: [deleteCharacterExpectation], timeout: NetworkTestsHelper.expectationTimeout)
    }
    
    /// Tests a `GET` request on the /story/{storyId}/character endpoint. This test will make two `POST` requests onto the server followed by a `GET` request to the /story/{storyId}/character endpoint to receive the data we sent earlier.
    func testGETCharactersByStoryId() {
        /// Two characters that will be posted onto the server and will later on be fetched through a GET request using their storyId's
        let firstCharacter = CreateCharacterRequestBody(storyId: 5, userId: 3, name: UUID().uuidString, colorHexString: "#000CCC", messageAlignment: "center")
        let secondCharacter = CreateCharacterRequestBody(storyId: 5, userId: 3, name: UUID().uuidString, colorHexString: "#111CCC", messageAlignment: "leading")
        
        var charactersToSend = [firstCharacter, secondCharacter] /// Store the character objects into an array so that we can make `POST`requests more efficient,
        let originalCharacterCount = charactersToSend.count /// We want to store the current character array count for testing purposes
        var charactersReceived = [WireCharacter]() /// Characters we receive from the GET request
        
        /// Create Expectation for the `GET` request to the server
        let getCharactersExpectation = XCTestExpectation(description: "Fetching a character asynchronously")
        
        /// Create `POST` requests for each character to be sent to the server.
        for element in charactersToSend {
            let postCharacterExpectation = XCTestExpectation(description: "Posting a character asynchronously")
            makePOSTRequest(expectation: postCharacterExpectation, character: element) { (wire) in
            }
            
            wait(for: [postCharacterExpectation], timeout: NetworkTestsHelper.expectationTimeout)
        }
        
        
        /// Make the `GET` request to the /story/{storyId}/character endpoint to receive the data we sent earlier. The returned wire is a WireCollection<WireCharacter> object.
        makeGETRequestToReceiveCharactersByStoryId(expectation: getCharactersExpectation, storyID: firstCharacter.storyId) { (wire) in
            /// Make sure that the returned wire isn't nil
            guard let wires = wire else {
                return
            }
            /// Reset our array equal to the WireCharacter items
            charactersReceived = wires.items
            
            /// Make sure the amount of characters that were sent back from the server are equal to the amount we started with.
            XCTAssertEqual(charactersReceived.count, originalCharacterCount)
        }
        
        wait(for: [getCharactersExpectation], timeout: NetworkTestsHelper.expectationTimeout)
        
        ///Make sure that all of the character's storyIds received from the server are equal to the original character's storyIds we sent earlier
        for character in charactersReceived {
            XCTAssertEqual(character.storyId, firstCharacter.storyId)
        }
        
        /// Finally, delete all of the characters from the server since we want to clean up testing data.
        for element in charactersReceived {
            let deleteCharacterExpectation = XCTestExpectation(description: "Deleting a character asynchronously")
            makeDELETERequest(expectation: deleteCharacterExpectation, characterID: element.characterId!)
            wait(for: [deleteCharacterExpectation], timeout: NetworkTestsHelper.expectationTimeout)
        }
    }
    
    /// Tests a GET request on the /user/{userId}/character endpoint. This test will make two `POST` requests onto the server followed by a `GET` request to the /user/{userId}/character endpoint to receive the data we sent earlier.
    func testGETCharactersByUserId() {
        /// Two characters that will be posted onto the server and will later on be fetched through a GET request using their userId's
        let firstCharacter = CreateCharacterRequestBody(storyId: 3, userId: 5, name: UUID().uuidString, colorHexString: "#000CCC", messageAlignment: "center")
        let secondCharacter = CreateCharacterRequestBody(storyId: 3, userId: 5, name: UUID().uuidString, colorHexString: "#111CCC", messageAlignment: "leading")
        
        var charactersToSend = [firstCharacter, secondCharacter] /// Store the character objects into an array so that we can make `POST`requests more efficient,
        var originalCharacterCount = charactersToSend.count /// We want to store the current character array count for testing purposes
        var charactersReceived = [WireCharacter]()
        
        /// Create Expectation for the `GET` request to the server
        let getCharactersExpectation = XCTestExpectation(description: "Fetching a character asynchronously")
        
        /// Create `POST` requests for each character to be sent to the server.
        for element in charactersToSend {
            let postCharacterExpectation = XCTestExpectation(description: "Posting a character asynchronously")
            makePOSTRequest(expectation: postCharacterExpectation, character: element) { (wire) in
            }
            
            wait(for: [postCharacterExpectation], timeout: NetworkTestsHelper.expectationTimeout)
        }
        
        /// Make the `GET` request to the /user/{userId}/character endpoint to receive the data we sent earlier. The returned wire is a WireCollection<WireCharacter> object.
        makeGETRequestToReceiveCharactersByUserId(expectation: getCharactersExpectation, userID: firstCharacter.userId) { (wire) in
            /// Make sure that the returned wire isn't nil
            guard let wires = wire else {
                return
            }
            /// Reset our array equal to the WireCharacter items
            charactersReceived = wires.items
            
            /// Make sure the amount of characters that were sent back from the server are equal to the amount we started with.
            XCTAssertEqual(charactersReceived.count, originalCharacterCount)
        }
        
        wait(for: [getCharactersExpectation], timeout: NetworkTestsHelper.expectationTimeout)
        
        /// Make sure that all of the character's userIds received from the server are equal to the original character's userIds we sent earlier
        /// These had to be changed to storyId since UserId's aren't sent back in response bodies
        for character in charactersReceived {
            XCTAssertEqual(character.storyId, firstCharacter.storyId)
        }
        
        /// Finally, delete all of the characters from the server since we want to clean up testing data.
        for element in charactersReceived {
            let deleteCharacterExpectation = XCTestExpectation(description: "Deleting a character asynchronously")
            makeDELETERequest(expectation: deleteCharacterExpectation, characterID: element.characterId!)
            wait(for: [deleteCharacterExpectation], timeout: NetworkTestsHelper.expectationTimeout)
        }
    }
    
    func makePOSTRequest(expectation: XCTestExpectation, character: CreateCharacterRequestBody, callback: @escaping (WireCharacter) -> Void) {
        NetworkTestsHelper.shared.networkManager.request(CreateCharacter(), parameters: character
        ).startWithResult({ result in
            switch result {
            case let .failure(error):
                XCTFail("Post character endpoint failed: \(error.localizedDescription)")
            case let .success(wire):
                /// Response bodies from a POST request on the /character endpoint should never be nil
                guard let wire = wire else {
                    XCTFail("Returned wire is nil")
                    return
                }
                
                callback(wire)
                
            }
            expectation.fulfill()
        })
    }
    
    func makePUTRequest(expectation: XCTestExpectation, character: UpdateCharacterRequestBody, characterID: Int) {
        NetworkTestsHelper.shared.networkManager.request(UpdateDraftCharacter(characterId: characterID), parameters: character).startWithResult({ result in
            switch result {
            case let .failure(error):
                print(error.localizedDescription)
            case let .success(_):
                print("Success!")
            }
            
            expectation.fulfill()
            
        })
    }
    
    func makeGETRequest(expectation: XCTestExpectation, characterID: Int, callback: @escaping (WireCharacter?) -> Void, failure: @escaping (Error?) -> Void) {
        NetworkTestsHelper.shared.networkManager.request(GetCharacterById(characterId: characterID)
        ).startWithResult({ result in
            switch result {
            case let .failure(error):
                failure(error)
            case let .success(wire):
                callback(wire)
            }
            
            expectation.fulfill()
        })
    }
    
    func makeGETRequestToReceiveCharactersByStoryId(expectation: XCTestExpectation, storyID: Int, callback: @escaping (WireCollection<WireCharacter>?) -> Void) {
        NetworkTestsHelper.shared.networkManager.request(GetCharactersByStoryId(storyId: storyID)
        ).startWithResult({ result in
            switch result {
            case let .failure(error):
                XCTFail("GET request to /story/{storyID}/character failed: \(error.localizedDescription)")
            case let .success(wire):
                callback(wire)
                
            }
            expectation.fulfill()
        })
    }
    
    func makeGETRequestToReceiveCharactersByUserId(expectation: XCTestExpectation, userID: Int, callback: @escaping (WireCollection<WireCharacter>?) -> Void) {
        NetworkTestsHelper.shared.networkManager.request(GetDraftCharactersFromUserResourceTarget(userId: userID)
        ).startWithResult({ result in
            switch result {
            case let .failure(error):
                XCTFail("GET request to /user/{userid}/character failed: \(error.localizedDescription)")
            case let .success(wire):
                callback(wire)
            }
            
            expectation.fulfill()
        })
    }
    
    func makeDELETERequest(expectation: XCTestExpectation, characterID: Int) {
        NetworkTestsHelper.shared.networkManager.request(DeleteDraftCharacter(characterId: characterID))
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

}
