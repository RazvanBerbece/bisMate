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
    
    override func viewDidLoad() {
        // initialisers
        self.getToken() {
            (token) in
            if (token != "") {
                self.loadProfile()
                Singleton.sharedInstance.CurrentLocalUser!.setToken(newToken: token)
                Singleton.sharedInstance.HTTPClient = RestClient(token: token)
            }
            else {
                // err handling token fail
            }
        }
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (self.CurrentUser.getUID() != "def") { // reload
            self.loadProfile()
        }
    }
    
    /** Methods */
    private func loadProfile() {
        // updates view with current user data
        self.labelGreet.text = "Hello, \(String(describing: Singleton.sharedInstance.CurrentLocalUser!.getDisplayName())) !"
    }
    
    @IBAction private func signOut() {
        // revoke token -- TODO
        // signs user out (dismiss segue)
        dismiss(animated: true, completion: nil)
    }
    
    private func getToken(completion: @escaping (String) -> Void) {
        self.CurrentUser = Singleton.sharedInstance.CurrentLocalUser!
        // called immediately on render to get user token
        Singleton.sharedInstance.CurrentFirebaseUser!.getIDTokenForcingRefresh(true) {
            // get token that can be used for backend ops
            (idToken, err) in
            if let error = err {
                print("token err: \(String(describing: error))")
                completion("")
            }
            completion(idToken!)
        }
    }
    
}
