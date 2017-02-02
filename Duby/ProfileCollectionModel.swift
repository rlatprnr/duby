//
//  ProfileCollectionModel.swift
//  Duby
//
//  Created by Harsh Damania on 2/3/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

class ProfileCollectionModel: NSObject {
    
    private var dubys = [Duby]()
    var user: DubyUser?
    private let maxBioHeight: CGFloat = 59
    private let maxHeaderHeight: CGFloat = 270
    
    var additionalDubys = [Duby]()
    var canGetMoreDubys = false
    var page = 0
    let dubyLimit = 1000
    
    var userId = ""
    
    var dubyCount = 0
    
    /// Returns size for cell
    class func cellSize() -> CGSize {
        var cellSize = CGRectGetWidth(UIScreen.mainScreen().bounds)
        cellSize -= 4*2 // 4 paddings of 8px each
        cellSize /= 3 // 3 dubys a row
        
        return CGSize(width: cellSize, height: cellSize)
    }
    
    /// User bio height
    func getBioHeight() -> CGFloat {
        let height = Constants.getHeightForText(user!.biography, width: CGRectGetWidth(UIScreen.mainScreen().bounds) - 30, font: UIFont.systemFontOfSize(12)) // 15px padding on each side
      return height;
    }
    
    /// Total header height that contains user data
    func getHeaderHeight() -> CGFloat {
      if (user == DubyUser.currentUser) {
        return getBioHeight() + 190;
      }
      return getBioHeight() + 190
    }
    
    /// Call when pulled to refresh
    func refresh() {
        dubyCount = 0
        page = 0
        
        canGetMoreDubys = false
        dubys = [Duby]()
        additionalDubys = [Duby]()
    }
    
    /// Gets dubys for user
    ///
    /// - parameter userId: user whose dubys needed
    /// - parameter completion: Passes back whether we got the dubys
    ///
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
                if dubys!.count == self.dubyLimit {
                    self.canGetMoreDubys = true
                    self.page++
                    self.getMoreDubys()
                } else {
                    self.canGetMoreDubys = false
                }
                
                self.dubyCount = count
                
                completion(true)
            }
        }
    }
    
    /// For pagination
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
    
    /// if we have more dubys for pagination, add them
    ///
    /// - returns: Bool If we need to refresh the table view
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
    
    /// New duby was just created. append to list of dubys
    func addNewDuby(duby: Duby) {
        dubys.append(duby)
    }
    
    /// Duby just deleted, remove from list
    ///
    /// - parameter objectId: duby id of duby deleted
    func dubyDeleted(objectId: String) -> Bool {
        let dubyObject = Duby()
        dubyObject.objectId = objectId
        
        if let index = dubys.indexOf(dubyObject) {
            dubys.removeAtIndex(index)
            dubyCount--
            
            dubyCount = dubyCount < 0 ? 0 : dubyCount
            return true
        } else if let index = additionalDubys.indexOf(dubyObject) {
            dubys.removeAtIndex(index)
            dubyCount--
            
            dubyCount = dubyCount < 0 ? 0 : dubyCount
            return false
        }
        
        return false
    }
    
    /// Get number of dubys in dubys array
    func numberOfDubys() -> Int {
        let dubyCount = dubys.count
//        if user == DubyUser.currentUser {
//            dubyCount++
//        }
        return dubyCount
    }
   
    /// Get duby at index
    func dubyAtIndex(index: Int) -> Duby {
        let adjustedIndex = index
//        if user == DubyUser.currentUser {
//            adjustedIndex--
//        }
        return dubys[adjustedIndex]
    }
    
    /// Get header data
    func getHeaderData() -> (Int, Int, Int) {
        
        var totalReach = 0
        var bestDuby = 0
        
        for duby in dubys {
            totalReach += duby.shareCount
            bestDuby = duby.shareCount > bestDuby ? duby.shareCount : bestDuby
        }

        return (dubyCount, totalReach, bestDuby)
    }
}
