//
//  SignInViewController.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 22/01/2021.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController {
    
    // UI Components
    // Text Fields
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    
    // HTTP Client APIs
    var FirebaseClient = FirebaseAuthClient()
    
    // Default user data
    var CurrentUser = User(UID: "def", email: "def", displayName: "def", phoneNumber: "def", photoURL: "def", emailVerified: false, token: "def")
    
    override func viewDidLoad() {
        
        // Auth state listener here, perform segue after successful data received
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                user.getIDTokenForcingRefresh(true) {
                    // get token that can be used for backend ops
                    (idToken, err) in
                    
                    if let error = err {
                        print("token err: \(String(describing: error))")
                        return
                    }
                    
                    // set current user now that the token is available
                    self.CurrentUser.setUID(newUID: user.uid)
                    self.CurrentUser.setEmail(newEmail: user.email!)
                    self.CurrentUser.setDisplayName(newName: user.displayName!)
                    self.CurrentUser.setPhoneNumber(newNo: user.phoneNumber ?? "No phone number added.")
                    // self.currentUser.setPhotoURL(newURL: user.photoURL)
                    if (user.isEmailVerified) {
                        self.CurrentUser.setEmailVerified()
                    }
                    self.CurrentUser.setToken(newToken: idToken!)
                    
                    // Perform segue to user dashboard (CurrentUser gets sent)
                    // TODO
                    print(self.CurrentUser.getDisplayName())
                }
            }
        }
        
        super.viewDidLoad()
        
        
    }
    
    /** Methods */
    @IBAction private func close() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func signInAction() {
        
        // data required for sign in op, available from input fields
        let inputEmail = self.textFieldEmail.text
        let inputPass = self.textFieldPassword.text
        
        // if both inputs are not empty, call the sign in function
        if (inputEmail != "" && inputPass != "") {
            self.FirebaseClient.signIn(email: inputEmail!, pass: inputPass!) {
                (result) in
                if (result) {
                    print("Sign in successful.")
                }
                else {
                    print("Sign in failed.")
                }
            }
        }
        else {
            // Inputs empty
            print("Input field/s empty.")
        }
        
    }
    
}
