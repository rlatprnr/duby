//
//  CreateModel.swift
//  Duby
//
//  Created by Harsh Damania on 2/23/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

class CreateModel: NSObject {
  
  var dubyImage: Dictionary<String, AnyObject>? {
    didSet {
      valid = !(dubyImage == nil && dubyDescription == "")
    }
  }
  
  var dubyDescription: String = "" {
    didSet {
      valid = !(dubyImage == nil && dubyDescription == "")
    }
  }
  
  var dubyVideo: Dictionary<String, AnyObject>?
  
  var valid = false
  
  func createDuby(completion: (String?) -> (Void)) {
    
    if LocationManager.sharedInstance.hasLocation {
      var dubyDict = ["createdBy" : DubyUser.currentUser.getParsePointerDictionary(),
        "location" : "\(LocationManager.sharedInstance.getLocationString().locationString)",
        "description" : dubyDescription,
        "isVideo" : false,
        "location_geo" : LocationManager.sharedInstance.getParseGeoPointDictionary(),
        "hashtags" : dubyDescription.getHashtags(),
        "shareCount": 0,
        "commentCount": 0,
        "usersSharedTo": [DubyUser.currentUser.getParsePointerDictionary()],
        "reports" : []] as Dictionary<String, AnyObject>
      
      if (dubyImage != nil) {
        dubyDict["content"] = dubyImage
      }
      
      if (dubyVideo != nil) {
        dubyDict["video"] = dubyVideo
        dubyDict["isVideo"] = true
        
        var tags = dubyDescription.getHashtags()
        tags += ["vid", "vids", "video", "videos"]
        
        dubyDict["hashtags"] = tags
      }
      
      DubyDatabase.createDuby(dubyDict, completion: { (created, newDubyParams, error) -> Void in
        if created && newDubyParams != nil {
          
          self.dubyImage = nil
          self.dubyDescription = ""
          
          delay(1, closure: { () -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
              NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_SHOW_PROFILE, object: nil, userInfo: newDubyParams)
              NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_NEW_DUBY, object: nil, userInfo: newDubyParams)
              completion(nil)
            })
          })
        } else {
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            print("error \(error?.localizedDescription)")
            
            completion(error?.localizedDescription)
            
          })
        }
      })
    } else {
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        
        completion("Error getting location. Please make sure that location services are enabled for Duby.")
        
      })
    }
    
  }
}
