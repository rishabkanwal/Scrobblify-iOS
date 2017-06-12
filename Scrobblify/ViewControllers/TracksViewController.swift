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

class TracksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var timePeriodSegmentedControl: UISegmentedControl!
    @IBOutlet weak var tracksTableView: UITableView!
    
    var refreshControl: UIRefreshControl!
    
    var tracks: [Track] = []
    
    var currentPage = 1
    
    var totalTracks = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRefreshControl()
        updateTracks(isRefresh: true)
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
        updateTracks(isRefresh: true)
        self.currentPage = 1
        self.tracks = []
        self.tracksTableView.reloadData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateTracks(isRefresh: Bool) {
        AppState.shared.requestsQueue.sync {
            if (isRefresh) {
                self.currentPage = 1
                self.tracks = []
            } else {
                self.currentPage += 1
            }
            AppState.shared.lastFmRequest.getTopTracks(page: self.currentPage, timePeriod: self.getCurrentTimePeriod(), completionHandler: {
                responseJsonString, error in
                if !(error != nil) {
                    let responseJson = JSON(data: responseJsonString!.data(using: .utf8, allowLossyConversion: false)!)
                    self.totalTracks = Int(responseJson["toptracks"]["@attr"]["total"].string!)!
                    for (_, valueJson) in responseJson["toptracks"]["track"] {
                        self.tracks.append(Track(JSONString: valueJson.rawString()!)!)
                    }
                    DispatchQueue.main.async(execute: {
                        self.refreshControl.endRefreshing()
                        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
                        self.tracksTableView.reloadData()
                    })
                }
            })
        }
    }
    
    
    
    func setupRefreshControl(){
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(TracksViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        self.tracksTableView.addSubview(refreshControl)
        
    }
    
    func refresh(_ sender: AnyObject){
        self.refreshControl.attributedTitle = NSAttributedString(string: "Refreshing")
        if(tracks.count != 0) {
            self.updateTracks(isRefresh: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (totalTracks == self.tracks.count) {
            return self.tracks.count
        } else {
            return self.tracks.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        if (indexPath.row < self.tracks.count) {
            let currentTrack = tracks[indexPath.row]
            
            let trackCell = tableView.dequeueReusableCell(withIdentifier: "TrackTableViewCell", for: indexPath) as! TrackTableViewCell
            
            trackCell.selectionStyle = .none
            trackCell.artImageView.layer.cornerRadius = 4;
            trackCell.nameLabel.text = currentTrack.name!
            trackCell.playsLabel.text = currentTrack.playcount! + " Plays"
            trackCell.rankLabel.text = "#" + currentTrack.rank! + " Most Played"
            if (currentTrack.imageUrl != nil) {
                trackCell.artImageView.kf.setImage(with: ImageResource(downloadURL: currentTrack.imageUrl!))
            } else {
                trackCell.artImageView.image = UIImage(named: "Disc")
            }
            return trackCell
        } else {
            let loadingCell =  tableView.dequeueReusableCell(withIdentifier: "LoadingTracksTableViewCell", for: indexPath) as! LoadingTracksTableViewCell
            loadingCell.selectionStyle = .none
            loadingCell.loadingActivityIndicator.startAnimating()
            return loadingCell
        }
    }
    
    func loadMoreTracks(scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 74 {
            updateTracks(isRefresh: false)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        loadMoreTracks(scrollView: scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        loadMoreTracks(scrollView: scrollView)
    }
    
    
}

