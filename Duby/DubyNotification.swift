//
//  DubyNotification.swift
//  Duby
//
//  Created by Harsh Damania on 4/15/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

class DubyNotification: Deserializable {
    
    var objectId = ""
    
    var createdAtString = ""
    var createdAt: NSDate?
    
    var dubyId: String?
    var pmId: String?
    var fromUserId: String?
    var toUserId: String?
    var seen: Bool? = true
    var primaryPhotoURL: String?
    var secondaryPhotoURL: String?
    var text = ""
    
    var type: NotificationType = .Other {
        didSet {
          if type == .Message {
            attributedMessage = NSAttributedString(string: text, attributes: [NSFontAttributeName: UIFont.openSansBold(12), NSForegroundColorAttributeName: UIColor.whiteColor()])
          } else {
            attributedMessage = NSAttributedString(string: text, attributes: [NSFontAttributeName: UIFont.openSansSemiBold(12), NSForegroundColorAttributeName: UIColor.whiteColor()])
          }
        }
    }
    
    var attributedMessage = NSAttributedString()
    
    init() {}
    
    required init(data: JSONDictionary) {
        objectId = data["objectId"] as! String
        
        createdAtString = data["createdAt"] as! String
        if createdAtString.characters.count > 0 {
            createdAt = Constants.dateFromISOString(createdAtString)
        }
        
        if let dubyId = (data["duby"] as? NSDictionary)?["objectId"] as? String {
            self.dubyId = dubyId
        }
        
        if let pmId = (data["pm"] as? NSDictionary)?["objectId"] as? String {
            self.pmId = pmId
        }
        
        if let fromUserId = (data["fromUser"] as? NSDictionary)?["objectId"] as? String {
            self.fromUserId = fromUserId;
        }
        
        if let toUserId = (data["toUser"] as? NSDictionary)?["objectId"] as? String {
            self.toUserId = toUserId;
        }
        
        text = data["text"] as! String
        seen = data["seen"]?.boolValue
        if let primaryPhotoURL = (data["primaryPhoto"] as? NSDictionary)?["url"] as? String {
            self.primaryPhotoURL = primaryPhotoURL;
        }
        if let secondaryPhotoURL = (data["secondaryPhoto"] as? NSDictionary)?["url"] as? String {
            self.secondaryPhotoURL = secondaryPhotoURL;
        }
        
        if seen == nil {
            seen = true
        }
        
        let notifType = data["type"] as? String
        if notifType != nil {
            setType(notifType!)
        }
    }
    
    func setType(type: String) {
        self.type = NotificationType(type: type)
    }
   
}
