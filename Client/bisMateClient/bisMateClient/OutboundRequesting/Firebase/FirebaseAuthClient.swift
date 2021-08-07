//
//  FirebaseAuthClient.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 16/01/2021.
//

import Foundation
import FirebaseAuth
import Firebase
import SwiftyJSON

// Basic user class
class User {
    
    private var UID            : String?
    private var email          : String?
    private var displayName    : String?
    private var phoneNumber    : String?
    private var photoURL       : String?
    private var emailVerified  :   Bool?
    
    private var token          : String? // used for server operations
    
    private var bio            : String?
    private var profilePic     : UIImage?
    
    /** Constructor */
    init(UID: String, email: String, displayName: String, phoneNumber: String, photoURL: String, emailVerified: Bool, token: String) {
        self.UID = UID
        self.email = email
        self.displayName = displayName
        self.phoneNumber = phoneNumber
        self.photoURL = photoURL
        self.emailVerified = emailVerified
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
    public func getPhoneNumber() -> String {
        return self.phoneNumber!
    }
    public func getPhotoURL() -> String {
        return self.photoURL!
    }
    public func getEmailVerified() -> Bool {
        return self.emailVerified!
    }
    public func getToken() -> String {
        return self.token!
    }
    public func getBio() -> String {
        return self.bio!
    }
    public func getProfilePic() -> UIImage {
        return self.profilePic!
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
    public func setPhoneNumber(newNo: String) {
        self.phoneNumber = newNo
    }
    public func setPhotoURL(newURL: String) {
        self.photoURL = newURL
    }
    public func setEmailVerified() {
        self.emailVerified = true
    }
    public func setToken(newToken: String) {
        self.token = newToken
    }
    public func setBio(newBio: String) {
        self.bio = newBio
    }
    public func setProfilePic(newProfilePic: UIImage) {
        self.profilePic = newProfilePic
    }
    
    /** Utils */
    static public func getUserFromData(data: JSON) -> User {
        
        let UID = data["Data"]["UID"]
        // temporary
        // will change requirements that all users must have a display name
        let DisplayName = data["Data"]["DisplayName"] == "" ? "User with no display name" : data["Data"]["DisplayName"]
        let PhotoURL = data["Data"]["PhotoURL"]
        let EmailVerified = data["Data"]["EmailVerified"]
        let user = User(UID: UID.stringValue, email: "-", displayName: DisplayName.stringValue, phoneNumber: "-", photoURL: PhotoURL.stringValue, emailVerified: EmailVerified.boolValue, token: "-")
        
        return user

    }
    
}


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
