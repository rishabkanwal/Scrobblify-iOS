//
//  AlbumsViewController.swift
//  Scrobblify
//
//  Created by Rishab Kanwal on 6/12/17.
//  Copyright © 2017 Rishab Kanwal. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher

class AlbumsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "AlbumsToTopItemsSegue") {
            let topItemsViewController = segue.destination  as! TopItemsViewController
            topItemsViewController.apiMethod = "user.getTopAlbums"
            topItemsViewController.baseJsonObject = "topalbums"
            topItemsViewController.mainJsonObject = "album"
        }
    }
    
}
