//
//  UpdateVC.swift
//  Duby
//
//  Created by Aziz on 2015-04-30.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

class UpdateVC: UIViewController {
    let appID = "966442183"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func updateButtonPressed(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: NSString(format: "itms-apps://itunes.apple.com/app/id%@", appID) as String)!)
    }
}
