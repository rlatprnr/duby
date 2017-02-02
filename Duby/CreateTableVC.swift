//
//  CreateTableVC.swift
//  Duby
//
//  Created by Harsh Damania on 2/22/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit
import MobileCoreServices
 

class CreateTableVC: UITableViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PBJViewControllerDelegate {
  
  @IBOutlet weak var lightUpButton: UIButton!
  private var dataModel = CreateModel()
  
  private var keyboardIsShowing = false
  
  private var imageCell: CreateImageCell!
  private var textCell: CreateTextCell!
  
  private var seen = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    UIApplication.sharedApplication().statusBarStyle = .LightContent
    
    navigationController?.navigationBar.translucent = true
    navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
    navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
    navigationController?.navigationBar.shadowImage = UIImage()
    
    (navigationController as! DubyNavVC).barColor = .Clear
    
    edgesForExtendedLayout = .None
    
    tableView.backgroundColor = UIColor.clearColor()
    
    
    lightUpButton.alpha = 0
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
    UIApplication.sharedApplication().statusBarStyle = .LightContent
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    // analytics
    let tracker = GAI.sharedInstance().defaultTracker
    tracker.set(kGAIScreenName, value: "Create")
    tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject: AnyObject])
    
    super.viewDidAppear(animated)
    
    // show tips
    if !UserDefaults.hasSeenTips(.Create) {
      UserDefaults.sawTips(.Create)
      navigationController?.presentTips(.Create)
    }
    
    
    if (!seen) {
      showMediaOptions()
      seen = true
    }
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  //MARK: keyboard
  
  func keyboardWillShow(notification: NSNotification) {
    let duration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
    let curve = (notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber) as UInt
    let keyboardFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
    
    UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions(rawValue: curve), animations: { () -> Void in
      
      // move frame up
      var frame = self.view.frame
      frame.origin.y = -(CGRectGetHeight(keyboardFrame) - CGRectGetMaxY(self.navigationController!.navigationBar.frame))
      self.view.frame = frame
      
      // hide light up button and navigation title
      self.lightUpButton.alpha = 0
      self.navigationItem.title = ""
      
      if CGRectGetHeight(UIScreen.mainScreen().bounds) == 480 {
        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0), atScrollPosition: .Bottom, animated: false)
        self.tableView.scrollEnabled = false
      }
      
      }) { (completed: Bool) -> Void in
        self.keyboardIsShowing = true
    }
  }
  
  func keyboardWillHide(notification: NSNotification) {
    let duration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
    let curve = (notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber) as UInt
    
    UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions(rawValue: curve), animations: { () -> Void in
      
      // bring frame back down
      var frame = self.view.frame
      frame.origin.y = CGRectGetMaxY(self.navigationController!.navigationBar.frame)
      self.view.frame = frame
      
      // and show light up button
      self.lightUpButton.alpha = 1
      self.navigationItem.title = "Create Duby"
      
      if CGRectGetHeight(UIScreen.mainScreen().bounds) == 480 {
        self.tableView.scrollEnabled = true
      }
      
      
      }) { (completed: Bool) -> Void in
        self.updateLightUpButtonStatus()
        self.keyboardIsShowing = false
    }
  }
  
  // checks if all conditions are met for posting and shows button
  func updateLightUpButtonStatus() {
    
    UIView.transitionWithView(lightUpButton, duration: 0.33, options: .TransitionCrossDissolve, animations: { () -> Void in
      self.lightUpButton.alpha = self.dataModel.valid ? 1 : 0
      }) { (_) -> Void in
        
    }
  }
  
  
  func showMediaOptions() {
    let actionSheet = UIActionSheet(title: "Select a Mode", delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
    actionSheet.addButtonWithTitle("Camera")
    actionSheet.addButtonWithTitle("Photo Library")
    actionSheet.addButtonWithTitle("Video")
    actionSheet.addButtonWithTitle("Cancel")
    
    actionSheet.cancelButtonIndex = 3
    actionSheet.showInView(UIApplication.sharedApplication().keyWindow!)
  }
  //MARK: actions
  
  @IBAction func lightUpPressed(sender: AnyObject) {
    
    // Disallowing empty Dubys
    let set = NSCharacterSet.whitespaceAndNewlineCharacterSet()
    if textCell.descriptionTextView.text.stringByTrimmingCharactersInSet(set).characters.count == 0 && imageCell.dubyImageView.image == nil
    {
      UIAlertView(title: "Invalid Duby Description", message: "Cannot create a duby with only empty space", delegate: nil, cancelButtonTitle: OK).show()
      return
    }
    
    // To disallow multiple creation of Dubys
    lightUpButton.userInteractionEnabled = false
    
    MBProgressHUD.showHUDAddedTo(view, animated: true)
    dataModel.createDuby { (error) -> (Void) in
      MBProgressHUD.hideHUDForView(self.view, animated: true)
      
      if error == nil {
        self.imageCell.clearView()
        self.textCell.clearView()
        
        self.updateLightUpButtonStatus()
      } else {
        UIAlertView(title: "Error", message: error, delegate: nil, cancelButtonTitle: OK).show()
      }
      
      self.lightUpButton.userInteractionEnabled = true
    }
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    let width = CGRectGetWidth(UIScreen.mainScreen().bounds)
    if indexPath.row == 0 {
      return width
    } else if indexPath.row == 1 {
      let screenHeight = CGRectGetHeight(UIScreen.mainScreen().bounds)
      if screenHeight == 480 {
        tableView.scrollEnabled = true
        return 206
      } else {
        var height = screenHeight  - CGRectGetMaxY(navigationController!.navigationBar.frame)
        height -= width
        
        tableView.scrollEnabled = false
        return height
      }
    }
    
    return 0
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.row == 0 {
      let cell = tableView.dequeueReusableCellWithIdentifier("CreateImageCell", forIndexPath: indexPath) as! CreateImageCell
      cell.dataModel = dataModel
      imageCell = cell
      
      return cell
    } else {
      let cell = tableView.dequeueReusableCellWithIdentifier("CreateTextCell", forIndexPath: indexPath) as! CreateTextCell
      cell.dataModel = dataModel
      textCell = cell
      
      return cell
    }
    
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
    
    if !keyboardIsShowing {
      if indexPath.row == 0 { // photo selection options
        showMediaOptions()
      }
    }
  }
  
  //MARK: action sheet
  
  func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
    if buttonIndex == actionSheet.cancelButtonIndex {
      return
    }
    
    if buttonIndex == 0 {
      openCamera()
    } else if buttonIndex == 1 {
      openLibrary()
    } else if buttonIndex == 2 {
      openVideo()
    }
  }
  
  func openVideo() {
    let cameraVC = PBJViewController();
    cameraVC.delegate = self;
    presentViewController(cameraVC, animated: true, completion: nil)
  }
  
  func openCamera() {
    let picker = UIImagePickerController()
    picker.sourceType = .Camera;
    picker.mediaTypes = [kUTTypeImage as String]
    picker.allowsEditing = true
    picker.delegate = self
    picker.navigationBar.titleTextAttributes = nil
    picker.navigationBar.tintColor = nil
    
    presentViewController(picker, animated: true, completion: nil)
  }
  
  func openLibrary() {
    let picker = UIImagePickerController()
    
    picker.sourceType = .PhotoLibrary;
    picker.mediaTypes = [kUTTypeImage as String]
    picker.allowsEditing = true
    picker.delegate = self
    picker.navigationBar.titleTextAttributes = nil
    picker.navigationBar.tintColor = nil
    
    presentViewController(picker, animated: true, completion: nil)
  }
  
  //MARK:-UINavigationControllerDelegate
  func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
    // to fix cropping issue
    UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
  }
  
  //MARK: image picker
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    
    picker.dismissViewControllerAnimated(true, completion: nil)
    
    let image = info[UIImagePickerControllerEditedImage] as? UIImage
    imageCell.setDubyData(image, videoURL: nil)
    updateLightUpButtonStatus()
    
    let photoFile = PFFile(name: "duby_image.jpg", data: UIImageJPEGRepresentation(image!, 0.1)!)
    
    MBProgressHUD.showHUDAddedTo(view, animated: true)
    
    photoFile?.saveInBackgroundWithBlock({ (saved, error) -> Void in
      print(error);
      MBProgressHUD.hideHUDForView(self.view, animated: true)
      if (error != nil || saved == false) {
        self.imageCell.setDubyData(nil, videoURL: nil)
      } else {
        self.dataModel.dubyImage = ["name": photoFile!.name, "__type": "File", "url": photoFile!.url!]
        self.dataModel.dubyVideo = nil
      }
      
      self.updateLightUpButtonStatus()
    })
    
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    picker.dismissViewControllerAnimated(true, completion: nil)
    
    updateLightUpButtonStatus()
    //        updateButtonStatuses(descriptionTextView.text)
  }
  
  func pbjViewControllerDidCancel() {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func pbjViewControllerDidCompleteWithInfo(info: [NSObject : AnyObject]!) {
    self.dismissViewControllerAnimated(true, completion: nil)
    let videoPath = info["videoPath"] as! NSString;
    let photo = info["photo"] as! UIImage
    
    let vidFile = try! PFFile(name: "vid.m4v", contentsAtPath: videoPath as String)
    let photoFile = PFFile(name: "duby_image.jpg", data: UIImageJPEGRepresentation(photo, 0.1)!)!
    
    imageCell.setDubyData(photo, videoURL: nil)
    
    MBProgressHUD.showHUDAddedTo(view, animated: true)
    
    
//    PFObject.saveAllInBackground([vidFile, photoFile], block: { (saved, error) -> Void in
//      println(error);
//      MBProgressHUD.hideHUDForView(self.view, animated: true)
//      if (error != nil || saved == false) {
//        self.imageCell.setDubyData(nil, videoURL: nil)
//      } else {
//        self.dataModel.dubyImage = ["name": photoFile.name, "__type": "File", "url": photoFile.url!]
//        self.dataModel.dubyVideo = ["name": vidFile.name, "__type": "File", "url": vidFile.url!]
//        self.imageCell.setDubyData(photo, videoURL: vidFile.url!)
//      }
//      
//      self.updateLightUpButtonStatus()
//    })
    
    vidFile.saveInBackgroundWithBlock { (saveA, errorA) -> Void in
      photoFile.saveInBackgroundWithBlock({ (saveB, errorB) -> Void in
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        if (errorA != nil || errorB != nil || saveA == false || saveB == false) {
          self.imageCell.setDubyData(nil, videoURL: nil)
        } else {
          self.dataModel.dubyImage = ["name": photoFile.name, "__type": "File", "url": photoFile.url!]
          self.dataModel.dubyVideo = ["name": vidFile.name, "__type": "File", "url": vidFile.url!]
          self.imageCell.setDubyData(photo, videoURL: vidFile.url!)
        }
        
        self.updateLightUpButtonStatus()
      })
    }
    
  }
}
