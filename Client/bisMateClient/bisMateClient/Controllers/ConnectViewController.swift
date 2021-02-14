//
//  ConnectViewController.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 14/02/2021.
//

import UIKit

/**
 The connect controller is linked to the location handler.
 Nearby users will be gathered from the backend and then stored into a list.
 Swiping right on an user leads to :
 1. Add local id to remote awaiting connections list
 2. If remote connects, add ids to successful connections on each end
 */
class ConnectViewController: UIViewController {
    
    /** UIView container for user profiles which can be swiped */
    private let swipeableView: UIView = {
        
        /** Screen sizes logic */
        let screenSize = UIScreen.main.bounds // .width, .height
        
        // Initialize view that will be swiped
        // 90% of width (empty 5% left 5% right), 73.33% of height
        let view = UIView(frame: CGRect(origin: CGPoint(x: (5/100) * screenSize.width, y: 125.0), size: CGSize(width: (90/100) * screenSize.width, height: (73.33/100) * screenSize.height)))
        
        // Subviews (profile data) to be added to swipeable view
        let remoteNameLabel = UILabel(frame: CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.width * 0.40, height: view.frame.height * 0.15))
        remoteNameLabel.textColor = .label
        remoteNameLabel.textAlignment = .center
        remoteNameLabel.center = CGPoint(x: view.frame.width / 2, y: view.frame.height * 0.075)
        
        // Subivew data logic
        remoteNameLabel.text = "Username here"
        
        // Add subviews
        view.addSubview(remoteNameLabel)
        
        // Configration
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
        
    }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.addSubview(self.swipeableView)
        
        // Configure swipe recognizers for swipeable view
        // left = skip (False), right = like (True)
        self.swipeableView.addGestureRecognizer(self.getSwipeGesture(for: .left))
        self.swipeableView.addGestureRecognizer(self.getSwipeGesture(for: .right))
        
        
    }
    
    // MARK: - Methods
    private func getSwipeGesture(for direction: UISwipeGestureRecognizer.Direction) -> UISwipeGestureRecognizer {
        
        // Init
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        
        // Configure
        swipeGestureRecognizer.direction = direction
        
        return swipeGestureRecognizer
    }
    
    // MARK: - Actions
    @objc private func didSwipe(_ sender: UISwipeGestureRecognizer) {
        
        let screenSize = UIScreen.main.bounds // .width, .height
        
        // Current frame and positions
        var frame = self.swipeableView.frame
        let originalX = frame.origin.x
        
        // Check direction of swipe and process accordingly
        switch sender.direction {
        case .left: // skip; false
            frame.origin.x -= screenSize.width + 150
        case .right: // like; true
            frame.origin.x += screenSize.width + 150
        default:
            break
        }
        
        UIView.animate(withDuration: 0.40) {
            self.swipeableView.frame = frame
        }
        
        self.swipeableView.frame.origin.x = originalX
        
    }
    
}
