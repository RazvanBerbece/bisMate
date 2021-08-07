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
class ConnectViewController: UIViewController, UITextViewDelegate {
    
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
        let viewWidth = (90/100) * screenSize.width
        let viewHeight = (73.33/100) * screenSize.height
        let view = UIView(frame: CGRect(origin: CGPoint(x: (5/100) * screenSize.width, y: 125.0), size: CGSize(width: viewWidth, height: viewHeight)))
        view.alpha = 1.0
        
        // Border setup for each connection tab that belongs to a user
        // view.layer.borderWidth = 1.0
        // view.layer.borderColor = CGColor(gray: 1, alpha: 1.0)
        
        // Configure swipe recognizers for swipeable view
        // left = skip (False), right = like (True)
        view.addGestureRecognizer(self.getSwipeGesture(for: .left))
        view.addGestureRecognizer(self.getSwipeGesture(for: .right))
        
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
        view.setNeedsLayout()
        view.reloadInputViews()
        
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
                    if (self.alreadyLiked(UID: uid) == true || uid == Singleton.sharedInstance.CurrentLocalUser!.getUID() || self.alreadyMatched(UID: uid) == true) {
                        continue // if this user has been swiped on or is current user, don't display
                    }
                    else { // not local or swiped user
                        
                        self.errorOn = false
                        self.swipeableView?.removeFromSuperview()
                        self.swipeableView?.alpha = 0.0
                        
                        noUsersNearby = false
                        
                        Singleton.sharedInstance.HTTPClient?.sendOperationWithToken(operation: "0", input: uid) {
                            (result, status) in
                            if (result != "") {
                                self.nearbyUsers.pushUser(user: User.getUserFromData(data: result))
                                // initialise first swipeable view -- once
                                if (!self.firstViewInit) {
                                    self.downloadUserData(user: self.nearbyUsers.getUsers()[0]) {
                                        self.swipeableView = self.getUIView(with: self.nearbyUsers.getUsers()[0])
                                        self.view.addSubview(self.swipeableView!)
                                        self.firstViewInit = true
                                    }
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
    
    private func alreadyMatched(UID: String) -> Bool {
        return Singleton.sharedInstance.matches!.contains(UID)
    }
    
    // MARK: - Actions
    @objc private func didSwipe(_ sender: UISwipeGestureRecognizer) {
        
        if (self.nearbyUsersIndex < self.nearbyUsers.getCount()) {
            
            let screenSize = UIScreen.main.bounds // .width, .height
            
            // Current frame and positions
            var frame = self.swipeableView!.frame
            var alpha = self.swipeableView!.alpha
            
            // Check direction of swipe and process accordingly
            switch sender.direction {
            case .left: // skip; false
                frame.origin.x -= screenSize.width + 150
                alpha = 0.0
                self.likes.append(self.nearbyUsers.getUsers()[self.nearbyUsersIndex].getUID()) // add this to the array so false swipes aren't seen twice in the same instance
            case .right: // like; true
                frame.origin.x += screenSize.width + 150
                alpha = 0.0
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
            
            UIView.animate(withDuration: 0.50) {
                self.swipeableView!.frame = frame
                self.swipeableView!.alpha = alpha
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
                self.downloadUserData(user: self.nearbyUsers.getUsers()[self.nearbyUsersIndex]) {
                    self.swipeableView = self.getUIView(with: self.nearbyUsers.getUsers()[self.nearbyUsersIndex])
                    self.view.addSubview(self.swipeableView!)
                }
            }
            
        }
        
    }
    
    // MARK: - Utils
    private func downloadUserData(user: User, callback: @escaping () -> Void) {
        
        // TODO: Modify callback to check for error codes after downloading user data
        
        // Download user bio
        Singleton.sharedInstance.HTTPClient?.sendOperationWithToken(operation: "ubg", input: user.getUID()) {
            (resultBio, errStatusBio) in
            if (resultBio != "") {
                user.setBio(newBio: resultBio["Data"].stringValue)
                // Download profile pic
                Singleton.sharedInstance.HTTPClient?.sendOperationWithToken(operation: "ppg", input: user.getUID()) {
                    (resultPic, errStatusPic) in
                    if (resultPic != "") {
                        if (resultPic["Data"] != "") { // decode base64 and display image
                            
                            let fixedBase64 = resultPic["Data"].stringValue.fixedBase64Format
                            let dataDecoded = Data.init(base64Encoded: fixedBase64, options: .ignoreUnknownCharacters)
                            let decodedImage = UIImage(data: dataDecoded!)
                            
                            user.setProfilePic(newProfilePic: decodedImage!)
                            
                            callback()
                            
                        }
                        else { // display default user pic
                            let defaultProfileImage: UIImage = UIImage(systemName: "person.fill")!
                            user.setProfilePic(newProfilePic: defaultProfileImage)
                            callback()
                        }
                    }
                    else {
                        print("Error occured while downloading profile picture.")
                        let defaultProfileImage: UIImage = UIImage(systemName: "person.fill")!
                        user.setProfilePic(newProfilePic: defaultProfileImage)
                        callback()
                    }
                }
            }
            else {
                print("Error occured while downloading user bio")
                callback()
            }
        }
    }
    
}
