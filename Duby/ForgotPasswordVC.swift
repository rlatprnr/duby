//
//  ForgotPasswordVC.swift
//  Duby
//
//  Created by Aziz on 10/19/15.
//  Copyright (c) 2015 PragmaOnce, LLC. All rights reserved.
//

import UIKit


class ForgotPasswordVC: UIViewController {
  
  
  @IBOutlet var emailField: UITextField!

  required init() {
    super.init(nibName: "ForgotPasswordVC", bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Reset"
    edgesForExtendedLayout = .None
    
    navigationController?.navigationBar.translucent = true
    navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
    navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
    navigationController?.navigationBar.shadowImage = UIImage()
    
    (navigationController as! DubyNavVC).barColor = .NewBlue
    view.addSubview(UINavigationBar.dubyWhiteBar())
  }
  
  
  @IBAction func resetTouchUp() {
//    DubyDatabase.forgotPassword(emailField.text!.lowercaseString)
    
    try! PFUser.requestPasswordResetForEmail(emailField.text!)
    
    let alert = UIAlertView(title: "Password Reset", message: "Please check your email and follow the instructions to reset your password", delegate: self, cancelButtonTitle: OK)
    alert.tag = 1
    alert.show()
    
    navigationController?.popViewControllerAnimated(true)
  }
  
}
