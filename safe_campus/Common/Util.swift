//
//  Util.swift
//  safe_campus
//
//  Created by Bhavya Pathak on 4/2/20.
//  Copyright © 2020 Bhavya Pathak. All rights reserved.
//

import Foundation
import UIKit
import OpenCageSDK
import CoreLocation

class Util {
    
    static func readJSONFile(fileName: String) -> Any?
    {
        var json: Any?
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                let fileUrl = URL(fileURLWithPath: path)
                // Getting data from JSON file using the file URL
                let data = try Data(contentsOf: fileUrl, options: .mappedIfSafe)
                json = try? JSONSerialization.jsonObject(with: data)
            } catch {
                // Handle error here
                print("Unable to read JSON data from file \(fileName)")
            }
        }
        return json
    }
    
    static func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    static func getZipForLocation(location: CLLocation?, handleResult: @escaping (String?) -> Void) {
        if let lastLocation = location {
            let geocoder = CLGeocoder()
                
            // Look up the location and pass it to the completion handler
            if(location != nil) {
                geocoder.reverseGeocodeLocation(lastLocation, completionHandler: { (placemarks, error) in
                    if error == nil {
                        let zip = placemarks?[0].postalCode;
                        let street = placemarks?[0].locality;
                        var location = SCLocation(lat: location!.coordinate.latitude, long: location!.coordinate.longitude, street: street!, zip: zip!)
                        handleResult(zip)
                    }
                    else {
                     // An error occurred during geocoding.
                        handleResult(nil)
                    }
                })
            }
        }
        else {
            // No location was available.
            handleResult(nil)
        }
    }
    
    static func getPlaceFromLocation(location: SCLocation?, handleResult: @escaping (SCLocation) -> Void) {
        if let lastLocation = location?.location {
            let geocoder = CLGeocoder()
                
            // Look up the location and pass it to the completion handler
            if(location != nil) {
                geocoder.reverseGeocodeLocation(lastLocation, completionHandler: { (placemarks, error) in
                    if error == nil {
                        let zip = placemarks?[0].postalCode;
                        let street = placemarks?[0].locality;
                        location!.zipCode = zip!;
                        location!.street = street!;
                        handleResult(location!)
                    }
                    else {
                     // An error occurred during geocoding.
                        handleResult(location!)
                    }
                })
            }
        }
        else {
            // No location was available.
            handleResult(location!)
        }
    }
    
    static func getIncidentImage(code: String) -> (image: UIImage, color: UIColor) {
        var image: UIImage
        var color: UIColor
        switch code {
            case "Drug Violation":
                image = Util.resizeImage(image: UIImage(named: "bong")!, targetSize: CGSize(width: 25, height: 25))
                color = UIColor(rgb: 0xd32f2f)
            case "Vandalism":
                image = Util.resizeImage(image: UIImage(named: "fight")!, targetSize: CGSize(width: 25, height: 25))
                color = UIColor(rgb: 0x004d40)
            case "Aggravated Assault", "Simple Assault":
                image = Util.resizeImage(image: UIImage(named: "knife")!, targetSize: CGSize(width: 25, height: 25))
                color = UIColor(rgb: 0x1a237e)
            case "Firearm Violations":
                image = Util.resizeImage(image: UIImage(named: "gun")!, targetSize: CGSize(width: 25, height: 25))
                color = UIColor(rgb: 0x3e2723)
            case "Auto Theft":
                image = Util.resizeImage(image: UIImage(named: "autoTheft")!, targetSize: CGSize(width: 25, height: 25))
                color = UIColor(rgb: 0x757575)
            case "Robbery", "Residential Burglary":
                image = Util.resizeImage(image: UIImage(named: "mask")!, targetSize: CGSize(width: 25, height: 25))
                color = UIColor(rgb: 0xff7043)
            default:
                image = Util.resizeImage(image: UIImage(named: "police")!, targetSize: CGSize(width: 25, height: 25))
                color = .black
        }
        return (image: image, color: color)
    }
    
    static func getTimestamp(dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
        let date = dateFormatter.date(from: dateString)!
        //var dateStamp:TimeInterval = date!.timeIntervalSince1970
        return date
    }
    
    static func dateToString (date: Date) -> String {
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: date)
        return dateString
    }
    
    static func filterZip(zip: String) -> String {
        print("Zip-\(zip)")
        let result = zip.filter("01234567890-.".contains)
        let items = result.split(separator: "-")
        print("\(items.first!)")
        return String(items.first!)
    }
    
}

//Use hex values for UIColour
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
