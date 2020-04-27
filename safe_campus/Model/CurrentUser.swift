//
//  CurrentUser.swift
//  safe_campus
//
//  Created by Bhavya Pathak on 4/14/20.
//  Copyright © 2020 Bhavya Pathak. All rights reserved.
//

import Foundation

class CurrentUser {
    
    static let shared = CurrentUser()
    private var currentLocation: SCLocation?
    var displayName: String?
    var uid: String?
    var isAdmin: Bool
    
    private init() {
        isAdmin = false
    }
    
    func setLocation(location: SCLocation) {
        self.currentLocation = location
    }
    
    func getLocation() -> SCLocation {
        return self.currentLocation!
    }

}
