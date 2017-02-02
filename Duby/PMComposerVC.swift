//
//  PMComposerVC.swift
//  Duby
//
//  Created by Aziz on 2015-08-01.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
 

@objc protocol PMComposeVCDelegate {
  optional func composeVCDidFinish(composeVC: PMComposerVC);
}


class PMComposerVC: UIViewController, UITextFieldDelegate, PMSendVCDelegate {
  private var image: UIImage!
  private var videoURL: NSURL!
  private var mediaPlayer: MPMoviePlayerController?
  private var toUser: DubyUser?
  private var timeout = "10"
  
  private weak var delegate: PMComposeVCDelegate?
  
  @IBOutlet private var imageView: UIImageView!
  @IBOutlet private var labelConstraint: NSLayoutConstraint!
  @IBOutlet private var label: UILabel!
  @IBOutlet private var timeoutLabel: UILabel!
  @IBOutlet private var captionButton: UIButton!
  @IBOutlet private var timeoutButton: UIButton!
  
  var sendVC: PMSendVC?
  
  
  required init(image: UIImage, toUser: DubyUser?, delegate: PMComposeVCDelegate) {
    self.image = image;
    self.toUser = toUser
    self.delegate = delegate
    super.init(nibName: "PMComposerVC", bundle: nil)
  }
  
  required init(videoURL: NSURL, toUser: DubyUser?, delegate: PMComposeVCDelegate) {
    self.videoURL = videoURL;
    self.toUser = toUser
    self.delegate = delegate
    super.init(nibName: "PMComposerVC", bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    label.hidden = true
    label.text = nil
    if (videoURL == nil) {
      imageView.image = image
    } else {
      mediaPlayer = MPMoviePlayerController(contentURL: videoURL)
      mediaPlayer?.view.frame = imageView.frame
      mediaPlayer?.controlStyle = MPMovieControlStyle.None//= MPMovieplayer
      mediaPlayer?.repeatMode = MPMovieRepeatMode.One
      mediaPlayer?.prepareToPlay()
      mediaPlayer?.scalingMode = .AspectFill
      self.view.insertSubview(mediaPlayer!.view, aboveSubview: imageView)
      mediaPlayer?.play()
      
      captionButton.hidden = true
      timeoutButton.hidden = true
      timeoutLabel.hidden = true
    }
    
    if (toUser == nil) {
      sendVC = PMSendVC(params: nil, delegate: self)
      sendVC?.search()
    }
    
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if(videoURL != nil) {
      mediaPlayer?.view.frame = imageView.frame
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
  }
  
  override func viewWillDisappear(animated: Bool) {
    UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
    UIApplication.sharedApplication().statusBarStyle = .LightContent
  }
  
  @IBAction func edit() {
    if (label.hidden) {
      label.hidden = false
      
      let alert = UIAlertController(title: "Enter Caption", message: "", preferredStyle: UIAlertControllerStyle.Alert)
      alert.addTextFieldWithConfigurationHandler({ (tf) -> Void in
        tf.delegate = self;
      })
      alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler:{ (UIAlertAction)in
        let textField = alert.textFields![0] 
        self.label.text = textField.text
      }));
      self.presentViewController(alert, animated: true, completion:nil)
      
    } else {
      label.hidden = true
    }
  }
  
  @IBAction func timer() {
    ActionSheetStringPicker.showPickerWithTitle("Set Timeout", rows: ["1","2","3","4","5","6","7", "9", "10", "11", "12"], initialSelection: 6, doneBlock: { (picker, index, value) -> Void in
      self.timeout = value as! String
      self.timeoutLabel.text = self.timeout
      }, cancelBlock: nil, origin: self.view)
  }
  
  @IBAction func pass(button: UIButton!) {
    MBProgressHUD.showHUDAddedTo(view, animated: true)
    var file : PFFile!
    if (videoURL != nil) {
      file = try! PFFile(name: "vid.m4v", contentsAtPath: videoURL.path!);
    } else {
      file = PFFile(name: "pm.jpg", data: UIImageJPEGRepresentation(image, 0.1)!);
    }
    
    button.enabled = false
    file.saveInBackgroundWithBlock { (success, error) -> Void in
      if (error == nil) {
        let pmFile = PFObject(className: "PMFile");
        pmFile["file"] = file;
        
        pmFile.saveInBackgroundWithBlock({ (success, error) -> Void in
          if (error == nil) {
            var params: [NSObject:AnyObject] = ["pmFileId": pmFile.objectId!, "to": Int(self.timeout)!];
            
            if (self.label.text != nil) {
              params["caption"] = self.label.text
            }
            params["isVideo"] = self.videoURL != nil
            
            if let user = self.toUser {
              params["toUserId"] = user.objectId
              PFCloud.callFunctionInBackground("sendPM", withParameters: params, block: { (resp, error) -> Void in
                if (error == nil) {
                  MBProgressHUD.hideHUDForView(self.view, animated: true);
                  self.delegate?.composeVCDidFinish?(self)
                  
                  
                  let tracker = GAI.sharedInstance().defaultTracker
                  tracker.set(kGAIScreenName, value: "PMComposerVC")
                  tracker.set("event", value: "pm_created")
                  tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject: AnyObject])
                  
                  button.enabled = true
                  
                } else {
                  MBProgressHUD.hideHUDForView(self.view, animated: true);
                  print(error);
                  button.enabled = true
                }
              })
            } else {
              self.sendVC?.params = params
              let navVC = DubyNavVC(rootViewController: self.sendVC!)
              self.presentViewController(navVC, animated: true, completion: nil)
              button.enabled = true
            }
          } else {
            MBProgressHUD.hideHUDForView(self.view, animated: true);
            print(error);
            button.enabled = true
          }
        })
      } else {
        MBProgressHUD.hideHUDForView(self.view, animated: true);
        print(error);
        button.enabled = true
      }
    }
  }
  
  @IBAction func cancel() {
    mediaPlayer?.stop()
    mediaPlayer?.view.removeFromSuperview()
    mediaPlayer = nil
    delegate?.composeVCDidFinish?(self)
  }
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    let length = textField.text!.utf16.count + string.utf16.count - range.length
    
    return length <= 75
    
  }
  
  func sendVCDidComplete() {
    self.delegate?.composeVCDidFinish?(self)
  }
  
}
