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

class RecentsViewController: UIViewController {
    
    @IBOutlet weak var recentsTableView: UITableView!
    
    var refreshControl: UIRefreshControl!
    
    var currentPage = 1
    var recentTracks: [RecentTrack] = []
    var totalTracks = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRefreshControl()
        updateRecentTracks(isRefresh: true)
        
        showEnableScrobblingDialogIfNeeded()
        showEnablePermissionsDialogIfNeeded()
        
        NotificationCenter.default.addObserver(self, selector: #selector(showEnablePermissionsDialogIfNeeded), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
    }
    
    @objc func refresh(_ sender: AnyObject){
        if recentTracks.count != 0 {
            updateRecentTracks(isRefresh: true)
        }
    }
    
    func setupRefreshControl(){
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(RecentsViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        
        recentsTableView.insertSubview(refreshControl, at: 0)
    }
    
    func updateRecentTracks(isRefresh: Bool) {
        AppState.shared.requestsQueue.sync {
            if isRefresh {
                self.currentPage = 1
                self.recentTracks = []
            } else {
                self.currentPage += 1
            }
            
            AppState.shared.lastFmRequestManager.getRecentTracks(page: self.currentPage, completionHandler: { responseJsonString, error in
                guard error == nil else {
                    makeSnackbar(message: "Network unavailable, refresh to try again")
                    
                    self.hideTableFooter()
                    
                    return
                }
                
                if let responseJson = try? JSON(data: responseJsonString!.data(using: .utf8, allowLossyConversion: false)!) {
                    self.totalTracks = Int(responseJson["recenttracks"]["@attr"]["total"].string!)!
                    
                    for (_, valueJson) in responseJson["recenttracks"]["track"] {
                        let newRecentTrack = RecentTrack(JSONString: valueJson.rawString()!)!
                        
                        if self.recentTracks.count > 0 && newRecentTrack.nowPlaying != nil {
                            continue
                        } else {
                            self.recentTracks.append(newRecentTrack)
                        }
                    }
                    
                    if self.recentTracks.count >= self.totalTracks {
                        self.hideTableFooter()
                    } else {
                        self.showTableFooter()
                    }
                    
                    DispatchQueue.main.async(execute: {
                        self.refreshControl.endRefreshing()
                        
                        self.recentsTableView.reloadData()
                    })
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
    
    func loadMoreRecents(scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 74 && recentTracks.count < totalTracks {
            updateRecentTracks(isRefresh: false)
        }
    }
    
    func showEnableScrobblingDialogIfNeeded() {
        if AppState.shared.shouldShowEnableScrobblingDialog() {
            let alert = UIAlertController(title: "Enable Apple Music Scrobbling?", message: "Would you like to enable scrobbling for Apple Music? You may be asked to give Scrobblify permissions to access Media & Apple Music", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: {
                action in
                AppState.shared.disableEnableScrobblingDialog()
            }))
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {
                action in
                AppState.shared.enableScrobbling()
                AppState.shared.disableEnableScrobblingDialog()
            }))
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func showEnablePermissionsDialogIfNeeded() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
            if MPMediaLibrary.authorizationStatus() != .authorized && AppState.shared.scrobblingEnabled && !AppState.shared.shouldShowEnableScrobblingDialog() {
                let alert = UIAlertController(title: "Could not access Media & Apple Music Permissions", message: "For Scrobbling to work you need to allow Scrobblify to access Media & Apple Music in settings, if you don't  see the permissions in settings try playing some music", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "Go to Settings", style: UIAlertActionStyle.default, handler: {
                    action in
                    openSettings()
                }))
                alert.addAction(UIAlertAction(title: "Disable Scrobbling", style: UIAlertActionStyle.default, handler: {
                    action in
                    AppState.shared.disableScrobbling()
                }))
                alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default, handler: {
                    action in
                    self.showEnablePermissionsDialogIfNeeded()
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
}

extension RecentsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentTracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let recentTrackCell = tableView.dequeueReusableCell(withIdentifier: "RecentTrackTableViewCell", for: indexPath) as! RecentTrackTableViewCell
        
        recentTrackCell.selectionStyle = .none
        
        if indexPath.row < recentTracks.count {
            let currentRecentTrack = recentTracks[indexPath.row]
            
            recentTrackCell.artImageView.layer.cornerRadius = 4;
            recentTrackCell.nameLabel.text = currentRecentTrack.name
            recentTrackCell.artistLabel.text = currentRecentTrack.artist
            recentTrackCell.timeLabel.text = (currentRecentTrack.nowPlaying != nil) ? "Playing now" : currentRecentTrack.getFormattedTimestamp()
            
            if let imageUrl = currentRecentTrack.imageUrl {
                recentTrackCell.artImageView.kf.setImage(with: ImageResource(downloadURL: imageUrl))
            }
        }
        return recentTrackCell
    }
    
}

extension RecentsViewController: UITableViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        loadMoreRecents(scrollView: scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        loadMoreRecents(scrollView: scrollView)
    }
    
}

