//
//  ConnectionPopup.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 17/07/2021.
//

import Foundation
import UIKit

class ConnectionPopup: UIView, UITextViewDelegate {
    
    static let shared = ConnectionPopup()
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    let backgroundColour: UIColor = {
        return UIColor(ciColor: .white)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = true
        // setup user view
        // self.setupConnectionPopup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func showConnectionPopup(user: User) {
        self.setupConnectionPopup(user: user)
    }
    
    private func setupConnectionPopup(user: User) {
        
        // self UIView styling
        self.backgroundColor = self.backgroundColour
        // self.alpha = 0.0
        self.layer.cornerRadius = 50
        self.layer.shadowOpacity = 1
        
        // get keyWindow (main app window) and add the popup as subview to it
        let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
        keyWindow!.addSubview(self)
        
        // self UIView layout -- centered on top of all views
        self.frame.size.width = self.screenSize.width - 30
        self.frame.size.height = self.screenSize.height - 40
        self.center = CGPoint(x: self.screenSize.width / 2, y: self.screenSize.height / 2)
        
        // SHOULD REFACTOR AND USE THE WIDTH OF SELF TO POSITION THE LABELS
        // USES SCREENSIZE WIDTH AT THE MOMENT
        
        let newConnectionLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 250, height: 25))
        newConnectionLabel.alpha = 0.0
        newConnectionLabel.textColor = .label
        newConnectionLabel.textAlignment = .center
        newConnectionLabel.text = "You've got a new connection !"
        newConnectionLabel.center = CGPoint(x: self.frame.width / 2, y: 45)
        newConnectionLabel.font = UIFont(name: newConnectionLabel.font.fontName, size: 20)
        self.addSubview(newConnectionLabel)
        
        // user data display
        let userNameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 25))
        userNameLabel.alpha = 0.0
        userNameLabel.textColor = .label
        userNameLabel.textAlignment = .center
        userNameLabel.center = CGPoint(x: self.frame.width / 2, y: 100)
        userNameLabel.text = user.getDisplayName()
        
        let userBioTextView = UITextView(frame: CGRect(x: 0, y: 0, width: 200, height: 125))
        userBioTextView.delegate = self
        userBioTextView.isScrollEnabled = true
        userBioTextView.alpha = 0.0
        userBioTextView.textColor = .label
        userBioTextView.textAlignment = .center
        userBioTextView.center = CGPoint(x: self.frame.width / 2, y: 150)
        userBioTextView.text = user.getBio()
        
        // add user data subviews
        self.addSubview(userNameLabel)
        self.addSubview(userBioTextView)
        
        // fade in connection popup
        UIView.animate(withDuration: 1.5, animations: {
            self.alpha = 1.0
        }) {
            _ in
            
            // animate user data -- will animate the whole profile at once, after animating greeting
            // animate notification greeting
            UIView.animate(withDuration: 2.0, animations: {
                newConnectionLabel.alpha = 1.0
            }) {
                _ in
                // animate user data
                UIView.animate(withDuration: 1.5, animations: {
                    // change user data views alphas here
                    userNameLabel.alpha = 1.0
                    userBioTextView.alpha = 1.0
                }) {
                    _ in
                    // fade out connection popup -- might remove and add an exit button for the popup
                    UIView.animate(withDuration: 5.5, animations: {
                        self.alpha = 0.0
                    }, completion: nil)
                }
            }
            
        }
        
        self.setNeedsLayout()
        self.reloadInputViews()
        
    }
    
}
