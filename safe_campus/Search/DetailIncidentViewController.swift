//
//  DetailIncidentViewController.swift
//  safe_campus
//
//  Created by Bhavya Pathak on 4/19/20.
//  Copyright © 2020 Bhavya Pathak. All rights reserved.
//

import UIKit
import ImageSlideshow
import LGButton

class DetailIncidentViewController: UIViewController {
    
    @IBOutlet weak var slideshow: ImageSlideshow!
    var incident: SCIncident!
    
    @IBOutlet weak var offenceCode: UILabel!
    @IBOutlet weak var dateTime: UILabel!
    @IBOutlet weak var offenceDetail: UITextView!
    @IBOutlet weak var markSafeBtn: LGButton!
    @IBOutlet weak var status: LGButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var containerView: UIView!
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.incident != nil) {            
            self.loadFields()
            self.loadLayout()
            loadMapView(location: incident.location)
            //self.loadImageSlides()
            
            if (!incident.imagesURL.isEmpty) {
                let imagesURl = incident.imagesURL.components(separatedBy: ",")
                if(!imagesURl.isEmpty){
                    loadImageSlides(imagesURl)
                }
            }
        }
        // Do any additional setup after loading the view.
    }
    
    func loadMapView(location: SCLocation) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let mapViewController = (storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController)
        mapViewController.location = location
//        mapViewController.placeMarker(incident: self.incident)
        addChild(mapViewController)
        containerView.addSubview(mapViewController.view)
        addConstraintToView(view: mapViewController.view)
        mapViewController.didMove(toParent: self)
        
    }
    
    func addConstraintToView(view: UIView) {
        //Enable Autolayout
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor).isActive = true
        //view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        let topBarHeight = UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
        view.topAnchor.constraint(equalTo: self.containerView.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: self.containerView.centerYAnchor, constant: -50).isActive = true
    }
    
    func loadImageSlides(_ imagesURL: [String]) {
        slideshow.slideshowInterval = 5.0
        slideshow.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
        slideshow.contentScaleMode = UIView.ContentMode.scaleAspectFill
        
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = UIColor.lightGray
        pageControl.pageIndicatorTintColor = UIColor.black
        slideshow.pageIndicator = pageControl
        
        // optional way to show activity indicator during image load (skipping the line will show no activity indicator)
        slideshow.activityIndicator = DefaultActivityIndicator()
        //slideshow.delegate = self
        
        
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        slideshow.addGestureRecognizer(recognizer)
        
        DbUtil.downloadMedia(imageURL: imagesURL) { (images) in
            var imagesSource = [ImageSource]()
            for image in images{
                imagesSource.append(ImageSource(image: image))
            }
            self.slideshow.setImageInputs(imagesSource)
        }
        
    }
    
    @objc func didTap() {
        let fullScreenController = slideshow.presentFullScreenController(from: self)
        // set the activity indicator for full screen controller (skipping the line will show no activity indicator)
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
    }

    func loadFields() {
        self.offenceCode!.text = self.incident.offenceCodeGroup
        self.dateTime!.text = self.incident.dateTime.toString(dateFormat: "yyyy-MM-dd HH:mm:ss")
        self.offenceDetail!.text = self.incident.offenceDescription
        if (self.incident.status == "ACTIVE") {
            status.bgColor = .red
        } else {
            status.bgColor = .green
            self.markSafeBtn.isHidden = true
        }
        status.titleString = self.incident.resolveIncidentStatus()
    }
    
    func alert(_ message : String){
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert);
//        let OkAction = UIAlertAction(title: "OK", style: .default) { (action) in
//            self.performSegue(withIdentifier: "SearchViewTableController", sender: Any?.self)
//        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
//        alert.addAction(OkAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func markSafeAction(_ sender: LGButton) {
        if(CurrentUser.shared.isAdmin && incident.status == "ACTIVE"){
            incident.status = "IN_ACTIVE"
            DbUtil.updateIncidentData(incident: incident)
            loadFields()
            alert("Marked safe")
        }
    }
    
    
    func loadLayout() {
        //Status
        
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        containerView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        
        
        status.translatesAutoresizingMaskIntoConstraints = false
        status.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -30).isActive = true
        status.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10).isActive = true
        status.heightAnchor.constraint(equalToConstant: 30).isActive = true
        status.widthAnchor.constraint(equalToConstant: 100).isActive = true
        //Offence Code
        offenceCode.translatesAutoresizingMaskIntoConstraints = false
        offenceCode.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        offenceCode.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20).isActive = true
        offenceCode.heightAnchor.constraint(equalToConstant: 30).isActive = true
        offenceCode.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        //Date Time
        dateTime.translatesAutoresizingMaskIntoConstraints = false
        dateTime.topAnchor.constraint(equalTo: offenceCode.bottomAnchor, constant: 10).isActive = true
        dateTime.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20).isActive = true
        dateTime.heightAnchor.constraint(equalToConstant: 10).isActive = true
        dateTime.trailingAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 50).isActive = true
        //Description
        offenceDetail.translatesAutoresizingMaskIntoConstraints = false
        offenceDetail.topAnchor.constraint(equalTo: dateTime.bottomAnchor, constant: 20).isActive = true
        offenceDetail.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20).isActive = true
        offenceDetail.heightAnchor.constraint(equalToConstant: 50).isActive = true
        offenceDetail.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        //SlideShow
        if (!incident.imagesURL.isEmpty) {
            slideshow.translatesAutoresizingMaskIntoConstraints = false
            slideshow.topAnchor.constraint(equalTo: offenceDetail.bottomAnchor, constant: 20).isActive = true
            slideshow.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
            slideshow.heightAnchor.constraint(equalToConstant: 200).isActive = true
            slideshow.widthAnchor.constraint(equalTo: containerView.widthAnchor, constant: -20).isActive = true
        } else {
            slideshow.isHidden = true
        }
        //Mark safe button
        markSafeBtn.translatesAutoresizingMaskIntoConstraints = false
        if(CurrentUser.shared.isAdmin && incident.status == "ACTIVE"){
            if (!incident.imagesURL.isEmpty) {
                markSafeBtn.topAnchor.constraint(equalTo: slideshow.bottomAnchor, constant: 20).isActive = true
                markSafeBtn.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
            } else {
                markSafeBtn.topAnchor.constraint(equalTo: offenceDetail.bottomAnchor, constant: 20).isActive = true
            }
            markSafeBtn.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
            markSafeBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true
            markSafeBtn.widthAnchor.constraint(equalTo: containerView.widthAnchor, constant: -40).isActive = true
        }
        else {
            markSafeBtn.isHidden = true
        }
    }
    
}
