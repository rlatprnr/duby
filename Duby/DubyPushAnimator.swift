//
//  DubyPushAnimator.swift
//  Duby
//
//  Created by Harsh Damania on 10/12/14.
//  Copyright (c) 2014 Dezapp. All rights reserved.
//

import UIKit

/// Custom animation transition so that we can keep the same background and also so that transitions from clear nav to white are smooth
class DubyPushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var pushing: Bool?
    var whiteToClear: Bool?
    var clearToWhite: Bool?
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.33;
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        var toView = toVC?.view
        
        let containerView = transitionContext.containerView()
        
        let initialFrame = transitionContext.initialFrameForViewController(fromVC!)
        
        var rightOffscreenFrame = initialFrame
        rightOffscreenFrame.origin.x += CGRectGetWidth(initialFrame)
        
        var leftOffscreenFrame = initialFrame
        leftOffscreenFrame.origin.x -= CGRectGetWidth(initialFrame)
        
        // This is how we the blurred/sharp image for initial and login/sign up VCs
//        if fromVC is InitialVC {
//            NSNotificationCenter.defaultCenter().postNotificationName("blurImage", object: nil)
//        } else if toVC is InitialVC {
//            NSNotificationCenter.defaultCenter().postNotificationName("sharpImage", object: nil)
//        }
//        
        if pushing! {
            containerView!.addSubview(toVC!.view)
            toVC?.view.frame = rightOffscreenFrame

            // Simple animation transition views
            UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: { () -> Void in
                toVC?.view.frame = initialFrame
                fromVC?.view.frame = leftOffscreenFrame
                
                self.animateNavBar(toVC!.navigationController!, transitionContext: transitionContext, animated: true)
                if self.whiteToClear! {
                    self.clearNavBar(toVC!.navigationController!, transitionContext: transitionContext, animated: true)
                } else if self.clearToWhite! {
                    self.whitenNavBar(toVC!.navigationController!, transitionContext: transitionContext, animated: true)
                }
                
                
                return
            }, completion: { (_) -> Void in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
            })
        } else {
            containerView!.addSubview(toVC!.view)
            containerView!.sendSubviewToBack(toVC!.view)
            
            toVC?.view.frame = leftOffscreenFrame
            
            // Simple animation transitioning views
            UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: { () -> Void in
                fromVC?.view.frame = rightOffscreenFrame
                toVC?.view.frame = initialFrame
                
                self.animateNavBar(toVC!.navigationController!, transitionContext: transitionContext, animated: true)
                if self.whiteToClear! {
                    self.clearNavBar(toVC!.navigationController!, transitionContext: transitionContext, animated: true)
                } else if self.clearToWhite! {
                    self.whitenNavBar(toVC!.navigationController!, transitionContext: transitionContext, animated: true)
                }
                
                return
            }, completion: { (_) -> Void in
                
                if transitionContext.transitionWasCancelled() {
                    
                    self.animateNavBar(toVC!.navigationController!, transitionContext: transitionContext, animated: false)
                    if self.whiteToClear! {
                        self.whitenNavBar(toVC!.navigationController!, transitionContext: transitionContext, animated: false)
                    } else if self.clearToWhite! {
                        self.clearNavBar(toVC!.navigationController!, transitionContext: transitionContext, animated: false)
                    }
                    
//                    if toVC is InitialVC {
//                        NSNotificationCenter.defaultCenter().postNotificationName("blurImage", object: nil)
//                    }
                }
                
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                return
            })
        }
    }
    
    func animateNavBar(navigationController: UINavigationController, transitionContext: UIViewControllerContextTransitioning, animated: Bool) {
        let transition = CATransition()
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = pushing! ? kCATransitionFromRight : kCATransitionFromLeft
        transition.duration = self.transitionDuration(transitionContext)
        
        if animated {
            navigationController.navigationBar.layer.addAnimation(transition, forKey: nil)
        }
    }
    
    /// Set title attributes for white nav bar
    func whitenNavBar(navigationController: UINavigationController, transitionContext: UIViewControllerContextTransitioning, animated: Bool) {
        navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor(), NSFontAttributeName: UIFont.openSans(17.0)]
        navigationController.navigationBar.tintColor = UIColor.blackColor()
    }
    
    // set title attributes for clear nav bar
    func clearNavBar(navigationController: UINavigationController, transitionContext: UIViewControllerContextTransitioning, animated: Bool) {
        navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.openSans(17.0)]
        navigationController.navigationBar.tintColor = UIColor.whiteColor()
    }
    
}
