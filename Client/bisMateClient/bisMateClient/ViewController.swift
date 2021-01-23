//
//  ViewController.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 15/01/2021.
//

import UIKit
import Firebase
import SwiftyJSON // for JSON type

class ViewController: UIViewController {
    
    // UI components
    // Labels
    @IBOutlet weak var labelTitleFirst: UILabel!
    @IBOutlet weak var labelTitleSecond: UILabel!
    @IBOutlet weak var labelMainText: UILabel!
    @IBOutlet weak var labelJoinUs: UILabel!
    
    // Buttons
    @IBOutlet weak var buttonSignUp: UIButton!
    @IBOutlet weak var buttonSignIn: UIButton!
    
    override func viewDidLoad() {
        
        // Initialisers
        self.initAnimatedComponents()
        
        super.viewDidLoad()
        
        // animations
        self.animateComponents()
        
    }
    
    /** Methods */
    /** Initialises components in this view that are animated */
    private func initAnimatedComponents() {
        self.labelTitleFirst.alpha = 0
        self.labelTitleSecond.alpha = 0
        self.labelMainText.alpha = 0
        self.labelJoinUs.alpha = 0
        self.buttonSignUp.alpha = 0
        self.buttonSignIn.alpha = 0
    }
    
    /** Animates components in this view  */
    private func animateComponents() {
        self.labelTitleFirst.fadeIn(duration: 2, delay: 0) {
            (finished) in
            // NOTHING HERE
        }
        self.labelTitleSecond.fadeIn(duration: 1.5, delay: 1.5) {
            (finished) in
            // NOTHING HERE
        }
        self.labelMainText.fadeIn(duration: 1.5, delay: 2) {
            (finished) in
            // NOTHING HERE
        }
        self.labelJoinUs.fadeIn(duration: 1.25, delay: 3.25) {
            (finished) in
            // NOTHING HERE
        }
        self.buttonSignUp.fadeIn(duration: 1.25, delay: 3.25) {
            (finished) in
            // NOTHING HERE
        }
        self.buttonSignIn.fadeIn(duration: 1.25, delay: 3.25) {
            (finished) in
            // NOTHING HERE
        }
    }
    
    @IBAction private func SignInPress() {
        // 'I already have an account' press
        performSegue(withIdentifier: "SegueSignIn", sender: self)
    }
    
}
