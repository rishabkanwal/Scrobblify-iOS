//
//  RecentTrackTableViewCell.swift
//  Scrobblify
//
//  Created by Rishab Kanwal on 6/11/17.
//  Copyright © 2017 Rishab Kanwal. All rights reserved.
//

import UIKit

class RecentTrackTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var artImageView: UIImageView!
    
}

class LoadingRecentsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
}
