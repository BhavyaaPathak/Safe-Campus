//
//  HomeViewController.swift
//  safe_campus
//
//  Created by Bhavya Pathak on 4/2/20.
//  Copyright © 2020 Bhavya Pathak. All rights reserved.
//

//TODO request always location

import UIKit
import CoreLocation
import FirebaseUI
import Reachability

class HomeViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var searchLbl: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var addLbl: UILabel!
    @IBOutlet weak var emergencyBtn: UIButton!
    @IBOutlet weak var emergencyLbl: UILabel!
    
    let locationManager = CLLocationManager()
    var dbUtil: DbUtil!
    var mapViewController: MapViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dbUtil = DbUtil()
        self.enableLocationServices()
        self.loadLayout()
    }
    
    func loadMapView(location: SCLocation) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        mapViewController = (storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController)
        mapViewController.location = location
        addChild(mapViewController)
        view.addSubview(mapViewController.view)
        addConstraintToView(view: mapViewController.view)
        // Notify Child View Controller
        mapViewController.didMove(toParent: self)
        
    }
    
   func enableLocationServices() {
        locationManager.delegate = self
    
        switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                // Request when-in-use authorization initially
                locationManager.requestWhenInUseAuthorization()
                break
                
            case .restricted, .denied:
                // Disable location features
                break
                
            case .authorizedWhenInUse:
                // Enable basic location features
                self.enableMyWhenInUseFeatures()
                break
                
            case .authorizedAlways:
                // Enable any of your app's location features
                self.enableMyAlwaysFeatures()
                break
            }
    }
    
    func enableMyWhenInUseFeatures() {
        print("Location WhenInUse enabled")
        if CLLocationManager.locationServicesEnabled() {
            // Location services are available, so query the user’s location.
        }
        self.startReceivingLocationChanges()
    }
    
    func enableMyAlwaysFeatures() {
        print("Location Always enabled")
        if CLLocationManager.locationServicesEnabled() {
            // Location services are available, so query the user’s location.
        }
    }
    
    func startReceivingLocationChanges() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != .authorizedWhenInUse && authorizationStatus != .authorizedAlways {
            // User has not authorized access to location information.
            print("User has not authorized access to location information")
            return
        }
        // Do not start services that aren't available.
        if !CLLocationManager.locationServicesEnabled() {
            // Location services is not available.
            return
        }
        // Configure and start the service.
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100.0  // In meters.
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last!
        // Do something with the location.
        let currentLocation = SCLocation(location: lastLocation, street: "", zip: "")
        CurrentUser.shared.setLocation(location: currentLocation)
        self.loadMapView(location: currentLocation)
        Util.getPlaceFromLocation(location: currentLocation, handleResult: { location in
            if (location != nil) {
                CurrentUser.shared.getLocation().zipCode = Util.filterZip(zip: location.zipCode)
                CurrentUser.shared.getLocation().street = location.street
                self.loadIncidentsFromZipCode(zipCode: location.zipCode)
            }
        })
    }
    
    func loadIncidentsFromZipCode(zipCode: String) {
        DbUtil.getDataByZip(zipCode: zipCode, result: { incidents in
            for incident in incidents {
                //check if to notify
                if(incident.toNotify() && incident.reportersId != nil && incident.reportersId! != CurrentUser.shared.uid && incident.isInThisWeek()){
                    if let viewControllers = self.navigationController?.viewControllers {
                        for viewController in viewControllers {
                            // some process
                            if viewController is HomeViewController {
                                print("Show notification")
                                self.mapViewController.placeMarker(incident: incident)
                                self.showAlert(title: "Alert", message: "There has been an incident nearby your location! Be safe!")
                                return
                            }
                        }
                    }
                }
                
//                if (incident.isInThisWeek()) {
//                    self.mapViewController.placeMarker(incident: incident)
//                }
            }
        });
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        manager.startUpdatingLocation()
    }
    
    @objc func logout() {
        try! Auth.auth().signOut()
        if let storyboard = self.storyboard {
            let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! ViewController
            self.present(vc, animated: false, completion: nil)
        }
        //self.navigationController?.popToRootViewController(animated: true)
    }
    
    func addConstraintToView(view: UIView) {
        //Enable Autolayout
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        //view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        let topBarHeight = UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
        view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: topBarHeight).isActive = true
        view.bottomAnchor.constraint(equalTo: addBtn.topAnchor, constant: -40).isActive = true
    }
    
    func loadLayout() {
        let w = ((self.view.frame.self.width / 2) / 2)
        print(self.view.frame.self.width)
        //Add navigation bar title
        self.navigationItem.title = "Home";
        //Add navigation bar logout button
        var image = UIImage(named: "logout")
        image = image?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image:image, style: UIBarButtonItem.Style.plain, target: self, action: #selector(logout))
        var imageLeft = UIImage(named: "hotline")?.withRenderingMode(.alwaysTemplate)

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:imageLeft, style: UIBarButtonItem.Style.plain, target: self, action: #selector(emergencyContacts))
        //Search Button
        searchBtn.translatesAutoresizingMaskIntoConstraints = false
        searchBtn.centerYAnchor.constraint(equalTo: searchLbl.centerYAnchor, constant: -60).isActive = true
        searchBtn.centerXAnchor.constraint(equalTo: view.rightAnchor, constant: -100).isActive = true
        searchBtn.heightAnchor.constraint(equalToConstant: 60).isActive = true
        searchBtn.widthAnchor.constraint(equalToConstant: 60).isActive = true
        //Search Button Label
        searchLbl.translatesAutoresizingMaskIntoConstraints = false
        searchLbl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        searchLbl.centerXAnchor.constraint(equalTo: searchBtn.centerXAnchor).isActive = true
        searchLbl.heightAnchor.constraint(equalToConstant: 80).isActive = true
        searchLbl.widthAnchor.constraint(equalToConstant: 80).isActive = true
        //Add Incident Button
        addBtn.translatesAutoresizingMaskIntoConstraints = false
        addBtn.centerYAnchor.constraint(equalTo: addLbl.centerYAnchor, constant: -60).isActive = true
        addBtn.centerXAnchor.constraint(equalTo: view.leftAnchor, constant: 100).isActive = true
        addBtn.heightAnchor.constraint(equalToConstant: 60).isActive = true
        addBtn.widthAnchor.constraint(equalToConstant: 60).isActive = true
        //Add Button Label
        addLbl.translatesAutoresizingMaskIntoConstraints = false
        addLbl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        addLbl.centerXAnchor.constraint(equalTo: addBtn.centerXAnchor).isActive = true
        addLbl.heightAnchor.constraint(equalToConstant: 80).isActive = true
        addLbl.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
    }

    @IBAction func emertgencyCall(_ sender: Any) {
        self.emergencyContacts()
    }
    
    @objc func emergencyContacts(){
        let actionSheet = UIAlertController(title: "Emergency Calls", message: "", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "SOS", style: .default, handler: { (action) -> Void in
            self.makeCall("8573187372")
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Call NUPD", style: .default, handler: { (action) -> Void in
            self.makeCall("8573187372")
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Call Helpline", style: .default, handler: { (action) in
            self.makeCall("8573187372")
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Call UHCS", style: .default, handler: { (action) in
            self.makeCall("8573187372")
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Call Fire Department", style: .default, handler: { (action) in
            self.makeCall("8573187372")
        }))
        
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func makeCall(_ contact: String)  {
        UIApplication.shared.open(URL(string: "tel://\(contact)")!, options: [:], completionHandler: nil)
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            print("Ok button tapped");
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion:nil)
    }
}
