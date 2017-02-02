//
//  DubyInfoCell.swift
//  Duby
//
//  Created by Harsh Damania on 1/23/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

protocol DubyInfoCellDelegate: class {
  func infoCellDidTapShare()
  func infoCellDidTapUser(user: DubyUser)
  func infoCellDidTapMore()
}

class DubyInfoCell: UITableViewCell {
  
  @IBOutlet weak private var posterInfoLabel: UILabel!
  @IBOutlet weak private var posterImageView: UIImageView!
  @IBOutlet weak private var reportButton: UIButton!
  @IBOutlet weak var reachButton: UIButton!
  
  @IBOutlet weak private var infoLabelWidthConstraint: NSLayoutConstraint!
  
  private var padding: CGFloat = 8
  private var avatarSize: CGFloat = 26
  
  weak var delegate: DubyInfoCellDelegate?
  
  var selectedDuby: Duby! {
    didSet {
      if selectedDuby.createdBy.username.characters.count > 0 {
        posterInfoLabel.text = "@\(selectedDuby.createdBy.username)"
      } else {
        posterInfoLabel.text = ""
      }
      
      //            var width = Constants.getWidthForText(posterInfoLabel.text!, font: posterInfoLabel.font)
      //            let maxWidth = CGRectGetWidth(UIScreen.mainScreen().bounds) - avatarSize - 5*padding - 2*40 // padding on either side of screen and between image and text & either button and image/text + 40px width for comment and report button
      //            width = width > maxWidth ? maxWidth : width
      //            infoLabelWidthConstraint.constant = width
      
      posterImageView.setImageWithURLString(selectedDuby.createdBy.profilePicURL, placeholderImage: UIImage.userPlaceholder(), completion: nil)
      
      //var count = tableModel.commentModel.commentCount
      reachButton.setTitle("\(Constants.getCountText(selectedDuby.usersSharedToCount))", forState: .Normal)
    }
  }
  
  var tableModel: DetailsTableViewModel! {
    didSet {
      reportButton.enabled = tableModel.canDelete || tableModel.canReport
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    backgroundColor = UIColor.clearColor()
    contentView.backgroundColor = UIColor.clearColor()
    contentView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth] // because, screw iOS 7
    
    posterImageView.layer.borderColor = UIColor.whiteColor().CGColor
    posterImageView.layer.borderWidth = 1.0
    posterImageView.layer.cornerRadius = CGRectGetWidth(posterImageView.frame)/2
    posterImageView.layer.masksToBounds = true
    
    reportButton.tintColor = UIColor.whiteColor()
    reportButton.setImage(UIImage(named: "dots")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
    reportButton.imageView?.contentMode = .ScaleAspectFit
  }
  
  @IBAction func reportPressed(sender: AnyObject) {
    delegate?.infoCellDidTapMore()
  }
  
  @IBAction func sharePressed(sender: AnyObject) {
    delegate?.infoCellDidTapShare()
  }
  
  @IBAction func userPressed() {
    delegate?.infoCellDidTapUser(selectedDuby.createdBy)
  }
  
}
