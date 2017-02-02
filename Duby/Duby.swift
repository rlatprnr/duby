//
//  Duby.swift
//  Duby
//
//  Created by Harsh Damania on 1/23/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit
import CoreLocation

class Duby: Deserializable, Equatable {
  
  var isVideo = false // for when video support
  var imageURL = "" // duby image URL
  var videoURL = ""
  
  var createdAt = ""
  var updatedAt = ""
  
  var description = "" // duby message
  var location = ""
  var locationGeo = CLLocationCoordinate2DMake(0,0)
  
  var objectId = ""
  
  var createdBy = DubyUser()
  
  var usersSharedTo = [DubyUser]?()
  var usersSharedToCount = 0
  var shareCount = 0
  
  var reports = [String]()
  var currentUserReported = false
  
  var commentCount = 0
  
  init() {}
  
  /// Map all data!
  required init(data: [String : AnyObject]) {
    //        println("data \(data)")
    
    objectId = data["objectId"] as! String
    
    if data["createdAt"] as? String != nil {
      createdAt = data["createdAt"] as! String
    }
    
    if data["updatedAt"] as? String != nil {
      updatedAt = data["updatedAt"] as! String
    }
    
    
    if let content = (data["content"] as? NSDictionary)?["url"] as? String {
      imageURL = content
    }
    
    if let content = (data["video"] as? NSDictionary)?["url"] as? String {
      videoURL = content
    }
    
    if data["description"] as? String != nil {
      description = data["description"] as! String
    }
    
    if let loc = data["location"] as? String {
      location = loc
    }
    
    if let loc = data["location_geo"] as? NSDictionary {
      locationGeo.latitude = loc["latitude"] as! CLLocationDegrees
      locationGeo.longitude = loc["longitude"]  as! CLLocationDegrees
    }
    
    if let isVideo = data["isVideo"] as? Bool {
      self.isVideo = isVideo
    }
    
    createdBy <-- data["createdBy"] // map created by user object
    
    if let sc = data["shareCount"] as? Int {
      self.shareCount = sc
    }
    
    // remove null users and update count if exists
    if data["numUsersSharedTo"] != nil {
      //            var updatedSharedToUsers = Constants.removeNullPointersFromArray(data["usersSharedTo"] as! Array<AnyObject>)
      usersSharedToCount = data["numUsersSharedTo"]!.integerValue
    }
    
    
    if data["usersSharedTo"] != nil {
      let ust = data["usersSharedTo"] as? [[String : AnyObject]];
      let ustu : [DubyUser]! = ust?.map({ (user) -> DubyUser in
        return DubyUser(data: user);
      });
      
      usersSharedTo = ustu;
    }
    
    if data["reports"] as? [String] != nil {
      reports = data["reports"] as! [String]
    }
    
    currentUserReported = reports.contains(DubyUser.currentUser.objectId)
    
    if let cc = data["commentCount"] as? Int {
      self.commentCount = cc
    }
  }
  
  // get duby Parse pointer to send up
  func getParsePointerDictionary() -> Dictionary<String, AnyObject> {
    let dubyDict = ["__type" : "Pointer",
      "className" : "Duby",
      "objectId" : objectId]
    
    return dubyDict
  }
  
  func sharedWithUser(user: DubyUser) -> Bool {
    if usersSharedTo == nil {
      return false;
    }
    return (usersSharedTo!).contains(user);
  }
}

// To check for equality, we compare the objectId
func == (lhs: Duby, rhs: Duby) -> Bool {
  return lhs.objectId == rhs.objectId
}
