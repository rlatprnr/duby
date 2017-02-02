//
//  AppDelegate.swift
//  Duby
//
//  Created by Wilson on 1/5/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit
import CoreData
import Fabric
import Crashlytics
import MessageUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  var note: NSDictionary!
  
  
  func applicationDidBecomeActive(application: UIApplication) {
    NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_BADGE_UPDATE, object: nil)
    FBSDKAppEvents.activateApp()
  }
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    let oneSignal = OneSignal(launchOptions: launchOptions, appId: "15eb97a7-b7a7-4778-9470-db212520c7e8", handleNotification: nil)
    
    OneSignal.defaultClient().enableInAppAlertNotification(true)
    
    UIApplication.sharedApplication().statusBarStyle = .LightContent
    
    //Parse.setApplicationId(PARSE_APPLICATION_ID_VALUE, clientKey: PARSE_CLIENT_KEY_VALUE);
    Parse.initializeWithConfiguration(ParseClientConfiguration(block: { (config) -> Void in
      config.applicationId = PARSE_APPLICATION_ID_VALUE
      config.clientKey = "clientkey"
      config.server = PARSE_SERVER_URL_VALUE
    }))
    
    PFUser.enableRevocableSessionInBackground()
    
    PFConfig.getConfigInBackground()
    Fabric.with([Crashlytics()])
    
    LocationManager.sharedInstance.updateLegals()
    
    /* Change status bar color to white */
    UIApplication.sharedApplication().statusBarStyle = .LightContent
    MZFormSheetPresentationController.appearance().shouldApplyBackgroundBlurEffect = true
    
    UIToolbar.appearance().tintColor = UIColor.whiteColor()
    UINavigationBar.appearance().tintColor = UIColor.whiteColor()
    UINavigationBar.appearance().titleTextAttributes = NSDictionary(dictionary: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.openSans(17.0)]) as? [String : AnyObject]
    UINavigationBar.my_appearanceWhenContainedIn(MFMessageComposeViewController.self).tintColor = nil
    UINavigationBar.my_appearanceWhenContainedIn(MFMessageComposeViewController.self).titleTextAttributes = nil
    
    
    PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)
    
    NSUserDefaults.standardUserDefaults().registerDefaults(["allowTracking": NSNumber(bool: true)])
    NSUserDefaults.standardUserDefaults().synchronize()
    
    self.checkLatestVersion();
    
    window = UIWindow(frame: UIScreen.mainScreen().bounds)
    window?.makeKeyAndVisible()
    
    setupAnalytics()
    showInitial()
    
    
    if PFUser.currentUser() != nil {
      showMain(false)
      registerForNotifications()
    } else {
      showInitial()
    }
    
    if let note = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary {
      delay(2, closure: { () -> () in
        self.handlePushReceived(note)
      })
    }
    
    
    
    NSNotificationCenter.defaultCenter().addObserverForName(NOTIFICATION_DID_SIGNUP, object: nil, queue: nil) { (n) -> Void in
      dispatch_async(dispatch_get_main_queue()) {
        self.showMain(true)
      }}
    
    NSNotificationCenter.defaultCenter().addObserverForName(NOTIFICATION_DID_LOGIN, object: nil, queue: nil) { (n) -> Void in
      dispatch_async(dispatch_get_main_queue()) {
        self.showMain(false)
      }}
    
    NSNotificationCenter.defaultCenter().addObserverForName(NOTIFICATION_DID_LOGOUT, object: nil, queue: nil) { (n) -> Void in
      dispatch_async(dispatch_get_main_queue()) {
        self.showInitial()
      }}
    
    return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  func registerForNotifications() {
    let app = UIApplication.sharedApplication()
    if app.respondsToSelector("registerUserNotificationSettings:") {
      let userNotificationTypes: UIUserNotificationType = ([UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound])
      let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
      app.registerUserNotificationSettings(settings)
      app.registerForRemoteNotifications()
    }
  }
  
  func setupFabric() {
  }
  
  func setupParse() {
  }
  
  func setupAnalytics() {
    GAI.sharedInstance().trackUncaughtExceptions = true
    GAI.sharedInstance().dispatchInterval = 30
    GAI.sharedInstance().trackerWithTrackingId(GOOGLE_ANALYTICS_KEY)
    GAI.sharedInstance().logger.logLevel = GAILogLevel.Error
    
    var _ = GAI.sharedInstance().defaultTracker
  }
  
  func showMain(signedUp: Bool) {
    LocationManager.sharedInstance.whereAmI()
    DubyUser.updateCurrentUser()
    
    let mainVC = MainVC(signedUp: signedUp)
    window?.rootViewController = mainVC
//    
//    if (signedUp) {
//      dispatch_async(dispatch_get_main_queue()) { () -> Void in
//        let localVC = LocalUsersVC()
//        let navVC = DubyNavVC(rootViewController:localVC)
//        mainVC.presentViewController(navVC, animated: true, completion: nil)
//      }
//    }
  }
  
  func showInitial() {
    let initialVC = InitialVC()
    let navVC = DubyNavVC(rootViewController: initialVC)
    
    window?.rootViewController = navVC
  }
  
  func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
    UserDefaults.setDeviceToken(deviceToken)
    
    if PFUser.currentUser() != nil {
      /* Store device token in the current installation on Parse */
      let currentInstallation = PFInstallation.currentInstallation()
      let version: String = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
      currentInstallation.setObject(PFUser.currentUser()!, forKey: "user")
      currentInstallation.setObject(version, forKey: "version")
      currentInstallation.setDeviceTokenFromData(deviceToken)
      currentInstallation.saveInBackgroundWithBlock { (completed, error) -> Void in
        if error != nil {
          NSLog("ERROR (Device Token): Failed to store current installation with error: ", error!)
        }
      }
    }
  }
  
  func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
    NSLog("ERROR (Push Notifications): Failed to register for push notifications: ", error)
  }
  
  func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
    UIApplication.sharedApplication().applicationIconBadgeNumber += 1
    if (application.applicationState == UIApplicationState.Inactive ||
      application.applicationState == UIApplicationState.Background) {
        handlePushReceived(userInfo as NSDictionary)
    } else {
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_BADGE_UPDATE, object: nil)
      })
    }
    
    
    completionHandler(.NewData)
  }
  
  func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
    return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
  }
  
  func applicationWillEnterForeground(application: UIApplication) {
    self.checkLatestVersion();
    LocationManager.sharedInstance.updateLegals()
  }
  
  func applicationDidEnterBackground(application: UIApplication) {
    LocationManager.sharedInstance.startSignificantLocationChanges()
  }
  
  func applicationWillTerminate(application: UIApplication) {
  }
  
  func checkLatestVersion() {
    PFConfig.getConfigInBackgroundWithBlock { (config, error) -> Void in
      let curVersion = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String?;
      let appVersion = config?["version"] as! String?;
      
      if curVersion != nil && appVersion != nil {
        
        if appVersion!.compare(curVersion!, options: NSStringCompareOptions.NumericSearch) == NSComparisonResult.OrderedDescending {
          print("newer version");
          let mainStoryboard = UIStoryboard(name: "LoginRegister", bundle: nil)
          let updateVC = mainStoryboard.instantiateViewControllerWithIdentifier("UpdateVC") 
          self.window?.rootViewController = updateVC;
        }
      }
    }
  }
  
  func handlePushReceived(note: NSDictionary) {
    NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_SHOW_NOTIFICATIONS, object: nil)

    if let aps = note["aps"] as? NSDictionary, alert = aps["alert"] as? String {
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_BADGE_UPDATE, object: nil, userInfo: ["alert": alert])
      })
      
//      if let tabbarVC = (window?.rootViewController as? TabBarContainerVC)?.tabbarVC {
//        tabbarVC.selectedIndex = 3;
//        if let navVC = tabbarVC.selectedViewController as? DubyNavVC {
//          
//          let delay = 1 * Double(NSEC_PER_SEC)
//          let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
//          dispatch_after(time, dispatch_get_main_queue(), {
//            let noteVC =  navVC.viewControllers[0] as! NotesVC
//            noteVC.queueOpenNoteWithText(alert)
//            navVC.popToRootViewControllerAnimated(true)
//          })
//        }
//      } else {
//        self.note = note
//      }
    }
  }
}

