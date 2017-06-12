//
//  TracksTableViewCells.swift
//  Scrobblify
//
//  Created by Rishab Kanwal on 6/12/17.
//  Copyright © 2017 Rishab Kanwal. All rights reserved.
//

import UIKit

class TrackTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var playsLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var artImageView: UIImageView!
    
}

class LoadingTracksTableViewCell: UITableViewCell {
    
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
}
