//
//  DubySwipeViewController.swift
//  Duby
//
//  Created by Harsh Damania on 3/22/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

/// Data source for Tinder like animation cards
protocol DubySwipeViewDataSource {
  /// Total number of views to be presented
  func numberOfDubyViews() -> Int
  
  /// Get View for index
  func viewForIndex(index: Int) -> DubyView
}

/// Delegate for Tinder like animation cards
protocol DubySwipeViewDelegate {
  /// User swiped on duby
  ///
  /// - parameter index: index of share
  /// - parameter shared: Whether user decided to share it or not
  ///
  func viewSwipedAtIndex(index: Int, shared: Bool)
  
  ///User tapped on Duby
  ///
  /// - parameter index: index of share
  ///
  func didSelectViewAtIndex(index: Int)
}

/// View controller for Tinder like animation cards
class DubySwipeViewController: UIViewController, DubyViewDelegate {
  
  private var numberOfViews: Int!
  var currentViews: [DubyView]! // max 3
  private var currentIndex: Int!
  
  var dataSource: DubySwipeViewDataSource?
  var delegate: DubySwipeViewDelegate?
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    customInit()
  }
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    
    customInit()
  }
  
  func customInit() {
    if currentViews != nil {
      for view in currentViews {
        view.removeFromSuperview()
      }
    }
    
    numberOfViews = 0
    currentViews = [DubyView]()
    currentIndex = 0
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.clearColor()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    numberOfViews = self.dataSource?.numberOfDubyViews()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  /// Resets to 0, and calls data source to see if there is anymore data
  func resetData() {
    customInit()
    numberOfViews = self.dataSource?.numberOfDubyViews()
    
    setUpView()
  }
  
  /// Calls data source to update the number of views
  func reloadData() {
    numberOfViews = self.dataSource?.numberOfDubyViews()
  }
  
  /// Initial setup to add all views
  private func setUpView() {
    if currentIndex < numberOfViews {
      let topView = self.dataSource?.viewForIndex(currentIndex)
      topView?.tag = 1
      topView?.delegate = self
      view.addSubview(topView!)
      currentViews.append(topView!)
      
      if currentIndex + 1 < numberOfViews {
        let secondView = self.dataSource?.viewForIndex(currentIndex+1)
        secondView?.tag = 2
        secondView?.delegate = self
        view.addSubview(secondView!)
        view.sendSubviewToBack(secondView!)
        currentViews.append(secondView!)
        
        if currentIndex + 2 < numberOfViews {
          let thirdView = self.dataSource?.viewForIndex(currentIndex+2)
          thirdView?.tag = 3
          thirdView?.delegate = self
          view.addSubview(thirdView!)
          view.sendSubviewToBack(thirdView!)
          currentViews.append(thirdView!)
        }
      }
      
      animateViews()
    }
  }
  
  /// Update view frames. Generally want to call this in an animation block
  private func updateDubyViews() {
    let topViewPadding: CGFloat = 0
    let topViewTopPadding: CGFloat = 10 // only needed if 3.5"
    
    
    
    let middleViewPadding: CGFloat = 5
    let bottomViewPadding: CGFloat = 2
    
    let backViewsAspectRatio: CGFloat = 0.75
    
    
    if currentViews.count > 0 {
      let dubyView = currentViews[0]
      
      let width = CGRectGetWidth(view.bounds) - 2*topViewPadding
      var height: CGFloat
      
      if CGRectGetHeight(UIScreen.mainScreen().bounds) <= 641  {
        print("4S")
        height = CGRectGetHeight(view.bounds) - 2*topViewTopPadding
      } else {
        height = width
      }
      
      dubyView.frame = CGRect(x: 0, y: 0, width: width, height: height)
      dubyView.center = view.convertPoint(view.center, fromView: view.superview)
      
      dubyView.isTop = true
      dubyView.userInteractionEnabled = true
      dubyView.alpha = 1
      dubyView.tag = 1
      
      dubyView.layoutIfNeeded()
      
      if currentViews.count > 1 {
        let secondView = currentViews[1]
        
        let x = middleViewPadding
        
        let width = CGRectGetWidth(dubyView.bounds) * backViewsAspectRatio
        let height = CGRectGetHeight(dubyView.bounds) * backViewsAspectRatio
        
        secondView.frame = CGRect(x: x, y: 0, width: width, height: height)
        secondView.center = CGPoint(x: secondView.center.x, y: CGRectGetHeight(view.bounds)/2)
        
        secondView.userInteractionEnabled = false
        secondView.alpha = 0.7
        secondView.locationLabel.alpha = 0
        secondView.commentCountButton.alpha = 0
        secondView.descriptionLabel.alpha = 0
        
        secondView.layoutIfNeeded()
        
        if currentViews.count > 2 {
          let thirdView = currentViews[2]
          
          let thirdX = bottomViewPadding
          let width = CGRectGetWidth(secondView.bounds) * backViewsAspectRatio
          let height = CGRectGetHeight(secondView.bounds) * backViewsAspectRatio
          
          thirdView.frame = CGRect(x: thirdX, y: 0, width: width, height: height)
          thirdView.center = CGPoint(x: thirdView.center.x, y: CGRectGetHeight(view.bounds)/2)
          
          thirdView.userInteractionEnabled = false
          thirdView.alpha = 0.5
          thirdView.locationLabel.alpha = 0
          thirdView.descriptionLabel.alpha = 0
          thirdView.commentCountButton.alpha = 0
          thirdView.willBeVisible = true
          
          thirdView.layoutIfNeeded()
        }
      }
    }
  }
  
  /// User swiped on a view, go to next one
  private func animateViews() {
    UIView.animateWithDuration(0.33, animations: { () -> Void in
      self.updateDubyViews()
      }) { (_) -> Void in
        if self.currentViews.count > 0 {
          self.currentViews[0].animateNeededSubviews()
        }
    }
  }
  
  //MARK: duby view delegate
  
  func userSwiped(shared shared: Bool) {
    if shared {
      currentViews[0].dubyAccepted()
    } else {
      currentViews[0].dubyDenied()
    }
    
  }
  
  /// Delegate for DubyView. user swiped on duby
  internal func dubyActionCompleted(accepted accepted: Bool) {
    currentViews.removeAtIndex(0)
    
    print("number of views \(numberOfViews) current \(currentIndex)")
    if currentIndex+3 < numberOfViews {
      let newView = self.dataSource?.viewForIndex(currentIndex + 3)
      newView?.delegate = self
      newView?.tag = 3
      
      view.addSubview(newView!)
      view.sendSubviewToBack(newView!)
      currentViews.append(newView!)
    }
    
    if currentViews.count > 0 {
      animateViews()
    }
    
    print("share \(accepted)")
    delegate?.viewSwipedAtIndex(currentIndex, shared: accepted)
    
    currentIndex = currentIndex + 1
  }
  
  // User tapped on duby
  internal func dubyTapped() {
    delegate?.didSelectViewAtIndex(currentIndex)
  }
  
}
