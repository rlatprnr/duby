//
//  PMViewVC.swift
//  Duby
//
//  Created by Aziz on 2015-08-01.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit
import AVFoundation
 

import MediaPlayer

@objc protocol PMViewVCDelegate {
  optional func viewVCDidFinish(viewVC: PMViewVC);
}


class PMViewVC: UIViewController {
  var notification: DubyNotification!
  private weak var delegate: PMViewVCDelegate?
  private var mediaPlayer: MPMoviePlayerController?
  
  private var timer: NSTimer?
  private var timeElapsed: Int = 0
  private var timeout: Int!
  
  @IBOutlet private var imageView: UIImageView!
  @IBOutlet private var labelConstraint: NSLayoutConstraint!
  @IBOutlet private var label: UILabel!
  @IBOutlet private var timeoutLabel: UILabel!
  @IBOutlet private var timeoutButton: UIButton!
  
  
  required init(notification: DubyNotification, delegate: PMViewVCDelegate) {
    self.notification = notification
    self.delegate = delegate
    super.init(nibName: "PMViewVC", bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func viewWillAppear(animated: Bool) {
    UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
  }
  
  override func viewWillDisappear(animated: Bool) {
    UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
    UIApplication.sharedApplication().statusBarStyle = .LightContent
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.label.hidden = true
    
    let tracker = GAI.sharedInstance().defaultTracker
    tracker.set(kGAIScreenName, value: "PMViewVC")
    tracker.set("event", value: "pm_viewed")
    tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject: AnyObject])
    
    let privateMessage = PFObject(className: "PrivateMessage");
    privateMessage.objectId = notification.pmId!
    privateMessage.fetchInBackgroundWithBlock{ (obj, error) -> Void in
      if let pm = obj {
        
        DubyDatabase.markPMSeen(self.notification.objectId)
        
        //                var note = PFObject(className: "Notification")
        //                note.objectId = self.notification.objectId;
        //
        //                note.deleteInBackgroundWithBlock(nil)
        
        let contentURL = (obj!["file"] as! PFFile).url!
        
        if (pm["isVideo"] as! Bool == true) {
          self.mediaPlayer = MPMoviePlayerController(contentURL: NSURL(string: contentURL))
          self.mediaPlayer?.view.frame = self.imageView.frame
          self.mediaPlayer?.controlStyle = MPMovieControlStyle.None//= MPMovieplayer
          self.mediaPlayer?.repeatMode = MPMovieRepeatMode.None
          self.mediaPlayer?.prepareToPlay()
          self.mediaPlayer?.scalingMode = .AspectFill
          self.view.insertSubview(self.mediaPlayer!.view, aboveSubview: self.imageView)
          self.mediaPlayer?.play()
          
          self.timeoutButton.hidden = true
          self.timeoutLabel.hidden = true
          
          self.label.hidden = true
          
          NSNotificationCenter.defaultCenter().addObserver(self, selector: "done", name: MPMoviePlayerPlaybackDidFinishNotification, object: nil)
        } else {
          MBProgressHUD.showHUDAddedTo(self.view, animated: true)
          self.imageView.sd_setImageWithURL(NSURL(string: contentURL), completed: { (image, error, type, url) -> Void in
            if (error == nil) {
              self.timeout = pm["to"] as! Int
              if let caption = pm["caption"] as? String {
                self.label.text = caption
                self.label.hidden = false
              } else {
                self.label.hidden = true
              }
              
              self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "secondUp", userInfo: nil, repeats: true)
            } else {
              print(error)
              self.done()
            }
            MBProgressHUD.hideHUDForView(self.view, animated: true)
          })
        }
      } else {
        print(error)
        self.done()
      }
    }
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    done()
  }
  
  func secondUp() {
    timeElapsed++
    if (timeElapsed >= timeout) {
      done()
    }
    self.timeoutLabel.text = "\(timeout - timeElapsed)"
  }
  
  @IBAction func done() {
    self.timer?.invalidate()
    self.timer = nil
    self.delegate?.viewVCDidFinish?(self)
    
    mediaPlayer?.stop()
    mediaPlayer?.view.removeFromSuperview()
    mediaPlayer = nil
    
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
}