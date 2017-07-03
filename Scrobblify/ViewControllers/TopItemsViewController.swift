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

class TopItemsViewController: UIViewController {
    
    @IBOutlet weak var timePeriodSegmentedControl: UISegmentedControl!
    @IBOutlet weak var topItemsTableView: UITableView!
    
    var refreshControl: UIRefreshControl!
    
    var currentPage = 1
    var topItems: [TopItem] = []
    var totalTopItems = -1
    
    var apiMethod: String?
    var baseJsonObject: String?
    var mainJsonObject: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRefreshControl()
        updateTopItems(isRefresh: true)
    }
    
    @IBAction func timeFrameChanged(_ sender: Any) {
        currentPage = 1
        topItems = []
        topItemsTableView.reloadData()
        
        showTableFooter()
        
        updateTopItems(isRefresh: true)
    }
    
    func refresh(_ sender: AnyObject){
        if topItems.count != 0 {
            updateTopItems(isRefresh: true)
        }
    }
    
    func setupRefreshControl(){
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(TopItemsViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        
        topItemsTableView.addSubview(refreshControl)
    }
    
    func updateTopItems(isRefresh: Bool) {
        AppState.shared.requestsQueue.sync {
            if isRefresh {
                self.currentPage = 1
                self.topItems = []
            } else {
                self.currentPage += 1
            }
            AppState.shared.lastFmRequestManager.getTopItems(apiMethod: apiMethod!, page: self.currentPage, timePeriod: self.getCurrentTimePeriod(), completionHandler: { responseJsonString, error in
                guard error == nil else {
                    makeSnackbar(message: "Network unavailable, refresh to try again")
                    
                    self.hideTableFooter()
                    
                    return
                }
                
                let responseJson = JSON(data: responseJsonString!.data(using: .utf8, allowLossyConversion: false)!)
                
                self.totalTopItems = Int(responseJson[self.baseJsonObject!]["@attr"]["total"].string!)!
                
                for (_, valueJson) in responseJson[self.baseJsonObject!][self.mainJsonObject!] {
                    self.topItems.append(TopItem(JSONString: valueJson.rawString()!)!)
                }
                
                if self.topItems.count == self.totalTopItems {
                    self.hideTableFooter()
                } else {
                    self.showTableFooter()
                }
                
                DispatchQueue.main.async(execute: {
                    self.refreshControl.endRefreshing()
                    
                    self.topItemsTableView.reloadData()
                })
            })
        }
    }
    
    func scrollToTopAndRefresh() {
        topItemsTableView.setContentOffset(CGPoint(x: 0, y: -refreshControl.frame.size.height), animated: true)
        
        refreshControl.beginRefreshing()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
            self.refresh(self.refreshControl)
        })
        
    }
    func showTableFooter() {
        topItemsTableView.tableFooterView?.frame.size.height = 74
        topItemsTableView.tableFooterView?.isHidden = false
    }
    
    func hideTableFooter() {
        topItemsTableView.tableFooterView?.frame.size.height = 0
        topItemsTableView.tableFooterView?.isHidden = true
    }
    
    func loadMoreTopItems(scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 74 {
            updateTopItems(isRefresh: false)
        }
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
    
}

extension TopItemsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let topItemCell = tableView.dequeueReusableCell(withIdentifier: "TopItemTableViewCell", for: indexPath) as! TopItemTableViewCell
        
        topItemCell.selectionStyle = .none
        
        if indexPath.row < topItems.count {
            let currentTopItem = topItems[indexPath.row]
            
            topItemCell.artImageView.layer.cornerRadius = 4;
            topItemCell.nameLabel.text = currentTopItem.name
            topItemCell.playsLabel.text = currentTopItem.playcount! + " Plays"
            topItemCell.rankLabel.text = "#" + currentTopItem.rank! + " Most Played"
            
            if let imageUrl = currentTopItem.imageUrl {
                topItemCell.artImageView.kf.setImage(with: ImageResource(downloadURL: imageUrl))
            }
            
            
        }
        return topItemCell
    }
    
}

extension TopItemsViewController: UITableViewDataSource {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        loadMoreTopItems(scrollView: scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        loadMoreTopItems(scrollView: scrollView)
    }
    
}

