//
//  NotificationCell.swift
//  Duby
//
//  Created by Anurag Kamasamudram on 3/18/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

protocol NotificationCellDelegate: class {
  func notificationCellDidTapUserWithId(userId: String)
}

class NotificationCell: UITableViewCell, UITextViewDelegate {
  
  @IBOutlet weak var profilePicture: UIImageView!
  @IBOutlet weak var notificationLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var dubyCover: UIImageView!
  @IBOutlet weak var notificationTextView: UITextView!
  @IBOutlet weak var messageToDubyImagePaddingConstraint: NSLayoutConstraint!
  @IBOutlet weak var dubyImageWidthConstraint: NSLayoutConstraint!
  
  var delegate: NotificationCellDelegate?
  private var notification: DubyNotification!
  
  static func heightForNotification(notification: DubyNotification) -> CGFloat {
    let defaultCellHeight: CGFloat = 60
    let defaultTextViewHeight: CGFloat = 17
    var cellHeight: CGFloat = 60
    
    let attributedMessage = notification.attributedMessage
    
    var textViewWidth = CGRectGetWidth(UIScreen.mainScreen().bounds) - 2*40 - 4*8 // 40=username, duby width. 8=paddings around places
    textViewWidth += 8 + 40
    
    let messageHeight = attributedMessage.boundingRectWithSize(CGSize(width: textViewWidth, height: 54), options: [NSStringDrawingOptions.UsesFontLeading, NSStringDrawingOptions.UsesLineFragmentOrigin], context: nil).size.height
    
    if messageHeight < defaultTextViewHeight {
      return cellHeight
    } else {
      cellHeight = defaultCellHeight + (messageHeight - defaultTextViewHeight)
    }
    
    return ceil(cellHeight)
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    // Initialization code
    profilePicture.layer.cornerRadius = CGRectGetWidth(profilePicture.bounds)/2
    profilePicture.clipsToBounds = true
    profilePicture.layer.borderWidth = 1
    profilePicture.layer.borderColor = UIColor.dubyGreen().CGColor
    
    notificationTextView.textContainerInset = UIEdgeInsetsZero
    notificationTextView.contentInset = UIEdgeInsetsZero
    notificationTextView.scrollEnabled = false
    notificationTextView.font = UIFont.openSansSemiBold(12)
    notificationTextView.backgroundColor = UIColor.clearColor()
    notificationTextView.textContainer.lineFragmentPadding = 0
    notificationTextView.editable = false
  }
  
  func setNotification(notification: DubyNotification) {
    self.notification = notification
    
    timeLabel.text = notification.createdAt?.timeAgo()
    
    //        if notification.type == .MessageSeen {
    //            timeLabel.text = timeLabel.text! + " (Tap to reply)"
    //        }
    
    profilePicture.image = nil;
    if let url = notification.primaryPhotoURL {
      profilePicture.setImageWithURLString(url, placeholderImage: UIImage.userPlaceholder(), completion: nil)
    } else {
      profilePicture.image = UIImage.userPlaceholder();
    }
    
    // show duby image for user if update or share count type
    if notification.type == .Update || notification.type == .ShareCount || notification.type == .Featured {
      profilePicture.image = UIImage(named: "icon-duby")
    }
    
    
    
    dubyCover.image = nil
    dubyCover.contentMode = UIViewContentMode.ScaleAspectFill
    if let url = notification.secondaryPhotoURL {
      dubyImageWidthConstraint.constant = 40
      messageToDubyImagePaddingConstraint.constant = 8
      
      dubyCover.setImageWithURLString(url, placeholderImage: UIImage.dubyPlaceholder(), completion: nil)
    } else if notification.type == .Message {
      dubyCover.image = UIImage(named: "icon-arrow")!
      dubyCover.contentMode = UIViewContentMode.ScaleAspectFit
      dubyImageWidthConstraint.constant = 40
      messageToDubyImagePaddingConstraint.constant = 8
    } else {
      dubyImageWidthConstraint.constant = 0
      messageToDubyImagePaddingConstraint.constant = 0
    }
    
    
    
    
    if !notification.seen! {
      contentView.layer.backgroundColor = UIColor(white: 1, alpha: 0.2).CGColor
      NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: "changeColor", userInfo: nil, repeats: false)
    } else {
      contentView.layer.backgroundColor = UIColor.clearColor().CGColor
    }
    
    // adjust text view properties for commented type
    notificationTextView.attributedText = notification.attributedMessage
    notificationTextView.userInteractionEnabled = false
    if notification.type == .Commented {
      notificationTextView.linkTextAttributes = [NSFontAttributeName: UIFont.openSansSemiBold(13)]
      notificationTextView.delegate = self
      notificationTextView.userInteractionEnabled = true
      
      profilePicture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "fromUserProfileSelected"))
      profilePicture.userInteractionEnabled = true
    }
    
    contentView.layoutIfNeeded()
  }
  
  func changeColor() { // Go from unseen gray to white
    UIView.animateWithDuration(1, animations: { () -> Void in
      self.contentView.layer.backgroundColor = UIColor.clearColor().CGColor
      self.notification.seen = true
    })
  }
  
  func fromUserProfileSelected() {
    //        delegate?.toProfileVC?(notification.fromUser!)
  }
  
  @IBAction func toProfile() {
    if let fromUserId = notification.fromUserId {
      delegate?.notificationCellDidTapUserWithId(fromUserId)
    }
  }
  
  
  //MARK: textview delegate
  
  func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
    //        var scheme = URL.scheme
    //        if URL.scheme == "user" { // user selected
    //            var host = URL.host
    //            if host == notification.fromUser!.objectId {
    //                fromUserProfileSelected()
    //            } else { // since the fromUser user was not selected, it has to be the duby createdBy user that was selected
    //                delegate?.toProfileVC?(notification.duby!.createdBy)
    //            }
    //        }
    
    return false
  }
  
  /// WE DO NOT USE THIS ANYMORE
  func populateData(data: Notification) {
    
    /* Display Alert */
    notificationTextView.text = data.alert
    
    /* Display time */
    timeLabel.text = data.postedTime?.timeAgo()
    
    /* Display User profile picture */
    if let image = data.user.profilePic {
      profilePicture.image = image
    } else if !data.user.profilePicURL.isEmpty {
      profilePicture.sd_setImageWithURL(NSURL(string: data.user.profilePicURL))
    }
    
    
    /* Display Duby Cover */
    if data.duby.imageURL.characters.count > 0 {
      dubyCover.sd_setImageWithURL(NSURL(string: data.duby.imageURL))
    }
  }
}
