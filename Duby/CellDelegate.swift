//
//  CellDelegate.swift
//  Duby
//
//  Created by Harsh Damania on 1/30/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

@objc protocol CellDelegate {    
    // Edit profile cells
    optional func usernameUpdated(newUsername: String)
    optional func updateBioCellHeight(newHeight: CGFloat)
    optional func bioUpdated(bio: String)
    optional func emailUpdated(newEmail: String)
    optional func genderUpdated(isMale: Bool)
    optional func firstnameUpdated(firstname: String)
    optional func lastnameUpdated(lastname: String)

}
