//
//  EditModel.swift
//  Duby
//
//  Created by Harsh Damania on 2/3/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

class EditModel: NSObject {
    
    var updatedUser = DubyUser.currentUser
    var updateDictionary = Dictionary<String, AnyObject>()
    var userUpdated = false
    var profilePicUpdated = false
    
    var bioCellHeight: CGFloat = -1
    var cellHeight: CGFloat = 50
        
    class func getInitialBioHeight() -> CGFloat {
        let initialHeight: CGFloat = 28
        let textPadding: CGFloat = 8
        var height = Constants.getHeightForText(DubyUser.currentUser.biography, width: CGRectGetWidth(UIScreen.mainScreen().bounds) - 52 - 16 - 10, font: UIFont.openSans(14)) + textPadding // 52 left to cell leading. 16 right to cell trailing. 10 padding text
        height = height < initialHeight ? initialHeight : height
        return height + 20
    }
    
    class func getCellDataForIndexPath(indexPath: NSIndexPath) -> [String: AnyObject?] {
        if indexPath.section == 0 {
            if indexPath.row == 1 {
                return ["image" : "person_icon",
                    "text" : DubyUser.currentUser.username,
                    "type" : "username"]
            } else if indexPath.row == 2 {
                return ["image" : "info_icon",
                    "text" : DubyUser.currentUser.biography,
                    "type" : "bio"]
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                return ["image" : "person_icon",
                    "text" : DubyUser.currentUser.firstName,
                    "type" : "firstname"]
            }else if indexPath.row == 1 {
                return ["image" : "person_icon",
                    "text" : DubyUser.currentUser.lastName,
                    "type" : "lastname"]
            }else if indexPath.row == 2 {
                return ["image" : "mail_icon",
                    "text" : DubyUser.currentUser.email,
                    "type" : "mail"]
            } else if indexPath.row == 3 {

                var text = "Not Specified"
                var selectedSegment = UISegmentedControlNoSegment
                
                if DubyUser.currentUser.isMale != nil {
                    if DubyUser.currentUser.isMale! {
                        text = "Male"
                        selectedSegment = 0
                    } else {
                        text = "Female"
                        selectedSegment = 1
                    }
                }
                
                return ["image" : "gender_icon",
                    "control" : true,
                    "selectedSegment" : selectedSegment,
                    "text" : text]
            } else if indexPath.row == 4 {
                return ["image" : "location_icon",
                    "text" : DubyUser.currentUser.location,
                    "control" : false]
            }
        }
        
        return ["Don't need no data" : "here"]
    }
    
    //MARK: editing
    
    func bioUpdated(bio: String) {
        if !userUpdated {
            userUpdated = bio.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) != DubyUser.currentUser.biography
        }
        
        updatedUser.biography = bio.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        let stupidiOSBugSolution = updateDictionary
        updateDictionary["biography"] = updatedUser.biography
    }
    
    func usernameUpdated(newUsername: String) {
        if !userUpdated {
            userUpdated = newUsername.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) != DubyUser.currentUser.username
        }
        
        updatedUser.username = newUsername.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        let stupidiOSBugSolution = updateDictionary
        updateDictionary["username"] = updatedUser.username
    }
    
    func emailUpdated(newEmail: String) {
        if !userUpdated {
            userUpdated = newEmail.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) != DubyUser.currentUser.email
        }
        

        updatedUser.email = newEmail.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        let stupidiOSBugSolution = updateDictionary
        updateDictionary["email"] = updatedUser.email
    }
    
    func genderUpdated(isMale: Bool) {
        if !userUpdated {
            userUpdated = isMale != DubyUser.currentUser.isMale
        }
        
        updatedUser.isMale = isMale
        
        let stupidiOSBugSolution = updateDictionary
        updateDictionary["isMale"] = updatedUser.isMale
    }
   
    func picUpdated(image: UIImage!) {
        profilePicUpdated = true
        
        updatedUser.profilePic = image
    }
    
    func firstnameUpdated(firstname: String) {
        if !userUpdated {
            userUpdated = firstname.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) != DubyUser.currentUser.firstName
        }
        
        updatedUser.firstName = firstname.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        updateDictionary["firstName"] = updatedUser.firstName
    }
    
    func lastnameUpdated(lastname: String) {
        if !userUpdated {
            userUpdated = lastname.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) != DubyUser.currentUser.lastName
        }
        
        updatedUser.lastName = lastname.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        updateDictionary["lastName"] = updatedUser.lastName
    }
    
    func pmDisabledUpdated(pmDisabled: Bool) {
        userUpdated = true
        updatedUser.pmDisabled = pmDisabled
        updateDictionary["pmDisabled"] = pmDisabled
    }
  
    func dubyTrackUpdated(dubyTrackDisabled: Bool) {
      userUpdated = true
      updatedUser.dubyTrackDisabled = dubyTrackDisabled
      updateDictionary["dubyTrackDisabled"] = dubyTrackDisabled
    }
  
  //dubyTrackDisabled
    
    //MARK: Send update

    /// Send update to server
    func updateUser(completion completion: (Bool) -> Void) {
        if profilePicUpdated {
            DubyDatabase.updateProfilePicForUser(updatedUser.profilePic!, completion: { (response, error) -> Void in
                if error != nil {
                    UIAlertView(title: "Error Updating Profile Picture", message: "Sorry there was an error updating the profile picture.", delegate: self, cancelButtonTitle: OK).show()
                } else {
                    let resp = response as! NSDictionary
                    let imageURL = resp["url"] as! String
                    let imageName = resp["name"] as! String
                    
                    let imageDictionary = ["profilePicture" : [
                        "name" : imageName,
                        "__type" : "File"]]
                    
                    DubyDatabase.updateUser(imageDictionary, completion: { (response, error) -> Void in
                        if response != nil {
                            DubyUser.currentUser = self.updatedUser
                            DubyUser.currentUser.profilePicURL = imageURL
                            
                            // user updated too
                            if self.userUpdated {
                                print(self.updateDictionary)
                                DubyDatabase.updateUser(self.updateDictionary, completion: { (response, error) -> Void in
                                    if response != nil {
                                        if (response as! NSDictionary)["updatedAt"] != nil {
                                            DubyUser.currentUser = self.updatedUser
                                            completion(true)
                                            PFUser.currentUser()?.fetchInBackground()
                                        } else if (response as! NSDictionary)["error"] != nil {
                                            completion(false)
                                            UIAlertView(title: "Error Updating User Information", message: (response as! NSDictionary)["error"] as? String, delegate: self, cancelButtonTitle: OK).show()
                                        }
                                    } else {
                                        UIAlertView(title: "Error Updating User", message: error!.localizedDescription, delegate: self, cancelButtonTitle: OK).show()
                                        
                                        completion(false)
                                        
                                    }
                                })
                            } else {
                                completion(true)
                            }
                        } else {
                            completion(false)
                        }
                    })
                }
            })
        } else if userUpdated {
            DubyDatabase.updateUser(updateDictionary, completion: { (response, error) -> Void in
                if response != nil {
                    if (response as! NSDictionary)["updatedAt"] != nil {
                        DubyUser.currentUser = self.updatedUser
                        completion(true)
                        PFUser.currentUser()?.fetchInBackground()
                    } else if (response as! NSDictionary)["error"] != nil {
                        completion(false)
                        UIAlertView(title: "Error Updating User", message: (response as! NSDictionary)["error"] as? String, delegate: self, cancelButtonTitle: OK).show()
                    }
                } else {
                    UIAlertView(title: "Error Updating User", message: error!.localizedDescription, delegate: self, cancelButtonTitle: OK).show()
                    
                    completion(false)
                }
            })
        } else {
            completion(true)
        }
    }
}
