//
//  RecentsViewController.swift
//  Scrobblify
//
//  Created by Rishab Kanwal on 6/11/17.
//  Copyright © 2017 Rishab Kanwal. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher
import MediaPlayer

class RecentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var recentsTableView: UITableView!
    
    var refreshControl: UIRefreshControl!
    
    var recentTracks: [RecentTrack] = []
    
    var currentPage = 1
    
    var totalTracks = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRefreshControl()
        updateRecentTracks(isRefresh: true)
        updateNowPlaying()
        AppState.shared.scrobbleManager.updateInBackground()
    }
    
    func updateNowPlaying() {
        AppState.shared.scrobbleManager.update()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.updateRecentTracks(isRefresh: true)
        })
    }
    
    func updateRecentTracks(isRefresh: Bool) {
        AppState.shared.requestsQueue.sync {
            if (isRefresh) {
                self.currentPage = 1
                self.recentTracks = []
            } else {
                self.currentPage += 1
            }
            AppState.shared.requestManager.getRecentTracks(page: self.currentPage, completionHandler: {
                responseJsonString, error in
                if (error == nil) {
                    let responseJson = JSON(data: responseJsonString!.data(using: .utf8, allowLossyConversion: false)!)
                    self.totalTracks = Int(responseJson["recenttracks"]["@attr"]["total"].string!)!
                    for (_, valueJson) in responseJson["recenttracks"]["track"] {
                        let newRecentTrack = RecentTrack(JSONString: valueJson.rawString()!)!
                        if (self.recentTracks.count > 0 && newRecentTrack.nowPlaying != nil)  {
                            continue
                        } else {
                            self.recentTracks.append(newRecentTrack)
                        }
                    }
                    if (self.recentTracks.count == self.totalTracks) {
                        self.hideTableFooter()
                    } else {
                        self.showTableFooter()
                    }
                    DispatchQueue.main.async(execute: {
                        self.refreshControl.endRefreshing()
                        self.recentsTableView.reloadData()
                    })
                } else {
                    makeSnackbar(message: "Network unavailable, refresh to try again")
                    self.hideTableFooter()
                }
                
            })
        }
        
    }
    
    func scrollToTopAndRefresh() {
        recentsTableView.setContentOffset(CGPoint(x: 0, y: -refreshControl.frame.size.height), animated: true)
        refreshControl.beginRefreshing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
            self.refresh(self.refreshControl)
        })
    }
    
    func showTableFooter() {
        recentsTableView.tableFooterView?.frame.size.height = 74
        recentsTableView.tableFooterView?.isHidden = false
    }
    
    func hideTableFooter() {
        recentsTableView.tableFooterView?.frame.size.height = 0
        recentsTableView.tableFooterView?.isHidden = true
    }
    
    func setupRefreshControl(){
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(RecentsViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        self.recentsTableView.insertSubview(refreshControl, at: 0)
    }
    
    func refresh(_ sender: AnyObject){
        if recentTracks.count < totalTracks {
            
        }
        if(recentTracks.count != 0) {
            updateRecentTracks(isRefresh: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return recentTracks.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let recentTrackCell = tableView.dequeueReusableCell(withIdentifier: "RecentTrackTableViewCell", for: indexPath) as! RecentTrackTableViewCell
        recentTrackCell.selectionStyle = .none

        if (indexPath.row < self.recentTracks.count) {
            let currentRecentTrack = recentTracks[indexPath.row]
            recentTrackCell.artImageView.layer.cornerRadius = 4;
            recentTrackCell.nameLabel.text = currentRecentTrack.name!
            recentTrackCell.artistLabel.text = currentRecentTrack.artist!
            recentTrackCell.timeLabel.text = (currentRecentTrack.nowPlaying != nil) ? "Playing now" : currentRecentTrack.getFormattedTimestamp()
            if (currentRecentTrack.imageUrl != nil) {
                recentTrackCell.artImageView.kf.setImage(with: ImageResource(downloadURL: currentRecentTrack.imageUrl!))
            } else {
                recentTrackCell.artImageView.image = UIImage(named: "Disc")
            }
            
        }
        
        return recentTrackCell

    }
    
    func loadMoreRecents(scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if (maximumOffset - currentOffset <= 74 && recentTracks.count < totalTracks){
            updateRecentTracks(isRefresh: false)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        loadMoreRecents(scrollView: scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        loadMoreRecents(scrollView: scrollView)
    }
    
}

