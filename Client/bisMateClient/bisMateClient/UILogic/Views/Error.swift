//
//  Error.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 07/07/2021.
//

import Foundation
import UIKit

/**
 Takes in an error string and returns an UIView for that error
 */
func getErrorView(error: String) -> UIView {
    
    let screenSize = UIScreen.main.bounds;
    
    // Initialize view that will be swiped
    // 90% of width (empty 5% left 5% right), 73.33% of height
    let view = UIView(frame: CGRect(origin: CGPoint(x: (5/100) * screenSize.width, y: 125.0), size: CGSize(width: (90/100) * screenSize.width, height: (73.33/100) * screenSize.height)))
    
    // Subviews (profile data) to be added to swipeable view
    let errorMessageLabel = UILabel(frame: CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.width * 0.75, height: view.frame.height * 0.2))
    errorMessageLabel.textColor = .label
    errorMessageLabel.textAlignment = .center
    errorMessageLabel.center = CGPoint(x: view.frame.width / 2, y: view.frame.height * 0.5)
    
    // Subivew data logic
    errorMessageLabel.text = error
    
    // Add subviews
    view.addSubview(errorMessageLabel)
    
    // Configration
    view.translatesAutoresizingMaskIntoConstraints = false
    
    return view
    
}
