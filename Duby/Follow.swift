//
//  Follow.swift
//  Duby
//
//  Created by Anurag Kamasamudram on 3/18/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

class Follow: NSObject, Deserializable {
    var objectId = ""
    var duby = Duby()
    
    required init(data: [String : AnyObject]) {
        duby <-- data["duby"]
        
        objectId = data["objectId"] as! String
    }
}
