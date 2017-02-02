//
//  TabBarContainerVC.swift
//  Duby
//
//  Created by Harsh Damania on 2/27/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

// used for constant background image
class TabBarContainerVC: UIViewController {
    
    var userSignedUp = false
    weak var tabbarVC : TabBarController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // custom to set if user just sign up
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TabBarSegue" {
            
            let tabbarVC = segue.destinationViewController as! TabBarController
            tabbarVC.userSignedUp = userSignedUp
            self.tabbarVC = tabbarVC
        }
    }
}
