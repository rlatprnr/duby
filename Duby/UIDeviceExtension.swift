//
//  UIDeviceExtension.swift
//  Duby
//
//  Created by Wilson on 1/7/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

private var deviceList =   ["i386":         "Simulator",
    "iPod1,1":      "iPod Touch",       // (Original)
    "iPod2,1":      "iPod Touch 2",     // (Second Generation)
    "iPod3,1":      "iPod Touch 3",     // (Third Generation)
    "iPod4,1":      "iPod Touch 4",     // (Fourth Generation)
    "iPhone1,1":    "iPhone 1",         // (Original)
    "iPhone1,2":    "iPhone 3G",        // (3G)
    "iPhone2,1":    "iPhone 3GS",       // (3GS)
    "iPad1,1":      "iPad 1",           // (Original)
    "iPad2,1":      "iPad 2",           //
    "iPad3,1":      "iPad 3",           // (3rd Generation)
    "iPhone3,1":    DEVICE_TYPE_SCREEN_4,         //
    "iPhone3,2":    DEVICE_TYPE_SCREEN_4,         //
    "iPhone4,1":    DEVICE_TYPE_SCREEN_4,        //
    "iPhone5,1":    DEVICE_TYPE_SCREEN_5,         // (model A1428, AT&T/Canada)
    "iPhone5,2":    DEVICE_TYPE_SCREEN_5,         // (model A1429, everything else)
    "iPad3,4":      "iPad 4",           // (4th Generation)
    "iPad2,5":      "iPad Mini 1",      // (Original)
    "iPhone5,3":    DEVICE_TYPE_SCREEN_5,        // (model A1456, A1532 | GSM)
    "iPhone5,4":    DEVICE_TYPE_SCREEN_5,        // (model A1507, A1516, A1526 (China), A1529 | Global)
    "iPhone6,1":    DEVICE_TYPE_SCREEN_5,        // (model A1433, A1533 | GSM)
    "iPhone6,2":    DEVICE_TYPE_SCREEN_5,        // (model A1457, A1518, A1528 (China), A1530 | Global)
    "iPad4,1":      "iPad Air 1",       // 5th Generation iPad (iPad Air) - Wifi
    "iPad4,2":      "iPad Air 2",       // 5th Generation iPad (iPad Air) - Cellular
    "iPad4,4":      "iPad Mini 2",      // (2nd Generation iPad Mini - Wifi)
    "iPad4,5":      "iPad Mini 2",      // (2nd Generation iPad Mini - Cellular)
    "iPhone7,1":    DEVICE_TYPE_SCREEN_6_PLUS,    // All iPhone 6 Plus's
    "iPhone7,2":    DEVICE_TYPE_SCREEN_6          // All iPhone 6's
]


public extension UIDevice {
  
  var modelName: String {
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let identifier = machineMirror.children.reduce("") { identifier, element in
      guard let value = element.value as? Int8 where value != 0 else { return identifier }
      return identifier + String(UnicodeScalar(UInt8(value)))
    }
    
    switch identifier {
    case "iPod5,1":                                 return "iPod Touch 5"
    case "iPod7,1":                                 return "iPod Touch 6"
    case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
    case "iPhone4,1":                               return "iPhone 4s"
    case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
    case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
    case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
    case "iPhone7,2":                               return "iPhone 6"
    case "iPhone7,1":                               return "iPhone 6 Plus"
    case "iPhone8,1":                               return "iPhone 6s"
    case "iPhone8,2":                               return "iPhone 6s Plus"
    case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
    case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
    case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
    case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
    case "iPad5,1", "iPad5,3", "iPad5,4":           return "iPad Air 2"
    case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
    case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
    case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
    case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
    case "i386", "x86_64":                          return "Simulator"
    default:                                        return identifier
    }
  }
  
}
