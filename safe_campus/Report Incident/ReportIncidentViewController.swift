//
//  ReportIncidentViewController.swift
//  safe_campus
//
//  Created by Bhavya Pathak on 4/13/20.
//  Copyright © 2020 Bhavya Pathak. All rights reserved.
//

import UIKit
import iOSDropDown
import MapKit
import CoreLocation
import MobileCoreServices
import MBProgressHUD

class ReportIncidentViewController: UIViewController, AttachmentsSelected{
    
    func notifyWhenAttached(images: [UIImage]) {
        self.images = images;
    }
    
    var incidentId: String?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var typeDropDown: UIPickerView!
    @IBOutlet weak var attachments: UIButton!
    
    var category: String?
    
    let picker = UIImagePickerController()
    //let locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: SCLocation?
    
    var mapViewController: MapViewController!
    
    var images: [UIImage]?
    var videos: [NSURL]?
    
    var incident: SCIncident?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        images = [UIImage]()
        videos = [NSURL]()
        
        incidentId = String(arc4random_uniform(99999))
        
        txtDescription.layer.borderWidth = 0.1;
        txtDescription.layer.borderColor = UIColor.gray.cgColor
        txtDescription.layer.cornerRadius = 8.0
        
        txtDescription.text = "Enter Discription"
        txtDescription.textColor = UIColor.lightGray
        txtDescription.returnKeyType = .done
        txtDescription.delegate = self
        
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.delegate = self
//        currentLocation = nil
        
        let saveBarButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        navigationItem.rightBarButtonItem = saveBarButton
        
        self.typeDropDown.delegate = self
        self.typeDropDown.dataSource = self
        loadMapView()
        registerForKeyboardNotifications()
        autoLayout()
    }
    
    func loadMapView(){
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        self.mapViewController = (storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController)
        mapViewController.location = CurrentUser.shared.getLocation()
        addChild(self.mapViewController)
        self.scrollView.addSubview(mapViewController.view)
        self.mapViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addConstraintToView(view: mapViewController.view)
        // Notify Child View Controller
        mapViewController.didMove(toParent: self)
    }
    
    func addConstraintToView(view: UIView) {
        //Enable Autolayout
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        view.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.5, constant: -100).isActive = true

    }
    
    func autoLayout(){
        self.typeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.typeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 10).isActive = true
        self.typeLabel.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        self.typeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 10).isActive = true
        self.typeLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        //DropDown
        self.typeDropDown.translatesAutoresizingMaskIntoConstraints = false
        self.typeDropDown.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.typeDropDown.centerYAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 5).isActive = true
        self.typeDropDown.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40).isActive = true
        self.typeDropDown.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        self.txtDescription.translatesAutoresizingMaskIntoConstraints = false
        self.txtDescription.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.txtDescription.topAnchor.constraint(equalTo: typeDropDown.bottomAnchor, constant: 10).isActive = true
        self.txtDescription.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40).isActive = true
        self.txtDescription.heightAnchor.constraint(equalToConstant: 120).isActive = true
        self.txtDescription.layer.borderColor = UIColor.black.cgColor
        self.txtDescription.layer.borderWidth = 1.5
        
        self.attachments.translatesAutoresizingMaskIntoConstraints = false
        self.attachments.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.attachments.topAnchor.constraint(equalTo: txtDescription.bottomAnchor, constant: 10).isActive = true
        self.attachments.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        self.attachments.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func registerForKeyboardNotifications(){
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeShown(note:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    fileprivate func enableAutoLayout(value: Bool) {
        self.typeLabel.translatesAutoresizingMaskIntoConstraints = value
        self.typeDropDown.translatesAutoresizingMaskIntoConstraints = value
        self.txtDescription.translatesAutoresizingMaskIntoConstraints = value
        self.attachments.translatesAutoresizingMaskIntoConstraints = value
    }
    
    @objc func keyboardWillBeShown(note: Notification) {
        let userInfo = note.userInfo
        let keyboardFrame = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        let adjustmentHeight = keyboardFrame.height + 10
        scrollView.contentInset.bottom += adjustmentHeight
        scrollView.scrollIndicatorInsets.bottom += adjustmentHeight
        scrollView.scrollRectToVisible(txtDescription.frame, animated: true)
        enableAutoLayout(value: true)
    }
    
    @objc func keyboardWillBeHidden(note: Notification) {
        let userInfo = note.userInfo
        let keyboardFrame = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        let adjustmentHeight = keyboardFrame.height + 10
        scrollView.contentInset.bottom -= adjustmentHeight
        scrollView.scrollIndicatorInsets.bottom -= adjustmentHeight
        scrollView.scrollRectToVisible(txtDescription.frame, animated: true)
        enableAutoLayout(value: false)
    }
    
    @IBAction func addAttachments(_ sender: Any) {
        //self.performSegue(withIdentifier: "AddAttachments", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AttachmentsTableViewController{
            vc.delegate = self
            vc.images = images
        }
    }
    
    @objc func save() {
        self.incident = SCIncident(id: self.incidentId! ,location: CurrentUser.shared.getLocation(), offenceCode: "0000", offenceCodeGroup: self.category!, offenceDescription: txtDescription.text!, reportersId: CurrentUser.shared.uid!)
        if(images!.count > 0){
            DbUtil.uploadAttachments(images: images!, videos: videos!, incident: self.incident!, result: { (url) in
                self.incident!.images.append(url)
            }) { (done) in
                if done {
                    MBProgressHUD.hide(for: self.view, animated: true)
                    DbUtil.saveIncident(incident: self.incident!)
                    self.alert("Incident added successfully!")
                } else {
                    let alert = UIAlertController(title: "Alert", message: "Could not upload images. Try without images", preferredStyle: .alert);
                    let OkAction = UIAlertAction(title: "OK", style: .default,handler: nil)
                    alert.addAction(OkAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
            let activitySpinner = MBProgressHUD.showAdded(to: self.view, animated: true)
            activitySpinner.label.text = "Uploading..."
            activitySpinner.detailsLabel.text = "Please wait"
        }else {
            DbUtil.saveIncident(incident: self.incident!)
            self.alert("Incident added successfully!")
        }
    }
    
    func alert(_ message : String){
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert);
        let OkAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(OkAction)
        self.present(alert, animated: true, completion: nil)
    }

}

extension ReportIncidentViewController: UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Enter Discription" {
            textView.text = ""
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Enter Discription"
            textView.textColor = UIColor.gray
        }
    }
}

extension ReportIncidentViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView.tag == 1) {
            return IncidentCatagoryList.list.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView.tag == 1) {
            return IncidentCatagoryList.list[row]
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        if (pickerView.tag == 1) {
            self.category = IncidentCatagoryList.list[row]
        }
    }
    
}
