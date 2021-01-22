//
//  ViewController.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 15/01/2021.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    var fbClient = FirebaseAuthClient()
    let httpClient = HTTPClient(token: "def")
    
    override func viewDidLoad() {
        
        // listen for signin state
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                user.getIDTokenForcingRefresh(true) {
                    (idToken, err) in
                    if let error = err {
                        print("token err: \(String(describing: error))")
                        return
                    }
                    // set current user
                    self.fbClient.setCurrentUser(withUser: User(email: user.email!, displayName: user.displayName!, UID: user.uid, token: idToken!))
                    let User : User = self.fbClient.getCurrentUser()
                    // send token to backend
                    self.httpClient.setToken(newTok: User.getToken())
                    self.httpClient.sendOperationWithToken(operation: "0", input: "") {
                        (result) in
                        print(result)
                    }
                }
            }
        }
        
        super.viewDidLoad()
        
        // behavioural test
        self.httpClient.testHTTPConn() {
            (result) in
            if (result != 0) {
                // temporary -- sign in with test account
                self.fbClient.signIn(email: "test1@yahoo.com", pass: "test12345") {
                    (result) in
                    if !result {
                        print("signIn() err")
                    }
                }
            }
            else {
                print("Connection failed.")
            }
        }
        
    }
    
}
