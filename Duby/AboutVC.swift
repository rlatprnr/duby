//
//  AboutVC.swift
//  Duby
//
//  Created by Harsh Damania on 2/8/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit
import MessageUI

class AboutVC: UITableViewController, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableHeaderView = UIView()
        
        let footerView = tableView.tableFooterView
        let infoLabel = footerView?.viewWithTag(5) as? UILabel
        infoLabel?.font = UIFont.openSans(13.5)
        
        tableView.backgroundColor = UIColor.whiteColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        let version: String = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 5, inSection: 0))
        cell?.textLabel?.text = "You are running Duby version \(version)" // set version
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        var urlString = ""
        // all of the urls
        switch indexPath.row {
            case 0:
                urlString = "https://duby.co"
            case 1:
                sendDubyEmail(support: true)
            case 2:
                sendDubyEmail(support: false)
            case 3:
                urlString = "https://www.duby.co/legal/"
            case 4:
                urlString = "https://www.duby.co/privacy/"
            default:
                urlString = ""
        }
        
        if urlString != "" {
            UIApplication.sharedApplication().openURL(NSURL(string: urlString)!)
        }
    }

    func sendDubyEmail(support support: Bool) {
        let emailTitle = support ? "Email Support" : "Report Abuse"
        let toRecipents = support ? ["support@duby.co"] : ["report@duby.co"]
        
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
}
