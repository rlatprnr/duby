//
//  DubyDetailsCollectionVC.swift
//  Duby
//
//  Created by Harsh Damania on 2/7/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit


class DubyDetailsCollectionVC: UICollectionViewController, DubyCollectionViewCellDelegate, UICollectionViewDelegateFlowLayout, UIActionSheetDelegate {
  let reuseIdentifier = "Cell"
  
  var userSignedUp = false
  var dataModel = DubyDetailsModel()
  var duby: Duby! {
    didSet {
      //            if duby.createdBy == DubyUser.currentUser {
      //                deleteButton.hidden = false
      //            } else {
      //                deleteButton.hidden = true
      //            }
    }
  }
  
  var headerView: DubyDetailsHeaderView?
  @IBOutlet weak var deleteButton: UIButton!
  
  private var refreshControl: UIRefreshControl!
  private var thisDubyDeleted = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    (navigationController as! DubyNavVC).barColor = .White
    view.addSubview(UINavigationBar.dubyWhiteBar())
    
    edgesForExtendedLayout = .None
    
    collectionView?.backgroundColor = UIColor.whiteColor()
    collectionView?.registerClass(DubyDetailsHeaderView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "detailsHeaderView") // Not sure why Footer works and not header when we are setting the header
    
    collectionView?.backgroundColor = UIColor.whiteColor()
    
    collectionView?.alwaysBounceVertical = true
    
    refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
    collectionView?.addSubview(refreshControl)
    refreshControl.tintColor = UIColor.dubyGreen()
    
    dataModel.currentDuby = duby
    
    getDubysForUser { (_) -> (Void) in
      
    }
    
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "dubyDeletedElsewhere:", name: "DubyDeleted", object: nil)
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: "DubyDeleted", object: nil)
  }
  
  override func viewWillAppear(animated: Bool) {
    UIApplication.sharedApplication().statusBarStyle = .Default
  }
  
  override func viewDidAppear(animated: Bool) {
    // Google analytics
    let tracker = GAI.sharedInstance().defaultTracker
    tracker.set(kGAIScreenName, value: "DubyDetails")
    tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject: AnyObject])
    
    super.viewDidAppear(animated)
    
    if userSignedUp {
      headerView?.setUserShareData(Constants.getFakeUsers(), zoomLevel: 8)
    }
  }
  
  
  func getDubysForUser(completion: (Bool) -> (Void)) {
    if !userSignedUp {
      dataModel.getDubys(userId: self.duby.createdBy.objectId, completion: { (gotDubys) -> Void in
        if gotDubys {
          self.collectionView?.reloadData()
        }
        
        completion(gotDubys)
      })
      
      dataModel.getDubyShareData( {(gotData, zoomLevel) -> Void in
        if gotData {
          print("got data \(self.dataModel.usersSharedTo)");
          self.headerView?.setUserShareData(self.dataModel.usersSharedTo, zoomLevel: zoomLevel)
        }
      })
    }
    
  }
  
  func refresh() {
    
    dataModel.getDubyShareData( {(gotData, zoomLevel) -> Void in
      if gotData {
        self.headerView?.setUserShareData(self.dataModel.usersSharedTo, zoomLevel: zoomLevel)
      }
    })
    
    DubyDatabase.getDubyInfo(duby.objectId, completion: { (duby, error) -> Void in
      if error != nil {
        UIAlertView(title: "Error", message: "Error refreshing data.", delegate: nil, cancelButtonTitle: "Ok").show()
        self.refreshControl.endRefreshing()
      } else {
        self.duby = duby
        self.getDubysForUser { (_) -> (Void) in
          self.refreshControl.endRefreshing()
        }
      }
    })
    
  }
  
  @IBAction func deleteDubyPressed(sender: AnyObject) {
    let actionSheet = UIActionSheet(title: "Delete this Duby?", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil)
    actionSheet.addButtonWithTitle("Delete")
    actionSheet.showInView(view)
  }
  
  func dubyDeletedElsewhere(notification: NSNotification) {
    let dubyId = notification.userInfo!["objectId"] as! String
    
    if dubyId == duby.objectId { // check if current duby deleted and not if this vc deleted it
      if !thisDubyDeleted {
        collectionView?.hidden = true
        navigationItem.rightBarButtonItem?.customView?.hidden = true
        collectionView?.userInteractionEnabled = false
        
        let deletedLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        deletedLabel.text = "Duby Deleted"
        deletedLabel.font = UIFont.openSans(14)
        deletedLabel.textColor = UIColor.blackColor()
        deletedLabel.textAlignment = NSTextAlignment.Center
        
        let centerY = (CGRectGetHeight(UIScreen.mainScreen().bounds) - CGRectGetHeight(tabBarController!.tabBar.frame) - CGRectGetMaxY(navigationController!.navigationBar.frame)) / 2
        
        deletedLabel.center = CGPoint(x: CGRectGetWidth(UIScreen.mainScreen().bounds)/2, y: centerY)
        
        view.addSubview(deletedLabel)
        view.bringSubviewToFront(deletedLabel)
        view.backgroundColor = UIColor.whiteColor()
      }
    } else if duby.createdBy == DubyUser.currentUser { // my own duby deleted. updated model by deleting from list
      if dataModel.dubyDeleted(dubyId) {
        collectionView?.reloadData()
      }
    }
  }
  
  // MARK: UICollectionViewDataSource
  
  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return dataModel.numberOfDubys()
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    return ProfileCollectionModel.cellSize()
  }
  
  // set header
  override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    
    //        var headerView = self.headerView
    
    if headerView == nil {
      headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "detailsHeaderView", forIndexPath: indexPath) as? DubyDetailsHeaderView
      //            self.headerView = headerView
    }
    
    headerView?.sender = self
    headerView?.setMap()
    headerView?.setDubyData(duby)
    
    return headerView!
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSize(width: CGRectGetWidth(UIScreen.mainScreen().bounds), height: 390)
  }
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("dubyCollectionCell", forIndexPath: indexPath) as! DubyCollectionViewCell
    cell.setData(dataModel.dubyAtIndex(indexPath.item))
    cell.layer.shouldRasterize = true
    cell.layer.rasterizationScale = UIScreen.mainScreen().scale
    
    cell.index = indexPath.item
    cell.delegate = self
    return cell
  }
  
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let selectedDuby = dataModel.dubyAtIndex(indexPath.item)
    navigationController?.pushToDetailsVC(duby: selectedDuby)
  }
  
  override func scrollViewDidScroll(scrollView: UIScrollView) {
    let offset = scrollView.contentOffset.y + 350
    let contentHeight = scrollView.contentSize.height
    let collectionHeight = scrollView.frame.height
    
    // paginate
    if offset > (contentHeight - collectionHeight) {
      if dataModel.addAdditionalDubys() {
        collectionView?.reloadData()
      }
    }
  }
  
  
  //MARK: cell delegate
  
  func toDubyDetails(index index: Int) {
    let selectedDuby = dataModel.dubyAtIndex(index)
    
    if selectedDuby != duby {
      navigationController?.pushToDubyDetailsVC(duby: selectedDuby)
    }
  }
  
  func collectionViewCellDidTapPassers(duby: Duby) {
    navigationController?.pushToDubyPassersVC(duby: duby)
  }
  
  //MARK: action sheet
  
  func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
    if buttonIndex == 1 { // delete
      MBProgressHUD.showHUDAddedTo(view, animated: true)
      DubyDatabase.deleteDuby(duby.objectId, completion: { (deleted) -> (Void) in
        print("delet status \(deleted)")
        
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        
        if deleted {
          self.thisDubyDeleted = true
          NSNotificationCenter.defaultCenter().postNotificationName("DubyDeleted", object: nil, userInfo: ["objectId":self.duby.objectId])
          self.navigationController?.popViewControllerAnimated(true)
        }
        
      })
    }
  }
  
}
