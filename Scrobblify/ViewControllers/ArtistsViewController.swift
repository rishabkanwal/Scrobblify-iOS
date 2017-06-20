//
//  ArtistsViewController.swift
//  Scrobblify
//
//  Created by Rishab Kanwal on 6/11/17.
//  Copyright © 2017 Rishab Kanwal. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher

class ArtistsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ArtistsToTopItemsSegue") {
            let topItemsViewController = segue.destination  as! TopItemsViewController
            topItemsViewController.apiMethod = "user.getTopArtists"
            topItemsViewController.baseJsonObject = "topartists"
            topItemsViewController.mainJsonObject = "artist"
        }
    }
    
}

