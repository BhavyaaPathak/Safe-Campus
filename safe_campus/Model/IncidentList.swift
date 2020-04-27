//
//  IncidentList.swift
//  safe_campus
//
//  Created by Bhavya Pathak on 4/14/20.
//  Copyright © 2020 Bhavya Pathak. All rights reserved.
//

import Foundation

class IncidentList {
    
    static let shared = IncidentList()
    private var list: [String: [SCIncident]]
    
    private init() {
        print("Called")
        list = [String: [SCIncident]]()
    }
    
    func addIncidents(incidents: [SCIncident]) {
        for i in incidents {
            if var l = list[i.location.zipCode] {
                if (!l.contains(where: {$0.id == i.id})) {
                    l.append(i)
                }
            } else {
                list[i.location.zipCode] = [SCIncident]()
                list[i.location.zipCode]?.append(i)
            }
        }
    }
    
    func addIncident(incident: SCIncident) {
        let keyExists = list[incident.location.zipCode] != nil
        if keyExists {
            if (!list[incident.location.zipCode]!.contains(where: {$0.id == incident.id})) {
                list[incident.location.zipCode]!.append(incident)
            }
        } else {
            list[incident.location.zipCode] = [SCIncident]()
            list[incident.location.zipCode]?.append(incident)
        }
    }
    
    func getIncidentByZip(zip: String) -> [SCIncident]? {
        if let l = list[zip] {
            return l
        }
        return nil
    }
}
