//
//  PasserCell.swift
//  Duby
//
//  Created by Aziz on 2015-08-23.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

protocol PasserCellDelegate : class {
  func passerCellDidFollow(cell: PasserCell, user: DubyUser)
}

class PasserCell: UITableViewCell {
  @IBOutlet var usernameLabel: UILabel!
  @IBOutlet var userImageView: UIImageView!
  @IBOutlet var followButton: UIButton!
  @IBOutlet var influenceLabel: UILabel!
  @IBOutlet var locationLabel: UILabel!
  
  var user: DubyUser!
  weak var delegate: PasserCellDelegate!
  
  override func awakeFromNib() {
    super.awakeFromNib()

    followButton.layer.cornerRadius = CGRectGetHeight(followButton.frame)/2
    
    userImageView.layer.cornerRadius = CGRectGetWidth(userImageView.frame)/2
    userImageView.layer.borderWidth = 1
    userImageView.layer.borderColor = UIColor.dubyGreen().CGColor
    userImageView.layer.masksToBounds = true
  }
  
  func updateCell(user: DubyUser, following: Bool, delegate: PasserCellDelegate?) {
    self.user = user
    self.delegate = delegate
    
    usernameLabel.text = user.username
    locationLabel.text = user.location
    influenceLabel.text = "\(user.influence)"
    
    userImageView.setImageWithURLString(user.profilePicURL, placeholderImage: UIImage.userPlaceholder(), completion: nil)
    
    followButton.hidden = user.objectId == DubyUser.currentUser.objectId
    
    if (following) {
      followButton.setTitle("✓  Following", forState: .Normal)
    } else {
      followButton.setTitle("+  Follow", forState: .Normal)
    }
  }
  
  @IBAction func follow() {
    delegate?.passerCellDidFollow(self, user:user)
  }
}