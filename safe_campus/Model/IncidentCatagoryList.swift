//
//  IncidentCatagoryList.swift
//  safe_campus
//
//  Created by Bhavya Pathak on 4/22/20.
//  Copyright © 2020 Bhavya Pathak. All rights reserved.
//

import Foundation

class IncidentCatagoryList {
    
    static let list = [
        "None",
        "Manslaughter",
        "Robbery",
        "Residential Burglary",
        "Aggravated Assault",
        "Other Burglary",
        "Auto Theft",
        "Simple Assault",
        "Vandalism",
        "Firearm Violations",
        "Prostitution",
        "Drug Violation",
        "Operating Under the Influence",
        "Disorderly Conduct",
        "Explosives",
        "Harassment",
        "Criminal Harassment",
        "Property Related Damage",
        "Fire Related Reports",
        "Firearm Discovery",
    ]
    
    static func getIncidentTypeImages(type: String) -> String {
        switch type {
        case "Robbery", "Residential Burglary", "Other Burglary":
            return "robbery"
        case "Manslaughter", "Aggravated Assault", "Simple Assault", "Explosives":
            return "attackColor"
        case "Vandalism", "Disorderly Conduct", "Harassment", "Criminal Harassment":
            return "vandalism"
        case "Auto Theft":
            return "carTheftColor"
        case "Fire Related Reports":
            return "fireColour"
        case "Firearm Discovery", "Firearm Violations":
            return "gunColor"
        case "Operating Under the Influence":
            return "wineColor"
        default:
           return "policeColor"
        }
    }
}
