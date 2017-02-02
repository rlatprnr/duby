//
//  NavigationBarColors.swift
//  Duby
//
//  Created by Harsh Damania on 2/8/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

/// Class mapper to help the DubyPushAnimator determine the navigation bar color and attributes
class NavigationBarColors: NSObject {
    
    /// Checks the 2 view controllers that are in the current transitioning phase to determine whether a change in navigation bar is required
    ///
    /// - parameter firstVC: VC is transition from
    /// - parameter secondVC: VC being transitioned to
    /// - returns: whiteToClear whether going from white to clear nav bar
    /// - returns: clearToWhite whether going from clear to white nav bar
    ///
    /// Both of the returns can be false, but both CANNOT be true.
    ///
    class func transitions(firstVC: UIViewController, secondVC: UIViewController) -> (whiteToClear: Bool, clearToWhite: Bool) {
        if NavigationBarColors()[firstVC] != NavigationBarColors()[secondVC] {
            
            if NavigationBarColors()[firstVC] == .White && NavigationBarColors()[secondVC] == .Clear {
                return (true, false)
            } else {
                return (false, true)
            }
            
        } else {
            return (false, false)
        }
    }
    
    /// View controller mapping to return the navigaiton bar color enum
    subscript(viewController: UIViewController) -> NavigationBarColor {
        
        if viewController is LandingVC {
            return .Clear
        } else if viewController is SearchVC {
            return .Clear
        } /*else if viewController is NewDubyVC {
            return .Clear
        } */else if viewController is PreviewVC {
            return .Clear
        } else if viewController is ProfileVC {
            return .White
        } else if viewController is EditProfileVC {
            return .White
        } else if viewController is OptionsContainerVC {
            return .White
        } else if viewController is DetailsTableVC {
            return .Clear
        } else if viewController is DubyDetailsCollectionVC {
            return .White
        } else if viewController is AboutContainerVC {
            return .White
        } else if viewController is ChangePasswordVC {
            return .White
        } else if viewController is CommentsContainerVC {
            return .Clear
        } else if viewController is FollowingVC {
            return .White
        } else if viewController is NotificationsContainerVC {
            return .White
        } else if viewController is HashtagsVC {
            return .White
        }
        
        return .Clear
    }
   
}
