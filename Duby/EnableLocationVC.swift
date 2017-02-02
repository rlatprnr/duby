//
//  EnableLocationVC.swift
//  Duby
//
//  Created by Aziz on 2015-10-08.
//  Copyright (c) 2015 PragmaOnce, LLC. All rights reserved.
//

import UIKit


@objc protocol EnableLocationVCDelegate {
  func enableLocationVCDidOkay()
}

class EnableLocationVC: UIViewController {
  
  var delegate: EnableLocationVCDelegate?
  
  class func presentFromViewController(viewController: UIViewController, delegate: EnableLocationVCDelegate) {
    let vc = EnableLocationVC()
    vc.delegate = delegate
    let fvc = MZFormSheetPresentationViewController(contentViewController: vc)
    fvc.presentationController?.shouldDismissOnBackgroundViewTap = true
    fvc.presentationController?.blurEffectStyle = UIBlurEffectStyle.Dark
//    fvc.presentationController?.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.StyleDropDown
    fvc.presentationController?.contentViewSize = CGSizeMake(300, 300)
    
    viewController.presentViewController(fvc, animated: true, completion: nil)
  }
  
  required init() {
    super.init(nibName: "EnableLocationVC", bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @IBAction func okayTouchUp() {
    delegate?.enableLocationVCDidOkay()
  }
}