//
//  MapViewController.swift
//  safe_campus
//
//  Created by Bhavya Pathak on 4/2/20.
//  Copyright © 2020 Bhavya Pathak. All rights reserved.
//

import UIKit
import MapKit

protocol MapView {
    func placeMarkerForCurrentLocation(location: SCLocation)
}

extension MKMapView {
  func centerToLocation(
    _ location: CLLocation,
    regionRadius: CLLocationDistance = 1000
  ) {
    let coordinateRegion = MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: regionRadius,
      longitudinalMeters: regionRadius)
    setRegion(coordinateRegion, animated: true)
  }
}

class MapViewController: UIViewController, MKMapViewDelegate {
    
    var location: SCLocation! = nil
    var mapView: MKMapView! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.location != nil) {
            self.loadMapView(location: self.location)
        } else {
            self.loadMapView()
        }
    }
    
    //HomeViewController
    func loadMapView(location: SCLocation) {
        
        
        self.mapView = MKMapView(frame: CGRect(x: 0, y: 20, width: 300, height: 300))
        
        // Set initial location
        let initialLocation = CLLocation(latitude: location.location.coordinate.latitude, longitude: location.location.coordinate.longitude)

        mapView.centerToLocation(initialLocation)
        view = mapView
        self.placeMarkerForCurrentLocation(location: location)
    }
    
    func loadMapView() {
        mapView = MKMapView(frame: self.view.bounds)
        view = mapView
    }
    
    func getMarker(incident: SCIncident) -> MKPointAnnotation {
        
        let marker = MKPointAnnotation()
        let mrk = Util.getIncidentImage(code: incident.offenceCodeGroup)
        let markerImage = mrk.image.withRenderingMode(.alwaysTemplate)
        let markerView = UIImageView(image: markerImage)
        markerView.tintColor = mrk.color
        marker.title = incident.offenceCodeGroup
        marker.subtitle = incident.offenceDescription
        return marker
    }
    
    func placeMarker(incident: SCIncident) {
        // Creates a marker in the center of the map.
        
        let marker = self.getMarker(incident: incident)
        marker.coordinate = CLLocationCoordinate2D(latitude: incident.location.location.coordinate.latitude, longitude: incident.location.location.coordinate.longitude)
        mapView.addAnnotation(marker);
    }
    //HomeViewController
    func placeMarkerForCurrentLocation(location: SCLocation) {
        let marker = MKPointAnnotation()
//        marker.title = "Your Location"
        marker.coordinate = CLLocationCoordinate2D(latitude: location.location.coordinate.latitude, longitude: location.location.coordinate.longitude)
        mapView.addAnnotation(marker);
        
        //Set marker with location
    }
}
