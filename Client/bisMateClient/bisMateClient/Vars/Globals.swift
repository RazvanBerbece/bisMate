//
//  Globals.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 17/07/2021.
//

import Foundation
import UIKit
import FirebaseAuth

class Singleton {
    
    // Required for global behaviour
    static let sharedInstance = Singleton()
    
    // Web client session
    var HTTPClient: RestClient?
    
    // User data
    var CurrentFirebaseUser: FirebaseAuth.User? // FirebaseAuth User object
    var CurrentLocalUser: bisMateClient.User? // local bisMate User object
    var currentCity: String? // subscribed to through delegate method, updates constantly on didUpdateLocations
    var matches: [String]? // subscribed to, updates constantly with the user matches
    
}
