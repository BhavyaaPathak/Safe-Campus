//
//  Incident.swift
//  safe_campus
//
//  Created by Bhavya Pathak on 4/8/20.
//  Copyright © 2020 Bhavya Pathak. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase

class SCIncident {
    var uId: String?
    var id: String
    var location: SCLocation
    var dateTime: Date
    var offenceCode: String
    var offenceCodeGroup: String
    var offenceDescription: String
    var status: String
    var verified: Int
    var imagesURL: String
    var reportersId: String?
    lazy var images: [URL] = [URL]()
    lazy var videos: [URL] = [URL]()
    
    func  getImagesURL() -> String {
        var value = ""
        for url in images {
            value += "\(url.absoluteString),"
        }
        return value.isEmpty ? value : String(value.dropLast())
    }
    
    var dict: [String: Any]{
        return [
            "ID": id,
            "LAT": String(location.location.coordinate.latitude),
            "LOCATION":"(\(location.location.coordinate.latitude),\(location.location.coordinate.longitude))",
            "LONG":String(location.location.coordinate.longitude),
            "OCCURRED_ON_DATE": dateTime.toString(dateFormat: "MM/dd/yyyy HH:mm"),
            "OFFENSE_CODE": offenceCode,
            "OFFENSE_CODE_GROUP": offenceCodeGroup,
            "OFFENSE_DESCRIPTION": offenceDescription,
            "STATUS": status,
            "STREET": location.street,
            "VERIFIED": 0,
            "ZIP_CODE": location.zipCode,
            "IMAGES": getImagesURL(),
            "REPORTER_ID": reportersId!
        ]
    }
    
    //    init (lat: Double, long: Double, time: String, offenceCode: String, grp: String, desc: String, street: String, id: String, zip: String) {
    //        self.location = SCLocation(lat: lat, long: long, street: street, zip: zip)
    //        self.timestamp = Util.getTimestamp(dateString: time)
    //        self.offenceCode = offenceCode
    //        self.offenceCodeGroup = grp
    //        self.offenceDescription = desc
    //        self.id = id
    //    }
    
    init(id: String, location: SCLocation,offenceCode: String,offenceCodeGroup: String,offenceDescription: String,reportersId: String) {
        self.id = id
        self.dateTime = Date()
        self.location = location
        self.offenceCode = offenceCode
        self.offenceCodeGroup = offenceCodeGroup
        self.offenceDescription = offenceDescription
        self.status = "ACTIVE"
        self.verified = 0
        self.imagesURL = ""
        self.reportersId = reportersId
    }
    
    init(dict: [String: Any]) {
        print(dict["UID"] as? String)
        let latitutde = dict["LAT"] as? String
        let longitude = dict["LONG"] as? String
        let street = dict["STREET"] as? String
        let zipCode = dict["ZIP_CODE"] as? String
        
        self.location = SCLocation(lat: Double(latitutde!)!, long: Double(longitude!)!, street: street!, zip: zipCode!)
        let date = (dict["OCCURRED_ON_DATE"] as? String)!
        self.dateTime = Util.getTimestamp(dateString: date)
        self.offenceCode = (dict["OFFENSE_CODE"] as? String)!
        self.offenceCodeGroup = (dict["OFFENSE_CODE_GROUP"] as? String)!
        self.offenceDescription = (dict["OFFENSE_DESCRIPTION"] as? String)!
        self.id = (dict["ID"] as? String)!
        self.status = (dict["STATUS"] as? String)!
        self.verified = (dict["VERIFIED"] as? Int)!
        self.uId = (dict["UID"] as? String)!
        self.imagesURL = dict.keys.contains("IMAGES") ? (dict["IMAGES"] as? String)! : ""
        if (dict["REPORTER_ID"] != nil) {
            self.reportersId = (dict["REPORTER_ID"] as? String)!
        } else {
            self.reportersId = nil
        }
    }
    
    func getDictionaryValuesForUpdate(updatedValues: SCIncident) -> [String: Any] {
        return [
            "LAT": String(updatedValues.location.location.coordinate.latitude),
            "LONG": String(updatedValues.location.location.coordinate.longitude),
            "STREET": updatedValues.location.street,
            "ZIP_CODE": updatedValues.location.zipCode,
            "OCCURRED_ON_DATE": updatedValues.dateTime.toString(dateFormat: "MM/dd/yyyy HH:mm"),
            "OFFENSE_CODE": updatedValues.offenceCode,
            "OFFENSE_CODE_GROUP": updatedValues.offenceCodeGroup,
            "OFFENSE_DESCRIPTION": updatedValues.offenceDescription,
            "ID": updatedValues.id,
            "STATUS": updatedValues.status,
            "VERIFIED": updatedValues.verified,
            "IMAGES": updatedValues.getImagesURL()
        ]
    }
    
    func toNotify() -> Bool {
        //TODO check with current time and distance weather to notify
        let earlyDate = Calendar.current.date(
            byAdding: .hour,
            value: -1,
            to: Date())
        
        if ((self.dateTime > earlyDate!)) {
            print("Notify")
            return true;
        }
        
        return false
    }
    
    func resolveIncidentStatus () -> String {
        switch self.status {
        case "IN_ACTIVE":
            return "Safe"
        case "ACTIVE":
            return "Ongoing"
        default:
            return "Safe"
        }
    }
    
    func isInThisWeek () -> Bool {
        let earlyDate = Calendar.current.date(
            byAdding: .day,
            value: -7,
            to: Date())
        
        if ((self.dateTime > earlyDate!)) {
            return true
        }
        
        return false
    }
}

extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
}
