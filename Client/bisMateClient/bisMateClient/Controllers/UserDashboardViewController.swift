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
class UserDashboardViewController: UIViewController, CLLocationManagerDelegate {
    
    // UI Components
    // Labels
    @IBOutlet weak var labelGreet: UILabel!
    
    // User data
    var fbUser: FirebaseAuth.User? // received from Firebase, will be translated to local User design
    var CurrentUser = User(UID: "def", email: "def", displayName: "def", phoneNumber: "def", photoURL: "def", emailVerified: false, token: "def")
    
    // Location
    var updatedLocation = false // toggles to true after updating location through backend
    var locationManager = CLLocationManager()
    var locationHandler : LocationHandler? // reverse geocoding logic wrapper
    
    override func viewDidLoad() {
        
        // initialisers
        self.initLocationManager()
        self.getToken() {
            (token) in
            if (token != "") {
                self.loadProfile()
                Singleton.sharedInstance.CurrentLocalUser!.setToken(newToken: token)
                Singleton.sharedInstance.HTTPClient = RestClient(token: token)
            }
            else {
                self.dismiss(animated: false, completion: nil)
            }
        }
        
        super.viewDidLoad()
        
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
        self.labelGreet.text = "Hello, \(String(describing: Singleton.sharedInstance.CurrentLocalUser!.getDisplayName())) !"
    }
    
    @IBAction private func signOut() {
        // revoke token -- TODO
        // signs user out (dismiss segue)
        dismiss(animated: true, completion: nil)
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
    
}
