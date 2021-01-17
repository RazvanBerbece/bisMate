//
//  FirebaseAuthClient.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 16/01/2021.
//

import Foundation
import FirebaseAuth
import Firebase

// Basic user structure
struct User {
    var email: String?
    var displayName: String?
    var UID: String?
    var token: String?
}

/** Manages operations with the Firebase project */
class FirebaseAuthClient {
    
    private var currentUser: User?
    
    init() {
        currentUser = User(email: "uninit", displayName: "uninit", UID: "uninit", token: "uninit")
    }
    
    /** Getters / Setters */
    public func getCurrentUser() -> User {
        return self.currentUser!
    }
    public func setCurrentUser(withUser: User) {
        self.currentUser!.UID = withUser.UID
        self.currentUser!.email = withUser.email
        self.currentUser!.displayName = withUser.displayName
        self.currentUser!.token = withUser.token
    }
    
    /** Signs in using Firebase */
    public func signIn(email: String, pass: String, callback: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: pass) {
            [weak self] authResult, error in
            guard self != nil else { return }
            if error != nil {
                print(error!)
                callback(false)
            }
            callback(true)
        }
    }
    
}
