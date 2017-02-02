//
//  TabBarController.swift
//  Duby
//
//  Created by Wilson on 1/5/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit


class TabBarController: UITabBarController {
    
    var userSignedUp = false
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"updateBadgeCount", name: NOTIFICATION_BADGE_UPDATE, object: nil)
        setupTabBar()
    }
    
    func setupTabBar() {
        var count = 0
        for item in tabBar.items! {
            item.image = item.image?.imageWithRenderingMode(.AlwaysOriginal)
            item.selectedImage = item.selectedImage!.imageWithRenderingMode(.AlwaysOriginal)
            item.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
            item.title = nil
            
            if count == 3 {
                if UIApplication.sharedApplication().applicationIconBadgeNumber == 0 {
                    item.badgeValue = nil
                } else {
                    item.badgeValue = String(UIApplication.sharedApplication().applicationIconBadgeNumber)
                }
            }
            ++count
        }
    }
    
    func updateBadgeCount() {
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        if self.tabBar.items?.count == 5 {
          if UIApplication.sharedApplication().applicationIconBadgeNumber == 0 {
            (self.tabBar.items![3] ).badgeValue = nil
          } else {
            (self.tabBar.items![3] ).badgeValue = String(UIApplication.sharedApplication().applicationIconBadgeNumber)
          }
        }
      })
    }
}
