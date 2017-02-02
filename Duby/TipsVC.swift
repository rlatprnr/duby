//
//  TipsVC.swift
//  Duby
//
//  Created by Harsh Damania on 3/20/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

/// View controller presented to show tips images
class TipsVC: UIViewController {

    @IBOutlet weak var tipsImageView: UIImageView!
    
    var tipType: TipsControllers!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let deviceName = Constants.currentDeviceModelName()
        
        let tipsImage = UIImage.tipsImage(tipType, deviceName: deviceName as String)
        
        if tipsImage != nil {
            tipsImageView.image = tipsImage

            self.tipsImageView.userInteractionEnabled = true
            self.tipsImageView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissTipView:"))
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }
    
    func dismissTipView(sender: UITapGestureRecognizer) {
        dismissViewControllerAnimated(true, completion: { () -> Void in
            if (self.tipType == TipsControllers.Profile || self.tipType == TipsControllers.Stats) {
                UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
            }
        })
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
