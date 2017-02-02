//
//  FollowingVC.swift
//  Duby
//
//  Created by Anurag Kamasamudram on 3/18/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

class FollowingVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, DubyCollectionViewCellDelegate {
  let reuseIdentifier = "Cell"
  
  private var refreshControl: UIRefreshControl!
  var follows = [Follow]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Register cell classes
    self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    
    /* UI Setup */
    collectionView?.backgroundColor = UIColor.whiteColor()
    collectionView?.alwaysBounceVertical = true
    
    edgesForExtendedLayout = .None
    navigationController?.navigationBar.translucent = true
    navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
    navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
    navigationController?.navigationBar.shadowImage = UIImage()
    (navigationController as! DubyNavVC).barColor = .White
    view.addSubview(UINavigationBar.dubyWhiteBar())
    
    /* Refresh Control */
    refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
    collectionView?.addSubview(refreshControl)
    refreshControl.tintColor = UIColor.dubyGreen()
    
    DubyDatabase.getFollowingDubys { (objects, error) -> Void in
      if error != nil {
        NSLog("ERROR (gettingFollowingDubys: %@", error!)
      } else {
        self.follows = objects!
        self.reloadCollectionView()
      }
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
  }
  
  override func viewDidAppear(animated: Bool) {
    // analytics
    let tracker = GAI.sharedInstance().defaultTracker
    tracker.set(kGAIScreenName, value: "Favorites")
    tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject: AnyObject])
    
    super.viewDidAppear(animated)
  }
  
  func refresh() {
    DubyDatabase.getFollowingDubys { (objects, error) -> Void in
      if error != nil {
        NSLog("ERROR (gettingFollowingDubys: %@", error!)
      } else {
        self.refreshControl.endRefreshing()
        self.follows = objects!
        self.reloadCollectionView()
      }
    }
  }
  
  func reloadCollectionView() {
    view.viewWithTag(5)?.removeFromSuperview()
    
    collectionView?.reloadData()
    
    if follows.count == 0 {
      let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 320, height: 60))
      noDataLabel.text = "You don't have any favorites.\nGo favorite some Dubys!"
      noDataLabel.font = UIFont.openSans(14)
      noDataLabel.textColor = UIColor.blackColor()
      noDataLabel.textAlignment = NSTextAlignment.Center
      noDataLabel.tag = 5
      noDataLabel.numberOfLines = 2
      
      let centerY = (CGRectGetHeight(UIScreen.mainScreen().bounds) - CGRectGetMaxY(navigationController!.navigationBar.frame)) / 2
      
      noDataLabel.center = CGPoint(x: CGRectGetWidth(UIScreen.mainScreen().bounds)/2, y: centerY)
      
      view.addSubview(noDataLabel)
      view.bringSubviewToFront(noDataLabel)
    }
  }
  
  //MARK: collection view
  
  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return follows.count
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    return ProfileCollectionModel.cellSize()
  }
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("dubyCollectionCell", forIndexPath: indexPath) as! DubyCollectionViewCell
    
    //        if indexPath.item == 0 && dataModel.user! == DubyUser.currentUser {
    //            cell.setAddDubyProperties()
    //        } else {
    //cell.setData(dataModel.dubyAtIndex(indexPath.item))
    //        }
    cell.setData(follows[indexPath.row].duby)
    cell.index = indexPath.item
    cell.delegate = self
    
    return cell
  }
  
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
    //        if indexPath.item == 0 && dataModel.user! == DubyUser.currentUser {
    //            tabBarController?.selectedIndex = 2
    //        } else {
    navigationController?.pushToDetailsVC(duby: follows[indexPath.row].duby)
    //        }ii
  }
  
  override func scrollViewDidScroll(scrollView: UIScrollView) {
    //        let offset = scrollView.contentOffset.y + dataModel.getHeaderHeight()
    //        let contentHeight = scrollView.contentSize.height
    //        let collectionHeight = scrollView.frame.height
    //
    //        if offset > (contentHeight - collectionHeight - 100) {
    //            if dataModel.addAdditionalDubys() {
    //                collectionView?.reloadData()
    //            }
    //        }
  }
  
  
  func performSegue(segueIdentifier: String) {
    performSegueWithIdentifier(segueIdentifier, sender: nil)
  }
  
  func collectionViewCellDidTapPassers(duby: Duby) {
    navigationController?.pushToDubyPassersVC(duby: duby)
  }
  
}
