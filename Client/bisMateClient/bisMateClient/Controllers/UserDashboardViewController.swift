//
//  UserDashboardViewController.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 23/01/2021.
//

import UIKit
import FirebaseAuth

class UserDashboardViewController: UIViewController {
    
    // UI Components
    // Labels
    @IBOutlet weak var labelGreet: UILabel!
    
    // User data
    var fbUser: FirebaseAuth.User? // received from Firebase, will be translated to local User design
    var CurrentUser = User(UID: "def", email: "def", displayName: "def", phoneNumber: "def", photoURL: "def", emailVerified: false, token: "def")
    
    // Tab Bar
    @IBOutlet weak var tabBar: UITabBar!
    
    override func viewDidLoad() {
        
        // initialisers
        self.initComponents()
        self.getToken()
        self.loadProfile()
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    /** Methods */
    private func loadProfile() {
        // updates view with current user data
        self.labelGreet.text = "Hello, \(self.CurrentUser.getDisplayName())"
    }
    
    private func initComponents() {
        self.tabBar.selectedItem = tabBar.items![0] as UITabBarItem
    }
    
    @IBAction private func signOut() {
        // revoke token -- TODO
        // signs user out (dismiss segue)
        dismiss(animated: true, completion: nil)
    }
    
    private func getToken() {
        self.CurrentUser.setUID(newUID: fbUser!.uid)
        self.CurrentUser.setEmail(newEmail: fbUser!.email!)
        self.CurrentUser.setDisplayName(newName: fbUser!.displayName!)
        self.CurrentUser.setPhoneNumber(newNo: fbUser!.phoneNumber ?? "No phone number added.")
        // self.currentUser.setPhotoURL(newURL: user.photoURL)
        if (self.fbUser!.isEmailVerified) {
            self.CurrentUser.setEmailVerified()
        }
        // called immediately on render to get user token
        self.fbUser!.getIDTokenForcingRefresh(true) {
            // get token that can be used for backend ops
            (idToken, err) in
            
            if let error = err {
                print("token err: \(String(describing: error))")
                return
            }
            self.CurrentUser.setToken(newToken: idToken!)
        }
    }
    
}
