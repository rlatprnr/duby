//
//  UserDefaults.swift
//  Duby
//
//  Created by Harsh Damania on 1/14/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit


/// Convinience class. Wrapper for NSUserDefaults
class UserDefaults: NSObject {
    
    internal class func setObject(object: AnyObject?, forKey key: String) {
        NSUserDefaults.standardUserDefaults().setValue(object, forKey: key)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    internal class func objectForKey(key: String) -> AnyObject? {
        return NSUserDefaults.standardUserDefaults().valueForKey(key)
    }
    
    private class func removeObejctForKey(key: String) {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(key)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    internal class func valueForKeyExists(key key: String) -> Bool {
        return UserDefaults.objectForKey(key) != nil
    }
    
    //MARK:
    
    class func isFirstLaunch() -> Bool {
        let isFirst = UserDefaults.objectForKey("firstLaunch")?.boolValue
        
        if isFirst == nil {
            UserDefaults.setObject(false, forKey: "firstLaunch")
            return true
        } else {
            return false
        }
    }
    
    //MARK: image
    
    class func getImageUploadQuality() -> ImageQuality {
        var imageQuality = UserDefaults.objectForKey("imageQuality")?.integerValue
        
        if imageQuality == nil {
            imageQuality = 1
            UserDefaults.setImageQuality(.Medium)
        }
        
        return ImageQuality(rawValue: imageQuality!)!
    }
   
    class func setImageQuality(quality: ImageQuality) {
        UserDefaults.setObject(quality.rawValue, forKey: "imageQuality")
    }
    
    //MARK: vc tips
    
    class func hasSeenTips(vcType: TipsControllers) -> Bool {
        let tips = UserDefaults.objectForKey(vcType.stringValue)?.boolValue
        
        if tips == nil {
            UserDefaults.setObject(false, forKey: vcType.stringValue)
            return false
        } else {
            return tips!
        }
    }
    
    class func sawTips(vcType: TipsControllers) {
        UserDefaults.setObject(true, forKey: vcType.stringValue)
    }
    
    class func setAllTips(seen seen: Bool) {
        UserDefaults.setObject(seen, forKey: TipsControllers.Create.stringValue)
        UserDefaults.setObject(seen, forKey: TipsControllers.Landing.stringValue)
        UserDefaults.setObject(seen, forKey: TipsControllers.Search.stringValue)
        UserDefaults.setObject(seen, forKey: TipsControllers.Profile.stringValue)
    }
    
    //MARK: Device token
    
    class func setDeviceToken(token: NSData) {
        if token.length > 0 {
            UserDefaults.setObject(token, forKey: "parseDeviceToken")
        }
    }
    
    class func getDeviceToken() -> NSData? {
        if UserDefaults.deviceTokenExists() && UserDefaults.objectForKey("parseDeviceToken") as? NSData != nil {
            return UserDefaults.objectForKey("parseDeviceToken") as? NSData
        } else {
            return nil
        }
    }
    
    class func deviceTokenExists() -> Bool {
        return UserDefaults.valueForKeyExists(key: "parseDeviceToken")
    }
}
