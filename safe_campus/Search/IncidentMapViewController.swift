//
//  IncidentMapViewController.swift
//  safe_campus
//
//  Created by Bhavya Pathak on 4/19/20.
//  Copyright © 2020 Bhavya Pathak. All rights reserved.
//

import UIKit
import MapKit

class IncidentMapViewController: UIViewController {
    
    var incidentList = [SCIncident]()
    
    @IBOutlet weak var noIncidentLbl: UILabel!
    var mapView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Map View";
        
        if (self.incidentList.count > 0) {
            loadMapView()
        } else {
            noIncidentLbl.isHidden = false
        }
    }
    
    func loadMapView() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let mapViewController = (storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController)
        addChild(mapViewController)
        self.mapView = mapViewController.view
        view.addSubview(self.mapView)
        mapViewController.location = self.incidentList[0].location
        // Notify Child View Controller
        mapViewController.didMove(toParent: self)
        //Mark Incidents on the map
//        for i in self.incidentList {
//            if(i.status == "ACTIVE") {
//                mapViewController.placeMarker(incident: i);
//            }
//        }
        for i in self.incidentList {
            mapViewController.placeMarker(incident: i);
        }
        
        
        let initialLocation = CLLocation(latitude: self.incidentList[0].location.location.coordinate.latitude, longitude: self.incidentList[0].location.location.coordinate.longitude)

        mapViewController.mapView.centerToLocation(initialLocation)
        
        
    }

}
