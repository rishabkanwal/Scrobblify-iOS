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
        getNowPlayingInfo()
    }
    
    func updateRecentTracks(isRefresh: Bool) {
        AppState.shared.requestsQueue.sync {
            if (isRefresh) {
                self.currentPage = 1
                self.recentTracks = []
            } else {
                self.currentPage += 1
            }
            AppState.shared.lastFmRequest.getRecentTracks(page: self.currentPage, completionHandler: {
                responseJsonString, error in
                if !(error != nil) {
                    let responseJson = JSON(data: responseJsonString!.data(using: .utf8, allowLossyConversion: false)!)
                    self.totalTracks = Int(responseJson["recenttracks"]["@attr"]["total"].string!)!
                    for (_, valueJson) in responseJson["recenttracks"]["track"] {
                        self.recentTracks.append(RecentTrack(JSONString: valueJson.rawString()!)!)
                    }
                    DispatchQueue.main.async(execute: {
                        self.refreshControl.endRefreshing()
                        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
                        self.recentsTableView.reloadData()
                    })
                }
                
            })
        }
        
    }
    
    func setupRefreshControl(){
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(RecentsViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        self.recentsTableView.addSubview(refreshControl)
    }
    
    func refresh(_ sender: AnyObject){
        self.refreshControl.attributedTitle = NSAttributedString(string: "Refreshing")
        if(recentTracks.count != 0) {
            updateRecentTracks(isRefresh: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (totalTracks == self.recentTracks.count) {
            return self.recentTracks.count
        } else {
            return self.recentTracks.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        if (indexPath.row < self.recentTracks.count) {
            let currentRecentTrack = recentTracks[indexPath.row]
            
            let recentTrackCell = tableView.dequeueReusableCell(withIdentifier: "RecentTrackTableViewCell", for: indexPath) as! RecentTrackTableViewCell
            
            recentTrackCell.selectionStyle = .none
            recentTrackCell.artImageView.layer.cornerRadius = 4;
            recentTrackCell.nameLabel.text = currentRecentTrack.name!
            recentTrackCell.artistLabel.text = currentRecentTrack.artist!
            recentTrackCell.timeLabel.text = (currentRecentTrack.nowPlaying != nil) ? "Playing now" : currentRecentTrack.getFormattedTimestamp()
            if (currentRecentTrack.imageUrl != nil) {
                recentTrackCell.artImageView.kf.setImage(with: ImageResource(downloadURL: currentRecentTrack.imageUrl!))
            } else {
                recentTrackCell.artImageView.image = UIImage(named: "Disc")
            }
            
            return recentTrackCell
        } else {
            let loadingCell =  tableView.dequeueReusableCell(withIdentifier: "LoadingRecentsTableViewCell", for: indexPath) as! LoadingRecentsTableViewCell
            loadingCell.selectionStyle = .none
            loadingCell.loadingActivityIndicator.startAnimating()
            return loadingCell
        }
    }
    
    func loadMoreRecents(scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 74 {
            updateRecentTracks(isRefresh: false)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        loadMoreRecents(scrollView: scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        loadMoreRecents(scrollView: scrollView)
    }
    
    func getNowPlayingInfo() {
        let nowPlaying = MPMusicPlayerController.systemMusicPlayer().nowPlayingItem
        if (nowPlaying != nil) {
            let track = nowPlaying!.title!
            let artist = nowPlaying!.artist!
            let album = nowPlaying!.albumTitle!
            let albumArtist = nowPlaying!.albumArtist!
            AppState.shared.lastFmRequest
                .searchTrack(track: track, artist: artist,
                             completionHandler: {
                                responseJsonString, error in
                                if !(error != nil) {
                                    let searchTrack = SearchTrack(JSONString: responseJsonString!)
                                    if (searchTrack?.name != nil) {
                                        AppState.shared.lastFmRequest.updateNowPlaying (track: track, artist: artist, album: album, albumArtist: albumArtist, mbid: searchTrack!.mbid!, timestamp: Int(Date().timeIntervalSince1970), completionHandler: {
                                            responseJsonString, error in
                                            if !(error != nil) {
                                                print(responseJsonString!)
                                                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                                    self.updateRecentTracks(isRefresh: true)
                                                })
                                            } else{}
                                        })
                                    }
                                    
                                } else {}
                })
        }
    }
    
}

