//
//  UIViewController.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 06/02/2021.
//

import Foundation
import UIKit

// Allows closing of iOS keyboard when highligthing an input field -- https://stackoverflow.com/questions/24126678/close-ios-keyboard-by-touching-anywhere-using-swift
extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}
