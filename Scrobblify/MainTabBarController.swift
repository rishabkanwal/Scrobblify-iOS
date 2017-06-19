//
//  TabBarController.swift
//  Scrobblify
//
//  Created by Rishab Kanwal on 6/18/17.
//  Copyright © 2017 Rishab Kanwal. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    var currentTag = 0
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if (currentTag == item.tag) {
            if (currentTag == 0) {
                (selectedViewController?.childViewControllers[0] as! RecentsViewController).scrollToTopAndRefresh()
            } else if (item.tag < 4){
                (selectedViewController?.childViewControllers[0].childViewControllers[0] as! TopItemsViewController).scrollToTopAndRefresh()
            }
        } else {
            currentTag = item.tag
        }
    }

}
