//
//  bisMateClientTests.swift
//  bisMateClientTests
//
//  Created by Razvan-Antonio Berbece on 15/01/2021.
//

import XCTest
@testable import bisMateClient
import Firebase

class bisMateClientTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // Test -- default accounts can communicate
    func testReceiveMessageDefault() {
        
        let wsClient1 = WSClient(id: 1)
        let wsClient2 = WSClient(id: 2)
        
        var counterClient1 = 0
        wsClient1.openConn() {
            (result) in
            wsClient2.openConn() {
                (result) in
                wsClient2.sendMessage(fromID: 2, toID: 1, inputMessage: "Test Message")
                wsClient1.getMessage() {
                    (message) in
                    counterClient1 += 1
                    XCTAssertEqual(counterClient1, 1, "Client 1 did not receive message from Client 2")
                }
            }
        }
        
    }
    
    // Test -- default accounts 1 (reads) and 2 (writes) can privately communicate
    func testMessagePrivacyDefault() {
        
        let wsClient1 = WSClient(id: 1)
        let wsClient2 = WSClient(id: 2)
        let wsClient3 = WSClient(id: 3)
        
        var counterClient1 = 0, counterClient3 = 0
        wsClient1.openConn() {
            (result) in
            wsClient2.openConn() {
                (result) in
                wsClient2.sendMessage(fromID: 2, toID: 1, inputMessage: "Test Message")
                wsClient1.getMessage() {
                    (message) in
                    counterClient1 += 1
                    XCTAssertEqual(counterClient1, 1, "Client 1 did not receive message from Client 2")
                    wsClient3.openConn() {
                        (result) in
                        wsClient3.getMessage() {
                            (message) in
                            counterClient3 += 1
                            XCTAssertEqual(counterClient3, 0, "One-on-one privacy not working")
                        }
                    }
                }
            }
        }
    }
    
    // Test -- default account sign in
    func testSignIn() {
        
        _ = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                let email = user.email
                XCTAssertEqual(email, "test1@yahoo.com", "Email not matching")
            }
        }
        
        let firebaseAuth = FirebaseAuthClient()
        firebaseAuth.signIn(email: "test1@yahoo.com", pass: "test12345") {
            (result) in
            if result {
                // SUCCESS, DO NOTHING AND WAIT FOR HANDLER
            }
            else {
                XCTFail()
            }
        }
    }
    
    // Test -- change display name operation
    func testChangeDisplayName() {
        
        let fbClient = FirebaseAuthClient()
        let httpClient = HTTPClient(token: "def")
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                user.getIDTokenForcingRefresh(true) {
                    (idToken, err) in
                    if err != nil {
                        // set current user
                        fbClient.setCurrentUser(withUser: User(email: user.email!, displayName: user.displayName!, UID: user.uid, token: idToken!))
                        let User : User = fbClient.getCurrentUser()
                        httpClient.setToken(newTok: User.getToken())
                        httpClient.sendOperationWithToken(operation: "1", input: "Test Name") {
                            (result) in
                            fbClient.getCurrentUser().setDisplayName(newName: "Test Name")
                            if (result != 0) {
                                XCTAssertEqual(fbClient.getCurrentUser().getDisplayName(), "Test Name")
                            }
                            else {
                                XCTFail()
                            }
                        }
                    }
                    else {
                        XCTFail()
                    }
                    
                }
            }
            else {
                XCTFail()
            }
        }
        
        let firebaseAuth = FirebaseAuthClient()
        firebaseAuth.signIn(email: "test1@yahoo.com", pass: "test12345") {
            (result) in
            if result {
                // SUCCESS, DO NOTHING AND WAIT FOR HANDLER
            }
            else {
                XCTFail()
            }
        }
    }
    
    // Test -- unknown operation
    func testUnknownOperation() {
        
        let fbClient = FirebaseAuthClient()
        let httpClient = HTTPClient(token: "def")
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                user.getIDTokenForcingRefresh(true) {
                    (idToken, err) in
                    if err != nil {
                        // set current user
                        fbClient.setCurrentUser(withUser: User(email: user.email!, displayName: user.displayName!, UID: user.uid, token: idToken!))
                        let User : User = fbClient.getCurrentUser()
                        httpClient.setToken(newTok: User.getToken())
                        httpClient.sendOperationWithToken(operation: "undefined", input: "undefined") {
                            (result) in
                            XCTAssertEqual(result, 0, "Server finished an undefined operation")
                        }
                    }
                    else {
                        XCTFail()
                    }
                    
                }
            }
            else {
                XCTFail()
            }
        }
        
        let firebaseAuth = FirebaseAuthClient()
        firebaseAuth.signIn(email: "test1@yahoo.com", pass: "test12345") {
            (result) in
            if result {
                // SUCCESS, DO NOTHING AND WAIT FOR HANDLER
            }
            else {
                XCTFail()
            }
        }
    }
    
}
