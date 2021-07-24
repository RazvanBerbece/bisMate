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
        
        // check whether user has bio or not
        if (1 == 0) { // user has bio, placeholder
            
        }
        else { // user doesn't have bio
            placeholderLabel = UILabel()
            placeholderLabel.numberOfLines = 0;
            placeholderLabel.text = "Write a short description of yourself.\nMake it interesting :)\n(max. 300 characters)"
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
        
        Singleton.sharedInstance.HTTPClient?.sendOperationWithToken(operation: "ubs", input: self.bioTextArea.text) {
            (result, errCheck) in
            if result != "" {
                
                Singleton.sharedInstance.CurrentLocalUser?.setBio(newBio: self.bioTextArea.text)
                
                // update bio locally from text view input & dismiss screen on successful operation and return to user dashboard
                self.dismiss(animated: true, completion: self.delegate?.popoverDidDismiss)
            }
            else {
                // err handling
                print("Error occured while saving user bio to server.")
                // TODO DISPLAY ERROR LABEL
            }
        }
        
    }
    
    // MARK: - Delegate
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !bioTextArea.text.isEmpty
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
