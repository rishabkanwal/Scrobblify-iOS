//
//  FirstViewController.swift
//  Scrobblify
//
//  Created by Rishab Kanwal on 6/11/17.
//  Copyright © 2017 Rishab Kanwal. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginActivityIndicator: UIActivityIndicatorView!
    
    @IBAction func loginButtonClicked(_ sender: UIButton) {
        let username = usernameTextField.text
        let password = passwordTextField.text
        self.usernameTextField.endEditing(true)
        self.passwordTextField.endEditing(true)
        if (username == "" || password == "") {
            makeSnackbar(message: "Enter both fields")
        } else {
            
            startSession(username: username!, password: password!)
        }
    }
    
    private func segueToTabBarController() {
        DispatchQueue.main.async(execute: {
            self.performSegue(withIdentifier: "LoginToTabBarControllerSegue", sender: nil)
            self.loginActivityIndicator.stopAnimating()
        })
    }

    private func startSession(username: String, password: String) {
        self.loginActivityIndicator.startAnimating()
        AppState.shared.lastFmRequestManager.getSession(username: username, password: password, completionHandler: {
            responseJsonString, error in
            if !(error != nil) {
                AppState.shared.session = Session(JSONString: responseJsonString!)!
                AppState.shared.saveSessionData()
                self.segueToTabBarController()
            } else {
                DispatchQueue.main.async(execute: {
                    makeSnackbar(message: "Check login credentials")
                    self.loginActivityIndicator.stopAnimating()
                })

            }
            
        })
    }
    
}

