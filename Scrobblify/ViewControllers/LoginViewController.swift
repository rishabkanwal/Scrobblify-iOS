//
//  FirstViewController.swift
//  Scrobblify
//
//  Created by Rishab Kanwal on 6/11/17.
//  Copyright © 2017 Rishab Kanwal. All rights reserved.
//

import UIKit
import TTGSnackbar

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginActivityIndicator: UIActivityIndicatorView!
    
    func makeSnackbar(message: String) {
        DispatchQueue.main.async(execute: {
            let snackbar = TTGSnackbar.init(message: "  " + message, duration: .short)
            snackbar.backgroundColor = UIColor.red
        })

    }
    
    func segueToTabBarController() {
        DispatchQueue.main.async(execute: {
            self.performSegue(withIdentifier: "LoginToTabBarControllerSegue", sender: nil)
            self.loginActivityIndicator.stopAnimating()
        })
    }

    func startSession(username: String, password: String) {
        self.loginActivityIndicator.startAnimating()
        AppState.shared.lastFmRequest.getSession(username: username, password: password, completionHandler: {
            responseJsonString, error in
            if !(error != nil) {
                AppState.shared.session = Session(JSONString: responseJsonString!)!
                AppState.shared.saveSessionData()
                self.segueToTabBarController()
            } else {
                DispatchQueue.main.async(execute: {
                    self.makeSnackbar(message: "Check login credentials")
                    self.loginActivityIndicator.stopAnimating()
                })

            }
            
        })
    }
    
    @IBAction func loginButtonClicked(_ sender: UIButton) {
        let username = usernameTextField.text
        let password = passwordTextField.text
        self.usernameTextField.endEditing(true)
        self.passwordTextField.endEditing(true)
        if (username == "" || password == "") {
            self.makeSnackbar(message: "Enter both fields")
        } else {
            
            startSession(username: username!, password: password!)
        }
    }
    
    
}

