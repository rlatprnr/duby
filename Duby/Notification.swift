//
//  Notification.swift
//  Duby
//
//  Created by Anurag Kamasamudram on 3/19/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

/// Old object, not of too much importance
class Notification: NSObject, Deserializable {
    var duby = Duby()
    var user = DubyUser()
    var alert = ""
    var postedTime : NSDate?
    
    // Indicating whether a user has seen this Notification.
    var read = false
    
    override init() { }

    required init(data: [String : AnyObject]) {
        
        /* Mapping duby data to duby object */
        duby <-- data["duby"]
        
        /* Mapping user data to user object */
        user <-- data["user"]
        
        /* Storing the date stamp when a notification is received */
        postedTime = NSDate()
        
        /* Mapping alert message to alert text */
        alert = (data["aps"] as! NSDictionary)["alert"] as! String
    }
}
