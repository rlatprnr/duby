//
//  ProfileHeaderView.swift
//  Duby
//
//  Created by Harsh Damania on 2/2/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit
 

@objc protocol ProfileHeaderProtocol {
  func performSegue(segueIdentifier: String)
  func showCoachMarks()
  func updatePic()
  func showHashtagVC(hashtag: String)
  func showProfileVC(username: String)
  func showFollowers()
  func privateMessage()
  func showInfo();
  func inviteFriends();
  func didFollow()
}

class ProfileHeaderView: UICollectionReusableView, TTTAttributedLabelDelegate {
  
  @IBOutlet weak var profileImageButton: UIButton!
  @IBOutlet weak var locationLabel: UILabel!
  @IBOutlet weak var descriptionLabel: TTTAttributedLabel!
  @IBOutlet weak var followButtonContainerView: UIView!
  @IBOutlet weak var dubyMeButtonContainerView: UIView!
  @IBOutlet weak var inviteButtonContainerView: UIView!
  @IBOutlet weak var followButton: UIButton!
  @IBOutlet weak var influenceButton: UIButton!
  @IBOutlet weak var followersButton: UIButton!
  @IBOutlet weak var inviteButton: UIButton!
  @IBOutlet weak var moreButton: UIButton!
  @IBOutlet weak var editProfileButton: UIButton!
  
  private var user: DubyUser!
//  private var profileModel: ProfileCollectionModel!
  
  var showEdit = false
  var delegate: ProfileHeaderProtocol?
  
  var following: Int?
  
  private var tapGesture: UITapGestureRecognizer!
  
  override func awakeFromNib() {
    profileImageButton.layer.cornerRadius = CGRectGetHeight(profileImageButton.frame)/2
    profileImageButton.layer.borderWidth = 2.0
    profileImageButton.layer.borderColor = UIColor.dubyGreen().CGColor
    profileImageButton.layer.masksToBounds = true
    
    followButtonContainerView.layer.cornerRadius = CGRectGetHeight(followButtonContainerView.frame)/2
    followButtonContainerView.layer.borderWidth = 1.0
    followButtonContainerView.layer.borderColor = UIColor.lightGrayColor().CGColor
    followButtonContainerView.layer.masksToBounds = true
    
    dubyMeButtonContainerView.layer.cornerRadius = CGRectGetHeight(followButtonContainerView.frame)/2
    dubyMeButtonContainerView.layer.borderWidth = 1.0
    dubyMeButtonContainerView.layer.borderColor = UIColor.lightGrayColor().CGColor
    dubyMeButtonContainerView.layer.masksToBounds = true
    
    inviteButtonContainerView.layer.cornerRadius = CGRectGetHeight(followButtonContainerView.frame)/2
    inviteButtonContainerView.layer.borderWidth = 1.0
    inviteButtonContainerView.layer.borderColor = UIColor.lightGrayColor().CGColor
    inviteButtonContainerView.layer.masksToBounds = true
  }
  
  // set all the data
  func setInitialData(user: DubyUser) {
    self.user = user
    locationLabel.text = user.location
    
    if user == DubyUser.currentUser {
      followButtonContainerView.hidden = true
      dubyMeButtonContainerView.hidden = true
      inviteButtonContainerView.hidden = false
      moreButton.hidden = true
      editProfileButton.hidden = false
    } else {
      followButtonContainerView.hidden = false
      dubyMeButtonContainerView.hidden = false
      inviteButtonContainerView.hidden = true
      moreButton.hidden = false
      editProfileButton.hidden = true
      updateForFollow()
    }
    
    
    descriptionLabel.linkAttributes = [kCTForegroundColorAttributeName: UIColor.dubyGreen()]
    //        descriptionLabel.linkAttributes
    //descriptionLabel.enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue;
    descriptionLabel.delegate = self;
    let bio = user.biography
    descriptionLabel.text = bio
    
    let entities = TwitterText.entitiesInText(bio)
    for e in entities {
      let entity = e as! TwitterTextEntity
      let range = entity.range
      let string = (bio as NSString!).substringWithRange(range)
      descriptionLabel.addLinkToURL(NSURL(string: string), withRange: range)
    }
    
    updateProfilePic()
    
    
    let infString = NSMutableAttributedString(string: "\(user.influence)", attributes: [NSForegroundColorAttributeName: UIColor.dubyBlue()])
    
    if user.boost != nil {
      let boostString = NSAttributedString(string: " +\(user.boost!)", attributes: [NSForegroundColorAttributeName: UIColor.redColor(),
        NSFontAttributeName: UIFont.systemFontOfSize(12),
        NSBaselineOffsetAttributeName: 5])
      
      infString.appendAttributedString(boostString)
    }
    
    influenceButton.setAttributedTitle(infString, forState: UIControlState.Normal)
    
    
    followersButton.setTitle("\(user.followersCount)", forState: UIControlState.Normal)
  }
  
  func updateForFollow() {
    PFCloud.callFunctionInBackground("amFollowing", withParameters: ["followingId": user.objectId]) { (obj, error) -> Void in
      if let following = obj as? Int {
        if following == 0 {
          self.followButton.setTitle("+ Follow", forState: UIControlState.Normal)
        } else {
          self.followButton.setTitle("✓ Following", forState: UIControlState.Normal)
        }
        self.following = following
      }
    }
  }
  
  // update to new profile pic
  func updateProfilePic() {
    profileImageButton.sd_setImageWithURL(NSURL(string: user.profilePicURL), forState: UIControlState.Normal, placeholderImage: user == DubyUser.currentUser ? UIImage(named: "edit_user_ph") : UIImage.userPlaceholder()) { (image, error, cacheType, url) -> Void in
      if error == nil {
        self.user?.profilePic = image
      } else {
        NSLog("ERROR displaying profile picture: %@", error)
      }
    }
  }
  
  func statsViewTapped() {
    delegate?.showCoachMarks()
  }
  
  @IBAction func follow(sender: AnyObject) {
    if following != nil {
      MBProgressHUD.showHUDAddedTo(self, animated: true)
      if following == 0 {
        
        
        PFCloud.callFunctionInBackground("follow", withParameters: ["toFollowId": user.objectId])
          { (obj, error) -> Void in
            self.user.followersCount++
            self.updateForFollow()
            MBProgressHUD.hideHUDForView(self, animated: true)
            self.delegate?.didFollow()
            
            PFUser.currentUser()?.fetchInBackground()
        }
        
      } else {
        PFCloud.callFunctionInBackground("unfollow", withParameters: ["followingId": user.objectId])
          { (obj, error) -> Void in
            self.user.followersCount--
            self.updateForFollow()
            MBProgressHUD.hideHUDForView(self, animated: true)
        }
      }
    } else {
    }
  }
  
  @IBAction func inviteFriends() {
    delegate?.inviteFriends()
  }
  
  @IBAction func displayProfileInFullScreen(sender: AnyObject) {
    delegate?.updatePic()
  }
  
  @IBAction func showFollowers() {
    delegate?.showFollowers()
  }
  
  @IBAction func showInfo() {
    delegate?.showInfo()
  }
  
  @IBAction func dubyMe() {
    delegate?.privateMessage()
  }
  
  func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
    var string = url.absoluteString
    if string.rangeOfString("#") != nil {
      delegate?.showHashtagVC(String((string).characters.dropFirst()))
    } else if string.rangeOfString("@") != nil {
      delegate?.showProfileVC(String((string).characters.dropFirst()))
    } else {
      if (string.hasPrefix("http://") == true) {
        UIApplication.sharedApplication().openURL(url)
      } else {
        //println("http://\(string!)");
        UIApplication.sharedApplication().openURL(NSURL(string: "http://\(string)")!);
      }
    }
  }
}
