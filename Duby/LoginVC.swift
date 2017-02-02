//
//  Login2VC.swift
//  Duby
//
//  Created by Aziz on 2015-10-09.
//  Copyright (c) 2015 PragmaOnce, LLC. All rights reserved.
//

import UIKit
 

class Login2VC: UIViewController {
  
  @IBOutlet var usernameField: UITextField!
  @IBOutlet var passwordField: UITextField!
  
  
  required init() {
    super.init(nibName: "LoginVC", bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Login"
    edgesForExtendedLayout = .None
    
    navigationController?.navigationBar.translucent = true
    navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
    navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
    navigationController?.navigationBar.shadowImage = UIImage()
    
    (navigationController as! DubyNavVC).barColor = .NewBlue
    view.addSubview(UINavigationBar.dubyWhiteBar())
  }
  
  @IBAction func forgotTouchUp() {
    let passVC = ForgotPasswordVC()
    navigationController?.pushViewController(passVC, animated: true)
  }
  
  @IBAction func loginTouchUp() {
    
    var alert = UIAlertView()
    if usernameField.text!.isEmpty { // is username empty? It says email, but was later changed to email
      alert = UIAlertView(title: ERROR_TITLE_SIGN_IN, message: ERROR_MESSAGE_MISSING_USERNAME_OR_EMAIL, delegate: self, cancelButtonTitle: OK)
      alert.show()
      //        } else if emailTextField.text.isEmail() {
      //            alert = UIAlertView(title: ERROR_TITLE_FORGOT_PASSWORD, message: ERROR_MESSAGE_INVALID_EMAIL, delegate: self, cancelButtonTitle: OK)
      //            alert.show()
    } else if passwordField.text!.isEmpty { // is password empty?
      alert = UIAlertView(title: ERROR_TITLE_SIGN_IN, message: ERROR_MESSAGE_MISSING_PASSWORD, delegate: self, cancelButtonTitle: OK)
      alert.show()
    } else {
      
      MBProgressHUD.showHUDAddedTo(view, animated: true)
      view.userInteractionEnabled = false
      PFUser.logInWithUsernameInBackground(usernameField.text!.lowercaseString, password: passwordField.text!) { (user, error) -> Void in
        print("error: \(error)")
        print("user: \(user)")
        
        if error == nil && user != nil {
                    
          DubyUser.updateCurrentUser()
          LocationManager.sharedInstance.sendLocationUpdate = true
          NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_DID_LOGIN, object: nil)
          
          MBProgressHUD.hideHUDForView(self.view, animated:true)
          
          if UserDefaults.getDeviceToken() != nil {
            let currentInstallation = PFInstallation.currentInstallation()
            let version: String = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
            currentInstallation.setObject(PFUser.currentUser()!, forKey: "user")
            currentInstallation.setObject(version, forKey: "version")
            currentInstallation.setDeviceTokenFromData(UserDefaults.getDeviceToken())
            currentInstallation.saveInBackgroundWithBlock({ (completed, error) -> Void in
              if error != nil {
                NSLog("ERROR (Device Token - SignIn): Failed to store current installation with error: ", error!)
              }
            })
          } else {
            print("ERROR (Device Token SignIn: Device token does not exist during sign up")
          }
          
          
        } else {
          MBProgressHUD.hideHUDForView(self.view, animated:true)
          
          UIAlertView(title: ERROR_TITLE_SIGN_IN, message: error!.userInfo["error"] as! NSString as String, delegate: self, cancelButtonTitle: OK).show()
          self.view.userInteractionEnabled = true
        }
      }
    }
  }
}