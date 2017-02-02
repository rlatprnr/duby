//
//  ParseSeshError.swift
//  Duby
//
//  Created by Russ Thomas on 4/9/16.
//  Copyright © 2016 Duby, LLC. All rights reserved.
//

import Foundation

class ParseErrorHandlingController {
    class func handleParseError(error: NSError) {
        if error.domain != PFParseErrorDomain {
            return
        }
        
        switch (error.code) {
        case kPFErrorInvalidSessionToken:
            handleInvalidSessionTokenError()
            
        // Other Parse API Errors that you want to explicitly handle.
        default:
            print("ERROR")
        }
        
    }
}

private func handleInvalidSessionTokenError() {
    
    let presentingViewController = UIApplication.sharedApplication().keyWindow?.rootViewController
    
    let refreshAlert = UIAlertController(title: "Duby Message", message: "Session is no longer valid, please log in again.", preferredStyle: UIAlertControllerStyle.Alert)
    
    refreshAlert.addAction(UIAlertAction(title: "Log Out", style: .Default, handler: { (action: UIAlertAction!) in
        print("Logging out user after ivalid session token found")
        //logout
        PFUser.logOut()
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_BADGE_UPDATE, object: nil)
        
        /* Remove deviceToken & user from installation on Parse */
        let currentInstallation = PFInstallation.currentInstallation()
        //currentInstallation.removeObjectForKey("user")
        currentInstallation.deviceToken = ""
        currentInstallation.saveInBackgroundWithBlock({ (completed, error) -> Void in
            if error != nil {
                NSLog("ERROR (Saving Installation on Logout): ", error!)
            }
        })
        
        DubyUser.currentUser = DubyUser()
        
        NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_DID_LOGOUT, object: nil)
        
    }))
    
    refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
        print("Handle Cancel Logic here")
    }))
    
    presentingViewController?.presentViewController(refreshAlert, animated: true, completion: nil)
}
