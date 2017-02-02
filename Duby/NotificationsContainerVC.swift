//
//  NotificationsContainerVC.swift
//  Duby
//
//  Created by Anurag Kamasamudram on 3/19/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

class NotificationsContainerVC: UIViewController {

    override func viewDidLoad() {
//        (navigationController as! DubyNavVC).barColor = .White
//        view.addSubview(UINavigationBar.dubyWhiteBar())
        
        navigationController?.navigationBar.translucent = true
        navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        (navigationController as! DubyNavVC).barColor = .White
        view.addSubview(UINavigationBar.dubyWhiteBar())
        
        edgesForExtendedLayout = .None
    }
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
    }
    
    override func viewDidAppear(animated: Bool) {
        // analytics
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Notifications")
        tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject: AnyObject])
        
        super.viewDidAppear(animated)
    }
}
