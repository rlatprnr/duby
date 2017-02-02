//
//  DubyShare.swift
//  Duby
//
//  Created by Harsh Damania on 2/10/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

struct DubyShare: Deserializable {
    var duby = Duby()
    
    var fromUser = DubyUser()
    var toUser = DubyUser()
    
    var seen: Bool? = false
    var valid: Bool? = false
    
    var objectId = ""
    
    private var createdAtString = ""
    var createdAt: NSDate?
    private var updatedAtString = ""
    var updatedAt: NSDate?
    
    init() { }
    
    init(data: [String : AnyObject]) {
        duby <-- data["duby"]
        
//        fromUser <<<< data["fromUser"]
//        toUser <<<< data["toUser"]
        
        seen = data["seen"]?.boolValue
        valid = data["valid"]?.boolValue
        
        objectId = data["objectId"] as! String
        
        createdAtString = data["createdAt"] as! String
        if createdAtString.characters.count > 0 {
            createdAt = Constants.dateFromISOString(createdAtString)
        }
        
        updatedAtString = data["updatedAt"] as! String
        if updatedAtString.characters.count > 0 {
            updatedAt = Constants.dateFromISOString(updatedAtString)
        }
        
        //println(self);
    }
}
