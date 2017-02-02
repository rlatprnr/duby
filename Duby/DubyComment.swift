//
//  DubyComment.swift
//  Duby
//
//  Created by Harsh Damania on 2/15/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

class DubyComment: NSObject, Deserializable {
    
    var objectId = ""
    
    private var createdAtString = ""
    var createdAt: NSDate?
    private var updatedAtString = ""
    var updatedAt: NSDate?
    
    var message = ""
    var sender = DubyUser()
    var duby = Duby()
    
    override init() { }
    
    required init(data: [String : AnyObject]) {
        message = data["message"] as! String
        sender <-- data["sender"]
//        duby <-- data["duby"]
        
        objectId = data["objectId"] as! String
        
        createdAtString = data["createdAt"] as! String
        if createdAtString.characters.count > 0 {
            createdAt = Constants.dateFromISOString(createdAtString)
        }
        
        updatedAtString = data["updatedAt"] as! String
        if updatedAtString.characters.count > 0 {
            updatedAt = Constants.dateFromISOString(updatedAtString)
        }
    }
    
    // get duby Parse pointer to send up
    func getParsePointerDictionary() -> Dictionary<String, AnyObject> {
        let dubyDict = ["__type" : "Pointer",
            "className" : "Comment",
            "objectId" : objectId]
        
        return dubyDict
    }
}
