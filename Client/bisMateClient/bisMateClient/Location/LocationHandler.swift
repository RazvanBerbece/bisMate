//
//  LocationHandler.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 14/02/2021.
//

import Foundation
import CoreLocation

// Processes the coordinates of the user
public class LocationHandler {
    
    private let longitude   : Double?
    private let latitude    : Double?
    
    init(longitude: Double, latitude: Double) {
        self.longitude = longitude
        self.latitude = latitude
    }
    
    /** Returns a string of the city linked to the instance coordinates */
    public func getCityNameFromCoords(completion: @escaping (CLPlacemark?, String?) -> (Void)) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(CLLocation(latitude: self.latitude!, longitude: self.longitude!)) {
            (placemarks, error) in
            if let err = error {
                completion(nil, err.localizedDescription)
            }
            else if let placemarkArray = placemarks {
                if let placemark = placemarkArray.first {
                    completion(placemark, nil)
                }
                else {
                    completion(nil, "LocationHandler err : Nil placemark")
                }
            }
            else {
                completion(nil, "Unknown error")
            }
        }
    }
    
}
