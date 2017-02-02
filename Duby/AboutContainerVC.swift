//
//  AboutContainerVC.swift
//  Duby
//
//  Created by Harsh Damania on 2/8/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

/// Is in a container to eliminate layout issues with tableviews
class AboutContainerVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        (navigationController as! DubyNavVC).barColor = .White
        view.addSubview(UINavigationBar.dubyWhiteBar())
        
        edgesForExtendedLayout = .None
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
