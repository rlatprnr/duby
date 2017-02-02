//
//  PreviewVC.swift
//  Duby
//
//  Created by Harsh Damania on 2/5/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

// WE USED TO USE THIS. WE MIGHT NEED IT BACK LATER.
// This is simply use to preview the duby. Kind of the same thing as Create...
class PreviewVC: UIViewController {
    
    var dubyImage: UIImage?
    var descriptionText: String!
    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet weak private var dubyImageView: UIImageView!
    @IBOutlet weak private var descriptionTextView: UITextView!
    @IBOutlet weak private var lightItUpButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        (navigationController as! DubyNavVC).barColor = .Clear

        if dubyImage == nil {
            descriptionTextView.text = ""
            descriptionLabel.text = descriptionText
            descriptionLabel.hidden = false
            dubyImageView.backgroundColor = UIColor.whiteColor()
        } else {
            dubyImageView.image = dubyImage
            descriptionTextView.text = descriptionText
            descriptionTextView.textColor = UIColor.whiteColor()
            descriptionTextView.font = UIFont.openSans(14)
            descriptionLabel.hidden = true
        }
    }
    
    @IBAction func lightItUpPressed(sender: AnyObject) {
        if LocationManager.sharedInstance.hasLocation {
            _ = ["createdBy" : DubyUser.currentUser.getParsePointerDictionary(),
                "location" : "\(LocationManager.sharedInstance.city), \(LocationManager.sharedInstance.state)",
                "description" : descriptionText,
                "isVideo" : false,
                "location_geo" : LocationManager.sharedInstance.getParseGeoPointDictionary(),
                "hashtags" : descriptionText.getHashtags(),
                "shareCount": 0,
                "commentCount": 0,
                "usersSharedTo": [DubyUser.currentUser.getParsePointerDictionary()]] as Dictionary<String, AnyObject>
            
            MBProgressHUD.showHUDAddedTo(view, animated: true)
//            DubyDatabase.createDuby(image: dubyImage, dubyParams: dubyDict, completion: { (created, error) -> Void in
//                if created {
//                    println("created !!!!!!")
//                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                        self.navigationController?.popToRootViewControllerAnimated(true)
//                        NSNotificationCenter.defaultCenter().postNotificationName("DubyCreated", object: nil, userInfo: nil)
//                        MBProgressHUD.hideHUDForView(self.view, animated: true)
//                    })
//                } else {
//                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                        println("error \(error?.localizedDescription)")
//                        MBProgressHUD.hideHUDForView(self.view, animated: true)
//                        UIAlertView(title: "Error", message: "There was an error creating Duby. PLease try again", delegate: nil, cancelButtonTitle: OK).show()
//                    })
//                }
//            })
        } else {
            UIAlertView(title: "Error", message: "Error getting location. Please make sure that location services are enabled for Duby.", delegate: nil, cancelButtonTitle: OK).show()
        }
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
