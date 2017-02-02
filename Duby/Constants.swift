//
//  Constants.swift
//  Duby
//
//  Created by DubyDaddy
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit
import MapKit

// MARK: TypeAliases
typealias CompletionHandler = ((locationData: NSDictionary) -> Void)

// MARK: - Session Revoke (rt04092016)
let kPFErrorInvalidSessionToken = 209

// MARK: - Keys
let PARSE_APPLICATION_ID_KEY: String = "X-Parse-Application-Id"
let PARSE_REST_API_KEY: String = "X-Parse-REST-API-Key"

let PARSE_APPLICATION_ID_VALUE: String = "I7j69Zj0dndUwin2e4uMflrruqyptx4X117cpz5p" // duby
let PARSE_REST_API_VALUE: String = "vPLg7QNzafmzbl9uLcPraJvuGlxuht7lLmUOjDNs" // duby
let PARSE_CLIENT_KEY_VALUE: String = "ZVtrh2CFdL75jLhTqQIYTESqKW2FY3Y0lrstgtLz" // duby
//let PARSE_SERVER_URL_VALUE: String = "https://api2.duby.co" // duby
let PARSE_SERVER_URL_VALUE: String = "https://testapi.duby.co" // duby

let GOOGLE_ANALYTICS_KEY = "UA-55621534-1" // duby

// MARK: Storyboards
let STORYBOARD_LOGIN_REGISTER: String = "LoginRegister"
let STORYBOARD_LOGIN_REGISTER_NC: String = "LoginRegisterNC"
let STORYBOARD_INTRO_PAGE_VC: String = "IntroPageVC"
let STORYBOARD_INTRO_PAGE_CONTENT_VC: String = "IntroPageContentVC"
let STORYBOARD_SIGNIN_VC: String = "SignInVC"
let STORYBOARD_SIGNUP_VC: String = "SignUpVC"

//let STORYBOARD_DETAILS_VC: String = "DetailsVC"

let SEGUE_FORGOT_PASSWORD: String = "ForgotPassword"
let SEGUE_EDIT_PROFILE = "EditProfileSegue"
let SEGUE_SETTINGS = "SettingsSegue"

// MARK: 
let OK: String = "Ok"

let ERROR_TITLE_SIGN_IN: String = "Sign In Error"
let ERROR_TITLE_SIGN_UP: String = "Sign Up Error"
let ERROR_TITLE_FORGOT_PASSWORD: String = "Password Reset Error"
let ERROR_TITLE_OUT_OF_AREA = "Out of Area"

let ERROR_MESSAGE_MISSING_EMAIL: String = "Missing Email."
let ERROR_MESSAGE_MISSING_USERNAME: String = "Missing Username."
let ERROR_MESSAGE_MISSING_USERNAME_OR_EMAIL: String = "Missing Username or Email."
let ERROR_MESSAGE_MISSING_PASSWORD: String = "Missing Password."
let ERROR_MESSAGE_MISSING_AGE: String = "Missing Age."
let ERROR_MESSAGE_MISSING_LOCATION: String = "Missing Location."
let ERROR_MESSAGE_OUT_OF_AREA = "Sorry! Duby is currently not available in your state."

let ERROR_MESSAGE_INVALID_EMAIL: String = "Invalid Email."
let ERROR_MESSAGE_INVALID_AGE: String = "You must be at least 18 years of age in order to Duby."

// MARK: Device type screen
let DEVICE_TYPE_SCREEN_4: String = "iPhone 4"
let DEVICE_TYPE_SCREEN_5: String = "iPhone 5"
let DEVICE_TYPE_SCREEN_6: String = "iPhone 6"
let DEVICE_TYPE_SCREEN_6_PLUS: String = "iPhone 6 Plus"

let NOTIFICATION_BADGE_UPDATE = "badgeUpdate"
let NOTIFICATION_SHOW_NOTIFICATIONS = "showNotifications"
let NOTIFICATION_SHOWED_NOTIFICATIONS = "showedNotifications"
let NOTIFICATION_SHOW_PROFILE = "showProfile"
let NOTIFICATION_SHOW_CREATE = "showCreate"
let NOTIFICATION_SHOW_MAIN = "showMain"
let NOTIFICATION_NEW_DUBY = "NewDuby"
let NOTIFICATION_PROFILE_UPDATED = "ProfileUpdated"
let NOTIFICATION_NEW_FOLLOWER = "newFollowerNotification"
let NOTIFICATION_DID_LOGIN = "didLogin"
let NOTIFICATION_DID_LOGOUT = "didLogout"
let NOTIFICATION_DID_SIGNUP = "didSignup"
let NOTIFICATION_DID_UPDATE_LOCATION = "didUpdateLocation"




// Privacy statement, shown in Edit Profile
let PRIVACY_STATEMENT = "Duby is anonymous by default. We require only your current location and email address during registration. Private user information is optional, and is not displayed publicly within the application without explicit permission of the account owner.  Additional information willfully provided by users, including all forms of media shared within the application, may increase the risks of being personally identified. For more information please see our privacy policy."

// MARK: Analytics actions and categories
let ANALYTICS_CATEGORY_API = "api_query"
let ANALYTICS_CATEGORY_UI_ACTION = "ui_action"

let ANALYTICS_ACTION_UI_BUTTON_TAP = "button_tap"
let ANALYTICS_ACTION_UI_DUBY_SWIPE = "duby_swipe"
let ANALYTICS_ACTION_SEARCH = "search"

/* Singleton */
private var currDevModelName: String? = nil

// MARK:
private var commentTextFontSize = [DEVICE_TYPE_SCREEN_4: 8.0 as CGFloat,
                                   DEVICE_TYPE_SCREEN_5: 8.0,
                                   DEVICE_TYPE_SCREEN_6: 12.0,
                                   DEVICE_TYPE_SCREEN_6_PLUS: 13.0]

private var signUpFieldsIcons = ["icon-email",
                                 "icon-username",
                                 "icon-calednar",
                                 "icon-location"]

private var signUpFieldsPlaceholders = ["Enter email",
                            "Create a username",
                            "Enter your age",
                            "Enter your location"]

/// Image quality setting found in Settings
enum ImageQuality: Int {
    case Low, Medium, High
    
    var stringValue: String {
        switch self {
            case .Low: return "Low"
            case .High: return "High"
            case .Medium: return "Medium"
        }
    }
    
    static let values = [Low, Medium, High]
}

/// Types of Tips images that we see. The image is shown in TipsVC
enum TipsControllers: Int {
    case Landing, Search, Create, Profile, Stats
    
    var stringValue: String {
        switch self {
            case .Landing: return "landingTips"
            case .Search: return "searchTips"
            case .Create: return "createTips"
            case .Profile: return "profileTips"
            case .Stats: return "help"
        }
    }
}

/// Notification type. Based on the type, we perform any intereactions
enum NotificationType: String {
    case Update = "update", Commented = "comment", ShareCount = "shareCount", Featured = "featured", Other = "other", Followed = "followed", Boosted = "boosted", Message = "message", MessageSeen = "messageSeen"
    
    init(type: String) {
        if NotificationType.rawValues.contains(type) {
            self = NotificationType(rawValue: type)!
        } else {
            self = Other
        }
    }

    static let rawValues = [Update.rawValue, Commented.rawValue, ShareCount.rawValue, Featured.rawValue, Followed.rawValue, Boosted.rawValue, Message.rawValue, MessageSeen.rawValue]
}


struct Platform {
  static let isSimulator: Bool = {
    var isSim = false
    #if arch(i386) || arch(x86_64)
      isSim = true
    #endif
    return isSim
  }()
}



func delay(delay:Double, closure:()->()) {
  dispatch_after(
    dispatch_time(
      DISPATCH_TIME_NOW,
      Int64(delay * Double(NSEC_PER_SEC))
    ),
    dispatch_get_main_queue(), closure)
}

/// Used for user location masking
enum MapDirection: Int {
    case East, Northeast, North, Northwest, West, Southwest, South, Southeast
    
    static let values = [East, Northeast, North, Northwest, West, Southwest, South, Southeast]
    
    /// Offsets user location in any of the directions listed in the enum.
    ///
    /// - parameter location: Real user location
    /// - returns: User location offsetted
    ///
    func getOffsetCoordinate(location: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let locationOffsetRadius: CLLocationDistance = CLLocationDistance(arc4random_uniform(200) + 50)
        
        // circle around a radios of the offset randomly calculated
        let circle = MKCircle(centerCoordinate: location, radius: locationOffsetRadius)
        let boundingRect = circle.boundingMapRect
        
        let minX = MKMapRectGetMinX(boundingRect)
        let maxX = MKMapRectGetMaxX(boundingRect)
        let minY = MKMapRectGetMinY(boundingRect)
        let maxY = MKMapRectGetMaxY(boundingRect)
        
        let eastX = minX
        let westX = maxX
        let northY = minY
        let southY = maxY
        
        let northSouthCenterX = (minX + maxX) / 2
        let eastWestCenterY = (minY + maxY) / 2
        
        var offsetPoint = MKMapPoint(x: 0, y: 0)
        
        switch self {
        case .East:
            offsetPoint = MKMapPoint(x: eastX, y: eastWestCenterY)
        case .Northeast:
            offsetPoint = MKMapPoint(x: eastX, y: northY)
        case .North:
            offsetPoint = MKMapPoint(x: northSouthCenterX, y: northY)
        case .Northwest:
            offsetPoint = MKMapPoint(x: westX, y: northY)
        case .West:
            offsetPoint = MKMapPoint(x: westX, y: eastWestCenterY)
        case .Southwest:
            offsetPoint = MKMapPoint(x: westX, y: southY)
        case .South:
            offsetPoint = MKMapPoint(x: northSouthCenterX, y: southY)
        case .Southeast:
            offsetPoint = MKMapPoint(x: eastX, y: southY)
        }
        
        return MKCoordinateForMapPoint(offsetPoint)
    }
}

class Constants: NSObject {
    /// Device Model
    class func currentDeviceModelName() -> NSString {
        if (currDevModelName == nil) {
            currDevModelName = UIDevice.currentDevice().modelName
        }
    
        return currDevModelName!
    }
    
    class func isEmailValid(email: NSString) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        return NSPredicate(format:"SELF MATCHES %@", emailRegEx).evaluateWithObject(email)
    }
    
    class func getWidthForText(text: NSString, font: UIFont) -> CGFloat {
        return ceil((text.boundingRectWithSize(CGSizeMake(CGFloat(NSIntegerMax), CGFloat(NSIntegerMax)), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)).size.width)
    }
    
    class func getHeightForText(text: NSString, width: CGFloat, font: UIFont) -> CGFloat {
        return ceil(((text as NSString).boundingRectWithSize(CGSizeMake(width, CGFloat(NSIntegerMax)), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)).size.height)
    }
    
    class func getRectForText(text: NSString, font: UIFont, maxSize: CGSize) -> CGRect {
        return text.boundingRectWithSize(CGSizeMake(maxSize.width, maxSize.height), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
    }
    
    /// Gets day, month, year from the provided date
    class func getDateComponents(date: NSDate) -> (Int, Int, Int) {
        let dateComponents = NSCalendar.currentCalendar().components([.NSDayCalendarUnit, .NSMonthCalendarUnit, .NSYearCalendarUnit], fromDate: date)
        return (dateComponents.day, dateComponents.month, dateComponents.year)
    }
    
    /// Checks if the 2 date days are the same. Only checks day, month, year
    class func checkDateDayEquality(firstDate firstDate: NSDate, secondDate: NSDate) -> Bool {
        let firstComponents = getDateComponents(firstDate)
        let secondComponents = getDateComponents(secondDate)
        
        return firstComponents.0 == secondComponents.0 && firstComponents.1 == secondComponents.1 && firstComponents.2 == secondComponents.2
    }
    
    class func getCommentTextFontSize() -> CGFloat {
        if (currDevModelName == nil) {
            currDevModelName = UIDevice.currentDevice().modelName
        }
        return commentTextFontSize[currDevModelName!]!
    }
    
    /// Helper to convert number to a shorter count text
    class func getCountText(count: Int) -> String {
        if count < 0 { // huh, negetive?
            return "0"
        } else if count < 1000 { // 100s is fine for full count
            return "\(count)"
        } else if count < 100000 { // 1000s = 1.5k
            let thousands = Int(count / 1000)
            let hundreds = Int(Int(count % 1000) / 100)
            return hundreds > 0 ? "\(thousands).\(hundreds)k" : "\(thousands)k"
        } else if count < 1000000 { // 100 1000s = 550k
            return "\(Int(count / 1000))k"
        } else if count < 100000000 {
            let millions = Int(count / 1000000)
            let thousands = Int(Int(count % 1000000) / 100000)
            return thousands > 0 ? "\(millions).\(thousands)m" : "\(millions)m"
        } else {
            return "\(count)"
        }
    }
    
    /// Parse date pointer
    class func getParseISODateDictionary(date: NSDate) -> [String: String] {
        let dict = ["__type" : "Date",
                    "iso" : Constants.dateToISOString(date)]
        
        return dict
    }
    
    /// Converts date to ISO string
    class func dateToISOString(date: NSDate!) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
        
        let gmtTimeZone = NSTimeZone(abbreviation: "GMT")
        formatter.timeZone = gmtTimeZone
        return formatter.stringFromDate(date)
    }
    
    /// Gets date from ISO string
    class func dateFromISOString(dateString: String) -> NSDate {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
//        formatter.timeZone = NSTimeZone(abbreviation: "GMT")
      
      if let date = formatter.dateFromString(dateString) {
        return NSDate(timeInterval: NSTimeInterval(NSTimeZone.systemTimeZone().secondsFromGMT), sinceDate: date)
      }
      
      return NSDate()
    }
    
    /// Checks the given array for any null values and retuens them
    class func removeNullPointersFromArray(array: Array<AnyObject>) -> Array<AnyObject>{
        
        var newArray = Array<AnyObject>()
        
        for object in array {
            if !(object is NSNull) {
                newArray.append(object)
            }
            
        }
        
        return newArray
    }
    
    /// Gets a random direction for user location offset
    class func getRandomDirection() -> MapDirection {
        let direction = Int(arc4random_uniform(UInt32(MapDirection.values.count)))
        
        return MapDirection(rawValue: direction)!
    }
    
    /// Fake user locations that we needed for AdminDubys. WE DO NOT USE THIS ANYMORE.
    class func getFakeUsers() -> [DubyUser] {
        var fakeUsers = [DubyUser]()
        
        let seattle = DubyUser()
        seattle.location_geo = CLLocationCoordinate2DMake(47.6097, -122.3331)
        
        let sf = DubyUser()
        sf.location_geo = CLLocationCoordinate2DMake(37.7833, -122.4167)
        
        let la = DubyUser()
        la.location_geo = CLLocationCoordinate2DMake(34.0500, -118.2500)
        
        let vegas = DubyUser()
        vegas.location_geo = CLLocationCoordinate2DMake(36.1215, -115.1739)
        
        let phx = DubyUser()
        phx.location_geo = CLLocationCoordinate2DMake(33.4500, -112.0667)
        
        let slc = DubyUser()
        slc.location_geo = CLLocationCoordinate2DMake(40.7500, -111.8833)
        
        let pdx = DubyUser()
        pdx.location_geo = CLLocationCoordinate2DMake(45.5200, -122.6819)
        
        let sandiego = DubyUser()
        sandiego.location_geo = CLLocationCoordinate2DMake(32.7150, -117.1625)
        
        let abq = DubyUser()
        abq.location_geo = CLLocationCoordinate2DMake(35.1107, -106.6100)
        
        let okc = DubyUser()
        okc.location_geo = CLLocationCoordinate2DMake(35.4822, -97.5350)
        
        let dallas = DubyUser()
        dallas.location_geo = CLLocationCoordinate2DMake(32.7767, -96.7970)
        
        let houston = DubyUser()
        houston.location_geo = CLLocationCoordinate2DMake(29.7604, -95.3698)
        
        let atl = DubyUser()
        atl.location_geo = CLLocationCoordinate2DMake(33.7550, -84.3900)
        
        let chicago = DubyUser()
        chicago.location_geo = CLLocationCoordinate2DMake(41.8369, -87.6847)
        
        let nyc = DubyUser()
        nyc.location_geo = CLLocationCoordinate2DMake(40.7127, -74.0059)
        
        let philly = DubyUser()
        philly.location_geo = CLLocationCoordinate2DMake(39.9500, -75.1667)
        
        let boston = DubyUser()
        boston.location_geo = CLLocationCoordinate2DMake(42.3601, -71.0589)
        
        let dc = DubyUser()
        dc.location_geo = CLLocationCoordinate2DMake(38.8951, -77.0367)
        
        let miami = DubyUser()
        miami.location_geo = CLLocationCoordinate2DMake(25.7877, -80.2241)
        
        let detroit = DubyUser()
        detroit.location_geo = CLLocationCoordinate2DMake(42.3314, -83.0458)
        
        fakeUsers = [seattle, sf, la, phx, vegas, pdx, abq, slc, sandiego, okc, dallas, houston, atl, chicago, nyc, philly, boston, dc, miami, detroit]
        
        return fakeUsers
    }
}

/// Dictionary appending
func + <K,V>(left: Dictionary<K,V>, right: Dictionary<K,V>)
    -> Dictionary<K,V>
{
    var map = Dictionary<K,V>()
    for (k, v) in left {
        map[k] = v
    }
    for (k, v) in right {
        map[k] = v
    }
    return map
}