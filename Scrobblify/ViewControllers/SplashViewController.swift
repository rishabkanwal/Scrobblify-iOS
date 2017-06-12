//
//  SplashViewController.swift
//  Scrobblify
//
//  Created by Rishab Kanwal on 6/11/17.
//  Copyright © 2017 Rishab Kanwal. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppState.shared.retrieveSessionData()
        if (AppState.shared.session!.key == nil) {
            segueSplashToLogin()
        } else {
            segueSplashToTabBarController()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func segueSplashToLogin() {
        DispatchQueue.main.async(execute: {
            self.performSegue(withIdentifier: "SplashToLoginSegue", sender: nil)
        })
    }
    
    func segueSplashToTabBarController() {
        DispatchQueue.main.async(execute: {
            self.performSegue(withIdentifier: "SplashToTabBarControllerSegue", sender: nil)
        })
    }
    
}
