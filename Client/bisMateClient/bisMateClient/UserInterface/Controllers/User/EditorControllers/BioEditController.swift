//
//  BioEditController.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 19/07/2021.
//

import UIKit

protocol BioEditControllerDelegate: AnyObject {
    func popoverDidDismiss()
}

class BioEditController: UIViewController, UITextViewDelegate {
    
    weak var delegate: BioEditControllerDelegate?
    
    // UI Components
    
    // Text Views
    @IBOutlet weak var bioTextArea: UITextView!
    
    // Labels
    var placeholderLabel : UILabel! // used in bioTextArea
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.initTextArea()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Methods
    
    // Initialisers & Config
    /** Puts user bio in the text view. If the user has no bio, the placeholder is shown */
    private func initTextArea() {
        
        bioTextArea.delegate = self
        placeholderLabel = UILabel()
        
        // check whether user has bio or not
        if (Singleton.sharedInstance.CurrentLocalUser?.getBio().count != 0) { // user has bio, placeholder
            bioTextArea.text = Singleton.sharedInstance.CurrentLocalUser?.getBio()
        }
        else { // user doesn't have bio
            placeholderLabel.numberOfLines = 0
            placeholderLabel.text = " Write a short description here.\n Make it interesting!\n (Max. 300 characters)"
            placeholderLabel.font = UIFont.italicSystemFont(ofSize: (bioTextArea.font?.pointSize)!)
            placeholderLabel.sizeToFit()
            bioTextArea.addSubview(placeholderLabel)
            placeholderLabel.frame.origin = CGPoint(x: 5, y: (bioTextArea.font?.pointSize)! / 2)
            placeholderLabel.textColor = UIColor.lightGray
            placeholderLabel.isHidden = !bioTextArea.text.isEmpty
        }
    }
    
    // MARK: - Actions
    @IBAction private func goBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func setUserBio() {
        
        DispatchQueue.background(delay: 3.0, background: {
            Singleton.sharedInstance.HTTPClient?.sendOperationWithToken(operation: "ubs", input: self.bioTextArea.text) {
                (result, errCheck) in
                if result != "" {
                    Singleton.sharedInstance.CurrentLocalUser?.setBio(newBio: self.bioTextArea.text)
                }
                else {
                    // err handling
                    print("Error occured while saving user bio to server.")
                    // TODO DISPLAY ERROR LABEL
                }
            }
        }, completion: {
            // update bio locally from text view input & dismiss screen on successful operation and return to user dashboard
            self.dismiss(animated: true, completion: self.delegate?.popoverDidDismiss)
        })
        
    }
    
    // MARK: - Delegate
    func textViewDidChange(_ textView: UITextView) {
        switch bioTextArea.text.isEmpty {
        case true:
            placeholderLabel.isHidden = false
        case false:
            placeholderLabel.isHidden = true
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
              let rangeOfTextToReplace = Range(range, in: textFieldText) else {
            return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= 300
    }
    
}
