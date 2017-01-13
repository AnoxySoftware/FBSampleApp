//
//  FBSampleAppTests.swift
//  FBSampleAppTests
//
//  Created by Eleftherios Charitou on 12/01/17.
//  Copyright © 2017 Anoxy Software. All rights reserved.
//

import XCTest
import FBSDKCoreKit
import FBSDKLoginKit

@testable import FBSampleApp

class FBSampleAppTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFBUserModelWithWrongData() {
        let missingIDDictionary = ["name":"Lefteris"]
        XCTAssertNil(FBUser(JSON:missingIDDictionary), "An FBUserModel should not be created with a missing ID")
        
        let missingNameDictionary = ["id":"123456"]
        XCTAssertNil(FBUser(JSON:missingNameDictionary), "An FBUserModel should not be created with a missing name")
    }
    
    func testFBUserModelWithCorrectData() {
        let correctDictionary = ["name":"Lefteris","id":"123456"]
        XCTAssertNotNil(FBUser(JSON:correctDictionary), "An FBUserModel should be created with the valid minimum data")
    }
    
    func testGetUserFBDataWithoutToken() {
        let mockedVC = MockViewController()
        let fetchExpectation = expectation(description: "FBData")
        
        mockedVC.getUserFBDataIfNeeded(completionHandler: { result, error in
            fetchExpectation.fulfill()
            
            if let error:NSError = error as? NSError,
                let errorCode = error.userInfo["com.facebook.sdk:FBSDKGraphRequestErrorGraphErrorCode"] as? Int {
                XCTAssertEqual(errorCode, 2500, "No Error code 2500, from Facebook with missing token!")
            }
            else {
                XCTFail("No error occured trying to get Facebook Data without token, or we didn't get a com.facebook.sdk:FBSDKGraphRequestErrorGraphErrorCode result in the userInfo dictionary")
            }
            })
        
        waitForExpectations(timeout: 10) {error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testGetUserFBDataWithToken() {
        let mockedVC = MockViewController()
        let fetchExpectation = expectation(description: "FBGetToken")
        
        let manager = FBSDKTestUsersManager.sharedInstance(forAppID: "671015183069661", appSecret: "1cfb75bfe837bece52c91f9c7789844f")
        
        manager!.requestTestAccountTokens(withArraysOfPermissions:nil, createIfNotFound: false) {
             result, error in
            
            if error != nil {
                XCTFail("Error getting access token: \(error)")
                fetchExpectation.fulfill()
            }
            else {
                if let accessToken : FBSDKAccessToken = result?[0] as? FBSDKAccessToken {
                    FBSDKAccessToken.setCurrent(accessToken)
                    
                    mockedVC.getUserFBDataIfNeeded(completionHandler: { result, error in
                        //we should have a response now
                        XCTAssertNotNil(result, "A response should have been retrieved now as we had a token")
                        XCTAssertTrue(mockedVC.getUserFriendsInvoked,"getUsersFriends not invoked although we did get data from Facebook!")
                        
                        fetchExpectation.fulfill()
                    })
                }
                else {
                    XCTFail("Error getting access token: \(result)")
                    fetchExpectation.fulfill()
                }
            }
            
        }
        
        waitForExpectations(timeout: 10) {error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testGetUserFriendsWithoutToken() {
        let mockedVC = MockViewController()
        let fetchExpectation = expectation(description: "FBData")
        
        mockedVC.getUsersFriends(completionHandler: { result, error in
            
            if let error:NSError = error as? NSError,
                let errorCode = error.userInfo["com.facebook.sdk:FBSDKGraphRequestErrorGraphErrorCode"] as? Int {
                XCTAssertEqual(errorCode, 2500, "No Error code 2500, from Facebook with missing token!")
            }
            else {
                XCTFail("No error occured trying to get Facebook Data without token, or we didn't get a com.facebook.sdk:FBSDKGraphRequestErrorGraphErrorCode result in the userInfo dictionary")
            }
            
            fetchExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 10) {error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testGetUserFriendsWithToken() {
        let mockedVC = MockViewController()
        let fetchExpectation = expectation(description: "FBGetToken")
        
        let manager = FBSDKTestUsersManager.sharedInstance(forAppID: "671015183069661", appSecret: "1cfb75bfe837bece52c91f9c7789844f")
        
        manager!.requestTestAccountTokens(withArraysOfPermissions:nil, createIfNotFound: false) {
            result, error in
            
            if error != nil {
                XCTFail("Error getting access token: \(error)")
                fetchExpectation.fulfill()
            }
            else {
                if let accessToken : FBSDKAccessToken = result?[0] as? FBSDKAccessToken {
                    FBSDKAccessToken.setCurrent(accessToken)
                    
                    mockedVC.getUsersFriends(completionHandler: { result, error in
                        //we should have a response now
                        XCTAssertNotNil(result, "A response should have been retrieved now as we had a token")
                        XCTAssertTrue(mockedVC.parseUserFriendsInvoked,"parseUserFriendsInvoked not invoked although we did get data from Facebook!")
                        
                        fetchExpectation.fulfill()
                    })
                }
                else {
                    XCTFail("Error getting access token: \(result)")
                    fetchExpectation.fulfill()
                }
            }
            
        }
        
        waitForExpectations(timeout: 10) {error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    
    func testParsingValidFriendsData() {
        let mockedVC = MockViewController()
        
        let testBundle = Bundle(for: type(of: self))
        
        guard let ressourceURL = testBundle.url(forResource: "mockdata", withExtension: "json") else {
            // file does not exist
            XCTFail("Could not find mock data")
            return
        }
        do {
            let ressourceData = try Data(contentsOf: ressourceURL)
            let json = try? JSONSerialization.jsonObject(with: ressourceData)
            mockedVC.parseUserFriends(json as! [String : AnyObject])
            
            XCTAssertEqual(mockedVC.dataSource.friends.count,5,"Mocked Data Friends should produce 5 friends objects!")
            XCTAssertTrue(mockedVC.updateCollectionInvoked,"updateCollectionByAppendingUsers not invoked although we did popuplate the datasource array")
        }
        catch let error {
            // some error occurred when reading the file
            XCTFail("Error loading mock data: \(error)")
        }
    }
    
}

// MARK: - Mock class
class MockViewController: UserFriendsViewController {
    var getUserFriendsInvoked = false
    var parseUserFriendsInvoked = false
    var updateCollectionInvoked = false
    
    override func getUsersFriends(completionHandler: ((Any?, Error?) -> ())?) {
        getUserFriendsInvoked = true
        super.getUsersFriends(completionHandler: completionHandler)
    }
    
    override func parseUserFriends(_ data: [String : AnyObject]) {
        parseUserFriendsInvoked = true
        super.parseUserFriends(data)
    }
    
    override func showErrorMessage(error:Error, completionHandler:((Bool) -> ())?) {
        //prevent the app from showing up error messages in test mode
    }
    
    override func showAbortMessage(title: String, message: String) {
        //prevent the app from showing up error messages in test mode
    }
    
    override func updateCollectionByAppendingUsers(_ users: [FBUser]) {
        dataSource.friends = users
        updateCollectionInvoked = true
    }
}
