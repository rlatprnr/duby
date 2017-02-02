//
//  DubyNavVC.swift
//  Duby
//
//  Created by Harsh Damania on 1/30/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

enum NavigationBarColor: Int {
  case Clear, White, NewBlue
}

protocol DubyNavVCDelegate: class {
  func navVCDidShow(navVC: DubyNavVC, shownVC: UIViewController)
}


/// Custom navigation controller for transitions and nav bar attributes
class DubyNavVC: UINavigationController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
  
  var barColor: NavigationBarColor = .Clear {
    didSet {
      if barColor == .Clear {
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.openSans(17.0)]
        navigationBar.tintColor = UIColor.whiteColor()
      } else if barColor == .White {
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor(), NSFontAttributeName: UIFont.openSans(17.0)]
        navigationBar.tintColor = UIColor.blackColor()
      } else {
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.newDubyBlue(), NSFontAttributeName: UIFont.openSans(17.0)]
        navigationBar.tintColor = UIColor.newDubyBlue()
      }
      
    }
  }
  
  private var interactiveTransition: UIPercentDrivenInteractiveTransition!
  private var panGesture: UIPanGestureRecognizer!
  private var startedPopping = false
  var whiteToTransparent: Bool = false
  
  weak var navDelegate: DubyNavVCDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    
    delegate = self
    
    // disable interactive pop for iOS 7 because it causes too many glitches
    if UIDevice.currentDevice().systemVersion.compare("8.0", options: .NumericSearch) == .OrderedAscending {
      interactivePopGestureRecognizer!.enabled = false
    } else {
      interactivePopGestureRecognizer!.delegate = self
      panGesture = UIPanGestureRecognizer(target: self, action: "handlePan:")
      panGesture.delegate = self
      view.addGestureRecognizer(panGesture)
    }
    
    let image = UIImage(named:"bg")
    let backgroundView = UIImageView(image: image)
    backgroundView.contentMode = UIViewContentMode.ScaleAspectFill
    backgroundView.translatesAutoresizingMaskIntoConstraints = false
    view.insertSubview(backgroundView, atIndex: 0)
    
    view.addConstraint(NSLayoutConstraint(item: backgroundView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0))
    view.addConstraint(NSLayoutConstraint(item: backgroundView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0))
  }
  
  //MARK: navigation bar delegate
  
  // Custom transitioning
  func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
    let animator = DubyPushAnimator()
    animator.pushing = operation == .Push
    let transitions: (whiteToClear: Bool, clearToWhite: Bool) = NavigationBarColors.transitions(fromVC, secondVC: toVC)
    animator.whiteToClear = transitions.whiteToClear
    animator.clearToWhite = transitions.clearToWhite
    
    return animator
  }
  
  func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return interactiveTransition
  }
  
  //MARK: gestures
  
  // Handle custom swipe back
  func handlePan(gesture: UIPanGestureRecognizer) {
    let pannedPercent = gesture.translationInView(gesture.view!).x / CGRectGetWidth(gesture.view!.frame)
    
    switch gesture.state {
    case .Began:
      let startPoint = gesture.locationInView(gesture.view)
      if startPoint.x < CGRectGetWidth(gesture.view!.frame) / 3 {
        interactiveTransition = UIPercentDrivenInteractiveTransition()
        popViewControllerAnimated(true)
        startedPopping = true
      } else {
        startedPopping = false
      }
    case .Changed:
      if startedPopping {
        interactiveTransition.updateInteractiveTransition(pannedPercent)
      }
    case .Ended:
      fallthrough
    case .Cancelled:
      if startedPopping {
        if pannedPercent > 0.5 {
          interactiveTransition.finishInteractiveTransition()
        } else {
          interactiveTransition.cancelInteractiveTransition()
        }
        
        interactiveTransition = nil
      }
    default:
      break
    }
  }
  
  func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
    if viewControllers.count < 2 {
      return false
    }
    
    if transitionCoordinator() != nil {
      if transitionCoordinator()!.isAnimated() {
        return false
      }
    }
    
    if gestureRecognizer == panGesture {
      return true
    }
    
    if gestureRecognizer == interactivePopGestureRecognizer {
      return true
    }
    
    return false
  }
  
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true;
  }
  
  func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
    navDelegate?.navVCDidShow(self, shownVC: viewController)
  }
}
