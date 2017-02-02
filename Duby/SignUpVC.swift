//
//  Signup2VC.swift
//  Duby
//
//  Created by Aziz on 2015-10-07.
//  Copyright (c) 2015 PragmaOnce, LLC. All rights reserved.
//

import UIKit
 

class Signup2VC: UIViewController, EnableLocationVCDelegate {
  
  @IBOutlet var emailField: UITextField!
  @IBOutlet var usernameField: UITextField!
  @IBOutlet var passwordField: UITextField!
  @IBOutlet var locationButton: UIButton!
  @IBOutlet var termsLabel: TTTAttributedLabel!
  
  var location: String?
  var ofAge = false
  
  required init() {
    super.init(nibName: "SignupVC", bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Who Am I?"
    edgesForExtendedLayout = .None
    
    navigationController?.navigationBar.translucent = true
    navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
    navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
    navigationController?.navigationBar.shadowImage = UIImage()
    
    (navigationController as! DubyNavVC).barColor = .NewBlue
    view.addSubview(UINavigationBar.dubyWhiteBar())
    
    NSNotificationCenter.defaultCenter().addObserverForName(NOTIFICATION_DID_UPDATE_LOCATION, object: nil, queue: nil) { (n) -> Void in
      dispatch_async(dispatch_get_main_queue()) {
        self.updateLocation()
      }}
    
    
    termsLabel.addLinkToURL(NSURL(string: "https://www.duby.co/privacy/"), withRange: (termsLabel.text! as NSString).rangeOfString("terms of service"))
    termsLabel.addLinkToURL(NSURL(string: "http://www.apple.com/legal/internet-services/itunes/appstore/dev/stdeula/"), withRange: (termsLabel.text! as NSString).rangeOfString("end users license agreement"))
    
    
    let tracker = GAI.sharedInstance().defaultTracker
    tracker.send(GAIDictionaryBuilder.createEventWithCategory(ANALYTICS_CATEGORY_UI_ACTION, action: ANALYTICS_ACTION_UI_BUTTON_TAP, label: "opened_signup", value: nil).build() as [NSObject: AnyObject])
  }
  
  func updateLocation() {
    let locationData = LocationManager.sharedInstance.getLocationString()
    location = locationData.locationString
    locationButton.setTitle(location, forState: .Normal)
    locationButton.enabled = false
  }
  
  func showError(error: String) {
    let alert = UIAlertController(title: "Error", message: error, preferredStyle: .Alert)
    alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
    self.presentViewController(alert, animated: true, completion: nil)
  }
  
  @IBAction func signupTouchUp() {
    
    
    let username = usernameField.text
    let email = emailField.text
    let password = passwordField.text
    
    if username == nil || email == nil || password == nil {
      showError("Please specify all fields")
      return
    }
    
    if (location == nil && !Platform.isSimulator) {
      showError("We need your location to sign you up!")
      return
    }
    
    if (ofAge == false) {
      showError("You must be 18 and up to sign up!")
      return
    }
    
    
    
    
    MBProgressHUD.showHUDAddedTo(view, animated: true)
    let user = PFUser()
    user.username = username
    user.password = password
    user.email = email
    
    let geoPoint = PFGeoPoint(location: Platform.isSimulator ? CLLocation(latitude: 43.70463450334839, longitude: -79.3747415103232) :  LocationManager.sharedInstance.currentLocation!)
    user.setValue(Platform.isSimulator ? "Toronto" : self.location, forKey: "location")
    user.setValue(geoPoint, forKey: "location_geo")
    user.setValue(5, forKey: "influence")
    user.setValue(0, forKey: "totalReach")
    user.setValue(0, forKey: "bestDuby")
    
    PFConfig.getConfigInBackground()
    
    // now send up new user data
    user.signUpInBackgroundWithBlock({ (succeeded, error) -> Void in
      print("error: \(error)")
      if error == nil && succeeded == true {
        
        PFCloud.callFunctionInBackground("setupInitialShares", withParameters: ["":""], block: { (obj, error) -> Void in
          DubyUser.updateCurrentUser()
//          DubyDatabase.setPasswordAndEmail(email!)
          
          UserDefaults.setAllTips(seen: false)
          MBProgressHUD.hideHUDForView(self.view, animated:true);
          NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_DID_SIGNUP, object: nil)
          
          PFCloud.callFunctionInBackground("setupUser", withParameters: ["":""], block: { (obj, error) -> Void in
            print("returning from setupuser")
            print(error)
          })
          
          
          NSNotificationCenter.defaultCenter().postNotificationName("sharpImage", object: nil)
          
          /* Store Device Token for Push Notifications */
          if UserDefaults.getDeviceToken() != nil {
            let currentInstallation = PFInstallation.currentInstallation()
            let version: String = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
            currentInstallation.setObject(PFUser.currentUser()!, forKey: "user")
            currentInstallation.setObject(version, forKey: "version")
            currentInstallation.setDeviceTokenFromData(UserDefaults.getDeviceToken())
            currentInstallation.saveInBackgroundWithBlock({ (completed, error) -> Void in
              if error != nil {
                NSLog("ERROR (Device Token - SignUp): Failed to store current installation with error: ", error!)
              }
            })
          } else {
            print("ERROR (Device Token SignUp: Device token does not exist during sign up")
          }
          
          let tracker = GAI.sharedInstance().defaultTracker
          tracker.send(GAIDictionaryBuilder.createEventWithCategory(ANALYTICS_CATEGORY_UI_ACTION, action: ANALYTICS_ACTION_UI_BUTTON_TAP, label: "signed_up", value: nil).build() as [NSObject: AnyObject])
          
          return
        })
        
      } else {
        MBProgressHUD.hideHUDForView(self.view, animated:true);
        
        UIAlertView(title: ERROR_TITLE_SIGN_UP, message: error!.userInfo["error"] as? String, delegate: nil, cancelButtonTitle: OK).show()
      }
    })
  }
  
  func handleEnableLocation() {
    
    
    if LocationManager.sharedInstance.locationServicesDisabled || (CLLocationManager.authorizationStatus() == .Denied || CLLocationManager.authorizationStatus() == .Restricted) {
      let message = "Please enable Location Services for Duby in your device Settings to use the app. Settings > Privacy > Location > Duby"
      
      let actionSheetController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
      
      let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
      }
      actionSheetController.addAction(cancelAction)
      let sAction: UIAlertAction = UIAlertAction(title: "Open Settings", style: .Default) { action -> Void in
        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
      }
      actionSheetController.addAction(sAction)
      self.presentViewController(actionSheetController, animated: true, completion: nil)
    } else {
      LocationManager.sharedInstance.whereAmI()
    }
  }
  
  @IBAction func locationTouchUp() {
    if let showLocDialog = try! PFConfig.getConfig().objectForKey("signup_enable_location") as? Bool where showLocDialog == true {
      EnableLocationVC.presentFromViewController(self, delegate: self)
    } else {
      handleEnableLocation()
    }
  }
  
  @IBAction func ageTouchUp(button: UIButton) {
    let alert = UIAlertController(title: "Confirm Age", message: "Are you above the age of 18?", preferredStyle: UIAlertControllerStyle.Alert)
    alert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
    alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action) -> Void in
      self.ofAge = true
      
      button.setTitle("Over 18", forState: .Normal)
      button.enabled = false
      
      self.view.endEditing(true)
    }))
    self.presentViewController(alert, animated: true, completion: nil)
  }
  
  func enableLocationVCDidOkay() {
    dismissViewControllerAnimated(true, completion: nil)
    handleEnableLocation()
  }
  
  func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
    UIApplication.sharedApplication().openURL(url);
  }
}