//
//  FirebaseAuthClient.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 16/01/2021.
//

import Foundation
import FirebaseAuth
import Firebase

/** Manages operations with the Firebase project */
class FirebaseAuthClient {
    
    private var currentUser: User?
    
    init() {
        currentUser = User(UID: "def", email: "def", displayName: "def", phoneNumber: "def", photoURL: "def", emailVerified: false, token: "def")
    }
    
    /** Getters / Setters */
    public func getCurrentUser() -> User {
        return self.currentUser!
    }
    public func setCurrentUser(withUser: User) {
        self.currentUser!.setUID(newUID: withUser.getUID())
        self.currentUser!.setEmail(newEmail: withUser.getEmail())
        self.currentUser!.setDisplayName(newName: withUser.getDisplayName())
        self.currentUser!.setPhoneNumber(newNo: withUser.getPhoneNumber())
        self.currentUser!.setPhotoURL(newURL: withUser.getPhotoURL())
        // self.currentUser!.setEmailVerified()
        self.currentUser!.setToken(newToken: withUser.getToken())
    }
    
    /** Signs in using Firebase */
    public func signIn(email: String, pass: String, callback: @escaping (Bool, Any) -> Void) {
        Auth.auth().signIn(withEmail: email, password: pass) {
            [weak self] authResult, error in
            guard self != nil else { return }
            if error != nil {
                print(error!)
                callback(false, error!)
            }
            else {
                callback(true, authResult!.user)
            }
        }
    }
}
