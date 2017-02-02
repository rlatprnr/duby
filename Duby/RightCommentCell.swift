//
//  RightCommentCell.swift
//  Duby
//
//  Created by Wilson on 1/7/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit


class RightCommentCell: UITableViewCell, TTTAttributedLabelDelegate {
  
  @IBOutlet weak var userAvatarImageView: UIImageView!
  @IBOutlet weak var commentBackgroundView: UIView!
  @IBOutlet weak var commentLabel: TTTAttributedLabel!
  
  @IBOutlet weak var commentBackgroundViewWidthConstraint: NSLayoutConstraint!
  @IBOutlet weak var commentBackgroundViewHeightConstraint: NSLayoutConstraint!
  
  var commentData: DubyComment!
  weak var delegate: CommentCellDelegate?
  var index: Int?
  
  override func awakeFromNib() {
    contentView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
    
    commentBackgroundView.layer.cornerRadius = 5.0
    commentBackgroundView.clipsToBounds = true
    
    userAvatarImageView.image = UIImage.userPlaceholder()
    userAvatarImageView.layer.cornerRadius = CGRectGetHeight(userAvatarImageView.frame) / 2
    userAvatarImageView.layer.borderColor = UIColor.whiteColor().CGColor
    userAvatarImageView.layer.borderWidth = 1.0
    userAvatarImageView.layer.masksToBounds = true
    
    userAvatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userTapped"))
    userAvatarImageView.userInteractionEnabled = true
    
    contentView.backgroundColor = UIColor.clearColor()
    backgroundColor = UIColor.clearColor()
  }
  
  func setData(comment: DubyComment, size: CGSize) {
    commentData = comment
    
    let text = comment.message
    commentLabel.text = text
    
    commentLabel.linkAttributes = [kCTForegroundColorAttributeName: UIColor.dubyGreen()]
    //commentLabel.enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue;
    commentLabel.delegate = self;
    commentLabel.text = text
    
    let entities = TwitterText.entitiesInText(text)
    for e in entities {
      let entity = e as! TwitterTextEntity
      let range = entity.range
      let string = (text as NSString!).substringWithRange(range)
      //println(string)
      commentLabel.addLinkToURL(NSURL(string: string), withRange: range)
    }
    
    
    
    userAvatarImageView.setImageWithURLString(comment.sender.profilePicURL, placeholderImage: UIImage.userPlaceholder(), completion: nil)
    
    commentBackgroundViewHeightConstraint.constant = size.height
    commentBackgroundViewWidthConstraint.constant = size.width
  }
  
  func userTapped() {
    delegate?.commentCellDidTapUser(commentData.sender)
  }
  
  func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
    let string = url.absoluteString
    if string.rangeOfString("#") != nil {
      delegate?.commentCellDidTapHashtag(String((string).characters.dropFirst()))
    } else if string.rangeOfString("@") != nil {
      delegate?.commentCellDidTapUsername(String((string).characters.dropFirst()))
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
