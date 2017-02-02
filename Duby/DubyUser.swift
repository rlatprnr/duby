//
//  DubyUser.swift
//  Duby
//
//  Created by Harsh Damania on 1/23/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit
import CoreLocation
 

class DubyUser: Deserializable, Equatable {
    
    var birthdayString = ""
    var birthday: NSDate?
    
    var createdAtString = ""
    var createdAt: NSDate?
    var updatedAtString = ""
    var updatedAt: NSDate?
    
    var email = ""
    var location = ""
    var username = ""
    var profilePicURL = ""
    var firstName = ""
    var lastName = ""
    var biography = ""
    var isMale: Bool?
    var pmDisabled = false
    var dubyTrackDisabled = false
    var profilePic: UIImage?
    var location_geo = CLLocationCoordinate2DMake(0,0)
    
    var influence = 5
    var boost: Int?
    var totalReach = 0
    var bestDuby = 0
    var followersCount = 0
    
    var objectId = ""
    
    var sessionToken = ""
    
    struct UserInfo {
        static var user = DubyUser()
    }

    class var currentUser: DubyUser {
        get { return UserInfo.user }
        
        set { UserInfo.user = newValue }
    }
    
//    // Mainly used for converting the PFUser to DubyUser
//    class func updateCurrentUser() {
//      print("updating current user")
//      PFSession.getCurrentSessionInBackgroundWithBlock { (sess, error) -> Void in
//        print(sess)
//        print(error)
//        if let sess = sess {
//          print("GET NEW SESS \(sess.sessionToken)")
//          DubyUser.currentUser.sessionToken = sess.sessionToken!
//        }
//      }
//        
    
        // Mainly used for converting the PFUser to DubyUser
        // Added logic to detect invalid session -DD04102016
        class func updateCurrentUser() {
            print("updating current user")
            PFSession.getCurrentSessionInBackgroundWithBlock { (sess, error) -> Void in
                
                if error == nil {
                    // Query Succeeded - continue your app logic here.
                    print(sess)
                    print(error)
                    if let sess = sess {
                        print("GET NEW SESS \(sess.sessionToken)")
                        DubyUser.currentUser.sessionToken = sess.sessionToken!
                    }
                } else {
                    // Query Failed - handle an error.
                    ParseErrorHandlingController.handleParseError(error!)
                }
                
            }
      
        PFUser.currentUser()?.fetchInBackground()
        
        var userDict = Dictionary<String, AnyObject>()
        
        for key in (PFUser.currentUser()!.allKeys ) {
            if PFUser.currentUser()!.valueForKey(key as String) is PFFile {
                let file = PFUser.currentUser()!.valueForKey(key as String) as! PFFile
                if key == "profilePicture" && file.url != nil {
                    userDict[key] = ["url" : file.url!]
                } else {
                    userDict[key] = ["url" : file.url!]
                }
            } else {
                userDict[key] = PFUser.currentUser()!.valueForKey(key as String)
            }
            
        }
        var newUser = DubyUser()
        newUser <-- (userDict as NSDictionary)
      
        DubyUser.currentUser = newUser
        DubyUser.currentUser.updatedAt = PFUser.currentUser()!.updatedAt
        DubyUser.currentUser.createdAt = PFUser.currentUser()!.createdAt
        DubyUser.currentUser.objectId = PFUser.currentUser()!.objectId!
        DubyUser.currentUser.sessionToken = PFUser.currentUser()!.sessionToken!
        
        if LocationManager.sharedInstance.hasLocation && LocationManager.sharedInstance.hasLocationComponents {
            DubyUser.currentUser.location = LocationManager.sharedInstance.getLocationString().locationString
            DubyUser.currentUser.location_geo = LocationManager.sharedInstance.currentLocation!.coordinate
        }
        
        // Cloud code function to get the latest user email and map to currentUser object
        //DubyDatabase.getEmail()
        
        LocationManager.sharedInstance.sendLocationUpdate = true
    }
    
    init() { }
   
    required init(data: [String : AnyObject]) {
        if let _ = data["objectId"] as? String {
            objectId = data["objectId"] as! String
        }
      
        
//        if let bday = data["birthday"] as? NSDictionary {
//            birthdayString = bday["iso"] as! String
//            birthday = Constants.dateFromISOString(birthdayString)
//        }
        
        if let _ = data["createdAt"] as? String {
            createdAtString = data["createdAt"] as! String
            if createdAtString.characters.count > 0 {
                createdAt = Constants.dateFromISOString(createdAtString)
            }
        }
        
        if let _ = data["updatedAt"] as? String {
            updatedAtString = data["updatedAt"] as! String
                    if updatedAtString.characters.count > 0 {
                        updatedAt = Constants.dateFromISOString(updatedAtString)
                    }
        }
        
        if data["email"] as? String != nil {
            email = data["email"] as! String
        }
        
        if data["username"] as? String != nil {
            username = data["username"] as! String
        }
        
        if data["pmDisabled"] as? Bool != nil {
            pmDisabled = data["pmDisabled"] as! Bool
        }
      
        if data["dubyTrackDisabled"] as? Bool != nil {
          dubyTrackDisabled = data["dubyTrackDisabled"] as! Bool
        }
      
      //dubyTrackDisabled
        
        if let profilePicture = data["profilePicture"] as? NSDictionary {
            profilePicURL = profilePicture["url"] as! String
        }
        
        if data["location"] as? String != nil {
            location = data["location"] as! String
        }
        
        
        if let loc = data["location_geo"] as? NSDictionary {
            let lat = loc["latitude"] as! CGFloat
            let lng = loc["longitude"] as! CGFloat
            
            location_geo = CLLocationCoordinate2DMake(CLLocationDegrees(lat), CLLocationDegrees(lng))
        }
        
        if data["firstName"] as? String != nil {
            firstName = data["firstName"] as! String
        }
        
        if data["lastName"] as? String != nil {
            lastName = data["lastName"] as! String
        }
        
        if data["biography"] as? String != nil {
            biography = data["biography"] as! String
        }
        
        isMale = data["isMale"]?.boolValue
        
        if data["influence"] as? Int != nil {
            influence = data["influence"]!.integerValue
        }
        
        boost = data["boost"]?.integerValue
        
        if data["bestDuby"] as? Int != nil {
            bestDuby = data["bestDuby"]!.integerValue
        }
        
        if data["totalReach"] as? Int != nil {
            totalReach = data["totalReach"]!.integerValue
        }
        
        if data["followersCount"] as? Int != nil {
            followersCount = data["followersCount"]!.integerValue
        }
    }
    
    func getParsePointerDictionary() -> Dictionary<String, AnyObject> {
        let userDict = ["__type" : "Pointer",
            "className" : "_User",
            "objectId" : objectId]
        
        return userDict
    }
    
}

// To check for equality, we only compare the objectId
func == (lhs: DubyUser, rhs: DubyUser) -> Bool {
    return lhs.objectId == rhs.objectId
}
