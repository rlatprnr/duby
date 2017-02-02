//
//  Login2VC.swift
//  Duby
//
//  Created by Aziz on 2015-10-06.
//  Copyright (c) 2015 PragmaOnce, LLC. All rights reserved.
//

import UIKit

class InitialVC: UIViewController, IntroVCDelegate {
  var seenIntro = false
  
  
  required init() {
    super.init(nibName: "InitialVC", bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    edgesForExtendedLayout = .None
    
    navigationController?.navigationBar.translucent = true
    navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
    navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
    navigationController?.navigationBar.shadowImage = UIImage()
    
    (navigationController as! DubyNavVC).barColor = .NewBlue
    view.addSubview(UINavigationBar.dubyWhiteBar())
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.setNavigationBarHidden(true, animated: true)
  }
  
  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    
    navigationController?.setNavigationBarHidden(false, animated: true)
  }
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    
    if (seenIntro) {
      return;
    } else {
      seenIntro = true
      
      let introVC = IntroVC(delegate: self)
      presentViewController(introVC, animated: true, completion: nil)
    }
  }
  
  @IBAction func signupTouchUp() {
    let signupVC = Signup2VC()
    navigationController?.pushViewController(signupVC, animated: true)
  }
  
  @IBAction func loginTouchUp() {
    let loginVC = Login2VC()
    navigationController?.pushViewController(loginVC, animated: true)
  }
  
  func introVCDidFinish() {
    dismissViewControllerAnimated(true, completion: nil)
  }
}