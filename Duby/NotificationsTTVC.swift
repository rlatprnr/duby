//
//  NotificationsTT.swift
//  Duby
//
//  Created by Aziz on 2015-11-19.
//  Copyright © 2015 Dezapp, LLC. All rights reserved.
//

import UIKit


@objc protocol EnableNotesTTVCDelegate {
  func enableNotesTTVCDidOkay()
  func enableNotesTTVCDidCancel()
}

class EnableNotesTTVC: UIViewController {
  
  var delegate: EnableNotesTTVCDelegate?
  
  class func presentFromViewController(viewController: UIViewController, delegate: EnableNotesTTVCDelegate) {
    let vc = EnableNotesTTVC()
    vc.delegate = delegate
    let fvc = MZFormSheetPresentationViewController(contentViewController: vc)
    fvc.presentationController?.shouldDismissOnBackgroundViewTap = true
    fvc.presentationController?.blurEffectStyle = UIBlurEffectStyle.Dark
    //    fvc.presentationController?.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.StyleDropDown
    fvc.presentationController?.contentViewSize = CGSizeMake(300, 300)
    
    viewController.presentViewController(fvc, animated: true, completion: nil)
  }
  
  required init() {
    super.init(nibName: "NotificationsTTVC", bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @IBAction func okayTouchUp() {
    delegate?.enableNotesTTVCDidOkay()
  }
  
  @IBAction func cancelTouchUp() {
    delegate?.enableNotesTTVCDidCancel()
  }
}