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
    
    // Labels
    @IBOutlet weak var labelSignInErr: UILabel!
    
    // Firebase Client API
    var FirebaseClient = FirebaseAuthClient()
    
    // Received User Data after sign in
    var FirebaseUser: FirebaseAuth.User?
    var status = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /** Methods */
    private func initComponents() {
        self.labelSignInErr.alpha = 0
        self.labelSignInErr.text = ""
    }
    
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
                (result, user) in
                if (result) {
                    print("Sign in successful.")
                    self.status = 1
                    // move to next view
                    self.FirebaseUser = user
                    self.performSegue(withIdentifier: "SignInSuccess", sender: self)
                }
                else {
                    // print("Sign in failed.")
                    self.labelSignInErr.text = "An error occured while signing in. Check your credentials and try again."
                    self.labelSignInErr.alpha = 1
                    self.labelSignInErr.fadeOut(duration: 4, delay: 3.5)
                    self.labelSignInErr.textColor = UIColor(ciColor: .red)
                }
            }
        }
        else {
            // Inputs empty
            print("Input field/s empty.")
            self.labelSignInErr.text = "The login credentials can't be empty. Fill in your email and password and try agaian."
            self.labelSignInErr.alpha = 1
            self.labelSignInErr.fadeOut(duration: 4, delay: 3.5)
            self.labelSignInErr.textColor = UIColor(ciColor: .red)
        }
    }
    
    // data passing on segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is UserDashboardViewController
        {
            let vc = segue.destination as? UserDashboardViewController
            vc?.fbUser = FirebaseUser
        }
    }
    
}
