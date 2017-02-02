//
//  LandingVC.swift
//  Duby
//
//  Created by Duby on 1/5/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit
 

class LandingVC: UIViewController, UINavigationControllerDelegate, UIGestureRecognizerDelegate, DubySwipeViewDataSource, DubySwipeViewDelegate,UIDocumentInteractionControllerDelegate, CreateTTVCDelegate {
  
  @IBOutlet weak var interactionContainerView: UIView!
  @IBOutlet weak var infoContainerView: UIView!
  @IBOutlet weak var creatorAvatarImageView: UIImageView!
  @IBOutlet weak var creatorUsernameLabel: UILabel!
  @IBOutlet weak var creatorViewWidthConstraint: NSLayoutConstraint!
  @IBOutlet weak var interactionContainerViewConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var dubyDescriptionLabel: UILabel!
  @IBOutlet weak var timeRemainingLabel: UILabel!
  
  @IBOutlet weak var dubyRejectButton: UIButton!
  @IBOutlet weak var dubyAcceptButton: UIButton!
  
  @IBOutlet weak var notificationsButton: UIButton!
  
  @IBOutlet weak var dubyCommentCountButton: UIButton!
  @IBOutlet weak var dubyLocationButton: UIButton!
  @IBOutlet weak var dubyShareCountLabel: UILabel!
  
  @IBOutlet weak var dubyDescLabelHeightConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var noMoreLabel: UILabel!
  
  
  var exploreMoreButton: UIImageView!
  
  //@IBOutlet weak var dubyCountButton: UIButton!
  
  private var swipeVC: DubySwipeViewController!
  private var dataModel: LandingModel!
  
  private var currentDubyIndex = 0
  
  private var shouldAutoRefresh = false
  
  private var tapGesture: UITapGestureRecognizer!
  
  var currentDubyCount = 0
  
  var userSignedUp = false
  
  private var docController: UIDocumentInteractionController?
  
  override func viewDidLoad() {
    // set navigation bar properties
    navigationController?.navigationBar.translucent = true
    navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
    navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
    navigationController?.navigationBar.shadowImage = UIImage()
    
    (navigationController as! DubyNavVC).barColor = .Clear
    edgesForExtendedLayout = .None
    
    tabBarController?.tabBar.barTintColor = UIColor.clearColor()
    
    let logoImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 55.0*1.3, height: 24.0*1.3))
    logoImageView.image = UIImage(named: "icon-logo")
    logoImageView.contentMode = .ScaleAspectFit
    self.navigationItem.titleView = logoImageView
    
    view.backgroundColor = UIColor.clearColor()
    interactionContainerView.backgroundColor = UIColor.clearColor()
    
    transitionViewAlpha(0,  animated: false)
    
    noMoreLabel.alpha = 0
    noMoreLabel.textColor = UIColor.whiteColor()
    
    creatorAvatarImageView.layer.borderColor = UIColor.whiteColor().CGColor
    creatorAvatarImageView.layer.borderWidth = 1.0
    creatorAvatarImageView.layer.cornerRadius = CGRectGetWidth(creatorAvatarImageView.frame)/2
    creatorAvatarImageView.layer.masksToBounds = true
    
    creatorUsernameLabel.superview!.userInteractionEnabled = true
    creatorUsernameLabel.superview!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userImageTapped"))
    
    if CGRectGetHeight(UIScreen.mainScreen().bounds) < 568  {
      changeMultiplier(interactionContainerViewConstraint, multiplier: 1.4)
    } else {
    }
    
    
    
    // to make sure both of these are not selected at the same time
    dubyAcceptButton.exclusiveTouch = true
    dubyRejectButton.exclusiveTouch = true
    
    tapGesture = UITapGestureRecognizer(target: self, action: "refresh")
    tapGesture.delegate = self
    
    userSignedUp = false//(tabBarController as! TabBarController).userSignedUp
    
    dataModel = LandingModel()
    //        userSignedUp = true
    dataModel.userSignedUp = userSignedUp
    
    let y = CGRectGetHeight(UIScreen.mainScreen().bounds)/2 - 120
    exploreMoreButton = UIImageView(frame: CGRect(x: 20, y: y, width: CGRectGetWidth(UIScreen.mainScreen().bounds)-40, height: 60))
    exploreMoreButton.image = UIImage(named: "explore-more")
    exploreMoreButton.contentMode = UIViewContentMode.Center
    //        exploreMoreButton.userInteractionEnabled = true
    //        exploreMoreButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "exploreMorePressed"))
    view.addSubview(exploreMoreButton)
    
    getDubys(adminDubys: false)
    
    
//    dubyCountButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit;
//    dubyCountButton.setImage(UIImage(named: "location_icon")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
//    dubyCountButton.tintColor = UIColor.whiteColor()
    
    badgeUpdate()

    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "enteredForeground", name: UIApplicationWillEnterForegroundNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "enteredBackground", name: UIApplicationDidEnterBackgroundNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "badgeUpdate", name: NOTIFICATION_BADGE_UPDATE, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "badgeUpdate", name: NOTIFICATION_SHOWED_NOTIFICATIONS, object: nil)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    UIApplication.sharedApplication().statusBarStyle = .LightContent
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    // Google analytics
    let tracker = GAI.sharedInstance().defaultTracker
    tracker.set(kGAIScreenName, value: "Landing")
    tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject: AnyObject])
    
    instantiateSwipe()
    
    // try to get more if there are 0 dubys currently
    enteredForeground()
    
    shouldAutoRefresh = false
    
    // show tips if new user signed up
    if !UserDefaults.hasSeenTips(.Landing) {
      UserDefaults.sawTips(.Landing)
      navigationController?.presentTips(.Landing)
    }
    
    UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
  }
  
  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)

  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    shouldAutoRefresh = true
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  func changeMultiplier(constraint: NSLayoutConstraint, multiplier: CGFloat) -> NSLayoutConstraint {
    let newConstraint = NSLayoutConstraint(
      item: constraint.firstItem,
      attribute: constraint.firstAttribute,
      relatedBy: constraint.relation,
      toItem: constraint.secondItem,
      attribute: constraint.secondAttribute,
      multiplier: multiplier,
      constant: constraint.constant)
    
    NSLayoutConstraint.deactivateConstraints([constraint])
    NSLayoutConstraint.activateConstraints([newConstraint])
    
    return newConstraint
  }
  
  func didSignUp() {
    badgeUpdate(3)
  }
  
  func badgeUpdate() {
    badgeUpdate(nil)
  }
  
  func badgeUpdate(number: Int?) {
    var finalNumber = UIApplication.sharedApplication().applicationIconBadgeNumber
    
    if let number = number {
      finalNumber = number
    }
    
    print("UPDATING BADGE WITH NUM \(finalNumber)")
    
    if number > 0 {
      notificationsButton.setTitle("\(finalNumber)", forState: .Normal)
      notificationsButton.setBackgroundImage(UIImage(named: "notes_full"), forState: .Normal)
      
      let center = self.notificationsButton.center
      let anim = CABasicAnimation(keyPath: "position")
      anim.duration = 0.05
      anim.repeatCount = 6
      anim.autoreverses = true
      
      anim.fromValue = NSValue(CGPoint:CGPointMake(center.x - 5, center.y))
      anim.toValue = NSValue(CGPoint:CGPointMake(center.x + 5, center.y))
      
      self.notificationsButton.layer.addAnimation(anim, forKey: "pos")
      
      print(self.notificationsButton)
      
    } else {
      print("EMPTYING IN APP BADGE")
      notificationsButton.setTitle(nil, forState: .Normal)
      notificationsButton.setBackgroundImage(UIImage(named: "notes_empty"), forState: .Normal)
    }
  }
  
  func enteredBackground() {
    shouldAutoRefresh = true
  }
  
  // fetch more dubys if 0
  func enteredForeground() {
    if currentDubyIndex == 0 && shouldAutoRefresh && dataModel.validShares.count == 0 && DubyUser.currentUser.objectId != "" && !userSignedUp{
      refresh()
    }
  }
  
  // add swipe vc
  private func instantiateSwipe() {
    if swipeVC == nil {
      swipeVC = DubySwipeViewController()
      swipeVC.customInit()
      swipeVC.view.frame = interactionContainerView.frame
      swipeVC.view.clipsToBounds = false
      swipeVC.dataSource = self
      swipeVC.delegate = self
      
      addChildViewController(swipeVC)
      view.addSubview(swipeVC.view)
      swipeVC.didMoveToParentViewController(self)
      
      view.bringSubviewToFront(swipeVC.view)
    }
  }
  
  // because some gesture thing is being messed. we have to force explore to be selected
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
    let loc = touch.locationInView(view)
    if CGRectContainsPoint(exploreMoreButton.frame, loc) {
      exploreMorePressed()
      return false
    }
    
    return true
  }
  
  func refresh() {
    getDubys(adminDubys: false)
  }
  
  // go to search vc
  func exploreMorePressed() {
    tabBarController?.selectedIndex = 1
  }
  
  // if we needed the individual tips for buttons. NOT USED RIGHT NOW
  func addHeartbeatPopover() {
    let label = UILabel(frame: CGRectZero)
    label.font = UIFont.openSans(13)
    label.text = "Watch Dubys grow in a live map"
    label.numberOfLines = 0
    label.backgroundColor = UIColor.whiteColor()
    label.textAlignment = NSTextAlignment.Center
    
    view.addSubview(label)
    
    label.layer.cornerRadius = 5
    label.layer.masksToBounds = true
    
    var size = label.text?.getSize(25, maxWidth: CGFloat.max, font: label.font)
    size?.height = 25
    size?.width += 16
    
    //var startOrigin = CGPoint(x: CGRectGetMaxX(dubyCountButton.frame), y: 0)
    //var endOrigin = CGPoint(x: CGRectGetWidth(UIScreen.mainScreen().bounds) - size!.width - 16, y: startOrigin.y)
    
    //label.frame = CGRect(origin: startOrigin, size: CGSizeZero)
    
//    UIView.transitionWithView(label, duration: 0.33, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
//      label.frame = CGRect(origin: endOrigin, size: size!)
//      }) { (_) -> Void in
//        
//    }
  }
  
  func getDubys(adminDubys adminDubys: Bool) {
    view.removeGestureRecognizer(tapGesture)
    
    transitionDubyMessageLabel(text: "", alpha: 0, animated: true)
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
    
    let x = CGRectGetWidth(UIScreen.mainScreen().bounds) / 2
    //let maxY = CGRectGetMaxY(navigationController!.navigationBar.frame)
    //let height = CGRectGetHeight(tabBarController!.tabBar.frame)
    let y = (CGRectGetHeight(UIScreen.mainScreen().bounds) - 64 - 50) / 2
    activityIndicator.center = CGPoint(x: x, y: y)
    
    activityIndicator.startAnimating()
    view.addSubview(activityIndicator)
    
    delay(1.2, closure: { () -> () in
      self.dataModel.getShares(initialDubys: adminDubys) { (gotShares, message) -> Void in
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
        if gotShares {
          self.instantiateSwipe()
          self.swipeVC.resetData()
          self.setCurrentDubyDetails(isInitial: true)
        } else {
          self.transitionViewAlpha(0, animated: false)
          self.transitionDubyMessageLabel(text: message, alpha: 1, animated: true)
        }
      }
    })
  }
  
  //MARK: duby data source
  
  func numberOfDubyViews() -> Int {
    return dataModel.validShares.count
  }
  
  func viewForIndex(index: Int) -> DubyView {
    let dubyView = DubyView(frame: CGRectZero)
    
    let currentDuby = dataModel.validShares[index].duby
    
    dubyView.location = currentDuby.location
    dubyView.dubyImageURL = currentDuby.imageURL
    dubyView.descriptionText = currentDuby.description
    dubyView.commentCount = currentDuby.commentCount
    dubyView.videoImageView.hidden = currentDuby.videoURL == ""
    
    return dubyView
  }
  
  //MARK: duby swipe view delegate
  
  func didSelectViewAtIndex(index: Int) {
    performSegueWithIdentifier("DetailsSegue", sender: self)
  }
  
  func viewSwipedAtIndex(index: Int, shared: Bool) {
    currentDubyIndex++
    
    userSwipedOnDuby(index, shared: shared)
    
    setCurrentDubyDetails(isInitial: false)
    
    checkIfFirstTime(shared)
    checkIfFirstFive()
  }
  
  func checkIfFirstTime(shared: Bool) {
    let user = PFUser.currentUser()!
    let key = shared ? "flat_passed" : "flag_putout"
    if user[key] == nil {
      user[key] = true
      user.saveEventually(nil)
      showPassedPutoutTooltip(shared)
    }
  }
  
  func checkIfFirstFive() {
    let user = PFUser.currentUser()!
    let key = "flag_create"
    if user[key] == nil && currentDubyIndex == 5 {
      user[key] = true
      user.saveEventually(nil)
      showCreateTooltip()
    }
  }
  
  
  func showCreateTooltip() {
    CreateTTVC.presentFromViewController(self, delegate: self)
  }
  
  func showPassedPutoutTooltip(shared: Bool) {
    
    if (!shared) {
      return
    }
    
    let vc = FirstPassTTVC(passed: shared)
    
    let fvc = MZFormSheetPresentationViewController(contentViewController: vc)
    fvc.presentationController?.shouldDismissOnBackgroundViewTap = true
    fvc.presentationController?.blurEffectStyle = UIBlurEffectStyle.Light
    //    fvc.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.StyleDropDown
    fvc.presentationController?.contentViewSize = CGSizeMake(280, 221)
    
    presentViewController(fvc, animated: true, completion: nil)
  }
  
  //MARK:
  
  /// transition all the duby data views alpha
  func transitionViewAlpha(alpha: CGFloat, animated: Bool) {
    UIView.transitionWithView(creatorAvatarImageView, duration: animated ? 0.33 : 0, options: .TransitionCrossDissolve, animations: { () -> Void in
      self.creatorAvatarImageView.alpha = alpha
      self.dubyDescriptionLabel.alpha = alpha
        self.infoContainerView.alpha = alpha
      //self.dubyCountButton.alpha = alpha
      self.dubyRejectButton.alpha = alpha
      self.dubyAcceptButton.alpha = alpha
      self.creatorUsernameLabel.alpha = alpha
      }) { (_) -> Void in
        
    }
  }
  
  /// transition the message label text and alpha
  ///
  /// - parameter text: label text to be set
  /// - parameter alpha: label and exploreMore alpha
  /// - parameter animated: did you want to animate?
  func transitionDubyMessageLabel(text text: String, alpha: CGFloat, animated: Bool) {
    UIView.transitionWithView(noMoreLabel, duration: animated ? 0.33 : 0, options: .TransitionCrossDissolve, animations: { () -> Void in
      
      self.noMoreLabel.text = text
      self.noMoreLabel.alpha = alpha
      self.exploreMoreButton.alpha = alpha
      
      }) { (_) -> Void in
        
    }
  }
  
  // set for next duby
  func updateDubyDetails() {
    currentDubyIndex++
    
    self.setCurrentDubyDetails(isInitial: false)
  }
  
  /// Set duby data for views
  func setCurrentDubyDetails(isInitial isInitial: Bool) {
    if dataModel.validShares.count > 0 { // if there are shares
      
      if currentDubyIndex < dataModel.validShares.count { // if the count is less than the total shares
        
        if isInitial { // if initial (first duby) set alphas
          transitionViewAlpha(1, animated: true)
          transitionDubyMessageLabel(text: "", alpha: 0, animated: false)
        }
        
        
        // transition all the texts
        UIView.transitionWithView(dubyDescriptionLabel, duration: 0.33, options: .TransitionCrossDissolve, animations: { () -> Void in
          
          let currentShare = self.dataModel.validShares[self.currentDubyIndex]
          let currentDuby = currentShare.duby
          
//          if count(currentDuby.imageURL) > 0 {
            self.dubyDescriptionLabel.text = currentDuby.description
            self.dubyCommentCountButton.setTitle("\(currentDuby.commentCount) comments", forState: UIControlState.Normal)
            self.dubyLocationButton.setTitle(currentDuby.location, forState: UIControlState.Normal)
            self.dubyShareCountLabel.text = "\(currentDuby.usersSharedToCount)"
//          } else {
//            self.dubyDescriptionLabel.text = ""
//            self.dubyCommentCountButton.setTitle("", forState: UIControlState.Normal)
//            self.dubyLocationButton.setTitle("", forState: UIControlState.Normal)
//            self.dubyShareCountLabel.text = ""
//          }
          
          _ = currentDuby.usersSharedToCount
          
          //self.dubyCountButton.setTitle("\(Constants.getCountText(shareCount))", forState: .Normal)
          
          self.creatorUsernameLabel.text = "@\(currentDuby.createdBy.username)"
          
//          var size = self.creatorUsernameLabel.text?.getSize(21, maxWidth: self.creatorViewWidthConstraint.constant, font: self.creatorUsernameLabel.font)
//          self.creatorViewWidthConstraint.constant = size!.width + 50 + 3*8 // 50 px for profile pic. 8px on either side of text and profile pic
          self.view.layoutIfNeeded()
          
          self.creatorAvatarImageView.setImageWithURLString(currentDuby.createdBy.profilePicURL, placeholderImage: UIImage.userPlaceholder(), completion: nil)
          }, completion: { (completed) -> Void in
            
            // and now set interaction to true
            self.dubyAcceptButton.userInteractionEnabled = true
            self.dubyRejectButton.userInteractionEnabled = true
            
        })
        
        //                if userSignedUp && currentDubyIndex == validShares.count-1 {
        //                    addHeartbeatPopover()
        //                }
        
      } else { // index is now greater than the number of shares
        
        self.dubyAcceptButton.userInteractionEnabled = false
        self.dubyRejectButton.userInteractionEnabled = false
        
        // set all duby data view alpha to 0 and reset other numbers
        self.transitionViewAlpha(0, animated: true)
        dataModel.validShares = [DubyShare]()
        currentDubyIndex = 0
        
        if userSignedUp {
          userSignedUp = !userSignedUp
        }
        
        if dataModel.canGetMoreShares {
          refresh() // refresh to see if we have more
        } else {
          if !self.userSignedUp {
            self.transitionDubyMessageLabel(text: "No more Dubys. \n Tap to Refresh.", alpha: 1, animated: true)
            
            view.addGestureRecognizer(self.tapGesture)
          } else {
            self.userSignedUp = false
            
            getDubys(adminDubys: false)
          }
        }
      }
      
      
    } else { // share count less than 0??????
      
      
      transitionViewAlpha(0, animated: false)
      transitionDubyMessageLabel(text: "No Dubys currently shared with you. \n Tap to Refresh.", alpha: 1, animated: true)
      
      dubyAcceptButton.userInteractionEnabled = false
      dubyRejectButton.userInteractionEnabled = false
      
      dataModel.validShares = [DubyShare]()
      currentDubyIndex = 0
      
      view.addGestureRecognizer(self.tapGesture)
    }
    
  }
  
  @IBAction func notificationsTapped() {
    NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_SHOW_NOTIFICATIONS, object: nil)
  }
  
  @IBAction func profileTapped() {
    NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_SHOW_PROFILE, object: nil)
  }
  
  @IBAction func searchTapped() {
    let searchVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SearchVC") as! SearchVC
    navigationController?.pushViewController(searchVC, animated: true)
  }
  
  @IBAction func dubyAccepted(sender: AnyObject) {
    dubyRejectButton.userInteractionEnabled = false
    dubyAcceptButton.userInteractionEnabled = false
    
    swipeVC.userSwiped(shared: true)
    
    let tracker = GAI.sharedInstance().defaultTracker
    tracker.send(GAIDictionaryBuilder.createEventWithCategory(ANALYTICS_CATEGORY_UI_ACTION, action: ANALYTICS_ACTION_UI_BUTTON_TAP, label: "duby_passed", value: nil).build() as [NSObject: AnyObject])
  }
  
  @IBAction func dubyDenied(sender: AnyObject) {
    dubyRejectButton.userInteractionEnabled = false
    dubyAcceptButton.userInteractionEnabled = false
    
    swipeVC.userSwiped(shared: false)
    
    let tracker = GAI.sharedInstance().defaultTracker
    tracker.send(GAIDictionaryBuilder.createEventWithCategory(ANALYTICS_CATEGORY_UI_ACTION, action: ANALYTICS_ACTION_UI_BUTTON_TAP, label: "duby_put_out", value: nil).build() as [NSObject: AnyObject])
  }
  
  // share count
  @IBAction func dubyCountPressed(sender: AnyObject) {
    let currentShare = self.dataModel.validShares[self.currentDubyIndex]
    let currentDuby = currentShare.duby
    navigationController?.pushToDubyPassersVC(duby: currentDuby)
//    if currentDubyIndex < dataModel.validShares.count {
//      performSegueWithIdentifier("DubyDetailsSegue", sender: self)
//    }
  }
  
  @IBAction func dubyLocationPressed() {
    let currentShare = self.dataModel.validShares[self.currentDubyIndex]
    let currentDuby = currentShare.duby
    self.navigationController?.pushToDubyDetailsVC(duby: currentDuby)
  }
  
  @IBAction func dubyCommentsPressed() {
    let currentShare = self.dataModel.validShares[self.currentDubyIndex]
    let currentDuby = currentShare.duby
    
    let commentsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CommentsContainerVC") as! CommentsContainerVC
    commentsVC.duby = currentDuby
    //commentsVC.dataModel = tableModel.commentModel
    commentsVC.showKeyboardOnStart = true
    
    self.navigationController?.pushViewController(commentsVC, animated: true)
  }
  
  @IBAction func dubyDescriptionPressed() {
    let currentShare = self.dataModel.validShares[self.currentDubyIndex]
    let currentDuby = currentShare.duby
    self.navigationController?.pushToDetailsVC(duby: currentDuby)
  }
  
  
  @IBAction func dubySharePressed() {
    let view = swipeVC.currentViews[0] as DubyView
    
    var items = ["Pass the Duby! Download for iPhone.\n\n", NSURL(string: "http://apple.co/1GF1tBw")!]
    
    if let image = view.imageView.image {
      items.append(image)
      
      
      let instagramUrl = NSURL(string: "instagram://app")
      if(UIApplication.sharedApplication().canOpenURL(instagramUrl!)){
        
        //Instagram App avaible
        
        let imageData = UIImageJPEGRepresentation(image, 100)
        let captionString = "Join my sesh on Duby! Username: \(DubyUser.currentUser.username)   http://apple.co/1FJHlLE"
        let writePath = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("instagram.igo")
        
        if(!imageData!.writeToFile(writePath, atomically: true)){
          //Fail to write. Don't post it
          return
        } else{
          //Safe to post
          
          let fileURL = NSURL(fileURLWithPath: writePath)
          docController = UIDocumentInteractionController(URL: fileURL)
          docController!.delegate = self
          docController!.UTI = "com.instagram.exclusivegram"
          docController!.annotation =  NSDictionary(object: captionString, forKey: "InstagramCaption")
          docController!.presentOpenInMenuFromRect(CGRectZero, inView: view, animated: true)
        }
      } else {
        let activity  = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activity.excludedActivityTypes = [UIActivityTypePrint, UIActivityTypeMail, UIActivityTypeSaveToCameraRoll, UIActivityTypeCopyToPasteboard, UIActivityTypeAirDrop, UIActivityTypeAddToReadingList]
        presentViewController(activity, animated: true, completion: nil)
      }
    }
    
    let tracker = GAI.sharedInstance().defaultTracker
    tracker.set(kGAIScreenName, value: "Landing")
    tracker.set("event", value: "share")
    tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject: AnyObject])
  }
  
  func userImageTapped() {
    if /*!userSignedUp &&*/ currentDubyIndex < dataModel.validShares.count {
      let share = dataModel.validShares[currentDubyIndex]
      navigationController?.pushToProfileVC(user: share.duby.createdBy)
    }
  }
  
  //MARK: interaction delegate
  
  func userSwipedOnDuby(index: Int, shared: Bool) {
    dubyAcceptButton.userInteractionEnabled = false
    dubyRejectButton.userInteractionEnabled = false
    
    // This should be uncommented if we want to pre fetch more - pagination
    //        if index == dataModel.validShares.count - 8 { // 8 is how many before we want to make the call
    //            dataModel.getAdditionalShares(completion: { (gotMore) -> Void in
    //                if gotMore {
    //                    self.swipeVC.reloadData()
    //                }
    //            })
    //        }
    dataModel.dubySwipedAtIndex(index, shared: shared)
  }
  
  func dubySelected() {
    if currentDubyIndex < dataModel.validShares.count {
      performSegueWithIdentifier("DetailsSegue", sender: self)
    }
  }
  
  //MARK:
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "DetailsSegue" {
      let detailsVC = segue.destinationViewController as? DetailsTableVC
      detailsVC?.selectedDuby = dataModel.validShares[currentDubyIndex].duby
      detailsVC?.sender = self
    } else if segue.identifier == "DubyDetailsSegue" {
      let dubyDetailsVC = segue.destinationViewController as! DubyDetailsCollectionVC
      dubyDetailsVC.duby = dataModel.validShares[currentDubyIndex].duby
    } else if segue.identifier == "CommentsSegue" {
        let currentShare = self.dataModel.validShares[self.currentDubyIndex]
        let currentDuby = currentShare.duby
        
        let commentContainerVC = segue.destinationViewController as! CommentsContainerVC
        commentContainerVC.duby = currentDuby

        commentContainerVC.dataModel = CommentsModel()
//        commentContainerVC.showKeyboardOnStart = showKeyboardInComments
//        showKeyboardInComments = false
    }
  }
  
  func createTTVCDidOkay() {
    dismissViewControllerAnimated(true, completion: nil)
    let mainStoryboard = UIStoryboard(name: "Main", bundle: nil);
    let vc = mainStoryboard.instantiateViewControllerWithIdentifier("CreateTableVC")
    navigationController?.pushViewController(vc, animated: true)
  }
  
  func createTTVCDidCancel() {
    dismissViewControllerAnimated(true, completion: nil)
  }
}
