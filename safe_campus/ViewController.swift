//
//  ViewController.swift
//  safe_campus
//
//  Created by Bhavya Pathak on 4/2/20.
//  Copyright © 2020 Bhavya Pathak. All rights reserved.
//

import UIKit
import FirebaseUI
import SkyFloatingLabelTextField
import Reachability
import LGButton

class ViewController: UIViewController, FUIAuthDelegate, UITextFieldDelegate {

    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var signInLbl: UILabel!
    @IBOutlet weak var emailTF: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordTF: SkyFloatingLabelTextField!
    @IBOutlet weak var noAccountLbl: UILabel!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var otherOptionsLbl: UILabel!
    @IBOutlet weak var googleBtn: LGButton!
    @IBOutlet weak var signInBtn: LGButton!
    
    var reachability: Reachability?
    
    override func viewWillAppear(_ animated: Bool) {
        //Check if user logged in
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if (user != nil) {
                print("\(user!.uid) \(user!.email) \(user!.displayName)")
                //CurrentUser.shared.displayName = user?.displayName!
                if(user?.uid=="h7ESvjRQInQfTJyCYW6dHVllL0W2"){
                    CurrentUser.shared.isAdmin = true
                }else {
                    CurrentUser.shared.isAdmin = false
                }
                CurrentUser.shared.uid = user?.uid
                self.performSegue(withIdentifier: "loginSuccessSegue", sender: self)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadLayout()
//        self.performSanityCheck()
        emailTF.delegate = self
        passwordTF.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    @objc func handleTap(){
        self.view.endEditing(true)
    }
    
    
    @IBAction func signInWithGoogle(_ sender: LGButton) {
        let authUI = FUIAuth.defaultAuthUI()
        
        guard authUI != nil else {
            print("Firebase authUI error")
            return
        }
        
        // You need to adopt a FUIAuthDelegate protocol to receive callback
        authUI!.delegate = self
        
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(),
        ]
        authUI!.providers = providers
        
        let authViewController = authUI!.authViewController()
        
        self.present(authViewController, animated: true, completion: nil);
    }
    
    
    @IBAction func signInBtnAction(_ sender: Any) {
        if (emailTF.text!.isEmpty || passwordTF.text!.isEmpty) {
            self.showAlert(title: "Error", message: "Please enter valid values")
            return
        }
        
        Auth.auth().signIn(withEmail: emailTF.text!, password: passwordTF.text!) { [weak self] user, error in
            if (error != nil) {
                if let errorCode = AuthErrorCode(rawValue: error!._code) {
                    print("Error in Sign up - \(errorCode.errorMessage)")
                    self!.showAlert(title: "Error", message: "\(errorCode.errorMessage)")
                    return
                }
            }
            guard let strongSelf = self else { return }
            // ...
        }
    }
    
    func getUserDetails() {
        let user = Auth.auth().currentUser
        if let user = user {
            // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with your backend server,
            // if you have one. Use getTokenWithCompletion:completion: instead.
            let uid = user.uid
            let email = user.email
            let photoURL = user.photoURL
            // ...
        }
    }
    
    //Handler for the result of the Google and Facebook sign-up flows
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        // handle user and error as necessary
        if (error != nil) {
            print("Sign in error \(String(describing: error))")
        } else {
            CurrentUser.shared.displayName = user!.displayName
            performSegue(withIdentifier: "loginSuccessSegue", sender: self)
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            print("Ok button tapped")
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion:nil)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//        if segue.identifier == "loginSuccessSegue" {
//            
//        }
//    }
    
    func loadLayout() {
        //Logo Image
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
        logo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logo.heightAnchor.constraint(equalToConstant: 200).isActive = true
        logo.widthAnchor.constraint(equalToConstant: 200).isActive = true
        //Title Label
        signInLbl.translatesAutoresizingMaskIntoConstraints = false
        signInLbl.textAlignment = .center
        signInLbl.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 20).isActive = true
        signInLbl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        signInLbl.heightAnchor.constraint(equalToConstant: 50).isActive = true
        signInLbl.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        //Email Text field
        emailTF.placeholder = "Email"
        emailTF.title = "Email"
        self.styleTextField(text: emailTF)
        //Email Text field Auto Layout
        emailTF.translatesAutoresizingMaskIntoConstraints = false
        emailTF.centerYAnchor.constraint(equalTo: signInLbl.bottomAnchor, constant: 30).isActive = true
        emailTF.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emailTF.heightAnchor.constraint(equalToConstant: 50).isActive = true
        emailTF.widthAnchor.constraint(equalToConstant: 300).isActive = true
        //Password Text field
        passwordTF.placeholder = "Password"
        passwordTF.title = "Password"
        self.styleTextField(text: passwordTF)
        //First Name Text field Auto Layout
        passwordTF.translatesAutoresizingMaskIntoConstraints = false
        passwordTF.centerYAnchor.constraint(equalTo: emailTF.bottomAnchor, constant: 30).isActive = true
        passwordTF.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        passwordTF.heightAnchor.constraint(equalToConstant: 50).isActive = true
        passwordTF.widthAnchor.constraint(equalToConstant: 300).isActive = true
        //Sign in button signIn
        signInBtn.translatesAutoresizingMaskIntoConstraints = false
        signInBtn.topAnchor.constraint(equalTo: passwordTF.bottomAnchor, constant: 20).isActive = true
        signInBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        signInBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true
        signInBtn.widthAnchor.constraint(equalToConstant: 250).isActive = true
        //Other option label
        otherOptionsLbl.translatesAutoresizingMaskIntoConstraints = false
        otherOptionsLbl.textAlignment = .center
        otherOptionsLbl.topAnchor.constraint(equalTo: passwordTF.bottomAnchor, constant: 80).isActive = true
        otherOptionsLbl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        otherOptionsLbl.heightAnchor.constraint(equalToConstant: 50).isActive = true
        otherOptionsLbl.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        //Other option label
        googleBtn.translatesAutoresizingMaskIntoConstraints = false
        googleBtn.topAnchor.constraint(equalTo: otherOptionsLbl.bottomAnchor, constant: 20).isActive = true
        googleBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        googleBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true
        googleBtn.widthAnchor.constraint(equalToConstant: 250).isActive = true
        //No Account Label
        noAccountLbl.translatesAutoresizingMaskIntoConstraints = false
        noAccountLbl.textAlignment = .center
        noAccountLbl.topAnchor.constraint(equalTo: otherOptionsLbl.bottomAnchor, constant: 100).isActive = true
        noAccountLbl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        noAccountLbl.heightAnchor.constraint(equalToConstant: 50).isActive = true
        noAccountLbl.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        //Sign Up Button
        signUpBtn.translatesAutoresizingMaskIntoConstraints = false
        signUpBtn.topAnchor.constraint(equalTo: noAccountLbl.bottomAnchor, constant: 5).isActive = true
        signUpBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        signUpBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        signUpBtn.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
    }
    
    func styleTextField(text: SkyFloatingLabelTextField) {
        text.tintColor = .black
        text.textColor = .black
//        text.lineColor = UIColor(rgb: 0xC51162)
        text.lineColor = .systemGreen
        text.selectedTitleColor = .systemGreen
        text.selectedLineColor = .systemGreen
    }

//    func performSanityCheck(){
//        batteryCheck()
//        //networkCheck()
//    }
    
    func batteryCheck() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(batteryLevelChanged), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
    }
    
    @objc func batteryLevelChanged(_ notification: Notification){
        let batteryLevel = UIDevice.current.batteryLevel
        let batterState = UIDevice.current.batteryState
        
        if(batterState != UIDevice.BatteryState.charging && batteryLevel <= 20 ){
            alert("Battery is Low!")
        }
    }
    
    func alert(_ message : String){
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert);
        let OkAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(OkAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func networkCheck(){
        reachability = Reachability()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkStatusChanged(_:)),
            name: .reachabilityChanged,
            object: reachability
        )
        do {
            try reachability!.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    @objc func networkStatusChanged(_ notification: Notification) {
        switch reachability!.connection {
        case .none:
            let offlineVC = self.storyboard?.instantiateViewController(withIdentifier: "Offline") as! OfflineViewController
            offlineVC.reachability = reachability
            self.present(offlineVC, animated: true, completion: nil)
        case .cellular:
            alert("Using cellular connection upload/download may be slower")
            self.setEditing(true, animated: true)
        default:
            self.setEditing(true, animated: true)
        }
    }
    
}

