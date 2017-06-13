//
//  TracksViewController.swift
//  Scrobblify
//
//  Created by Rishab Kanwal on 6/12/17.
//  Copyright © 2017 Rishab Kanwal. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher

class TracksViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "TracksToTopItemsSegue") {
            let topItemsViewController = segue.destination  as! TopItemsViewController
            topItemsViewController.apiMethod = "user.getTopTracks"
            topItemsViewController.baseJsonObject = "toptracks"
            topItemsViewController.mainJsonObject = "track"
        }
    }
    
}

