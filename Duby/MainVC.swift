//
//  MainVC.swift
//  Duby
//
//  Created by Duby on 10/26/15.
//  Copyright (c) 2016 Duby LLC. All rights reserved.
//

import UIKit

class MainVC: UIViewController, DubyNavVCDelegate, LocalUsersVCDelegate {
  
  @IBOutlet var containerView: UIView!
  @IBOutlet var mainView: UIView!
  @IBOutlet var leftView: UIView!
  @IBOutlet var rightView: UIView!
  @IBOutlet var gesRecognizer: UIPanGestureRecognizer!
  
  @IBOutlet var containerViewConstraint: NSLayoutConstraint!
  
  
  var mainNavVC: DubyNavVC!
  var leftNavVC: DubyNavVC!
  var rightNavVC: DubyNavVC!
  
  
  var signedUp: Bool!
  var seen = false
  
  required init(signedUp: Bool) {
    self.signedUp = signedUp
    
    super.init(nibName: "MainVC", bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    mainNavVC = instantiateViewController("LandingNavVC") as! DubyNavVC
    leftNavVC = instantiateViewController("NotesNavVC") as! DubyNavVC
    rightNavVC = instantiateViewController("ProfileNavVC") as! DubyNavVC
    
    mainNavVC.navDelegate = self
    leftNavVC.navDelegate = self
    rightNavVC.navDelegate = self
    
    addViewController(mainNavVC, view: mainView)
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "showNotifications", name: NOTIFICATION_SHOW_NOTIFICATIONS, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "showProfile", name: NOTIFICATION_SHOW_PROFILE, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "showMain", name: NOTIFICATION_SHOW_MAIN, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "showCreate", name: NOTIFICATION_SHOW_CREATE, object: nil)
    
//
    
//    delay(1) { () -> () in
//      if (self.signedUp == true) {
//        (self.mainNavVC.viewControllers[0] as! LandingVC).didSignUp()
//      } else {
//      }
//    }
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    
    if (signedUp == true && !seen) {
      (self.mainNavVC.viewControllers[0] as! LandingVC).didSignUp()
      print("SIGNED UP")
      
      if let showLocal = try! PFConfig.getConfig().objectForKey("signup_local_follower") as? Bool where showLocal == true {
        let localVC = LocalUsersVC()
        localVC.delegate = self
        let navVC = DubyNavVC(rootViewController:localVC)
        presentViewController(navVC, animated: true, completion: nil)
      } else {
        showLandingTTIfNeeded()
      }
    } else {
      print("NOT SIGNED UP")
      showLandingTTIfNeeded()
    }
    
    seen = true
  }
  
  func instantiateViewController(iden: String) -> UIViewController {
    let mainStoryboard = UIStoryboard(name: "Main", bundle: nil);
    let vc = mainStoryboard.instantiateViewControllerWithIdentifier(iden) 
    return vc
  }
  
  func addViewController(vc: UIViewController, view: UIView) {
    addChildViewController(vc)
    view.addSubview(vc.view)
    vc.view.frame = view.bounds
    
    vc.didMoveToParentViewController(self)
  }
  
  func removeViewController(vc: UIViewController) {
    if vc.parentViewController == nil {
      return
    }
    
    vc.willMoveToParentViewController(nil)
    vc.view.removeFromSuperview()
    vc.removeFromParentViewController()
  }
  
  func showCreate() {
    showMain {
    }
    let mainStoryboard = UIStoryboard(name: "Main", bundle: nil);
    let vc = mainStoryboard.instantiateViewControllerWithIdentifier("CreateTableVC")
    self.mainNavVC.pushViewController(vc, animated: true)
  }
  
  func showLandingTTIfNeeded() {
    let user = PFUser.currentUser()!
    let key = "flag_landing"
    if user[key] == nil {
      user[key] = true
      user.saveEventually(nil)
      
      
      if let showLandingTT = try! PFConfig.getConfig().objectForKey("signup_onboarding_landing") as? Bool where showLandingTT == true {
        LandingTTVC.presentFromViewController(self)
      }
    } else {
      
    }
  }
  
  func showNotifications() {
    if (leftNavVC.parentViewController == nil) {
      print("adding left")
      addViewController(leftNavVC, view: leftView)
    }
    
    self.leftNavVC.popToRootViewControllerAnimated(false)

    
    let width = mainView.bounds.size.width
    containerViewConstraint.constant = -width
    containerView.setNeedsUpdateConstraints()
    UIView.animateWithDuration(0.3, animations: { () -> Void in
      self.containerView.layoutIfNeeded()
      },
      completion: { (completed) -> Void in
        self.removeViewController(self.mainNavVC)
        self.mainNavVC.popToRootViewControllerAnimated(false)
        
        NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_SHOWED_NOTIFICATIONS, object: nil)
    })
  }
  
  func showMain() {
    showMain {
      
    }
  }
  
  func showMain(completion: () -> ()) {
    if (mainNavVC.parentViewController == nil) {
      addViewController(mainNavVC, view: mainView)
    }
    
    containerViewConstraint.constant = 0
    containerView.setNeedsUpdateConstraints()
    UIView.animateWithDuration(0.3, animations: { () -> Void in
      self.containerView.layoutIfNeeded()
      },
      completion: { (completed) -> Void in
        self.removeViewController(self.leftNavVC)
        self.removeViewController(self.rightNavVC)
        completion()
    })
  }
  
  func showProfile() {
    if (rightNavVC.parentViewController == nil) {
      print("adding right")
      addViewController(rightNavVC, view: rightView)
    }
    
    self.rightNavVC.popToRootViewControllerAnimated(false)
    
    
    let width = mainView.bounds.size.width
    containerViewConstraint.constant = width
    containerView.setNeedsUpdateConstraints()
    UIView.animateWithDuration(0.3, animations: { () -> Void in
      self.containerView.layoutIfNeeded()
      },
      completion: { (completed) -> Void in
        self.removeViewController(self.mainNavVC)
        self.mainNavVC.popToRootViewControllerAnimated(false)
    })
  }
  
  @IBAction func panned(recognizer: UIPanGestureRecognizer) {
    let translation = recognizer.translationInView(self.view).x
    var finalTranslation = containerViewConstraint.constant
    let width = mainView.bounds.size.width
    
    if abs(finalTranslation - translation) >= width {
      return
    }
    
    switch recognizer.state {
    case .Ended:
      
      if finalTranslation > 0 {
        //right
        
        if (finalTranslation > width/2) {
          containerViewConstraint.constant = width
          UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
        } else {
          containerViewConstraint.constant = 0
          UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
        }
      } else if finalTranslation < 0 {
        //left
        
        if (abs(finalTranslation) > width/2) {
          containerViewConstraint.constant = -width
          UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
        } else {
          containerViewConstraint.constant = 0
          UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_SHOWED_NOTIFICATIONS, object: nil)
      }
      
      containerView.setNeedsUpdateConstraints()
      UIView.animateWithDuration(0.2, animations: { () -> Void in
        self.containerView.layoutIfNeeded()
        }, completion: { (completed) -> Void in
          finalTranslation = self.containerViewConstraint.constant
          if  finalTranslation == 0 {
            print("removing left and right")
            
            self.leftNavVC.popToRootViewControllerAnimated(false)
            self.rightNavVC.popToRootViewControllerAnimated(false)
            
            
            self.removeViewController(self.leftNavVC)
            self.removeViewController(self.rightNavVC)
          } else if abs(finalTranslation) >= width {
            print("removing main")
            self.removeViewController(self.mainNavVC)
          }
      })
      
      break
    case .Changed:
      
      if (mainNavVC.parentViewController == nil) {
        print("adding main")
        addViewController(mainNavVC, view: mainView)
      }
      
      if finalTranslation > 0 {
        //right
        
        if (rightNavVC.parentViewController == nil) {
          print("adding right")
          addViewController(rightNavVC, view: rightView)
        }
        
        if (leftNavVC.parentViewController != nil) {
          print("removing left")
          removeViewController(leftNavVC)
        }
      } else if finalTranslation < 0  {
        //left
        
        if (leftNavVC.parentViewController == nil) {
          print("adding left")
          addViewController(leftNavVC, view: leftView)
        }
        
        if (rightNavVC.parentViewController != nil) {
          print("removing right")
          removeViewController(rightNavVC)
        }
      }
      
      containerViewConstraint.constant -= translation
      recognizer.setTranslation(CGPointZero, inView: recognizer.view)
    default:
      break
    }
  }
  
  func landingVCDidTapNotifications(vc: LandingVC) {
    if (leftNavVC.parentViewController == nil) {
      print("adding left")
      addViewController(leftNavVC, view: leftView)
    }
    
    let width = mainView.bounds.size.width
    containerViewConstraint.constant = -width
    containerView.setNeedsUpdateConstraints()
    UIView.animateWithDuration(0.3, animations: { () -> Void in
      self.containerView.layoutIfNeeded()
      },
      completion: { (completed) -> Void in
        self.removeViewController(self.mainNavVC)
    })
  }
  
  func landingVCDidTapProfile(vc: LandingVC) {
    if (rightNavVC.parentViewController == nil) {
      print("adding right")
      addViewController(rightNavVC, view: rightView)
    }
    
    let width = mainView.bounds.size.width
    containerViewConstraint.constant = width
    containerView.setNeedsUpdateConstraints()
    UIView.animateWithDuration(0.3, animations: { () -> Void in
      self.containerView.layoutIfNeeded()
      },
      completion: { (completed) -> Void in
        self.removeViewController(self.mainNavVC)
    })
  }
  
  func navVCDidShow(navVC: DubyNavVC, shownVC: UIViewController) {
//    println("\(navVC.viewControllers)")
//    println("\(navVC.viewControllers.count == 0)")
    gesRecognizer.enabled = navVC.viewControllers.count == 1
  }
  
  func localUsersVCDidFinish() {
    delay(0.5) {
      self.showLandingTTIfNeeded()
    }
  }

}
