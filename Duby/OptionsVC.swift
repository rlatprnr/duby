//
//  OptionsVC.swift
//  Duby
//
//  Created by Harsh Damania on 2/4/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit
 
import MessageUI

class OptionsVC: UITableViewController, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate {
  let appID = "966442183"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.tableFooterView = UIView()
    tableView.tableHeaderView = UIView()
    
    tableView.backgroundColor = UIColor.whiteColor()
    
  }
  
  override func viewWillAppear(animated: Bool) {
    UIApplication.sharedApplication().statusBarStyle = .Default
    
    updateImageQualityCell()
  }
  
  func updateImageQualityCell() {
    let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 3))
    cell?.detailTextLabel?.text = UserDefaults.getImageUploadQuality().stringValue
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    if indexPath.section == 0 {
      // Rate Duby
      if indexPath.row == 0 {
        
        UIApplication.sharedApplication().openURL(NSURL(string: NSString(format: "itms-apps://itunes.apple.com/app/id%@", appID) as String)!)
      } else {
        let activity  = UIActivityViewController(activityItems: ["Download Duby! \n\n", NSURL(string: "http://apple.co/1GF1tBw")!], applicationActivities: nil)
        activity.excludedActivityTypes = [UIActivityTypePrint, UIActivityTypeMail, UIActivityTypeSaveToCameraRoll, UIActivityTypeCopyToPasteboard, UIActivityTypeAirDrop, UIActivityTypeAddToReadingList]
        presentViewController(activity, animated: true, completion: nil)
      }
    }
    else if indexPath.section == 1 {
      if indexPath.row == 0 { // open in instagram
        
        let instagramURL = NSURL(string: "instagram://user?username=dubyapp")!
        let safariURL = NSURL(string: "http://instagram.com/dubyapp/")!
        if UIApplication.sharedApplication().canOpenURL(instagramURL) {
          UIApplication.sharedApplication().openURL(instagramURL)
        } else {
          UIApplication.sharedApplication().openURL(safariURL)
        }
        
      } else if indexPath.row == 1 { // open in twitter
        let twitterURL = NSURL(string: "twitter://user?screen_name=dubyapp")!
        let safariURL = NSURL(string: "https://twitter.com/#!/dubyapp")!
        
        if UIApplication.sharedApplication().canOpenURL(twitterURL) {
          UIApplication.sharedApplication().openURL(twitterURL)
        } else {
          UIApplication.sharedApplication().openURL(safariURL)
        }
      } else if indexPath.row == 2 { // open in facebook
        let fbURL = NSURL(string: "fb://profile/1464384713824595")!
        let safariURL = NSURL(string: "https://www.facebook.com/dubyapp")!
        
        if UIApplication.sharedApplication().canOpenURL(fbURL) {
          UIApplication.sharedApplication().openURL(fbURL)
        } else {
          UIApplication.sharedApplication().openURL(safariURL)
        }
      }
    } else if indexPath.section == 2 {
      if indexPath.row == 0 { // send duby email
        sendDubyEmail()
      } else if indexPath.row == 1 {
        UIApplication.sharedApplication().openURL(NSURL(string: NSString(format: "itms-apps://itunes.apple.com/app/id%@", appID) as String)!)
      } else if indexPath.row == 2 { // about
        parentViewController?.performSegueWithIdentifier("AboutSegue", sender: self)
      }
    } else if indexPath.section == 3 { // image quality
      let actionSheet = UIActionSheet(title: "Select upload quality", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil)
      actionSheet.addButtonWithTitle("Low")
      actionSheet.addButtonWithTitle("Medium")
      actionSheet.addButtonWithTitle("High")
      actionSheet.showInView(view)
    } else if indexPath.section == 4 {
      if indexPath.row == 0 {
        parentViewController?.performSegueWithIdentifier("ChangePasswordSegue", sender: self)
      } else if indexPath.row == 1 { // logout
        PFUser.logOut()
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_BADGE_UPDATE, object: nil)
        
        /* Remove deviceToken & user from installation on Parse */
        let currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.removeObjectForKey("user")
        currentInstallation.deviceToken = ""
        currentInstallation.saveInBackgroundWithBlock({ (completed, error) -> Void in
          if error != nil {
            NSLog("ERROR (Saving Installation on Logout): ", error!)
          }
        })
        
        DubyUser.currentUser = DubyUser()

        NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_DID_LOGOUT, object: nil)
      }
    }
  }
  
  func sendDubyEmail() {
    let emailTitle = "Request Info"
    let toRecipents = ["info@duby.co"]
    
    let mailComposer: MFMailComposeViewController = MFMailComposeViewController()
    mailComposer.mailComposeDelegate = self
    mailComposer.setSubject(emailTitle)
    mailComposer.setToRecipients(toRecipents)
    
    mailComposer.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor()]
    mailComposer.navigationBar.tintColor = nil
    
    self.presentViewController(mailComposer, animated: true, completion: nil)
  }
  
  //MARK: mail
  
  func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
    controller.dismissViewControllerAnimated(true, completion: nil)
  }
  
  //MARK: action sheet - image quality
  
  func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
    if buttonIndex > 0 && buttonIndex < 4 {
      UserDefaults.setImageQuality(ImageQuality(rawValue: buttonIndex-1)!)
      updateImageQualityCell()
    }
  }
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using [segue destinationViewController].
  // Pass the selected object to the new view controller.
  }
  */
  
}
