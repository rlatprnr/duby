//
//  DubyDetailsModel.swift
//  Duby
//
//  Created by Harsh Damania on 2/8/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit
 

class DubyDetailsModel: NSObject {

    private var dubys = [Duby]()
    
    var usersSharedTo = [DubyUser]()
    var currentDuby = Duby()
    
    var additionalDubys = [Duby]()
    var canGetMoreDubys = false
    var page = 0
    let dubyLimit = 36
    
    var userId = ""
    
    var dubyCount = 0
    
    class func cellSize() -> CGSize {
        var cellSize = CGRectGetWidth(UIScreen.mainScreen().bounds)
        cellSize -= 4*2 // 4 paddings of 8px each
        cellSize /= 3 // 3 dubys a row
        
        return CGSize(width: cellSize, height: cellSize)
    }
    
    /// Get list of users that this duby has been shared to
    func getDubyShareData(completion: (Bool, Int) -> (Void)) {
        DubyDatabase.getUsersSharedToForDuby(currentDuby.objectId, completion: { (sharedUsers, error) -> (Void) in
            if sharedUsers != nil {
                self.usersSharedTo = sharedUsers!
              
              PFConfig.getConfigInBackgroundWithBlock({ (config, error) -> Void in
                if let _ = error {
                  completion(true, 8)
                } else {
                  print(config)
                  print(config?["map_max_zoom_level"])
                  let zoomLevel = config?["map_max_zoom_level"] as! Int
                  completion(true, zoomLevel)
                }
              })
            } else {
                completion(false, 8)
            }
        })
    }
    
    func getDubys(userId userId: String, completion: (Bool) -> Void) {
        self.userId = userId
        DubyDatabase.getDubysForUser(userId, limit: dubyLimit, skip: page) { (dubys, count, error) -> Void in
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    print("error getting dubys \(error?.description)")
                    completion(false)
                })
            } else {
                self.dubys = dubys!
                self.dubyCount = count
                if dubys!.count == self.dubyLimit {
                    self.canGetMoreDubys = true
                    self.page++
                    self.getMoreDubys()
                } else {
                    self.canGetMoreDubys = false
                }
                
                completion(true)
            }
        }
    }
    
    func getMoreDubys() {
        
        canGetMoreDubys = false
        DubyDatabase.getDubysForUser(userId, limit: dubyLimit, skip: page) { (dubys, _, error) -> Void in
            if error != nil {
                self.canGetMoreDubys = false
            } else {
                self.additionalDubys = dubys!
                if dubys!.count == self.dubyLimit {
                    self.canGetMoreDubys = true
                    self.page++
                } else {
                    self.canGetMoreDubys = false
                }
            }
        }
    }
    
    func addAdditionalDubys() -> Bool {
        if additionalDubys.count > 0 {
            dubys = dubys + additionalDubys
            
            additionalDubys = [Duby]()
            
            if canGetMoreDubys {
                getMoreDubys()
            }
            
            return true
        } else {
            return false
        }
    }
    
    /// Handle a deleted duby from somewhere else
    func dubyDeleted(objectId: String) -> Bool {
        let dubyObject = Duby()
        dubyObject.objectId = objectId
        
        if let index = dubys.indexOf(dubyObject) {
            dubys.removeAtIndex(index)
            
            return true
        } else if let index = additionalDubys.indexOf(dubyObject) {
            dubys.removeAtIndex(index)

            return false
        }
        
        return false
    }
    
    func numberOfDubys() -> Int {
        return dubys.count
    }
    
    func dubyAtIndex(index: Int) -> Duby {
        return dubys[index]
    }
    
}
