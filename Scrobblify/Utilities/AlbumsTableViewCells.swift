//
//  File.swift
//  Scrobblify
//
//  Created by Rishab Kanwal on 6/12/17.
//  Copyright © 2017 Rishab Kanwal. All rights reserved.
//

import UIKit

class AlbumTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var playsLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var artImageView: UIImageView!
    
}

class LoadingAlbumsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
}
