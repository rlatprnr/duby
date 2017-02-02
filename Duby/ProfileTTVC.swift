//
//  ProfileTTVC.swift
//  Duby
//
//  Created by Aziz on 2015-11-19.
//  Copyright © 2015 Dezapp, LLC. All rights reserved.
//

import UIKit

@objc protocol ProfileTTVCDelegate {
  func profileTTVCDidCancel()
  func profileTTVCDidEdit()
}

class ProfileTTVC: UIViewController {
  
  var delegate: ProfileTTVCDelegate?
  
  class func presentFromViewController(viewController: UIViewController, delegate: ProfileTTVCDelegate) {
    let vc = ProfileTTVC()
    vc.delegate = delegate
    let fvc = MZFormSheetPresentationViewController(contentViewController: vc)
    fvc.presentationController?.shouldDismissOnBackgroundViewTap = true
    fvc.presentationController?.blurEffectStyle = UIBlurEffectStyle.Dark
    //    fvc.presentationController?.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.StyleDropDown
    fvc.presentationController?.contentViewSize = CGSizeMake(300, 300)
    
    viewController.presentViewController(fvc, animated: true, completion: nil)
  }
  
  required init() {
    super.init(nibName: "ProfileTTVC", bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @IBAction func okayTouchUp() {
    delegate?.profileTTVCDidEdit()
  }
  
  @IBAction func cancelTouchUp() {
    delegate?.profileTTVCDidCancel()
  }
}