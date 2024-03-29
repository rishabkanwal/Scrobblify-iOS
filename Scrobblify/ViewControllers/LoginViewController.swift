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
        
        usernameTextField.endEditing(true)
        passwordTextField.endEditing(true)
        
        if username == "" || password == "" {
            makeSnackbar(message: "Enter both fields")
        } else {
            startSession(username: username!, password: password!)
        }
    }
    
    func segueToTabBarController() {
        DispatchQueue.main.async(execute: {
            self.performSegue(withIdentifier: "LoginToTabBarControllerSegue", sender: nil)
            
            self.loginActivityIndicator.stopAnimating()
        })
    }
    
    func startSession(username: String, password: String) {
        loginActivityIndicator.startAnimating()
        
        AppState.shared.lastFmRequestManager.getSession(username: username, password: password, completionHandler: { responseJsonString, error in
            guard error == nil else {
                DispatchQueue.main.async(execute: {
                    makeSnackbar(message: "Check login credentials")
                    
                    self.loginActivityIndicator.stopAnimating()
                })
                return
            }
            
            AppState.shared.lastFmSession = LastFmSession(JSONString: responseJsonString!)
            AppState.shared.saveSessionData()
            
            self.segueToTabBarController()
        })
    }

}

