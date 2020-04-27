//
//  Location.swift
//  safe_campus
//
//  Created by Bhavya Pathak on 4/13/20.
//  Copyright © 2020 Bhavya Pathak. All rights reserved.
//

import Foundation
import CoreLocation

class SCLocation {
    var location: CLLocation
    var street: String
    var zipCode: String
    
    init(lat: Double, long: Double, street: String, zip: String) {
        self.street = street
        self.zipCode = zip
        self.location = CLLocation(latitude: lat, longitude: long)
    }
    
    init(location: CLLocation, street: String, zip: String) {
        self.street = street
        self.zipCode = zip
        self.location = location
    }
}
