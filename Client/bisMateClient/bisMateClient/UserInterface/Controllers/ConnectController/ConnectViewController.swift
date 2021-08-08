//
//  ConnectViewController.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 14/02/2021.
//

import UIKit
import SwiftyJSON

/**
 The connect controller is linked to the location handler.
 Nearby users will be gathered from the backend and then stored into a list.
 Swiping right on an user leads to :
 1. Add local id to remote awaiting connections list
 2. If remote connects, add ids to successful connections on each end
 */
class ConnectViewController: UIViewController, UITextViewDelegate {
    
    /** UIViews */
    @IBOutlet weak var loadingProfilesIndicator: UIActivityIndicatorView!
    @IBOutlet weak var labelLoadingProfiles: UILabel!
    
    /** UIView container for user profiles which can be swiped */
    private var swipeableView: UIView?
    
    // Nearby Users Wrapper
    private var nearbyUsers = NearbyUsers(users: [], count: 0)
    private var nearbyUsersIndex = 0 // used to display i-th user in swipeable view
    
    // Likes array
    private var likedBy : [String] = []     // UIDs swiped on current user
    private var likes   : [String] = []     // current user swiped on these UIDs
    
    // View logic
    private var errorOn : Bool = false
    private var firstViewDisplayed = false // has the first view of the swipeable been displayed ?
    private var initialLoading = false
    
    // Internal classes instances
    private var swipeableProcessor = SwipeableViewProcessor()
    
    override func viewDidLoad() {
        
        self.initUI()
        
        // update likes given by user and received likes - 1
        self.getLikes()
        self.getLikedBy()
        self.initialLoading = true
        self.populateNearbyUsers() {
            self.turnOffActivityIndicator()
            self.initSwiper()
            self.initialLoading = false
        }
        
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // update likes given by user and received likes - 2
        self.getLikes()
        self.getLikedBy()
        if (!self.initialLoading) {
            self.populateNearbyUsers() {
                self.turnOffActivityIndicator()
                self.initSwiper()
                self.initialLoading = false
            }
        }
        
        super.viewDidAppear(animated)
        
        
    }
    
    private func initUI() {
        self.labelLoadingProfiles.fadeIn()
        self.loadingProfilesIndicator.startAnimating()
    }
    
    private func turnOffActivityIndicator() {
        self.loadingProfilesIndicator.stopAnimating()
        self.loadingProfilesIndicator.alpha = 0.0
        self.labelLoadingProfiles.alpha = 0.0
    }
    
    // MARK: - Methods
    private func populateNearbyUsers(callback: @escaping () -> Void) {
        
        var noUsersNearby = true // assuming that no users are nearby, and we download nearby users on first run
        let downloadedUsers = NearbyUsers(users: [], count: 0)
        
        // Get nearby users
        self.getUIDsInCity() {
            (list, err) in
            if err == nil {
                // Query user data from backend using the UIDs
                for (index, uid) in list!.enumerated() {
                    if (self.alreadyLiked(UID: uid) == true || uid == Singleton.sharedInstance.CurrentLocalUser!.getUID() || self.alreadyMatched(UID: uid) == true) {
                        continue // if this user has been swiped on or is current user, don't display
                    }
                    else { // not local or swiped user
                        
                        self.errorOn = false
                        noUsersNearby = false
                        
                        Singleton.sharedInstance.HTTPClient?.sendOperationWithToken(operation: "0", input: uid) {
                            (result, status) in
                            if (result != "") {
                                // add user to local list of nearby users -- to prevent duplications
                                downloadedUsers.pushUser(user: User.getUserFromData(data: result))
                                self.nearbyUsers = downloadedUsers
                            }
                            else {
                                print("Error occured while collecting nearby users - get user with uid.")
                            }
                            
                            if (index == (list!.count - 1)) { // loaded all profiles
                                callback()
                            }
                            
                        }
                    }
                }
                
                if (noUsersNearby == true) {
                    
                    self.turnOffActivityIndicator()
                    
                    self.errorOn = true
                    
                    DispatchQueue.main.async {
                        self.swipeableView = getErrorView(error: "No users left in area.")
                        self.view.addSubview(self.swipeableView!)
                    }
                    self.firstViewDisplayed = false // reset the first view initializer check
                }
                
            }
            else {
                print(err!)
                callback()
            }
        }
    }
    
    private func initSwiper() {
        
        if (!self.firstViewDisplayed) { // generate subview (for user 0 in array) and assign
            // download further user data (profile pic, bio, etc)
            self.downloadUserData(user: self.nearbyUsers.getUsers()[0]) {
                
                self.turnOffActivityIndicator()
                
                self.swipeableView = self.swipeableProcessor.getUIView(with: self.nearbyUsers.getUsers()[0], for: self.getSwipeGesture(for: .left), and: self.getSwipeGesture(for: .right))
                self.view.addSubview(self.swipeableView!)
                self.firstViewDisplayed = true // we have initialised the first view of the swipeable
                
            }
        }
        else { // subsequent views
            // Maybe nothing has to be here ? TODO
        }
        
    }
    
    private func alreadyLiked(UID: String) -> Bool {
        return self.likes.contains(UID)
    }
    
    private func alreadyMatched(UID: String) -> Bool {
        return Singleton.sharedInstance.matches!.contains(UID)
    }
    
    // MARK: - Actions
    private func getSwipeGesture(for direction: UISwipeGestureRecognizer.Direction) -> UISwipeGestureRecognizer {
        
        // Init
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        
        // Configure
        swipeGestureRecognizer.direction = direction
        
        return swipeGestureRecognizer
    }
    
    @objc private func didSwipe(_ sender: UISwipeGestureRecognizer) {
        
        if (self.nearbyUsersIndex < self.nearbyUsers.getCount()) {
            
            let screenSize = UIScreen.main.bounds // .width, .height
            
            // Current frame and positions
            var frame = self.swipeableView!.frame
            
            // Check direction of swipe and process accordingly
            switch sender.direction {
            case .left: // skip; false
                
                frame.origin.x -= screenSize.width + 175
                
                self.likes.append(self.nearbyUsers.getUsers()[self.nearbyUsersIndex].getUID()) // add this to the array so false swipes aren't seen twice in the same instance
            
            
            case .right: // like; true
                
                frame.origin.x += screenSize.width + 175
                
                self.likes.append(self.nearbyUsers.getUsers()[self.nearbyUsersIndex].getUID())
                
                // Upload like to server
                Singleton.sharedInstance.HTTPClient!.sendOperationWithToken(operation: "xs", input: self.nearbyUsers.getUsers()[self.nearbyUsersIndex].getUID()) {
                    (result, status) in
                    if (status == 1) {
                        // nothing here at the moment
                    }
                    else {
                        print("An error occured while liking this user.")
                    }
                }
                
            default:
                break
            }
            
            UIView.animate(withDuration: 0.75, delay: 0.0, options: [], animations: {
                self.swipeableView!.frame = frame
            }, completion: {
                (finished: Bool) in
                
                self.nearbyUsersIndex += 1
                
                // if no users left in area, display message
                if (self.nearbyUsersIndex >= self.nearbyUsers.getCount()) { // if no users left, display message
                    
                    if (self.swipeableView != nil) {
                        DispatchQueue.main.async {
                            self.swipeableProcessor.resetUIView(for: self.swipeableView!)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.swipeableView = getErrorView(error: "No users left in area.")
                        self.view.addSubview(self.swipeableView!)
                    }
                    
                    self.firstViewDisplayed = false // reset the first view initializer check
                    self.errorOn = true
                }
                else { // there are users left in area
                    
                    if (self.swipeableView != nil) {
                        DispatchQueue.main.async {
                            self.swipeableProcessor.resetUIView(for: self.swipeableView!)
                        }
                    }
                    
                    self.downloadUserData(user: self.nearbyUsers.getUsers()[self.nearbyUsersIndex]) {
                        self.swipeableView = self.swipeableProcessor.getUIView(with: self.nearbyUsers.getUsers()[self.nearbyUsersIndex], for: self.getSwipeGesture(for: .left), and: self.getSwipeGesture(for: .right))
                        self.view.addSubview(self.swipeableView!)
                    }
                    
                }
            })
            
        }
        
    }
    
    // MARK: - Utils
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
    
    private func downloadUserData(user: User, callback: @escaping () -> Void) {
        
        self.labelLoadingProfiles.alpha = 1.0
        self.loadingProfilesIndicator.alpha = 1.0
        self.loadingProfilesIndicator.startAnimating()
        
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
                            
                            self.turnOffActivityIndicator()
                            callback()
                            
                        }
                        else { // display default user pic
                            let defaultProfileImage: UIImage = UIImage(systemName: "person.fill")!
                            user.setProfilePic(newProfilePic: defaultProfileImage)
                            self.turnOffActivityIndicator()
                            callback()
                        }
                    }
                    else {
                        print("Error occured while downloading profile picture.")
                        let defaultProfileImage: UIImage = UIImage(systemName: "person.fill")!
                        user.setProfilePic(newProfilePic: defaultProfileImage)
                        self.turnOffActivityIndicator()
                        callback()
                    }
                }
            }
            else {
                print("Error occured while downloading user bio")
                self.turnOffActivityIndicator()
                callback()
            }
        }
    }
    
}
