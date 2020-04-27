//
//  DbUtil.swift
//  safe_campus
//
//  Created by Bhavya Pathak on 4/7/20.
//  Copyright © 2020 Bhavya Pathak. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage

enum SCError: Error {
    case parseError(String)
}

class DbUtil {
    static var ref: DatabaseReference!
    static var storageRef: StorageReference!
    
    init (){
        DbUtil.ref = Database.database().reference()
        DbUtil.storageRef = Storage.storage().reference()
    }
    
    static func updateIncidentData (incident: SCIncident){
        print("\(incident.location.zipCode) \(incident.uId)");
        let updatedIncident = incident.getDictionaryValuesForUpdate(updatedValues: incident); ref.child("incidentMasterData").child(incident.location.zipCode).child(incident.uId!).setValue(updatedIncident) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Data could not be saved: \(error).")
            } else {
                print("Data saved successfully!")
            }
        }
    }

    
    static func getDataByZip (zipCode: String, result: @escaping ([SCIncident]) -> Void) {
        var incidents: [SCIncident] = []
        
        ref.child("incidentMasterData").child(zipCode).observe(DataEventType.value, with: { (snapshot) in
            // Get user value
            guard let data = snapshot.value as? [String: Any] else { return }
            for (key, value) in data {
                if var dict = value as? [String: Any] {
                    if let date = dict["OCCURRED_ON_DATE"] {

                        let dateFormatterGet = DateFormatter()
                        dateFormatterGet.dateFormat = "MM/dd/yyyy HH:mm"

                        let dateFormatterPrint = DateFormatter()
                        dateFormatterPrint.dateFormat = "MM/dd/yyyy"
                        
                        let dateString = String(describing: date)

                        if let dateS = dateFormatterGet.date(from: dateString) {
//                            print(dateFormatterPrint.string(from: dateS))
                            let formatter = DateFormatter()
                            formatter.dateFormat = "MM/dd/yyyy"
                            let someDateTime = formatter.date(from: "01/01/2018")!
                            
//                            print(someDateTime)
//                            print(dateS)
                            
                            if dateS.compare(someDateTime) == .orderedDescending {
//                                print("--------------------- \(dateS)")
                                dict["UID"] = key
                                let incident = SCIncident(dict: dict)
                                IncidentList.shared.addIncident(incident: incident)
                                incidents.append(incident)
                            }
                        } else {
                           print("There was an error decoding the string")
                        }
                    }
//                    if(Int?(date.year!) >= Int?(dateOcc.year!)) {
                        
//                    }
                }
            }
            result(incidents)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    

    static func saveIncident(incident: SCIncident){
           ref.child("incidentMasterData").observeSingleEvent(of: .value, with: {(snapshot) in
            if(snapshot.hasChild(incident.location.zipCode)){
                ref.child("incidentMasterData").child(incident.location.zipCode).childByAutoId().setValue(incident.dict)
            } else {
                ref.child("incidentMasterData/\(incident.location.zipCode)").childByAutoId().setValue(incident.dict)
            }
           });
        
    }
    
    static func uploadAttachments(images: [UIImage], videos: [NSURL], incident: SCIncident, result: @escaping (URL) -> Void, done: @escaping (Bool) -> Void){
        var count = 0
        for (index,image) in images.enumerated() {
            let imgData = image.pngData()!
            let metaData = StorageMetadata()
            metaData.contentType = "image/png"
            let imageRef = DbUtil.storageRef.child("images/\(incident.id)_\(index)")
            imageRef.putData(imgData, metadata: metaData, completion:     {(metadata, error) in
                if (error != nil){
                    print("could not upload")
                } else {
                    imageRef.downloadURL(completion: { (url, error) in
                        guard url != nil else {
                            print(error!)
                            done(false)
                            return
                        }
                        
                        result(url!)
                        count += 1
                        if(count >= images.count){
                            done(true)
                        }
                    })
                }
            })
            
        }
        
    }
    
    static func downloadMedia(imageURL: [String], completed: @escaping ([UIImage])->Void){
        let storage = Storage.storage()
        var images:[UIImage] = [UIImage]()
        for url in imageURL {
            let ref = storage.reference(forURL: url);
            ref.getData(maxSize: 100 * 1024 * 1024) { (data, error) in
                if error != nil {
                    return
                }
                guard let image = UIImage(data: data!) else {
                    return
                }
                images.append(image)
                if(images.count >= imageURL.count){
                    completed(images)
                }
                
            }
        }
    }
    
}
