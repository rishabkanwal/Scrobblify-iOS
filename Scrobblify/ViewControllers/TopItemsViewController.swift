//
//  TopItemsViewController.swift
//  Scrobblify
//
//  Created by Rishab Kanwal on 6/12/17.
//  Copyright © 2017 Rishab Kanwal. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher

class TopItemsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var timePeriodSegmentedControl: UISegmentedControl!
    @IBOutlet weak var topItemsTableView: UITableView!
    
    
    var refreshControl: UIRefreshControl!
    
    var topItems: [TopItem] = []
    
    var currentPage = 1
    
    var totalTopItems = -1
    
    var apiMethod: String?
    
    var baseJsonObject: String?
    
    var mainJsonObject: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRefreshControl()
        updateTopItems(isRefresh: true)
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
        updateTopItems(isRefresh: true)
        self.currentPage = 1
        self.topItems = []
        self.topItemsTableView.reloadData()
    }
    
    func updateTopItems(isRefresh: Bool) {
        AppState.shared.requestsQueue.sync {
            if (isRefresh) {
                self.currentPage = 1
                self.topItems = []
            } else {
                self.currentPage += 1
            }
            AppState.shared.lastFmRequest.getTopItems(apiMethod: apiMethod!, page: self.currentPage, timePeriod: self.getCurrentTimePeriod(), completionHandler: {
                responseJsonString, error in
                if !(error != nil) {
                    let responseJson = JSON(data: responseJsonString!.data(using: .utf8, allowLossyConversion: false)!)
                    self.totalTopItems = Int(responseJson[self.baseJsonObject!]["@attr"]["total"].string!)!
                    for (_, valueJson) in responseJson[self.baseJsonObject!][self.mainJsonObject!] {
                        self.topItems.append(TopItem(JSONString: valueJson.rawString()!)!)
                    }
                    DispatchQueue.main.async(execute: {
                        self.refreshControl.endRefreshing()
                        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
                        self.topItemsTableView.reloadData()
                    })
                }
            })
        }
    }
    
    
    
    func setupRefreshControl(){
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(TopItemsViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        self.topItemsTableView.addSubview(refreshControl)
        
    }
    
    func refresh(_ sender: AnyObject){
        self.refreshControl.attributedTitle = NSAttributedString(string: "Refreshing")
        if(topItems.count != 0) {
            self.updateTopItems(isRefresh: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (totalTopItems == self.topItems.count) {
            return self.topItems.count
        } else {
            return self.topItems.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        if (indexPath.row < self.topItems.count) {
            let currentTopItem = topItems[indexPath.row]
            
            let topItemCell = tableView.dequeueReusableCell(withIdentifier: "TopItemTableViewCell", for: indexPath) as! TopItemTableViewCell
            
            topItemCell.selectionStyle = .none
            topItemCell.artImageView.layer.cornerRadius = 4;
            topItemCell.nameLabel.text = currentTopItem.name!
            topItemCell.playsLabel.text = currentTopItem.playcount! + " Plays"
            topItemCell.rankLabel.text = "#" + currentTopItem.rank! + " Most Played"
            if (currentTopItem.imageUrl != nil) {
                topItemCell.artImageView.kf.setImage(with: ImageResource(downloadURL: currentTopItem.imageUrl!))
            } else {
                topItemCell.artImageView.image = UIImage(named: "Disc")
            }
            
            return topItemCell
            
        } else {
            let loadingCell =  tableView.dequeueReusableCell(withIdentifier: "LoadingTopItemsTableViewCell", for: indexPath) as! LoadingTopItemsTableViewCell
            loadingCell.selectionStyle = .none
            loadingCell.loadingActivityIndicator.startAnimating()
            return loadingCell
        }
    }
    
    func loadMoreTopItems(scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 74 {
            updateTopItems(isRefresh: false)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        loadMoreTopItems(scrollView: scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        loadMoreTopItems(scrollView: scrollView)
    }
    
    
}

