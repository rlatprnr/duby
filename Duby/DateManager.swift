//
//  DateManager.swift
//  Duby
//
//  Created by Harsh Damania on 2/15/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

/// Convience class, NSDate wrapper
class DateManager: NSObject {
    
    /// Calculate age based on provided date
    class func calculateAge(date: NSDate) -> NSInteger {
        var userAge: NSInteger = 0
        let calendar: NSCalendar = NSCalendar.currentCalendar()
        let unitFlags: NSCalendarUnit = [NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day]
        let dateComponentNow: NSDateComponents = calendar.components(unitFlags, fromDate: NSDate())
        let dateComponentBirth: NSDateComponents = calendar.components(unitFlags, fromDate: date)
        
        if((dateComponentNow.month < dateComponentBirth.month) || ((dateComponentNow.month == dateComponentBirth.month) && (dateComponentNow.day < dateComponentBirth.day))) {
            return dateComponentNow.year - dateComponentBirth.year - 1
        } else {
            return dateComponentNow.year - dateComponentBirth.year
        }
    }
    
    class func getDateComponents(date: NSDate) -> (Int, Int, Int) {
        let dateComponents = NSCalendar.currentCalendar().components([.Second, .NSMinuteCalendarUnit, .NSHourCalendarUnit, .NSDayCalendarUnit, .NSWeekCalendarUnit, .NSMonthCalendarUnit, .NSYearCalendarUnit], fromDate: date)
        
        return (dateComponents.day, dateComponents.month, dateComponents.year)
    }
   
}
