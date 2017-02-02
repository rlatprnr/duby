//
//  UserCell.swift
//  Duby
//
//  Created by Aziz on 2015-05-28.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

protocol UserCellDelegate: class {
  func userCellDidTapUser(user: DubyUser)
  func userCellDidTapBoost(user: DubyUser)
}


//if user.boost != nil {
//  delegate?.showMessage!("This user has been boosted! They can now share to \(user.influence + user.boost!) people.")
//} else {
//  delegate?.showMessage!("Every time this user shares a Duby it goes to \(user.influence) people.")
//}

class UserCell: UICollectionViewCell {
  
  @IBOutlet weak var userImageView: UIImageView!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var locationLabel: UILabel!
  @IBOutlet weak var influenceButton: UIButton!
  @IBOutlet weak var reachButton: UIButton!
  
  var user: DubyUser!
  var index: Int!
  
  weak var delegate: UserCellDelegate?
  
  override func awakeFromNib() {
    contentView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
    
    layer.cornerRadius = 3.0
    
    usernameLabel.userInteractionEnabled = true
    usernameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userProfileTapped"))
    
    reachButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit;
    reachButton.setImage(UIImage(named: "follow")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
    reachButton.tintColor = UIColor.blackColor()
    
    influenceButton.setImage(UIImage(named: "usersSmall")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
    influenceButton.tintColor = UIColor.blackColor()
    influenceButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit;
    //        influenceButton.userInteractionEnabled = false
    //        influenceButton.addTarget(self, action: "commentsCountPressed:", forControlEvents: UIControlEvents.TouchUpInside)
    
    userImageView.backgroundColor = UIColor.dubyLightGray()
  }
  
  func setUserData(user: DubyUser) {
    self.user = user
    
    userImageView.sd_cancelCurrentImageLoad()
    userImageView.image = nil
    
    if user.profilePicURL != "" {
      userImageView.setImageWithURLString(user.profilePicURL, placeholderImage: UIImage.userPlaceholder(), completion: nil)
      //println(duby)
    } else {
      userImageView.image = UIImage.userPlaceholder()
    }
    
    reachButton.setTitle("\(Constants.getCountText(user.followersCount))", forState: .Normal)
    influenceButton.setTitle("\(Constants.getCountText(user.influence))", forState: .Normal)
    
    usernameLabel.text = "@\(user.username)"
    locationLabel.text = user.location
    
    
    let infString = NSMutableAttributedString(string: "\(user.influence)")
    
    if user.boost != nil {
      let boostString = NSAttributedString(string: " +\(user.boost!)", attributes: [NSForegroundColorAttributeName: UIColor.redColor(),
        NSFontAttributeName: UIFont.systemFontOfSize(12),
        NSBaselineOffsetAttributeName: 5])
      
      infString.appendAttributedString(boostString)
    }
    influenceButton.setAttributedTitle(infString, forState: UIControlState.Normal)
  }
  
  func userProfileTapped() {
    delegate?.userCellDidTapUser(user)
  }
  
  @IBAction func shareCountPressed(sender: AnyObject) {
    delegate?.userCellDidTapUser(user)
  }
  
  @IBAction func influencePressed() {
    delegate?.userCellDidTapBoost(user)
  }
}
