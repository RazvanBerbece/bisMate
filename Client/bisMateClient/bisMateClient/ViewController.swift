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
    let httpClient = HTTPClient(token: "tokenHere")

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
                    self.fbClient.setCurrentUser(withUser: User(email: user.email, displayName: user.displayName, UID: user.uid, token: idToken))
                    print(self.fbClient.getCurrentUser())
                    // send token to backend TODO
                }
            }
        }
        
        super.viewDidLoad()
        
        // temporary -- sign in with test account
        self.fbClient.signIn(email: "test1@yahoo.com", pass: "test12345") {
            (result) in
            if !result {
                print("signIn() err")
            }
        }
        
        self.httpClient.testHTTPConn() {
            (result) in
            print(result)
        }
        
    }

}
