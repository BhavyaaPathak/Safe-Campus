//
//  RegisterViewController.swift
//  safe_campus
//
//  Created by Bhavya Pathak on 4/2/20.
//  Copyright © 2020 Bhavya Pathak. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import FirebaseUI

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTF: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordTF: SkyFloatingLabelTextField!
    @IBOutlet weak var confirmTF: SkyFloatingLabelTextField!
    @IBOutlet weak var firstnameTF: SkyFloatingLabelTextField!
    @IBOutlet weak var lastNameTF: SkyFloatingLabelTextField!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var errorLbl: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadLayout()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func registerBtn(_ sender: Any) {
        if (firstnameTF.text!.isEmpty || lastNameTF.text!.isEmpty || emailTF.text!.isEmpty || confirmTF.text!.isEmpty || passwordTF.text!.isEmpty) {
            errorLbl.isHidden = false
            return
        }
        if (passwordTF.text! != confirmTF.text!) {
            errorLbl.isHidden = false
            return
        }
        Auth.auth().createUser(withEmail: emailTF.text!, password: passwordTF.text!) { authResult, error in
            if (error != nil) {
                if let errorCode = AuthErrorCode(rawValue: error!._code) {
                    print("Error in Sign up - \(errorCode.errorMessage)")
                    self.showAlert(title: "Error", message: "\(errorCode.errorMessage)", when: .error)
                    return
                }
            }
            print("Sign up Done!")
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = "\(self.firstnameTF.text!) \(self.lastNameTF.text!)"
            changeRequest?.commitChanges { (error) in
                if (error != nil) {
                    if let errorCode = AuthErrorCode(rawValue: error!._code) {
                        print("Error in Sign up - \(errorCode.errorMessage)")
                        self.showAlert(title: "Error", message: "\(errorCode.errorMessage)", when: .error)
                        return
                    }
                }
                self.showAlert(title: "Success", message: "Created account successfully", when: .success)
            }
        }
        errorLbl.isHidden = true
    }
    
    func showAlert(title: String, message: String, when: ShowAlert) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if (when == .error) {
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                print("Ok button tapped");
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion:nil)
        }
        
        if (when == .success) {
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                self.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion:nil)
        }
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func loadLayout() {
        //Title Label
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        //titleLbl.topAnchor.constraint(equalTo: self.navigationController!.navigationBar.bottomAnchor, constant: 100).isActive = true
        titleLbl.centerYAnchor.constraint(equalTo: view.topAnchor, constant: 150).isActive = true
        titleLbl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLbl.heightAnchor.constraint(equalToConstant: 50).isActive = true
        titleLbl.widthAnchor.constraint(equalToConstant: 200).isActive = true
        //Back Button
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        //titleLbl.topAnchor.constraint(equalTo: self.navigationController!.navigationBar.bottomAnchor, constant: 100).isActive = true
        backBtn.bottomAnchor.constraint(equalTo: titleLbl.topAnchor, constant: -10).isActive = true
        backBtn.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        backBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        backBtn.widthAnchor.constraint(equalToConstant: 200).isActive = true
        //First Name Text field
        firstnameTF.placeholder = "First name"
        firstnameTF.title = "First name"
        self.styleTextField(text: firstnameTF)
        //First Name Text field Auto Layout
        firstnameTF.translatesAutoresizingMaskIntoConstraints = false
        firstnameTF.centerYAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 50).isActive = true
        firstnameTF.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -20).isActive = true
        firstnameTF.heightAnchor.constraint(equalToConstant: 50).isActive = true
        firstnameTF.widthAnchor.constraint(equalToConstant: 130).isActive = true
        //Last Name Text field
        lastNameTF.placeholder = "Last name"
        lastNameTF.title = "Last name"
        self.styleTextField(text: lastNameTF)
        //Last Name Text field Auto Layout
        lastNameTF.translatesAutoresizingMaskIntoConstraints = false
        lastNameTF.centerYAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 50).isActive = true
        lastNameTF.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 20).isActive = true
        lastNameTF.heightAnchor.constraint(equalToConstant: 50).isActive = true
        lastNameTF.widthAnchor.constraint(equalToConstant: 130).isActive = true
        //Email Text Field
        emailTF.placeholder = "Email"
        emailTF.title = "Enter your email"
        self.styleTextField(text: emailTF)
        //Email Text Field Auto Layout
        emailTF.translatesAutoresizingMaskIntoConstraints = false
        emailTF.topAnchor.constraint(equalTo: lastNameTF.topAnchor, constant: 70).isActive = true
        emailTF.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emailTF.heightAnchor.constraint(equalToConstant: 50).isActive = true
        emailTF.widthAnchor.constraint(equalToConstant: 300).isActive = true
        //Password Text Field
        passwordTF.placeholder = "Password"
        passwordTF.title = "Enter your password"
        self.styleTextField(text: passwordTF)
        //Password Text Field Auto Layout
        passwordTF.translatesAutoresizingMaskIntoConstraints = false
        passwordTF.topAnchor.constraint(equalTo: emailTF.topAnchor, constant: 70).isActive = true
        passwordTF.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        passwordTF.heightAnchor.constraint(equalToConstant: 50).isActive = true
        passwordTF.widthAnchor.constraint(equalToConstant: 300).isActive = true
        //Password Text Field
        confirmTF.placeholder = "Confrim Password"
        confirmTF.title = "Re-enter your password"
        self.styleTextField(text: confirmTF)
        //Password Text Field Auto Layout
        confirmTF.translatesAutoresizingMaskIntoConstraints = false
        confirmTF.topAnchor.constraint(equalTo: passwordTF.topAnchor, constant: 70).isActive = true
        confirmTF.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        confirmTF.heightAnchor.constraint(equalToConstant: 50).isActive = true
        confirmTF.widthAnchor.constraint(equalToConstant: 300).isActive = true
        //Error Label
        errorLbl.translatesAutoresizingMaskIntoConstraints = false
        errorLbl.centerYAnchor.constraint(equalTo: confirmTF.bottomAnchor, constant: 50).isActive = true
        errorLbl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        errorLbl.heightAnchor.constraint(equalToConstant: 50).isActive = true
        errorLbl.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20).isActive = true
        //Register Button
        registerBtn.translatesAutoresizingMaskIntoConstraints = false
        registerBtn.centerYAnchor.constraint(equalTo: errorLbl.bottomAnchor, constant: 10).isActive = true
        registerBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        registerBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        registerBtn.widthAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    func styleTextField(text: SkyFloatingLabelTextField) {
        text.tintColor = .black
        text.textColor = .black
        text.lineColor = UIColor.systemGreen
        text.selectedTitleColor = UIColor.systemGreen
        text.selectedLineColor = UIColor.systemGreen
    }

}

extension AuthErrorCode {
    var errorMessage: String {
        switch self {
        case .emailAlreadyInUse:
            return "The email is already in use with another account"
        case .userNotFound:
            return "Account not found for the specified user. Please check and try again"
        case .userDisabled:
            return "Your account has been disabled. Please contact support."
        case .invalidEmail, .invalidSender, .invalidRecipientEmail:
            return "Please enter a valid email"
        case .networkError:
            return "Network error. Please try again."
        case .weakPassword:
            return "Your password is too weak. The password must be 6 characters long or more."
        case .wrongPassword:
            return "Your password is incorrect. Please try again or use 'Forgot password' to reset your password"
        default:
            return "Unknown error occurred"
        }
    }
}

enum ShowAlert {
    case error
    case success
}
