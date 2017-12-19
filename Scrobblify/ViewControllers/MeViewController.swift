//
//  MeViewController.swift
//  Scrobblify
//
//  Created by Rishab Kanwal on 6/12/17.
//  Copyright © 2017 Rishab Kanwal. All rights reserved.
//

import UIKit
import Kingfisher
import SwiftyJSON

class MeViewController: UIViewController {
    
    @IBOutlet weak var mainActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var playsLabel: UILabel!
    @IBOutlet weak var subscribersLabel: UILabel!
    @IBOutlet weak var joinDateLabel: UILabel!
    @IBOutlet weak var overlayImageView: UIImageView!
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var refreshButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUserDetails()
    }
    
    @IBAction func settingsClicked(_ sender: Any) {
        openSettings()
    }
    
    @IBAction func refreshClicked(_ sender: Any) {
        refreshButton.isHidden = true
        
        updateUserDetails()
    }
    
    func updateUserDetails() {
        AppState.shared.lastFmRequestManager.getUserInfo(completionHandler: { responseJsonString, error in
            guard error == nil else {
                return
            }
            
            if let responseJson = try? JSON(data: responseJsonString!.data(using: .utf8, allowLossyConversion: false)!).rawString() {
                let user = User(JSONString: responseJson!)!
                
                DispatchQueue.main.async(execute: {
                    self.mainActivityIndicator.stopAnimating()
                    
                    self.mainView.isHidden = false
                    self.usernameLabel.isHidden = false
                    self.overlayImageView.isHidden = false
                    self.pictureImageView.isHidden = false
                    self.refreshButton.isHidden = false
                    
                    self.usernameLabel.text = user.username
                    self.playsLabel.text = (user.getFormattedPlaycount()) + " total plays"
                    self.subscribersLabel.text = user.subscribers! + " subscribers"
                    self.joinDateLabel.text = "Joined " + user.getFormattedRegisterDate()
                    
                    if let imageUrl = user.imageUrl {
                        self.pictureImageView.kf.setImage(with: ImageResource(downloadURL: imageUrl))
                    }
                })
            }
        })
    }
    
}
