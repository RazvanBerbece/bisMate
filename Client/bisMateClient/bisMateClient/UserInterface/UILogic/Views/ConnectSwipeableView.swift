//
//  ConnectSwipeableView.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 08/08/2021.
//

import Foundation
import UIKit

class SwipeableViewProcessor: NSObject, UITextViewDelegate {
    
    public func getUIView(with user: User, for leftGestureRec: UISwipeGestureRecognizer, and rightGestureRec: UISwipeGestureRecognizer) -> UIView {
        // a bit of natural language in the param list ;) saw that swift allows this with param list configs and decided to have an example, it's quite cool
        
        /** Screen sizes logic */
        let screenSize = UIScreen.main.bounds // .width, .height
        
        // Initialize view that will be swiped
        // 90% of width (empty 5% left 5% right), 73.33% of height
        let viewWidth = (90/100) * screenSize.width
        let viewHeight = (73.33/100) * screenSize.height
        let view = UIView(frame: CGRect(origin: CGPoint(x: (5/100) * screenSize.width, y: 125.0), size: CGSize(width: viewWidth, height: viewHeight)))
        view.alpha = 1.0
        
        // Border setup for each connection tab that belongs to a user
        // view.layer.borderWidth = 1.0
        // view.layer.borderColor = CGColor(gray: 1, alpha: 1.0)
        
        // Configure swipe recognizers for swipeable view
        // left = skip (False), right = like (True)
        view.addGestureRecognizer(leftGestureRec)
        view.addGestureRecognizer(rightGestureRec)
        
        // Subviews (profile data) to be added to swipeable view
        let userProfilePicView = UIImageView(frame: CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: 85, height: 85))
        userProfilePicView.center = CGPoint(x: viewWidth / 2, y: viewHeight * 0.075)
        userProfilePicView.layer.cornerRadius = userProfilePicView.frame.width / 2
        
        let remoteNameLabel = UILabel(frame: CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: viewWidth * 0.50, height: 30))
        remoteNameLabel.font = UIFont.systemFont(ofSize: 18.0)
        remoteNameLabel.textColor = .label
        remoteNameLabel.textAlignment = .center
        remoteNameLabel.center = CGPoint(x: viewWidth / 2, y: viewHeight * 0.20)
        
        let userBioTextView = UITextView(frame: CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: (80 / 100.0) * viewWidth, height: 125))
        userBioTextView.delegate = self
        userBioTextView.isScrollEnabled = true
        userBioTextView.isSelectable = false
        userBioTextView.textColor = .label
        userBioTextView.textAlignment = .center
        userBioTextView.center = CGPoint(x: viewWidth / 2, y: viewHeight * 0.40)
        userBioTextView.font = UIFont.systemFont(ofSize: 16.0)
        
        // Subivew data logic
        remoteNameLabel.text = user.getDisplayName()
        userProfilePicView.maskCircleWithShadow(anyImage: user.getProfilePic())
        userBioTextView.text = user.getBio()
        
        // Add subviews
        view.addSubview(remoteNameLabel)
        view.addSubview(userProfilePicView)
        view.addSubview(userBioTextView)
        
        // Configration
        view.translatesAutoresizingMaskIntoConstraints = false
        // view.setNeedsLayout()
        
        return view
        
    }
    
    public func resetUIView(for view: UIView) {
        for subview in view.subviews {
            subview.removeFromSuperview()
            subview.alpha = 0.0
        }
        view.alpha = 0.0
        view.removeFromSuperview()
    }
    
    
}
