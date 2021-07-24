//
//  UserDashboardViewController.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 23/01/2021.
//

import UIKit
import FirebaseAuth
import CoreLocation

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
    
    // Indicators
    @IBOutlet weak var bioIndicator: UIActivityIndicatorView!
    
    
    // User data
    var fbUser: FirebaseAuth.User? // received from Firebase, will be translated to local User design
    var CurrentUser = User(UID: "def", email: "def", displayName: "def", phoneNumber: "def", photoURL: "def", emailVerified: false, token: "def")
    
    // Location
    var updatedLocation = false // toggles to true after updating location through backend
    var locationManager = CLLocationManager()
    var locationHandler : LocationHandler? // reverse geocoding logic wrapper
    
    // Gestures
    var tap: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        
        // UI components inits
        self.bioIndicator.startAnimating()
        
        // initialisers
        self.initLocationManager()
        self.getToken() {
            (token) in
            if (token != "") {
                
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
        
        // gesture init -- tap
        let tapRec = UITapGestureRecognizer(target: self, action: #selector(self.performSegueBioEdit(_:)))
        self.textViewBio.addGestureRecognizer(tapRec)
        
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
                        // print(result)
                        
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
        // Executes downloadConnections every second
        // Updates UI if the connections list has changed
        Singleton.sharedInstance.timer = Timer.scheduledTimer(timeInterval: 1.00, target: self, selector: #selector(self.downloadConnections), userInfo: nil, repeats: true)
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
                                // display connection popup using result["Data"]["DisplayName"], result["Data"]["PhotoURL"] etc
                                let user = User.getUserFromData(data: result)
                                Singleton.sharedInstance.HTTPClient?.sendOperationWithToken(operation: "ubg", input: user.getUID()) {
                                    (result, errStatus) in
                                    if (result != "") {
                                        user.setBio(newBio: result["Data"].stringValue)
                                        ConnectionPopup.shared.showConnectionPopup(user: user)
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
    
    // MARK: - Tap Logic (Segues to profile modifiers)
    @objc private func performSegueBioEdit(_ sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "bioEditSegue", sender: self)
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
