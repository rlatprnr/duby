//
//  NotificationModel.swift
//  Duby
//
//  Created by Anurag Kamasamudram on 3/18/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

class NotificationModel: NSObject {
    
    var notifications = [Notification]()
    var unseenNotificationsCount = 0
    
    var tableNotifications = [DubyNotification]()
    private var unseenNotifications = [String]()
    
    private var page = 0
    private var canPaginateMore: Bool = false
    private var additionalNotifications = [DubyNotification]()
    private var additionalUnseenNotifications = [String]()
    
    class var sharedInstance : NotificationModel {
        struct Singleton {
            static let instance = NotificationModel()
        }
        
        return Singleton.instance
    }
    
    class func markNotificationsSeen() {
        if sharedInstance.unseenNotifications.count > 0 {
            DubyDatabase.markMultipleNotificationsSeen(sharedInstance.unseenNotifications)
            sharedInstance.unseenNotifications = [String]()
        }
    }
    
    class func getNumberOfNotifications() -> Int {
        return sharedInstance.tableNotifications.count
    }
    
    class func getNotificationInfo(index index: Int) -> DubyNotification {
        return sharedInstance.tableNotifications[index]
    }
    
    class func getHeightForCellAtIndex(index: Int) -> CGFloat {
        let defaultCellHeight: CGFloat = 60
        let defaultTextViewHeight: CGFloat = 17
        var cellHeight: CGFloat = 60
        
        let notification = getNotificationInfo(index: index)
        let attributedMessage = notification.attributedMessage
        
        var textViewWidth = CGRectGetWidth(UIScreen.mainScreen().bounds) - 2*40 - 4*8 // 40=username, duby width. 8=paddings around places
        textViewWidth += 8 + 40
        
        let messageHeight = attributedMessage.boundingRectWithSize(CGSize(width: textViewWidth, height: 54), options: [NSStringDrawingOptions.UsesFontLeading, NSStringDrawingOptions.UsesLineFragmentOrigin], context: nil).size.height
        
        if messageHeight < defaultTextViewHeight {
            return cellHeight
        } else {
            cellHeight = defaultCellHeight + (messageHeight - defaultTextViewHeight)
        }
        
        return ceil(cellHeight)
    }
    
    class func addAdditionalNotifications() -> Bool {
        if sharedInstance.canPaginateMore {
            sharedInstance.unseenNotifications += sharedInstance.additionalUnseenNotifications
            sharedInstance.tableNotifications += sharedInstance.additionalNotifications
            
            getNotifications(paginateMore: true, completion: { (gotNotifications) -> Void in
                if !gotNotifications {
                    NotificationModel.sharedInstance.canPaginateMore = false
                } else {
                    NotificationModel.sharedInstance.canPaginateMore = NotificationModel.sharedInstance.additionalNotifications.count >= 20
                }
            })
            
            return true
        }
        
        return false
    }
    
    class func getNotifications(paginateMore paginateMore: Bool, completion: (Bool) -> Void) {
        
        if !paginateMore { // initialCall, reset stuff
            NotificationModel.sharedInstance.page = 0
        } else {
            NotificationModel.sharedInstance.page++
        }
        
      DubyDatabase.getNotifications(type: "all") { (notifications, error) -> Void in
            if notifications != nil && notifications!.count > 0 {
                var notifs = [DubyNotification]()
                var unseenNotifs = [String]()
                
                for notification in notifications! {
                    let shouldAppend = true
                    
//                    switch notification.type {
//                    case .Commented:
//                        shouldAppend = notification.duby != nil && notification.duby?.objectId != "" && notification.fromUser?.objectId != "" && notification.duby?.createdBy.objectId != ""
//                    case .Update, .Other:
//                        shouldAppend = notification.message != ""
//                    case .ShareCount:
//                        shouldAppend = notification.duby != nil && notification.duby?.objectId != "" && notification.message != ""
//                    }
                    
                    if shouldAppend {
                        notifs.append(notification)
                        
                        if !notification.seen! {
                            unseenNotifs.append(notification.objectId)
                        }
                        
                    } else {
                        if !notification.seen! {
                            //DubyDatabase.markNotificationSeen(notification.objectId)
                        }
                    }
                }
                
                if !paginateMore { // initialCall, reset stuff. We do this later on after getting the data to avoid a crash during pull to refresh
                    NotificationModel.sharedInstance.unseenNotifications = [String]()
                    NotificationModel.sharedInstance.tableNotifications = [DubyNotification]()
                } else {
                    NotificationModel.sharedInstance.additionalUnseenNotifications = [String]()
                    NotificationModel.sharedInstance.additionalNotifications = [DubyNotification]()
                }

                if paginateMore {
                    NotificationModel.sharedInstance.additionalUnseenNotifications = unseenNotifs
                    NotificationModel.sharedInstance.additionalNotifications = notifs
                } else {
                    NotificationModel.sharedInstance.unseenNotifications = unseenNotifs
                    NotificationModel.sharedInstance.tableNotifications = notifs
                    
                    if notifications?.count == 20 {
                        NotificationModel.sharedInstance.canPaginateMore = true
                    } else {
                        NotificationModel.sharedInstance.canPaginateMore = false
                    }
                }
                
                if notifs.count > 0 {
                    completion(true)
                } else {
                    NotificationModel.sharedInstance.canPaginateMore = false
                    completion(false)
                }
                
            } else {
                NotificationModel.sharedInstance.canPaginateMore = false
                if !paginateMore {
                    NotificationModel.sharedInstance.unseenNotifications = [String]()
                    NotificationModel.sharedInstance.tableNotifications = [DubyNotification]()
                } else {
                    NotificationModel.sharedInstance.additionalUnseenNotifications = [String]()
                    NotificationModel.sharedInstance.additionalNotifications = [DubyNotification]()
                }
                completion(false)
            }
        }
    }
}
