//
//  DetailsTableVC.swift
//  Duby
//
//  Created by Harsh Damania on 1/23/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit
import QuartzCore
 

class DetailsTableVC: UITableViewController, DubyImageCellDelegate, DubyInfoCellDelegate, DubyDescriptionCellDelegate, CommentCellDelegate, UIActionSheetDelegate, UIDocumentInteractionControllerDelegate {
  
  @IBOutlet weak var dubyCountButton: UIButton!
  @IBOutlet weak var followButton: UIButton!
  
  var userSignedUp = false
  var sender: LandingVC?
  var selectedDuby: Duby! {
    didSet {
      tableModel = DetailsTableViewModel(duby: selectedDuby)
      tableModel.userSignedUp = userSignedUp
    }
  }
  var voteStatus: Int?
  
  var duby: PFObject?
  var follow: PFObject? = nil
  
  private var tableModel: DetailsTableViewModel!
  
  private var showKeyboardInComments = false
  
  private var isDeleted = false
  private var thisDubyDeleted = false
  
  private var reportButtonIndex = -1
  private var deleteButtonIndex = -1
  
  private var docController: UIDocumentInteractionController?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Dont use this anymore
    if !userSignedUp {
      let refreshControl = UIRefreshControl()
      refreshControl.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
      refreshControl.tintColor = UIColor.whiteColor()
      self.refreshControl = refreshControl
    }
    
    
    //dubyCountButton.setTitle(" \(Constants.getCountText(count))", forState: .Normal)
    //dubyCountButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit;
//    dubyCountButton.setImage(UIImage(named: "icon-loc-med")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
//    dubyCountButton.tintColor = UIColor.whiteColor()
//    
    (navigationController as! DubyNavVC).barColor = .Clear
    
    tableView.backgroundColor = UIColor.clearColor()
    edgesForExtendedLayout = .None
    
    automaticallyAdjustsScrollViewInsets = false
    tableView.tableFooterView = UIView()
    tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: CGRectGetWidth(UIScreen.mainScreen().bounds), height: 0.01))
    
    if !userSignedUp {
      getComments { (_) -> (Void) in
        
      }
    }
    
    title = "Details"
    
    self.followButton.layer.cornerRadius = 3
    if selectedDuby.createdBy == DubyUser.currentUser {
      followButton.hidden = true
    } else {
      
      /* Set follow button to "Following" state */
      followButton.backgroundColor = UIColor.clearColor()
      followButton.tintColor = UIColor.whiteColor()
      followButton.setTitle("Favorite", forState: .Normal)
      followButton.setImage(UIImage(named: "duby_fav_off")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
      followButton.imageView?.contentMode = .ScaleAspectFit
      
      /* Query Follow Table to see if user is following Duby */
      DubyDatabase.followingDuby(selectedDuby.objectId, completion: { (followObjectId, error) -> Void in
        if error != nil {
          NSLog("ERROR (check followingDuby): Could not check if user is following Duby: %@", error!)
        } else if followObjectId != nil {
          
          /* Set follow button to "Following" state */
          self.followButton.setTitle("Unfavorite", forState: .Normal)
          self.followButton.setImage(UIImage(named: "duby_fav_on")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
          self.followButton.imageView?.contentMode = .ScaleAspectFit
          
          /* Get pointer to follow */
          let query = PFQuery(className: "Follow")
          query.getObjectInBackgroundWithId(followObjectId!, block: { (object, error) -> Void in
            if error != nil {
              NSLog("ERROR (getObjectWithId for follow): ", error!)
            } else {
              self.follow = object
            }
          })
          
        } else if followObjectId == nil {
          /* Set follow pointer to nil to indicate that the user is not following this duby */
          self.follow = nil
        }
      })
    }
    
    if sender == nil {
      MBProgressHUD.showHUDAddedTo(view, animated: true);
      DubyDatabase.getDubyVoteStatus(selectedDuby.objectId, completion: { (status, error) -> Void in
        self.voteStatus = status;
        MBProgressHUD.hideHUDForView(self.view, animated: true);
        self.tableView.reloadData();
        
      })
    }
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "newCommentAdded:", name: "NewComment", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "dubyDeleted:", name: "DubyDeleted", object: nil)
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: "NewComment", object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(self, name: "DubyDeleted", object: nil)
  }
  
  override func viewWillAppear(animated: Bool) {
    UIApplication.sharedApplication().statusBarStyle = .LightContent
  }
  
  override func viewDidAppear(animated: Bool) {
    // Google analytics
    let tracker = GAI.sharedInstance().defaultTracker
    tracker.set(kGAIScreenName, value: "Details")
    tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject: AnyObject])
    
    super.viewDidAppear(animated)
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 0, inSection: 0)) as? DubyImageCell {
      cell.removePlayer()
    }
  }
  
  func getComments(completion: (Bool) -> (Void)) {
    tableModel.commentModel.getCommentsForDuby(selectedDuby, completion: { (gotComments) -> (Void) in
      self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
      self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: .None)
      
      completion(gotComments)
    })
  }
  
  func refresh() {
    DubyDatabase.getDubyInfo(selectedDuby.objectId, completion: { (duby, error) -> Void in
      if error != nil {
        UIAlertView(title: "Error", message: "Error refreshing data.", delegate: nil, cancelButtonTitle: "Ok").show()
        self.refreshControl?.endRefreshing()
      } else {
        self.selectedDuby = duby
        self.getComments({ (_) -> (Void) in
          self.refreshControl?.endRefreshing()
          return
        })
      }
    })
  }
  
  func dubyDeleted(notification: NSNotification) {
    if (notification.userInfo!["objectId"] as! String) == selectedDuby.objectId && !thisDubyDeleted {
      isDeleted = true
      tableView.reloadData()
      tableView.userInteractionEnabled = false
      
      navigationItem.rightBarButtonItem?.customView?.hidden = true
      
      let deletedLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
      deletedLabel.text = "Duby Deleted"
      deletedLabel.font = UIFont.openSans(14)
      deletedLabel.textColor = UIColor.whiteColor()
      deletedLabel.textAlignment = NSTextAlignment.Center
      
      let centerY = (CGRectGetHeight(UIScreen.mainScreen().bounds) - CGRectGetHeight(tabBarController!.tabBar.frame) - CGRectGetMaxY(navigationController!.navigationBar.frame)) / 2
      
      deletedLabel.center = CGPoint(x: CGRectGetWidth(UIScreen.mainScreen().bounds)/2, y: centerY)
      
      view.addSubview(deletedLabel)
      view.bringSubviewToFront(deletedLabel)
    }
  }
  
  // MARK:-UIButton Delegates
  @IBAction func followButtonPressed(sender: AnyObject) {
    if follow != nil {
      
      /* Change button UI to display "Follow" */
      followButton.backgroundColor = UIColor.clearColor()
      followButton.tintColor = UIColor.whiteColor()
      followButton.setTitle("Favorite", forState: .Normal)
      followButton.setImage(UIImage(named: "duby_fav_off")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
      followButton.imageView?.contentMode = .ScaleAspectFit
      
      follow?.deleteInBackgroundWithBlock({ (deleted, error) -> Void in
        if error != nil {
          
          UIAlertView(title: "Unable to unfollow Duby", message: "Currently unable to unfollow Duby. Please try again later!", delegate: nil, cancelButtonTitle: "Ok").show()
          /* Display alertview that user could not follow Duby */
          
          /* Display "Following" button UI */
          self.followButton.tintColor = UIColor.whiteColor()
          self.followButton.setTitle("Unfavorite", forState: .Normal)
          self.followButton.setImage(UIImage(named: "duby_fav_on")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
          self.followButton.imageView?.contentMode = .ScaleAspectFit
        } else {
          self.follow = nil
        }
      })
    } else {
      
      /* Create a follow in the DB */
      follow = PFObject(className: "Follow")
      follow!.setObject(DubyUser.currentUser.getParsePointerDictionary(), forKey: "user")
      follow!.setObject(selectedDuby.getParsePointerDictionary(), forKey: "duby")
      follow!.saveInBackgroundWithBlock({ (success, error) -> Void in
        if error != nil {
          
          /* Display alertview that user could not follow Duby */
          UIAlertView(title: "Unable to unfollow Duby", message: "Currently unable to unfollow Duby. Please try again later!", delegate: nil, cancelButtonTitle: "Ok").show()
          
          /* Change button UI to display "Follow" */
          self.followButton.tintColor = UIColor.whiteColor()
          self.followButton.setTitle("Favorite", forState: .Normal)
          self.followButton.setImage(UIImage(named: "duby_fav_off")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
          self.followButton.imageView?.contentMode = .ScaleAspectFit
        }
      })
      
      /* Display "Following" button UI */
      followButton.tintColor = UIColor.whiteColor()
      followButton.setTitle("Unfavorite", forState: .Normal)
      self.followButton.setImage(UIImage(named: "duby_fav_on")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
      self.followButton.imageView?.contentMode = .ScaleAspectFit
    }
  }
  
  //MARK: cell delegate
  
  // duby share selected
  func imageCellDidAcceptDuby() {
    print("accepting")
    navigationController?.popViewControllerAnimated(true)
    if sender != nil {
      sender?.dubyAccepted(UIButton())
    } else {
      DubyDatabase.voteDuby(selectedDuby, pass: true, completion: { (sucess, error) -> Void in
        
      });
    }
  }
  
  // duby denied selected
  func imageCellDidRejectDuby() {
    print("rejecting")
    navigationController?.popViewControllerAnimated(true)
    if sender != nil {
      sender?.dubyDenied(UIButton())
    } else {
      DubyDatabase.voteDuby(selectedDuby, pass: false, completion: { (sucess, error) -> Void in
        
      });
    }
  }
  
  // report pressed
  func reportDuby() {
    let actionSheet = UIActionSheet(title: "Report Duby", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil)
    actionSheet.addButtonWithTitle("Report")
    actionSheet.showInView(view)
  }
  
  func share() {
    let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! DubyImageCell
    var items = ["Pass the Duby! Download for iPhone.\n\n", NSURL(string: "http://apple.co/1GF1tBw")!]
    
    if let image = cell.dubyImageView.image {
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
    tracker.set(kGAIScreenName, value: "Details")
    tracker.set("event", value: "share")
    tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject: AnyObject])
  }
  
  // select some option. The table model determines if the user can or cannot report/delete
  func openDubyActionSheet() {
    if !userSignedUp {
      let actionSheet = UIActionSheet(title: "Select an Option", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil)
      
      if tableModel.canDelete {
        actionSheet.addButtonWithTitle("Delete this Duby")
        deleteButtonIndex = 1
      }
      
      if tableModel.canReport {
        actionSheet.addButtonWithTitle("Report")
        
        if tableModel.canDelete {
          reportButtonIndex = 2
        } else {
          reportButtonIndex = 1
        }
      }
      
      actionSheet.addButtonWithTitle("Share");
      
      actionSheet.showInView(view);
    }
  }
  
  // new comment added in comments vc
  func newCommentAdded(notification: NSNotification) {
    if (notification.userInfo!["objectId"] as! String) == selectedDuby.objectId {
      tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
      tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: .None)
    }
  }
  
  func toProfileVC(index index: Int) {
    if !userSignedUp {
      navigationController?.pushToProfileVC(user: tableModel.commentModel.getDetailsCommentAtIndex(index).comment.sender)
    }
  }
  
  func toProfileVC(user: DubyUser) {
    navigationController?.pushToProfileVC(user: user)
  }
  
  //MARK:
  
  @IBAction func dubyCountPressed(sender: AnyObject) {
    print("PRESSED")
    performSegueWithIdentifier("DubyDetailsSegue", sender: self)
  }
  
  func goToComments() {
    if !userSignedUp {
      showKeyboardInComments = true
      performSegueWithIdentifier("CommentsSegue", sender: self)
    }
    
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    if isDeleted {
      return 0
    } else {
      return tableModel.getNumberOfSections()
    }
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tableModel.getNumberOfRows(section: section)
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return tableModel.heightForRowAtIndexPath(indexPath)
  }
  
  override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    if section == 1 {
      return 44
    } else {
      return 0
    }
  }
  
  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if section == 1 && tableModel.commentModel.comments.count > 0 {
      return 30
    } else {
      return 0
    }
  }
  
  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return tableModel.getHeaderView(section)
  }
  
  override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let footer = tableModel.getFooterView(section)
    
    (footer.viewWithTag(5) as? UIButton)?.addTarget(self, action: "goToComments", forControlEvents: .TouchUpInside)
    
    return footer
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    if indexPath.section == 0 {
      switch indexPath.row {
      case 0:
        let cell = tableView.dequeueReusableCellWithIdentifier("dubyImageCell", forIndexPath: indexPath) as! DubyImageCell
        cell.selectedDuby = selectedDuby
        
        if sender != nil {
          cell.showButtons()
        } else {
          if voteStatus == nil {
            cell.hideButtons();
          } else {
            
            cell.setStatus(voteStatus!);
            if voteStatus == 1 {
              cell.showButtons();
            } else {
              cell.hideButtons();
            }
          }
        }
        cell.delegate = self
        return cell
      case 1:
        let cell = tableView.dequeueReusableCellWithIdentifier("dubyInfoCell", forIndexPath: indexPath) as! DubyInfoCell
        cell.selectedDuby = selectedDuby
        cell.tableModel = tableModel
        cell.delegate = self
        return cell
      case 2:
        let cell = tableView.dequeueReusableCellWithIdentifier("dubyDescriptionCell", forIndexPath: indexPath) as! DubyDescriptionCell
        cell.tableModel = tableModel
        cell.selectedDuby = selectedDuby
        cell.delegate = self
        return cell
      default:
        print("some other row? \(indexPath.row)")
      }
    } else if indexPath.section == 1 {
      let commentInfo = tableModel.commentModel.getDetailsCommentAtIndex(indexPath.row)
      let size = tableModel.commentModel.getCellSizeAtIndex(indexPath.row, details: true)
      
      if commentInfo.selfSender {
        let cell = tableView.dequeueReusableCellWithIdentifier("RightCommentCell", forIndexPath: indexPath) as! RightCommentCell
        cell.index = indexPath.row
        cell.setData(commentInfo.comment, size: size)
        cell.delegate = self
        
        return cell
      } else {
        let cell = tableView.dequeueReusableCellWithIdentifier("LeftCommentCell", forIndexPath: indexPath) as! LeftCommentCell
        cell.index = indexPath.row
        cell.setData(commentInfo.comment, size: size)
        cell.delegate = self
        
        return cell
      }
    }
    
    
    let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) 
    
    // Configure the cell...
    
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.section == 0 && indexPath.row == 1 {
      if !userSignedUp {
        //navigationController?.pushToProfileVC(user: selectedDuby.createdBy)
      }
    } else if indexPath.section == 1 {
      goToComments()
    }
  }
  
  //MARK: action sheet
  
  func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
    print("byt \(buttonIndex)")
    print("repo \(reportButtonIndex)")
    print("delete \(deleteButtonIndex)")
    
    if buttonIndex == reportButtonIndex {
      DubyDatabase.reportDuby(selectedDuby)
      selectedDuby.reports.append(DubyUser.currentUser.objectId)
      tableModel.canReport = false
      tableView.reloadData()
    } else if buttonIndex == deleteButtonIndex {
      MBProgressHUD.showHUDAddedTo(view, animated: true)
      DubyDatabase.deleteDuby(selectedDuby.objectId, completion: { (deleted) -> (Void) in
        print("delete status \(deleted)")
        
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        
        if deleted {
          self.thisDubyDeleted = true
          NSNotificationCenter.defaultCenter().postNotificationName("DubyDeleted", object: nil, userInfo: ["objectId":self.selectedDuby.objectId])
          self.navigationController?.popViewControllerAnimated(true)
        }
        
      })
    } else {
      let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! DubyImageCell
      var items = ["Pass the Duby! Download for iPhone.\n\n", NSURL(string: "http://apple.co/1GF1tBw")!]
      
      if let image = cell.dubyImageView.image {
        items.append(image)
      }
      
      let activity  = UIActivityViewController(activityItems: items, applicationActivities: nil)
      activity.excludedActivityTypes = [UIActivityTypePrint, UIActivityTypeMail, UIActivityTypeSaveToCameraRoll, UIActivityTypeCopyToPasteboard, UIActivityTypeAirDrop, UIActivityTypeAddToReadingList]
      presentViewController(activity, animated: true, completion: nil)
    }
  }
  
  //MARK: navigation
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // going to comments
    if segue.identifier == "CommentsSegue" {
      let commentContainerVC = segue.destinationViewController as! CommentsContainerVC
      commentContainerVC.duby = selectedDuby
      commentContainerVC.dataModel = tableModel.commentModel
      commentContainerVC.showKeyboardOnStart = showKeyboardInComments
      showKeyboardInComments = false
    } else if segue.identifier == "DubyDetailsSegue" { // going to duby details
      let dubyDetailsVC = segue.destinationViewController as! DubyDetailsCollectionVC
      dubyDetailsVC.userSignedUp = userSignedUp
      dubyDetailsVC.duby = selectedDuby
    } else if segue.identifier == "passers" {
      let passersVC = segue.destinationViewController as! PassersVC
      passersVC.dubyId = selectedDuby.objectId
    }
  }
  
  func toHashtagsVC(hashtag: String) {
    let hashtagVC = HashtagsVC(collectionViewLayout: UICollectionViewFlowLayout())
    hashtagVC.hashtag = hashtag
    navigationController?.pushViewController(hashtagVC, animated: true)
  }
  
  func toProfileVCWithUsername(username: String) {
    DubyDatabase.getUser(username, completion: { (user, error) -> (Void) in
      print(user)
      if let dubyUser = user {
        self.navigationController?.pushToProfileVC(user: dubyUser)
      }
    })
  }
  
  func infoCellDidTapShare() {
    share()
  }
  
  func infoCellDidTapUser(user: DubyUser) {
    navigationController?.pushToProfileVC(user: user)
  }
  
  func infoCellDidTapMore() {
    openDubyActionSheet()
  }
  
  func descriptionCellDidTapHashtag(hashtag: String) {
    let hashtagVC = HashtagsVC(collectionViewLayout: UICollectionViewFlowLayout())
    hashtagVC.hashtag = hashtag
    navigationController?.pushViewController(hashtagVC, animated: true)
  }
  
  func descriptionCellDidTapUsername(username: String) {
    DubyDatabase.getUser(username, completion: { (user, error) -> (Void) in
      print(user)
      if let dubyUser = user {
        self.navigationController?.pushToProfileVC(user: dubyUser)
      }
    })
  }

  func commentCellDidTapUser(user: DubyUser) {
    navigationController?.pushToProfileVC(user: user)
  }
  
  func commentCellDidTapUsername(username: String) {
    DubyDatabase.getUser(username, completion: { (user, error) -> (Void) in
      print(user)
      if let dubyUser = user {
        self.navigationController?.pushToProfileVC(user: dubyUser)
      }
    })
  }
  
  func commentCellDidTapHashtag(hashtag: String) {
    let hashtagVC = HashtagsVC(collectionViewLayout: UICollectionViewFlowLayout())
    hashtagVC.hashtag = hashtag
    navigationController?.pushViewController(hashtagVC, animated: true)
  }
  
}
