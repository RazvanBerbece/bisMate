//
//  ConnectViewController.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 14/02/2021.
//

import UIKit
import SwiftyJSON

// A container class that manages the list of nearby users gathered from the DB
class NearbyUsers {
    
    private var users : [bisMateClient.User]?
    private var count : Int?
    
    init(users: [bisMateClient.User], count: Int) {
        self.users = users
        self.count = count
    }
    
    /** Getters */
    public func getUsers() -> [User] {
        return self.users!
    }
    public func getCount() -> Int {
        return count!
    }
    
    /** Setters */
    public func pushUser(user: User) { // on download
        self.users?.append(user)
        self.incrementCount()
    }
    public func removeUser(deleteUser: User) { // on swipe left
        for (index, user) in self.users!.enumerated() {
            if user.getUID() == deleteUser.getUID() {
                self.users?.remove(at: index)
            }
        }
    }
    private func incrementCount() {
        self.count! += 1
    }
    
}

/**
 The connect controller is linked to the location handler.
 Nearby users will be gathered from the backend and then stored into a list.
 Swiping right on an user leads to :
 1. Add local id to remote awaiting connections list
 2. If remote connects, add ids to successful connections on each end
 */
class ConnectViewController: UIViewController {
    
    /** UIView container for user profiles which can be swiped */
    private var firstViewInit = false
    private var swipeableView: UIView?
    private var nearbyUsersIndex = 0
    
    // Nearby Users Wrapper
    private var nearbyUsers = NearbyUsers(users: [], count: 0)
    
    // Likes array
    private var likedBy : [String] = []     // UIDs swiped on current user
    private var likes   : [String] = []     // current user swiped on these UIDs
    
    // View logic
    private var errorOn : Bool = false
    
    override func viewDidLoad() {
        
        // update likes given by user and received likes - 1
        self.getLikes()
        self.getLikedBy()
        
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // update likes given by user and received likes - 2
        self.getLikedBy()
        
        super.viewDidAppear(animated)
        
        self.populateSwiper()
        
    }
    
    // MARK: - Methods
    private func getUIView(with user: User) -> UIView {
        
        /** Screen sizes logic */
        let screenSize = UIScreen.main.bounds // .width, .height
        
        // Initialize view that will be swiped
        // 90% of width (empty 5% left 5% right), 73.33% of height
        let view = UIView(frame: CGRect(origin: CGPoint(x: (5/100) * screenSize.width, y: 125.0), size: CGSize(width: (90/100) * screenSize.width, height: (73.33/100) * screenSize.height)))
        
        // Configure swipe recognizers for swipeable view
        // left = skip (False), right = like (True)
        view.addGestureRecognizer(self.getSwipeGesture(for: .left))
        view.addGestureRecognizer(self.getSwipeGesture(for: .right))
        
        // Subviews (profile data) to be added to swipeable view
        let remoteNameLabel = UILabel(frame: CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.width * 0.40, height: view.frame.height * 0.15))
        remoteNameLabel.textColor = .label
        remoteNameLabel.textAlignment = .center
        remoteNameLabel.center = CGPoint(x: view.frame.width / 2, y: view.frame.height * 0.075)
        
        // Subivew data logic
        remoteNameLabel.text = user.getDisplayName()
        
        // Add subviews
        view.addSubview(remoteNameLabel)
        
        // Configration
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
        
    }
    
    private func getSwipeGesture(for direction: UISwipeGestureRecognizer.Direction) -> UISwipeGestureRecognizer {
        
        // Init
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        
        // Configure
        swipeGestureRecognizer.direction = direction
        
        return swipeGestureRecognizer
    }
    
    private func getUIDsInCity(completion: @escaping ([String]?, String?) -> (Void)) {
        // Gets a list of all UIDs in current user city
        Singleton.sharedInstance.HTTPClient?.sendOperationWithToken(operation: "wg", input: Singleton.sharedInstance.currentCity!) {
            (result, status) in
            if (result != "") {
                // success
                let stringArr : [String] = result["Data"].arrayValue.map { $0.stringValue }
                completion(stringArr, nil)
            }
            else {
                // err handling
                completion(nil, "Error occured while downloading profiles.")
            }
        }
    }
    
    private func populateSwiper() {
        
        // Get nearby users
        self.nearbyUsersIndex = 0
        var noUsersNearby = true
        
        self.getUIDsInCity() {
            (list, err) in
            if err == nil {
                // Query user data from backend using the UIDs
                for uid in list! {
                    if (self.alreadyLiked(UID: uid) == true || uid == Singleton.sharedInstance.CurrentLocalUser!.getUID()) {
                        continue // if this user has been swiped on or is current user, don't display
                    }
                    else { // not local or swiped user
                        
                        self.errorOn = false
                        self.swipeableView?.removeFromSuperview()
                        noUsersNearby = false
                        
                        Singleton.sharedInstance.HTTPClient?.sendOperationWithToken(operation: "0", input: uid) {
                            (result, status) in
                            if (result != "") {
                                
                                // create a user instance (with less data as it's only for swiping purposes) and add it to NearbyUsers.users
                                let UID = result["Data"]["UID"]
                                // temporary
                                // will change requirements that all users must have a display name
                                let DisplayName = result["Data"]["DisplayName"] == "" ? "User with no display name" : result["Data"]["DisplayName"]
                                let PhotoURL = result["Data"]["PhotoURL"]
                                let EmailVerified = result["Data"]["EmailVerified"]
                                let user = User(UID: UID.stringValue, email: "-", displayName: DisplayName.stringValue, phoneNumber: "-", photoURL: PhotoURL.stringValue, emailVerified: EmailVerified.boolValue, token: "-")
                                self.nearbyUsers.pushUser(user: user)
                                // initialise first swipeable view -- once
                                if (!self.firstViewInit) {
                                    self.swipeableView = self.getUIView(with: self.nearbyUsers.getUsers()[0])
                                    self.view.addSubview(self.swipeableView!)
                                    self.firstViewInit = true
                                }
                            }
                            else {
                                print("Error occured while collecting nearby users.")
                            }
                        }
                    }
                }
                if (noUsersNearby == true) {
                    self.errorOn = true
                    self.swipeableView = getErrorView(error: "No users left in area.")
                    self.view.addSubview(self.swipeableView!)
                    self.firstViewInit = false // reset the first view initializer check
                }
            }
            else {
                print(err!)
            }
        }
    }
    
    private func getLikedBy() {
        Singleton.sharedInstance.HTTPClient!.sendOperationWithToken(operation: "xg", input: Singleton.sharedInstance.CurrentLocalUser!.getUID()) {
            (result, status) in
            if (status == 1) {
                // print(result["Data"])
                var uids : [String] = []
                for (_, uidTuple) in result["Data"].enumerated() {
                    uids.append(uidTuple.1.stringValue)
                }
                self.likedBy = uids
            }
            else {
                print("An error occured while getting like list.")
            }
        }
    }
    
    private func getLikes() {
        Singleton.sharedInstance.HTTPClient!.sendOperationWithToken(operation: "xx", input: Singleton.sharedInstance.CurrentLocalUser!.getUID()) {
            (result, status) in
            if (status == 1) {
                // print(result["Data"])
                var uids : [String] = []
                for (_, uidTuple) in result["Data"].enumerated() {
                    uids.append(uidTuple.1.stringValue)
                }
                self.likes = uids
            }
            else {
                print("An error occured while getting like list.")
            }
        }
    }
    
    private func alreadyLiked(UID: String) -> Bool {
        return self.likes.contains(UID)
    }
    
    // MARK: - Actions
    @objc private func didSwipe(_ sender: UISwipeGestureRecognizer) {
        
        if (self.nearbyUsersIndex < self.nearbyUsers.getCount()) {
            
            let screenSize = UIScreen.main.bounds // .width, .height
            
            // Current frame and positions
            var frame = self.swipeableView!.frame
            
            // Check direction of swipe and process accordingly
            switch sender.direction {
            case .left: // skip; false
                frame.origin.x -= screenSize.width + 150
                self.likes.append(self.nearbyUsers.getUsers()[self.nearbyUsersIndex].getUID()) // add this to the array so false swipes aren't seen twice in the same instance
            case .right: // like; true
                frame.origin.x += screenSize.width + 150
                self.likes.append(self.nearbyUsers.getUsers()[self.nearbyUsersIndex].getUID())
                Singleton.sharedInstance.HTTPClient!.sendOperationWithToken(operation: "xs", input: self.nearbyUsers.getUsers()[self.nearbyUsersIndex].getUID()) {
                    (result, status) in
                    if (status == 1) {
                        // TODO
                    }
                    else {
                        print("An error occured while liking this user.")
                    }
                }
            default:
                break
            }
            
            UIView.animate(withDuration: 0.40) {
                self.swipeableView!.frame = frame
            }
            
            self.nearbyUsersIndex += 1
            
            // if no users left in area, display message
            if (self.nearbyUsersIndex >= self.nearbyUsers.getCount()) { // if no users left, display message
                self.swipeableView = getErrorView(error: "No users left in area.")
                self.view.addSubview(self.swipeableView!)
                self.firstViewInit = false // reset the first view initializer check
                self.errorOn = true
            }
            else { // there are users left in area
                self.swipeableView = self.getUIView(with: self.nearbyUsers.getUsers()[self.nearbyUsersIndex])
                self.view.addSubview(self.swipeableView!)
            }
            
        }
        
    }
    
}
