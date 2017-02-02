//
//  NotesVC.swift
//  Duby
//
//  Created by Aziz on 2015-08-18.
//  Copyright (c) 2015 PragmaOnce, LLC. All rights reserved.
//


//remove < Activity crap

//textview did touch crap
//remove notificationsvc, rename to it
//move from function to notification for when notification arrives

import UIKit
import MobileCoreServices


class NotesVC: UITableViewController, NotificationCellDelegate, PMViewVCDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, PMComposeVCDelegate, EnableNotesTTVCDelegate {
  
  enum Type : String {
    case All = "all"
    case Private = "private"
  }
  
  let notificationCellIden = "NotificationCell"
  let privateCellIden = "PrivateCell"
  
  @IBOutlet var headerView: UIView!
  @IBOutlet var messagesImageView: UIImageView!
  @IBOutlet var notificationsButton: UIButton!
  @IBOutlet var privatesButton: UIButton!
  
  var notifications: [DubyNotification] = []
  var type : Type = .All
  
  var selectedNotification: DubyNotification?
  var queuedNoteWithText: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "notificationReceived:", name: NOTIFICATION_BADGE_UPDATE, object: nil)
    setupAppearance()
    
    if !UIApplication.sharedApplication().isRegisteredForRemoteNotifications() {
      if let showLocDialog = try! PFConfig.getConfig().objectForKey("signup_enable_notification") as? Bool where showLocDialog == true {
        delay(1.5, closure: { () -> () in
          EnableNotesTTVC.presentFromViewController(self, delegate: self)
        })
      } else {
        (UIApplication.sharedApplication().delegate as! AppDelegate).registerForNotifications()
      }
    }
    
    messagesImageView.hidden = true
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    UIApplication.sharedApplication().statusBarStyle = .LightContent
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    reload()
    
    let tracker = GAI.sharedInstance().defaultTracker
    tracker.set(kGAIScreenName, value: "PMNotesVC")
    tracker.set("event", value: "opened")
    tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject: AnyObject])
    
    
    
    PFCloud.callFunctionInBackground("hasMessages", withParameters: nil) { (resp, error) -> Void in
      if let hasMessages = resp as? Bool where hasMessages == true {
        self.animateMessagesIcon()
      }
    }
  }
  
  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
  }
  
  func setupAppearance() {
    title = "Activity"
    
    navigationController?.navigationBar.translucent = true
//    navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
    navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
    (navigationController as! DubyNavVC).barColor = .Clear
    
    edgesForExtendedLayout = .None
    
    tableView.backgroundColor = UIColor.clearColor()
    
    let item = UIBarButtonItem(image: UIImage(named: "home_icon-2")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), style: .Plain, target: self, action: "showMain")
    navigationItem.rightBarButtonItem = item
  }
  
  
  func notificationReceived(note: NSNotification) {
    if let info = note.userInfo, alert = info["alert"] as? String {
      queuedNoteWithText = alert
      reload()
    } else {
      reload()
    }
  }
  
  func animateMessagesIcon() {
    
    messagesImageView.hidden = false
    
    let center = self.messagesImageView.center
    let anim = CABasicAnimation(keyPath: "position")
    anim.duration = 0.05
    anim.repeatCount = 20
    anim.autoreverses = true
    
    anim.fromValue = NSValue(CGPoint:CGPointMake(center.x - 5, center.y))
    anim.toValue = NSValue(CGPoint:CGPointMake(center.x + 5, center.y))
    
    self.messagesImageView.layer.addAnimation(anim, forKey: "pos")
//    delay(1) { () -> () in
//      self.messagesImageView.hidden = true
//    }
  }
  
  func showMain() {
    NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_SHOW_MAIN, object: nil)
  }
  
  
  
  func reload() {
    
    if let text = queuedNoteWithText  {
      if (text.rangeOfString("sent you a") != nil) {
        privatesButton.alpha = 1
        notificationsButton.alpha = 0.6
        type = .Private
      } else {
        
        notificationsButton.alpha = 1
        privatesButton.alpha = 0.6
        type = .All
      }
    }
    
    if (self.view.window != nil && UIApplication.sharedApplication().applicationIconBadgeNumber != 0) {
      UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }
    
    MBProgressHUD.showHUDAddedTo(view, animated: true)
    DubyDatabase.getNotifications(type: type.rawValue) { (notifications, error) -> Void in
      MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
      if let notifications = notifications {
        self.notifications = notifications
        self.markSeen()
        
        
        self.tableView.reloadData()
        
        
        if let text = self.queuedNoteWithText {
          for (i, note) in self.notifications.enumerate() {
            if note.text == text {
              self.tableView(self.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: i, inSection: 0))
              self.queuedNoteWithText = nil;
              break;
            }
          }
        }
        
      }
    }
  }
  
  func markSeen() {
    let unseen = notifications.filter({ (note) -> Bool in
      return !note.seen!
    })
    
    let ids = unseen.map({ (note) -> String in
      return note.objectId
    })
    
    DubyDatabase.markMultipleNotificationsSeen(ids)
  }
  
  func openCamera() {
    let picker = UIImagePickerController()
    picker.sourceType = .Camera;
    picker.mediaTypes = [kUTTypeImage as String]
    picker.delegate = self
    picker.navigationBar.titleTextAttributes = nil
    picker.navigationBar.tintColor = nil
      
    presentViewController(picker, animated: true, completion: nil)
  }
  
  func openLibrary() {
      let picker = UIImagePickerController()
      
      picker.sourceType = .PhotoLibrary;
      picker.mediaTypes = [kUTTypeImage as String]
      picker.delegate = self
      picker.navigationBar.titleTextAttributes = nil
      picker.navigationBar.tintColor = nil
      
      presentViewController(picker, animated: true, completion: nil)
  }
  
  func showUploadOptions() {
    let actionSheet = UIActionSheet(title: "Select a Mode", delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
    actionSheet.addButtonWithTitle("Cancel")
    actionSheet.addButtonWithTitle("Camera")
    actionSheet.addButtonWithTitle("Photo Library")
    
    actionSheet.cancelButtonIndex = 0
    
    actionSheet.showInView(UIApplication.sharedApplication().keyWindow!)
  }
  
  @IBAction func showPrivates() {
    privatesButton.alpha = 1
    notificationsButton.alpha = 0.6
    type = .Private
    
    reload()
    
    
    let tracker = GAI.sharedInstance().defaultTracker
    tracker.set(kGAIScreenName, value: "PMNotesVC")
    tracker.set("event", value: "pm_opened")
    tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject: AnyObject])
  }
  
  @IBAction func showNotifications() {
    privatesButton.alpha = 0.6
    notificationsButton.alpha = 1
    type = .All
    
    reload()
    
    let tracker = GAI.sharedInstance().defaultTracker
    tracker.set(kGAIScreenName, value: "PMNotesVC")
    tracker.set("event", value: "activity_opened")
    tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject: AnyObject])
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    if type == .Private {
      return 2
    }
    return 1
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    
    if type == .Private && indexPath.section == 0 {
      return 60
    }
    
    let notification = notifications[indexPath.row]
    return NotificationCell.heightForNotification(notification)
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if type == .Private && section == 0 {
      return 1
    }
    return notifications.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if type == .Private && indexPath.section == 0 {
      let cell = tableView.dequeueReusableCellWithIdentifier("SendAllCell")!
      return cell
    }
    
    let cell = tableView.dequeueReusableCellWithIdentifier(notificationCellIden) as! NotificationCell
    let notification = notifications[indexPath.row]
    
    cell.setNotification(notification)
    cell.delegate = self
    cell.notificationTextView.tag = indexPath.row
    //!!!
//    cell.notificationTextView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "textViewTapped:"))
    notification.seen = true
    
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    if type == .Private && indexPath.section == 0 {
      showUploadOptions()
//      var sendVC = PMSendVC(file: nil)
//      var navVC = DubyNavVC(rootViewController: sendVC)
//      self.presentViewController(navVC, animated: true, completion: nil)
      return
    }
    
    let notification = notifications[indexPath.row]
    
    switch notification.type {
    case .Commented, .Featured, .Other:
      if let dubyId = notification.dubyId {
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        DubyDatabase.getDubyInfo(dubyId, completion: { (duby, error) -> Void in
          MBProgressHUD.hideHUDForView(self.view, animated: true)
          if error != nil {
            self.navigationController?.pushToDetailsVC(duby: duby)
          } else {
            self.navigationController?.pushToDetailsVC(duby: duby)
          }
        })
      }
    case .ShareCount:
      if let dubyId = notification.dubyId {
        let passersVC = PassersVC()
        passersVC.dubyId = dubyId
        navigationController?.pushViewController(passersVC, animated: true)
      }
      break
    case .Followed:
      if let userId = notification.fromUserId {
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        DubyDatabase.getUserInfo(userId, completion: { (user, error) -> (Void) in
          MBProgressHUD.hideHUDForView(self.view, animated: true)
          if user != nil {
            self.navigationController?.pushToProfileVC(user: user)
          }
        })
      }
      break
    case .Boosted:
      if let userId = notification.toUserId {
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        DubyDatabase.getUserInfo(userId, completion: { (user, error) -> (Void) in
          MBProgressHUD.hideHUDForView(self.view, animated: true)
          if user != nil {
            self.navigationController?.pushToProfileVC(user: user)
          }
        })
      }
      break
    case .Update:
      let appID = "966442183"
      UIApplication.sharedApplication().openURL(NSURL(string: NSString(format: "itms-apps://itunes.apple.com/app/id%@", appID) as String)!)
      break
      
    case .Message:
      let viewVC = PMViewVC(notification: notification, delegate: self)
      presentViewController(viewVC, animated: true, completion: nil)
      break
    case .MessageSeen:
      selectedNotification = notification
      showUploadOptions()
      
      break
    }
  }
  
  func notificationCellDidTapUserWithId(userId: String) {
    DubyDatabase.getUserInfo(userId, completion: { (user, error) -> (Void) in
      if let user = user {
        self.navigationController?.pushToProfileVC(user: user)
      }
    })
  }
  
  func viewVCDidFinish(viewVC: PMViewVC) {
    dismissViewControllerAnimated(true, completion: nil)
  }
    
  func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
    if buttonIndex == actionSheet.cancelButtonIndex {
      return
    }
      
    if buttonIndex == 1 {
        openCamera()
    } else if buttonIndex == 2 {
        openLibrary()
    } else if buttonIndex == 3 {
    }
  }
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
    picker.dismissViewControllerAnimated(true, completion: { () -> Void in
      
      let image = UIImage.resizedImageToFillWithBounds(image, bounds: CGSizeMake(750, 1134))
      if let note = self.selectedNotification {
        let composer = PMComposerVC(image: image, toUser: DubyUser(data: ["objectId" : note.fromUserId!]), delegate: self)
        self.presentViewController(composer, animated: true, completion: nil)
      } else {
        let composer = PMComposerVC(image: image, toUser: nil, delegate: self)
        self.presentViewController(composer, animated: true, completion: nil)
        
//        var sendVC = PMSendVC()
//        self.presentViewController(sendVC, animated: true, completion: nil)
      }
      
      
      self.selectedNotification = nil
    })
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func composeVCDidFinish(composeVC: PMComposerVC) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func enableNotesTTVCDidOkay() {
    (UIApplication.sharedApplication().delegate as! AppDelegate).registerForNotifications()
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func enableNotesTTVCDidCancel() {
    dismissViewControllerAnimated(true, completion: nil)
  }
}
