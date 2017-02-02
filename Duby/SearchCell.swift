//
//  SearchCell.swift
//  Duby
//
//  Created by Harsh Damania on 2/6/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

protocol SearchCellDelegate: class {
  func searchCellDidTapUser(cellIndex: Int)
  func searchCellDidTapPassers(duby: Duby)
}

class SearchCell: UICollectionViewCell {
  
  
  
  @IBOutlet weak var dubyImageView: UIImageView!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var locationLabel: UILabel!
  @IBOutlet weak var sharesCount: UIButton!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var commentsCount: UIButton!
  @IBOutlet weak var cameraImageView: UIImageView!
  
  var duby: Duby!
  var index: Int!
  
  weak var delegate: SearchCellDelegate?
  
  override func awakeFromNib() {
    contentView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
    
    layer.cornerRadius = 3.0
    
    profileImageView.layer.cornerRadius = CGRectGetWidth(profileImageView.frame)/2
    profileImageView.layer.borderWidth = 1
    profileImageView.layer.borderColor = UIColor.dubyGreen().CGColor
    profileImageView.layer.masksToBounds = true
    
    profileImageView.userInteractionEnabled = true
    profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userProfileTapped"))
    
    usernameLabel.userInteractionEnabled = true
    usernameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userProfileTapped"))
    
    sharesCount.imageView?.contentMode = UIViewContentMode.ScaleAspectFit;
    sharesCount.setImage(UIImage(named: "users")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
    sharesCount.tintColor = UIColor.blackColor()
    
    commentsCount.setImage(UIImage(named: "icon-comment")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
    commentsCount.tintColor = UIColor.blackColor()
    commentsCount.userInteractionEnabled = false
    
    dubyImageView.backgroundColor = UIColor.dubyLightGray()
  }
  
  func setDubyData(dubyData: Duby) {
    duby = dubyData
    
    dubyImageView.sd_cancelCurrentImageLoad()
    dubyImageView.image = nil
    descriptionLabel.text = ""
    
    if duby.imageURL != "" {
      descriptionLabel.text = ""
      dubyImageView.setImageWithURLString(duby.imageURL, placeholderImage: UIImage.dubyPlaceholder(), completion: nil)
      //println(duby)
      cameraImageView.hidden = duby.videoURL == ""
    } else {
      descriptionLabel.text = duby.description
      cameraImageView.hidden = true
    }
    
    profileImageView.setImageWithURLString(duby.createdBy.profilePicURL, placeholderImage: UIImage.userPlaceholder(), completion: nil)
    
    sharesCount.setTitle("\(Constants.getCountText(duby.usersSharedToCount))", forState: .Normal)
    commentsCount.setTitle("\(Constants.getCountText(duby.commentCount))", forState: .Normal)
    
    if duby.createdBy.username.characters.count > 0 {
      usernameLabel.text = "@\(duby.createdBy.username)"
    } else {
      usernameLabel.text = ""
    }
    
    locationLabel.text = duby.location
  }
  
  func userProfileTapped() {
    delegate?.searchCellDidTapUser(index)
  }
  
  @IBAction func shareCountPressed(sender: AnyObject) {
    delegate?.searchCellDidTapPassers(duby)
  }
  
  @IBAction func commentsCountPressed(sender: AnyObject) {
  }
}
