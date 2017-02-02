//
//  EditProfilePicCell.swift
//  Duby
//
//  Created by Harsh Damania on 2/3/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

class EditProfilePicCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        
        profileImageView.layer.cornerRadius = CGRectGetHeight(profileImageView.frame)/2
        profileImageView.layer.borderWidth = 1.0
        profileImageView.layer.borderColor = UIColor.dubyGreen().CGColor
        profileImageView.layer.masksToBounds = true
    }
    
    func setCellData() {
        
        if DubyUser.currentUser.profilePic != nil {
            profileImageView.image = DubyUser.currentUser.profilePic
        } else {
            profileImageView.setImageWithURLString(DubyUser.currentUser.profilePicURL, placeholderImage: UIImage.userPlaceholder(), completion: nil)
        }
        
        
    }
}
