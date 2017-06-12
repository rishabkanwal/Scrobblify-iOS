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

class AlbumsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var timePeriodSegmentedControl: UISegmentedControl!
    @IBOutlet weak var albumsTableView: UITableView!
    
    var refreshControl: UIRefreshControl!
    
    var albums: [Album] = []
    
    var currentPage = 1
    
    var totalAlbums = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRefreshControl()
        updateAlbums(isRefresh: true)
    }
    
    func getCurrentTimePeriod() -> String {
        switch timePeriodSegmentedControl.selectedSegmentIndex
        {
        case 0:
            return "7day"
        case 1:
            return "1month"
        case 2:
            return "12month"
        case 3:
            return "overall"
        default:
            break
        }
        return "7day"
    }
    
    @IBAction func timeFrameChanged(_ sender: Any) {
        updateAlbums(isRefresh: true)
        self.currentPage = 1
        self.albums = []
        self.albumsTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateAlbums(isRefresh: Bool) {
        AppState.shared.requestsQueue.sync {
            if (isRefresh) {
                self.currentPage = 1
                self.albums = []
            } else {
                self.currentPage += 1
            }
            AppState.shared.lastFmRequest.getTopAlbums(page: self.currentPage, timePeriod: self.getCurrentTimePeriod(), completionHandler: {
                responseJsonString, error in
                if !(error != nil) {
                    let responseJson = JSON(data: responseJsonString!.data(using: .utf8, allowLossyConversion: false)!)
                    self.totalAlbums = Int(responseJson["topalbums"]["@attr"]["total"].string!)!
                    for (_, valueJson) in responseJson["topalbums"]["album"] {
                        self.albums.append(Album(JSONString: valueJson.rawString()!)!)
                    }
                    DispatchQueue.main.async(execute: {
                        self.refreshControl.endRefreshing()
                        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
                        self.albumsTableView.reloadData()
                    })
                }
            })
        }
    }
    
    
    
    func setupRefreshControl(){
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(AlbumsViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        self.albumsTableView.addSubview(refreshControl)
        
    }
    
    func refresh(_ sender: AnyObject){
        self.refreshControl.attributedTitle = NSAttributedString(string: "Refreshing")
        if(albums.count != 0) {
            self.updateAlbums(isRefresh: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (totalAlbums == self.albums.count) {
            return self.albums.count
        } else {
            return self.albums.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        if (indexPath.row < self.albums.count) {
            let currentAlbum = albums[indexPath.row]
            
            let albumCell = tableView.dequeueReusableCell(withIdentifier: "AlbumTableViewCell", for: indexPath) as! AlbumTableViewCell

            albumCell.selectionStyle = .none
            albumCell.artImageView.layer.cornerRadius = 4;
            albumCell.nameLabel.text = currentAlbum.name!
            albumCell.playsLabel.text = currentAlbum.playcount! + " Plays"
            albumCell.rankLabel.text = "#" + currentAlbum.rank! + " Most Played"
            if (currentAlbum.imageUrl != nil) {
                albumCell.artImageView.kf.setImage(with: ImageResource(downloadURL: currentAlbum.imageUrl!))
            } else {
                albumCell.artImageView.image = UIImage(named: "Disc")
            }
            
            return albumCell
        } else {
            let loadingCell =  tableView.dequeueReusableCell(withIdentifier: "LoadingAlbumsTableViewCell", for: indexPath) as! LoadingAlbumsTableViewCell
            loadingCell.selectionStyle = .none
            loadingCell.loadingActivityIndicator.startAnimating()
            return loadingCell
        }
    }
    
    func loadMoreAlbums(scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 74 {
            updateAlbums(isRefresh: false)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        loadMoreAlbums(scrollView: scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        loadMoreAlbums(scrollView: scrollView)
    }
    
    
}
