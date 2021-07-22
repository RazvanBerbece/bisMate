//
//  BioEditController.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 19/07/2021.
//

import UIKit

class BioEditController: UIViewController, UITextViewDelegate {
    
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
    
    // MARK: - Segue Logic
    @IBAction private func goBack() {
        dismiss(animated: true, completion: nil)
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
