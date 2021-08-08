//
//  LocalUser.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 08/08/2021.
//

import Foundation
import UIKit
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
