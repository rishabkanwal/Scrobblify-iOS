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

class ArtistsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var timePeriodSegmentedControl: UISegmentedControl!
    @IBOutlet weak var artistsTableView: UITableView!
    
    var refreshControl: UIRefreshControl!
    
    var artists: [Artist] = []
    
    var currentPage = 1
    
    var totalArtists = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRefreshControl()
        updateArtists(isRefresh: true)
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
        updateArtists(isRefresh: true)
        self.currentPage = 1
        self.artists = []
        self.artistsTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateArtists(isRefresh: Bool) {
        AppState.shared.requestsQueue.sync {
            if (isRefresh) {
                self.currentPage = 1
                self.artists = []
            } else {
                self.currentPage += 1
            }
            AppState.shared.lastFmRequest.getTopArtists(page: self.currentPage, timePeriod: self.getCurrentTimePeriod(), completionHandler: {
                responseJsonString, error in
                if !(error != nil) {
                    let responseJson = JSON(data: responseJsonString!.data(using: .utf8, allowLossyConversion: false)!)
                    self.totalArtists = Int(responseJson["topartists"]["@attr"]["total"].string!)!
                    for (_, valueJson) in responseJson["topartists"]["artist"] {
                        self.artists.append(Artist(JSONString: valueJson.rawString()!)!)
                    }
                    DispatchQueue.main.async(execute: {
                        self.refreshControl.endRefreshing()
                        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
                        self.artistsTableView.reloadData()
                    })
                }
            })
        }
    }
    
    
    
    func setupRefreshControl(){
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(ArtistsViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        self.artistsTableView.addSubview(refreshControl)
        
    }
    
    func refresh(_ sender: AnyObject){
        self.refreshControl.attributedTitle = NSAttributedString(string: "Refreshing")
        if(artists.count != 0) {
            self.updateArtists(isRefresh: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (totalArtists == self.artists.count) {
            return self.artists.count
        } else {
            return self.artists.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        if (indexPath.row < self.artists.count) {
            let currentArtist = self.artists[indexPath.row]
            
            let artistCell: ArtistTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ArtistTableViewCell", for: indexPath) as! ArtistTableViewCell
            
            artistCell.artImageView.layer.cornerRadius = 4;
            
            artistCell.nameLabel.text = currentArtist.name!
            artistCell.playsLabel.text = currentArtist.playcount! + " Plays"
            artistCell.rankLabel.text = "#" + currentArtist.rank! + " Most Played"
            if (currentArtist.imageUrl != nil) {
                artistCell.artImageView.kf.setImage(with: ImageResource(downloadURL: currentArtist.imageUrl!))
            } else {
                artistCell.artImageView.image = UIImage(named: "Disc")
            }
            
            return artistCell
        } else {
            let loadingCell =  tableView.dequeueReusableCell(withIdentifier: "LoadingArtistsTableViewCell", for: indexPath) as! LoadingArtistsTableViewCell
            loadingCell.loadingActivityIndicator.startAnimating()
            return loadingCell
        }
    }
    
    func loadMoreArtists(scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 74 {
            self.updateArtists(isRefresh: false)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        loadMoreArtists(scrollView: scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        loadMoreArtists(scrollView: scrollView)
    }
    
    
}

