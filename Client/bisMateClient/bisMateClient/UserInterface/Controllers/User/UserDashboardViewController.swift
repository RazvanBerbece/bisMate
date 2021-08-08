//
//  UserDashboardViewController.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 23/01/2021.
//

import UIKit
import FirebaseAuth
import CoreLocation
import SwiftyJSON

/**
 User dashboard will also send location data on each viewDidLoad() which will be stored in the DB.
 */
class UserDashboardViewController: UIViewController, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    
    // UI Components
    
    // Labels
    @IBOutlet weak var labelGreet: UILabel!
    @IBOutlet weak var labelLoading: UILabel!
    
    // Text Views
    @IBOutlet weak var textViewBio: UITextView!
    
    // Image Views
    @IBOutlet weak var imageViewProfilePic: UIImageView!
    
    // Indicators
    @IBOutlet weak var bioIndicator: UIActivityIndicatorView!
    
    // Delegates
    var imagePicker: ImagePicker?
    
    // User data
    var fbUser: FirebaseAuth.User? // received from Firebase, will be translated to local User design
    var CurrentUser = User(UID: "def", email: "def", displayName: "def", phoneNumber: "def", photoURL: "def", emailVerified: false, token: "def")
    
    // Location
    var updatedLocation = false // toggles to true after updating location through backend
    var locationManager = CLLocationManager()
    var locationHandler : LocationHandler? // reverse geocoding logic wrapper
    
    override func viewDidLoad() {
        
        // UI components inits
        self.bioIndicator.startAnimating()
        
        // initialisers
        self.initLocationManager()
        self.getToken() {
            (token) in
            if (token != "") {
                
                // location update
                self.updateLocation()
                
                Singleton.sharedInstance.CurrentLocalUser!.setToken(newToken: token)
                Singleton.sharedInstance.HTTPClient = RestClient(token: token)
                
                self.loadProfile() // initial profile load
                
                // get current connections
                Singleton.sharedInstance.matches = []
                self.initConnectionList() // might not be useful actually
                
                // subscribe
                self.subscribeToConnections()

            }
            else {
                self.dismiss(animated: false, completion: nil)
            }
        }
        
        super.viewDidLoad()
        
        // gesture init -- tap bio
        let tapRecBio = UITapGestureRecognizer(target: self, action: #selector(self.performSegueBioEdit(_:)))
        self.textViewBio.addGestureRecognizer(tapRecBio)
        
        let tapRecPic = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        self.imageViewProfilePic.isUserInteractionEnabled = true
        self.imageViewProfilePic.addGestureRecognizer(tapRecPic)
        
        // image picker init
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (self.CurrentUser.getUID() != "def") { // reload
            self.loadProfile()
        }
    }
    
    // MARK: - Methods
    private func loadProfile() {
        
        // updates view with current user data
        
        // init default model
        Singleton.sharedInstance.CurrentLocalUser?.setProfilePic(newProfilePic: UIImage(systemName: "person.fill")!)
        
        // greeting
        self.labelGreet.text = "\(String(describing: Singleton.sharedInstance.CurrentLocalUser!.getDisplayName()))"
        
        // get user bio
        Singleton.sharedInstance.HTTPClient?.sendOperationWithToken(operation: "ubg", input: Singleton.sharedInstance.CurrentLocalUser!.getUID()) {
            (result, errCheck) in
            if result != "" {
                // print(result)
                // set textView
                DispatchQueue.main.async {
                    
                    self.bioIndicator.stopAnimating()
                    self.bioIndicator.isHidden = true
                    self.labelLoading.isHidden = true
                    
                    // update user model
                    Singleton.sharedInstance.CurrentLocalUser?.setBio(newBio: result["Data"].stringValue != "" ? result["Data"].stringValue : "Click on this field to change your bio !")
                    
                    self.textViewBio.text = Singleton.sharedInstance.CurrentLocalUser?.getBio()
                }
            }
            else {
                // err handling
                print("Error occured while getting user bio from server.")
                
                // TODO - handle get bio error
                self.textViewBio.text = "null" // temporary
                
            }
        }
        
        // get profile pic
        Singleton.sharedInstance.HTTPClient?.sendOperationWithToken(operation: "ppg", input: Singleton.sharedInstance.CurrentLocalUser!.getUID()) {
            (result, errStatus) in
            if (errStatus == 0) {
                print("Error occured while downloading profile picture")
            }
            else {
                self.processDownloadedLocalProfileImage(result: result)
            }
        }
        
        
    }
    
    private func getToken(completion: @escaping (String) -> Void) {
        self.CurrentUser = Singleton.sharedInstance.CurrentLocalUser!
        // called immediately on render to get user token
        Singleton.sharedInstance.CurrentFirebaseUser!.getIDTokenForcingRefresh(true) {
            // get token that can be used for backend ops
            (idToken, err) in
            if let error = err {
                print("token err: \(String(describing: error))")
                completion("")
            }
            completion(idToken!)
        }
    }
    
    private func initLocationManager() {
        // initialises location manager variables
        self.locationManager.requestAlwaysAuthorization() // ask suer authorisation
        self.locationManager.requestWhenInUseAuthorization() // foreground use
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    private func startGeocoder() {
        // calls the location handler function to reverse geocode user location and get city name
        self.locationHandler!.getCityNameFromCoords() {
            (placemark, err) in
            if err != nil {
                // failed reverse geocoding
                print("Error occured while getting user city name.")
            }
            else {
                // success -- save current UID to backend
                let cityName = placemark!.locality!
                Singleton.sharedInstance.currentCity = cityName
                Singleton.sharedInstance.HTTPClient?.sendOperationWithToken(operation: "ws", input: cityName) {
                    (result, errCheck) in
                    if result != "" {
                        // successful upload
                        // delete previous location - TODO
                    }
                    else {
                        // err handling
                        print("Error occured while sending location data to server.")
                    }
                }
            }
        }
    }
    
    // MARK: - Delegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        // print("locations = \(locValue.latitude) \(locValue.longitude)")
        self.locationHandler = LocationHandler(longitude: locValue.longitude, latitude: locValue.latitude)
        // get user city name
        if (!self.updatedLocation) {
            self.startGeocoder()
        }
        self.updatedLocation = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? BioEditController {
            destinationVC.delegate = self
        }
    }
    
    // MARK: - Connection Updater Method (This SHOULD be reworked)
    private func subscribeToConnections() {
        // Executes downloadConnections every 2.5 seconds in background thread
        // Updates UI if the connections list has changed
        Singleton.sharedInstance.timer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { (_) in
            DispatchQueue.global(qos: .background).async { // in background thread
                self.downloadConnections()
                DispatchQueue.main.async { // in main thread
                    // NOTHING HERE, BUT UI WOULD GET UPDATED HERE
                }
            }
        }
    }
    
    @objc private func downloadConnections() {
        Singleton.sharedInstance.HTTPClient!.sendOperationWithToken(operation: "xxy", input: Singleton.sharedInstance.CurrentLocalUser!.getUID()) {
            (result, status) in
            if (status == 0) {
                print("An error occured while downloading matches list")
            }
            else {
                var uids : [String] = []
                for (_, uidtuple) in result["Data"].enumerated() {
                    uids.append(uidtuple.1.stringValue)
                }
                
                // check if there are new connections
                for uid in uids {
                    
                    if (Singleton.sharedInstance.matches!.contains(uid) == false) {
                        // new connection found, update match popup status and display in controllers
                        Singleton.sharedInstance.HTTPClient!.sendOperationWithToken(operation: "0", input: uid) {
                            (result, status) in
                            if (status == 0) {
                                print("An error occured while downloading connection data.")
                            }
                            else {
                                // display connection popup using result["Data"]["DisplayName"], etc
                                let user = User.getUserFromData(data: result)
                                Singleton.sharedInstance.HTTPClient?.sendOperationWithToken(operation: "ubg", input: user.getUID()) {
                                    (resultBio, errStatusBio) in
                                    if (result != "") {
                                        
                                        user.setBio(newBio: resultBio["Data"].stringValue)
                                        
                                        Singleton.sharedInstance.HTTPClient?.sendOperationWithToken(operation: "ppg", input: user.getUID()) {
                                            (resultProfilePic, errStatusProfilePic) in
                                            self.processDownloadedPopupProfileImage(result: resultProfilePic, user: user)
                                            ConnectionPopup.shared.showConnectionPopup(user: user)
                                        }
                                        
                                    }
                                    else {
                                        print("Error occured while downloading user bio")
                                    }
                                }
                            }
                        }
                    }
                    
                }
                
                // update local connections array
                Singleton.sharedInstance.matches! = uids
                
            }
        }
    }
    
    private func initConnectionList() {
        Singleton.sharedInstance.HTTPClient!.sendOperationWithToken(operation: "xxy", input: Singleton.sharedInstance.CurrentLocalUser!.getUID()) {
            (result, status) in
            if (status == 0) {
                print("An error occured while downloading matches list")
            }
            else {
                var uids : [String] = []
                for (_, uidtuple) in result["Data"].enumerated() {
                    uids.append(uidtuple.1.stringValue)
                }
                
                // update local connections array
                Singleton.sharedInstance.matches! = uids
            }
        }
    }
    
    // MARK: - Tap Logic
    
    // Segues to profile modifiers
    @objc private func performSegueBioEdit(_ sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "bioEditSegue", sender: self)
    }
    
    // MARK: - Actions
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        // let tappedImage = tapGestureRecognizer.view as! UIImageView
        // present picker view
        self.imagePicker!.present(from: self.view)
    }
    
    // MARK: - Utils
    private func imageContextSet() {
        // Profile pic context
        let itemSize = CGSize.init(width: 55, height: 55)
        UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale);
        let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
        self.imageViewProfilePic?.image!.draw(in: imageRect)
        self.imageViewProfilePic?.image! = UIGraphicsGetImageFromCurrentImageContext()!;
        self.imageViewProfilePic?.layer.cornerRadius = self.imageViewProfilePic!.frame.height / 2
        UIGraphicsEndImageContext();
    }
    
    private func updateLocation() {
        guard let locValue: CLLocationCoordinate2D = self.locationManager.location?.coordinate else { return }
        self.locationHandler = LocationHandler(longitude: locValue.longitude, latitude: locValue.latitude)
        if (!self.updatedLocation) {
            self.startGeocoder()
        }
        self.updatedLocation = true
    }
    
    private func processDownloadedLocalProfileImage(result: JSON) {
        if (result != "") {
            if (result["Data"] != "") { // decode base64 and display image
                DispatchQueue.main.async {
                    
                    let fixedBase64 = result["Data"].stringValue.fixedBase64Format
                    let dataDecoded = Data.init(base64Encoded: fixedBase64, options: .ignoreUnknownCharacters)
                    let decodedImage = UIImage(data: dataDecoded!)
                    
                    self.imageViewProfilePic.maskCircleWithShadow(anyImage: decodedImage!)
                    self.imageContextSet()
                    
                    Singleton.sharedInstance.CurrentLocalUser?.setProfilePic(newProfilePic: decodedImage!)
                }
            }
            else { // display default user pic
                let defaultProfileImage: UIImage = UIImage(systemName: "person.fill")!
                self.imageViewProfilePic.maskCircleWithShadow(anyImage: defaultProfileImage)
                self.imageContextSet()
                Singleton.sharedInstance.CurrentLocalUser?.setProfilePic(newProfilePic: defaultProfileImage)
            }
        }
        else {
            print("Error occured while downloading profile picture.")
            let defaultProfileImage: UIImage = UIImage(systemName: "person.fill")!
            self.imageViewProfilePic.maskCircleWithShadow(anyImage: defaultProfileImage)
            self.imageContextSet()
            Singleton.sharedInstance.CurrentLocalUser?.setProfilePic(newProfilePic: defaultProfileImage)
        }
    }
    
    private func processDownloadedPopupProfileImage(result: JSON, user: User) {
        // to keep in mind, Swift functions are pass by reference
        if (result != "") {
            if (result["Data"] != "") { // decode base64 and display image
                
                let fixedBase64 = result["Data"].stringValue.fixedBase64Format
                let dataDecoded = Data.init(base64Encoded: fixedBase64, options: .ignoreUnknownCharacters)
                let decodedImage = UIImage(data: dataDecoded!)
                
                user.setProfilePic(newProfilePic: decodedImage!)
                
            }
            else { // display default user pic
                let defaultProfileImage: UIImage = UIImage(systemName: "person.fill")!
                user.setProfilePic(newProfilePic: defaultProfileImage)
            }
        }
        else {
            print("Error occured while downloading profile picture.")
            let defaultProfileImage: UIImage = UIImage(systemName: "person.fill")!
            user.setProfilePic(newProfilePic: defaultProfileImage)
        }
    }
    
}

// MARK: - Extensions
extension UserDashboardViewController: BioEditControllerDelegate {
    func popoverDidDismiss() {
        
        self.textViewBio.text = ""
        self.bioIndicator.startAnimating()
        self.bioIndicator.isHidden = false
        self.labelLoading.isHidden = false
        
        self.loadProfile()
        
    }
}

extension UserDashboardViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        if let pickedImg = image {
            
            self.imageViewProfilePic.image = pickedImg
            
            // upload picture to database here
            let imageData: Data = pickedImg.jpegData(compressionQuality: 1)!
            let imageBase64Str = imageData.base64EncodedString(options: .lineLength64Characters)
            
            // Run image upload in background
            DispatchQueue.background(delay: 0.0, background: { // in background thread
                Singleton.sharedInstance.HTTPClient?.sendOperationWithToken(operation: "pps", input: imageBase64Str) {
                    (result, errStatus) in
                    if (result != "") {
                        print("Profile picture uploaded successfully")
                    }
                    else {
                        print("An error occured while uploading your profile picture")
                    }
                }
            }, completion: {
                // when background job finishes, wait <delay> seconds and do something in main thread
            })
            
        }
        else {
            // DON'T DO ANYTHING
        }
    }
}
