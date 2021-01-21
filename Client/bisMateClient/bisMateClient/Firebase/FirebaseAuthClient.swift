//
//  FirebaseAuthClient.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 16/01/2021.
//

import Foundation
import FirebaseAuth
import Firebase

// Basic user class
class User {
    
    private var email          : String?
    private var displayName    : String?
    private var UID            : String?
    private var token          : String?
    
    /** Constructor */
    init(email: String, displayName: String, UID: String, token: String) {
        self.email = email
        self.displayName = displayName
        self.UID = UID
        self.token = token
    }
    
    /** Getters */
    public func getDisplayName() -> String {
        return self.displayName!
    }
    public func getEmail() -> String {
        return self.email!
    }
    public func getUID() -> String {
        return self.UID!
    }
    public func getToken() -> String {
        return self.token!
    }
    
    /** Setters */
    public func setDisplayName(newName: String) {
        self.displayName = newName
    }
    public func setEmail(newEmail: String) {
        self.email = newEmail
    }
    public func setUID(newUID: String) {
        self.UID = newUID
    }
    public func setToken(newToken: String) {
        self.token = newToken
    }
    
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
        self.currentUser!.setUID(newUID: withUser.getUID())
        self.currentUser!.setEmail(newEmail: withUser.getEmail())
        self.currentUser!.setDisplayName(newName: withUser.getDisplayName())
        self.currentUser!.setToken(newToken: withUser.getToken())
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
