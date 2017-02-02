//
//  LandingTTVC.swift
//  Duby
//
//  Created by Aziz on 2015-12-07.
//  Copyright © 2015 Dezapp, LLC. All rights reserved.
//

import UIKit

class LandingTTVC: UIViewController {
  class func presentFromViewController(viewController: UIViewController) {
    let vc = LandingTTVC()
    let fvc = MZFormSheetPresentationViewController(contentViewController: vc)
    fvc.presentationController?.shouldDismissOnBackgroundViewTap = true
    fvc.presentationController?.blurEffectStyle = UIBlurEffectStyle.Dark
    //    fvc.presentationController?.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.StyleDropDown
    fvc.presentationController?.contentViewSize = CGSizeMake(300, 320)
    
    viewController.presentViewController(fvc, animated: true, completion: nil)
  }
  
  required init() {
    super.init(nibName: "LandingTTVC", bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @IBAction func okayTouchUp() {
    dismissViewControllerAnimated(true, completion: nil)
  }
}
