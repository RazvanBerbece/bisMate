//
//  ConnectionPopup.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 17/07/2021.
//

import Foundation
import UIKit

class ConnectionPopup: UIView, UITextViewDelegate, UIGestureRecognizerDelegate {
    
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
    
    @objc public func dismissConnectionPopup(sender: UIButton!) {
        self.alpha = 0.0
        for subview in self.subviews {
            subview.removeFromSuperview()
            subview.alpha = 0.0
        }
        self.removeFromSuperview()
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
        
        let newConnectionLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        newConnectionLabel.textColor = .label
        newConnectionLabel.textAlignment = .center
        newConnectionLabel.text = "New Connection"
        newConnectionLabel.center = CGPoint(x: self.frame.width / 2, y: 45)
        newConnectionLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        self.addSubview(newConnectionLabel)
        
        // user data display
        let userProfilePicView = UIImageView(frame: CGRect(x: 0, y: 0, width: 85, height: 85))
        userProfilePicView.center = CGPoint(x: self.frame.width / 2, y: 130)
        userProfilePicView.maskCircleWithShadow(anyImage: user.getProfilePic())
        userProfilePicView.layer.cornerRadius = userProfilePicView.frame.width / 2
        
        let userNameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 25))
        userNameLabel.textColor = .label
        userNameLabel.textAlignment = .center
        userNameLabel.center = CGPoint(x: self.frame.width / 2, y: 200)
        userNameLabel.font = UIFont.systemFont(ofSize: 17.0)
        userNameLabel.text = user.getDisplayName()
        
        let userBioTextView = UITextView(frame: CGRect(x: 0, y: 0, width: (80 / 100.0) * self.screenSize.width, height: 125))
        userBioTextView.delegate = self
        userBioTextView.isScrollEnabled = true
        userBioTextView.textColor = .label
        userBioTextView.isSelectable = false
        userBioTextView.textAlignment = .center
        userBioTextView.center = CGPoint(x: self.frame.width / 2, y: 300)
        userBioTextView.font = UIFont.systemFont(ofSize: 16.0)
        userBioTextView.text = user.getBio()
        
        // functionals
        let dismissButon = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
        dismissButon.setTitle("Dismiss", for: .normal)
        dismissButon.setTitleColor(UIColor(rgb: 0xB56C77), for: .normal)
        dismissButon.center = CGPoint(x: self.frame.width / 2, y: (85 / 100.0) * self.screenSize.height)
        dismissButon.titleLabel?.font =  UIFont.boldSystemFont(ofSize: 20.0)
        // set the button functionality
        dismissButon.addTarget(self, action: #selector(dismissConnectionPopup), for: .touchUpInside)
        
        // add user data subviews
        self.addSubview(userNameLabel)
        self.addSubview(userBioTextView)
        self.addSubview(userProfilePicView)
        self.addSubview(dismissButon)
        
        // fade in connection popup
        UIView.animate(withDuration: 3.33, animations: {
            self.alpha = 1.0
        })
        
        self.setNeedsLayout()
        self.reloadInputViews()
        
    }
    
}
