//
//  ProfileVC.swift
//  Duby
//
//  Created by Wilson on 1/14/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit
import MobileCoreServices
import MessageUI
 

class ProfileVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, DubyCollectionViewCellDelegate, ProfileHeaderProtocol, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, PMComposeVCDelegate, PBJViewControllerDelegate, MFMessageComposeViewControllerDelegate, FollowTTVCDelegate, ProfileTTVCDelegate, UIDocumentInteractionControllerDelegate {
  
  
  enum MediaState {
    case ProfilePic
    case PrivateMessage
  }
  
  private var headerView: ProfileHeaderView?
  var user: DubyUser?
  var dubies =  [Duby]()
  var loading = false
  
  private var showEdit = false
  private var mediaState : MediaState?
  private var refreshControl: UIRefreshControl!
  
  private var docController: UIDocumentInteractionController?
  
  override func viewDidLoad() {
    
    collectionView?.backgroundColor = UIColor.whiteColor()
    
    edgesForExtendedLayout = .None
    
    navigationController?.navigationBar.translucent = true
    navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
    navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
    navigationController?.navigationBar.shadowImage = UIImage()
    
    (navigationController as! DubyNavVC).barColor = .White
    view.addSubview(UINavigationBar.dubyWhiteBar())
    
    collectionView?.registerClass(ProfileHeaderView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "headerView") // not sure why footer works here and not header
    
    collectionView?.alwaysBounceVertical = true
    
    
    if user != nil { // if user is passed here, not 4th tab so no need to show all those buttons
      showEdit = false
      self.title = "@\(user!.username)"
      self.navigationItem.leftBarButtonItem = nil
    } else {
      user = DubyUser.currentUser
      
      delay(1.25) { () -> () in
        if PFUser.currentUser()?["flag_profile"] == nil  {
          ProfileTTVC.presentFromViewController(self, delegate: self)
          PFUser.currentUser()?["flag_profile"] = true
          PFUser.currentUser()?.saveInBackground()
        } else {
        }
      }
      
      //duby_fav_off
      let favButton = UIBarButtonItem(image: UIImage(named: "duby_fav_off"), style: UIBarButtonItemStyle.Plain, target: self, action: "favsButtonPressed:")
      let settingsButton = UIBarButtonItem(image: UIImage(named: "icon-settings"), style: UIBarButtonItemStyle.Plain, target: self, action: "settingsButtonPressed:")
      self.navigationItem.rightBarButtonItems = [settingsButton, favButton]// = UIBarButtonItem(image: UIImage(named: "icon-settings"), style: UIBarButtonItemStyle.Plain, target: self, action: "settingsButtonPressed:")
      self.title = "@\(user!.username)"
      
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "dubyCreated:", name: NOTIFICATION_NEW_DUBY, object: nil)
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "refresh", name: NOTIFICATION_PROFILE_UPDATED, object: nil)
      
      
      let item = UIBarButtonItem(image: UIImage(named: "home_icon_blue")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), style: .Plain, target: self, action: "showMain")
      navigationItem.leftBarButtonItem = item
    }
    
    refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
    collectionView?.addSubview(refreshControl)
    refreshControl.tintColor = UIColor.dubyGreen()
    
    self.refresh()
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: "ProfileUpdated", object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(self, name: "DubyDeleted", object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_NEW_DUBY, object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_PROFILE_UPDATED, object: nil)
    
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    DubyUser.updateCurrentUser()
    // tips
    if showEdit && !UserDefaults.hasSeenTips(.Profile) {
      UserDefaults.sawTips(.Profile)
      navigationController?.presentTips(.Profile)
    }
    
    if user == DubyUser.currentUser {
      let tracker = GAI.sharedInstance().defaultTracker
      tracker.set(kGAIScreenName, value: "Profile(Self)")
      tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject: AnyObject])
    } else {
      let tracker = GAI.sharedInstance().defaultTracker
      tracker.set(kGAIScreenName, value: "Profile(Other)")
      tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject: AnyObject])
    }
  }
  
  func getBioHeight() -> CGFloat {
    let height = Constants.getHeightForText(user!.biography, width: CGRectGetWidth(UIScreen.mainScreen().bounds) - 30, font: UIFont.systemFontOfSize(14)) // 15px padding on each side
    return height;
  }
  
  /// Total header height that contains user data
  func getHeaderHeight() -> CGFloat {
    return getBioHeight() + 190
  }
  
  func showMain() {
    NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_SHOW_MAIN, object: nil)
  }
  
  // notifications update
  func updateBadgeCount() {
  }
  
  // duby was created add to list
  func dubyCreated(notification: NSNotification) {
    self.refresh()
    
    
    let user = PFUser.currentUser()!
    let key = "flag_new_duby"
    if user[key] == nil {
      user[key] = true
      user.saveEventually(nil)
      NewDubyTTVC.presentFromViewController(self)
    }
    
  }
  
  // dont show current users profile pic
  override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
    //        println(identifier)
    //        if let iden = identifier {
    //            if iden == "edit" {
    //                if dataModel.user == DubyUser.currentUser {
    //                    return false
    //                }
    //            }
    //        }
    //
    return true
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "profilePicFullScreenSegue" {
      let vc = segue.destinationViewController as! FullScreenImageVC
      if user?.profilePic != nil {
        vc.image = user?.profilePic
      }
    }
    
  }
  
  @IBAction func notificationButtonPressed(sender: AnyObject) {
    performSegueWithIdentifier("NotificationsSegue", sender: self)
  }
  
  // profile updated. reload collection view
  func profileUpdated() {
    collectionView?.reloadData()
  }
  
  @IBAction func settingsButtonPressed(sender: AnyObject) {
    performSegueWithIdentifier(SEGUE_SETTINGS, sender: self)
  }
  
  @IBAction func favsButtonPressed(sender: AnyObject?) {
    performSegueWithIdentifier("favsSegue", sender: self)
  }
  
  @IBAction func blockUser() {
    
  }
  
  func getUserDubys(clear: Bool, completion: (Bool) -> (Void)) {
    if loading {
      return;
    }
    loading = true
    
    if (clear) {
      dubies = [Duby]()
    }
    
    DubyDatabase.getDubysForUser(user!.objectId, limit: 30, skip: dubies.count) { (dubies, count, error) -> Void in
      self.loading = false
      if error != nil || dubies == nil {
        completion(false)
      } else {
        self.dubies = self.dubies + dubies!
        
        if self.dubies.count != 0 {
          self.collectionView?.reloadData()
          self.collectionView?.backgroundView = nil
        } else {
          if (self.user != DubyUser.currentUser) {
            return;
          }
          
          let bounds = self.collectionView!.bounds
          let button = UIButton(frame: CGRect(x: 0, y: 0, width: bounds.size.width * 0.8, height: bounds.size.height))
          button.setImage(UIImage(named: "no_content"), forState: .Normal)
          button.imageView!.contentMode = .ScaleAspectFit
          button.addTarget(self, action: "createDuby", forControlEvents: .TouchUpInside)
          
          
//          let imageView = UIImageView(image: UIImage(named: "no-content"))
//          imageView.frame = self.collectionView!.bounds
//          imageView.contentMode = .ScaleAspectFit
          self.collectionView?.backgroundView = button
        }
        
        completion(self.dubies.count != 0)
      }
    }
  }
  
  func createDuby() {
    NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_SHOW_CREATE, object: nil)
  }
  
  func refresh() {
    DubyDatabase.getUserInfo(user!.objectId, completion: { (user, error) -> (Void) in
      if error != nil {
        UIAlertView(title: "Error", message: "Error refreshing data.", delegate: nil, cancelButtonTitle: "Ok").show()
        self.refreshControl.endRefreshing()
      } else {
        self.user = user
        self.collectionView?.reloadData()
        
        self.getUserDubys(true) { (_) -> (Void) in
          self.refreshControl.endRefreshing()
        }
        
        self.headerView?.setInitialData(self.user!)
      }
    })
  }
  
  func dubyDeleted(notification: NSNotification) {
//    let dubyId = notification.userInfo!["objectId"] as! String
//    
//    if dataModel.dubyDeleted(dubyId) {
//      collectionView?.reloadData()
//      //            headerView?.updateWithDubyData(self.dataModel.getHeaderData())
//    }
  }
  
  //MARK: collection view
  
  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return dubies.count
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    return ProfileCollectionModel.cellSize()
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSize(width: CGRectGetWidth(UIScreen.mainScreen().bounds), height: getHeaderHeight())
  }
  
  override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    
    let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "headerView", forIndexPath: indexPath) as! ProfileHeaderView
    headerView.delegate = self
    self.headerView = headerView
    
    headerView.showEdit = showEdit
    headerView.setInitialData(user!)
    
    var headerFrame = headerView.frame
    headerFrame.size.height = getHeaderHeight()
    headerView.frame = headerFrame
    
    
    return headerView
  }
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("dubyCollectionCell", forIndexPath: indexPath) as! DubyCollectionViewCell

    cell.setData(dubies[indexPath.row])
    cell.layer.shouldRasterize = true
    cell.layer.rasterizationScale = UIScreen.mainScreen().scale
    
    cell.index = indexPath.item
    cell.delegate = self
    
    return cell
  }
  
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    navigationController?.pushToDetailsVC(duby: dubies[indexPath.row])
  }
  
  override func scrollViewDidScroll(scrollView: UIScrollView) {
    let offset = scrollView.contentOffset.y + getHeaderHeight()
    let contentHeight = scrollView.contentSize.height
    let collectionHeight = scrollView.frame.height
    
    if offset > (contentHeight - collectionHeight - 100) {
      self.getUserDubys(false) { (_) -> (Void) in
        self.refreshControl.endRefreshing()
      }
    }
  }
  
  //MARK: cell delegate

  // MARK: ProfileHeaderProtocol
  func performSegue(segueIdentifier: String) {
    performSegueWithIdentifier(segueIdentifier, sender: nil)
  }
  
  func showCoachMarks() {
    navigationController?.presentTips(.Stats)
  }
  
  @IBAction func followPressed() {
    performSegue("FollowingSegue")
  }
  
  @IBAction func showFollowers() {
    let followersVC = FollowersVC2()
    followersVC.user = self.user != nil ? self.user : DubyUser.currentUser
    navigationController?.pushViewController(followersVC, animated: true)
  }
  
  @IBAction func more() {
    
    MBProgressHUD.showHUDAddedTo(view, animated: true)
    
    PFCloud.callFunctionInBackground("isBlocked", withParameters: ["userId" : user!.objectId]) { (response, error) -> Void in
      MBProgressHUD.hideHUDForView(self.view, animated: true)
      if let blocked = response as? Bool where blocked == false {
        print("unblocked")
        
        let alertController = UIAlertController(title: "Block", message: "Block this user?", preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Nevermind", style: .Cancel) {(_) -> Void in }
        let okAction = UIAlertAction(title: "Yes", style: .Default, handler: { (action) -> Void in
          PFCloud.callFunctionInBackground("block", withParameters: ["userId": self.user!.objectId], block: { (resp, error) -> Void in print(error);print(resp); })
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        self.presentViewController(alertController, animated: true, completion:nil)
      } else {
        print("blocked")
        
        
        let alertController = UIAlertController(title: "Unblock", message: "Unblock this user?", preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Nevermind", style: .Cancel) {(_) -> Void in }
        let okAction = UIAlertAction(title: "Yes", style: .Default, handler: { (action) -> Void in
          PFCloud.callFunctionInBackground("unblock", withParameters: ["userId": self.user!.objectId], block: { (_, _) -> Void in })
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        self.presentViewController(alertController, animated: true, completion:nil)
      }
    }
    
  }
  
  func showInfo() {
    let vc = InfluenceTTVC(user: user!)
    

    
    let fvc = MZFormSheetPresentationViewController(contentViewController: vc)
    fvc.presentationController?.shouldDismissOnBackgroundViewTap = true
    fvc.presentationController?.blurEffectStyle = UIBlurEffectStyle.Light
//    fvc.presentationController?.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.StyleDropDown
    fvc.presentationController?.contentViewSize = CGSizeMake(280, 350)
    
    presentViewController(fvc, animated: true, completion: nil)
  }
  
  func sendPM() {
    presentMediaOptions(.PrivateMessage)
  }
  
  func updatePic() {
    if (user! == DubyUser.currentUser) {
      performSegueWithIdentifier("EditProfileSegue", sender: self)
//      navigationController?.pushViewController(EditUserVC(), animated: true)
    } else {
      if (user!.profilePic != nil) {
        performSegueWithIdentifier("profilePicFullScreenSegue", sender: self)
      }
    }
  }
  
  func inviteFriends() {
    
    UIGraphicsBeginImageContextWithOptions(CGSize(width: navigationController!.view.bounds.size.width, height: navigationController!.view.bounds.size.width), true, 0.0);
//    UIGraphicsBeginImageContext(CGSize(width: navigationController!.view.bounds.size.width, height: navigationController!.view.bounds.size.width));
    self.navigationController!.view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
    let screenShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    let alertController = UIAlertController(title: "+ Share", message: nil, preferredStyle: .ActionSheet)
    let cancelAction = UIAlertAction(title: "Nevermind", style: .Cancel) {(_) -> Void in }
    let inviteAction = UIAlertAction(title: "Invite Friends", style: .Default, handler: { (action) -> Void in
      let messageComposeVC = MFMessageComposeViewController()
      messageComposeVC.messageComposeDelegate = self
      messageComposeVC.body = "Join my sesh on Duby! Username: \(DubyUser.currentUser.username)   http://apple.co/1FJHlLE"
      
      messageComposeVC.navigationBar.titleTextAttributes = nil
      messageComposeVC.navigationBar.tintColor = UIColor.blackColor()
      
      
      MBProgressHUD.showHUDAddedTo(self.view, animated: true)
      self.presentViewController(messageComposeVC, animated: true) { () -> Void in
        MBProgressHUD.hideHUDForView(self.view, animated: true)
      }
    })
    
    alertController.addAction(cancelAction)
    alertController.addAction(inviteAction)
    
    let instagramUrl = NSURL(string: "instagram://app")
    if(UIApplication.sharedApplication().canOpenURL(instagramUrl!)){
  
      
      let instagramAction = UIAlertAction(title: "Share Profile to Instagram", style: .Default, handler: { (action) -> Void in
        
        let imageData = UIImageJPEGRepresentation(screenShot, 100)
        let captionString = "Checkout my profile on Duby: \(DubyUser.currentUser.username)   http://apple.co/1FJHlLE"
        let writePath = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("instagram.igo")
        
        if(!imageData!.writeToFile(writePath, atomically: true)){
          //Fail to write. Don't post it
          return
        } else{
          //Safe to post
          
          let fileURL = NSURL(fileURLWithPath: writePath)
          self.docController = UIDocumentInteractionController(URL: fileURL)
          self.docController!.delegate = self
          self.docController!.UTI = "com.instagram.exclusivegram"
          self.docController!.annotation =  NSDictionary(object: captionString, forKey: "InstagramCaption")
          self.docController!.presentOpenInMenuFromRect(CGRectZero, inView: self.view, animated: true)
        }
        
      })
      alertController.addAction(instagramAction)
      
    }
    
    
    self.presentViewController(alertController, animated: true, completion:nil)
    
  }
  
  func didFollow() {
    if PFUser.currentUser()?["flag_follow"] == nil  {
      FollowTTVC.presentFromViewController(self, delegate: self)
      PFUser.currentUser()?["flag_follow"] = true
      PFUser.currentUser()?.saveInBackground()
    } else {
    }
  }
  
  func presentMediaOptions(state: MediaState) {
    self.mediaState = state
    
    let actionSheet = UIActionSheet(title: "Select a Mode", delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
    actionSheet.addButtonWithTitle("Cancel")
    actionSheet.addButtonWithTitle("Camera")
    actionSheet.addButtonWithTitle("Photo Library")
    actionSheet.cancelButtonIndex = 0
    actionSheet.showInView(UIApplication.sharedApplication().keyWindow!)
    
  }
  
  func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
    if buttonIndex == actionSheet.cancelButtonIndex {
      return
    }
    
    if buttonIndex == 1 {
      openCamera()
    } else if buttonIndex == 2 {
      openLibrary()
    } else if buttonIndex == 3 {
      let cameraVC = PBJViewController();
      cameraVC.delegate = self;
      presentViewController(cameraVC, animated: true, completion: nil)
    }
  }
  
  func openCamera() {
    let picker = UIImagePickerController()
    picker.sourceType = .Camera;
    picker.mediaTypes = [kUTTypeImage as String]
    picker.allowsEditing = (mediaState == .ProfilePic)
    picker.delegate = self
    picker.navigationBar.titleTextAttributes = nil
    picker.navigationBar.tintColor = nil
    
    presentViewController(picker, animated: true, completion: nil)
  }
  
  func openLibrary() {
    let picker = UIImagePickerController()
    
    picker.sourceType = .PhotoLibrary;
    picker.mediaTypes = [kUTTypeImage as String]
    picker.allowsEditing = (mediaState == .ProfilePic)
    picker.delegate = self
    picker.navigationBar.titleTextAttributes = nil
    picker.navigationBar.tintColor = nil
    
    presentViewController(picker, animated: true, completion: nil)
  }
  
  //    func pictureDeleted() {
  //        dataModel.picUpdated(nil)
  //    }
  
  //MARK: picker delegate
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
    if (mediaState == .ProfilePic) {
      picker.dismissViewControllerAnimated(true, completion: nil)
      let editModel = EditModel()
      editModel.picUpdated(image)
      editModel.updateUser { (done) -> Void in
        self.user = DubyUser.currentUser
      }
    } else if (mediaState == .PrivateMessage) {
      picker.dismissViewControllerAnimated(true, completion: { () -> Void in
        let image = UIImage.resizedImageToFillWithBounds(image, bounds: CGSizeMake(750, 1134))
        let composer = PMComposerVC(image: image, toUser: self.user!, delegate: self)
        self.presentViewController(composer, animated: true, completion: nil)
      })
    }
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func showHashtagVC(hashtag: String) {
    let hashtagVC = HashtagsVC(collectionViewLayout: UICollectionViewFlowLayout())
    hashtagVC.hashtag = hashtag
    navigationController?.pushViewController(hashtagVC, animated: true)
  }
  
  func showProfileVC(username: String) {
    DubyDatabase.getUser(username, completion: { (user, error) -> (Void) in
      if let dubyUser = user {
        self.navigationController?.pushToProfileVC(user: dubyUser)
      }
    })
  }
  
  func collectionViewCellDidTapPassers(duby: Duby) {
    navigationController?.pushToDubyPassersVC(duby: duby)
  }
  
  func composeVCDidFinish(composeVC: PMComposerVC) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func privateMessage() {
    PFCloud.callFunctionInBackground("amFollowed", withParameters: ["followerId": user!.objectId]) { (obj, error) -> Void in
      if let followed = obj as? Int {
        if followed == 0 {
          SVProgressHUD.showErrorWithStatus("You can't message @\(self.user!.username) because they do not follow you.")
        } else {
          
          let u = PFUser()
          u.objectId = self.user!.objectId;
          
          u.fetchInBackgroundWithBlock({ (us, e) -> Void in
            if let disabled = u["pmDisabled"] as? Bool where disabled == true {
              SVProgressHUD.showErrorWithStatus("You can't message @\(self.user!.username) because they have disabled private messaging.")
            } else {
              self.sendPM()
            }
          })
          
        }
      }
    }
  }
  
  
  func pbjViewControllerDidCancel() {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func pbjViewControllerDidCompleteWithInfo(info: [NSObject : AnyObject]!) {
    
    self.dismissViewControllerAnimated(true, completion: { () -> Void in
      let videoPath = info["videoPath"] as! NSString;
      _ = info["photo"] as! UIImage
      
      let videoURL = NSURL(fileURLWithPath: videoPath as String)
      
      let composer = PMComposerVC(videoURL: videoURL, toUser: self.user!, delegate: self)
      self.presentViewController(composer, animated: true, completion: nil)
    })
    
    
    //        var vidFile = PFFile(name: "vid.m4v", contentsAtPath: videoPath as String)
    //        var photoFile = PFFile(name: "duby_image.jpg", data: UIImageJPEGRepresentation(photo, 0.1))
    //
    //        imageCell.setDubyData(photo, videoURL: nil)
    //
    //        MBProgressHUD.showHUDAddedTo(view, animated: true)
    //
    //        PFObject.saveAllInBackground([vidFile, photoFile], block: { (saved, error) -> Void in
    //            println(error);
    //            MBProgressHUD.hideHUDForView(self.view, animated: true)
    //            if (error != nil || saved == false) {
    //                self.imageCell.setDubyData(nil, videoURL: nil)
    //            } else {
    //                self.dataModel.dubyImage = ["name": photoFile.name, "__type": "File", "url": photoFile.url!]
    //                self.dataModel.dubyVideo = ["name": vidFile.name, "__type": "File", "url": vidFile.url!]
    //                self.imageCell.setDubyData(photo, videoURL: vidFile.url!)
    //            }
    //
    //            self.updateLightUpButtonStatus()
    //        })
  }
  
  func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
    dismissViewControllerAnimated(true, completion: nil)
  }

  func followTTVCDidOkay() {
    dismissViewControllerAnimated(true, completion: nil)
  }

  
  func profileTTVCDidCancel() {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func profileTTVCDidEdit() {
    dismissViewControllerAnimated(true) { () -> Void in
      self.performSegueWithIdentifier("EditProfileSegue", sender: self)
    }
  }
}
