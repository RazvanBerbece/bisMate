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
    
    // Test if default accounts can communicate
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
    
    // Test if default accounts 1 (reads) and 2 (writes) can privately communicate
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
    
    // Test if default account can signin
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

}
