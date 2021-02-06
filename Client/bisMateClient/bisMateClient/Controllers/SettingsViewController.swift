//
//  SettingsViewController.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 23/01/2021.
//

import UIKit

class SettingsViewController: UIViewController {
    
    // Backend API
    var HTTPClient : RestClient?
    
    // UI Components
    // Inputs
    @IBOutlet weak var inputNewDisplayName: UITextField!
    
    // Labels
    @IBOutlet weak var labelChangeResult: UILabel!
    
    override func viewDidLoad() {
        
        // Init
        self.initComponents()
        self.hideKeyboardWhenTappedAround()
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        self.HTTPClient = RestClient(token: Singleton.sharedInstance.CurrentLocalUser!.getToken())
        
    }
    
    /** Methods */
    private func initComponents() {
        self.labelChangeResult.alpha = 0
    }
    
    @IBAction private func submitProfileChanges() {
        
        let newDisplayName = self.inputNewDisplayName.text
        
        if (newDisplayName != "") {
            self.HTTPClient!.sendOperationWithToken(operation: "2", input: newDisplayName!) {
                (result, errCheck) in
                if errCheck == 0 {
                    print(result)
                    Singleton.sharedInstance.CurrentLocalUser!.setDisplayName(newName: String(describing: result["Data"]))
                    DispatchQueue.main.async {
                        self.labelChangeResult.alpha = 1
                        self.labelChangeResult.text = String(describing: result["Message"])
                        self.labelChangeResult.textColor = UIColor.systemGreen
                        self.labelChangeResult.fadeOut(duration: 4, delay: 3.5)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self.labelChangeResult.alpha = 1
                        self.labelChangeResult.text = "An error occured while submitting your changes. Please try again."
                        self.labelChangeResult.textColor = UIColor.red
                        self.labelChangeResult.fadeOut(duration: 4, delay: 3.5)
                    }
                }
            }
        }
        else {
            // TODO
        }
        
    }
    
}
