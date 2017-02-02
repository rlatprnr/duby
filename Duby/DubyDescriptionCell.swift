//
//  DubyDescriptionCell.swift
//  Duby
//
//  Created by Harsh Damania on 1/23/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

protocol DubyDescriptionCellDelegate: class {
  func descriptionCellDidTapHashtag(hashtag: String)
  func descriptionCellDidTapUsername(username: String)
}

class DubyDescriptionCell: UITableViewCell, TTTAttributedLabelDelegate {
  
  weak var delegate: DubyDescriptionCellDelegate?
  
  @IBOutlet weak private var descriptionLabel: TTTAttributedLabel!
  @IBOutlet weak private var descriptionHeightConstraint: NSLayoutConstraint!
  
  var selectedDuby: Duby! {
    didSet {
      
      if selectedDuby.imageURL.characters.count <= 0 {
        descriptionLabel.text = ""
      } else {
        
        let text = selectedDuby.description
        
        descriptionLabel.linkAttributes = [kCTForegroundColorAttributeName: UIColor.dubyGreen()]
        //descriptionLabel.enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue;
        descriptionLabel.delegate = self;
        descriptionLabel.text = text
        
        let entities = TwitterText.entitiesInText(text)
        for e in entities {
          let entity = e as! TwitterTextEntity
          let range = entity.range
          let string = (text as NSString!).substringWithRange(range)
          descriptionLabel.addLinkToURL(NSURL(string: string), withRange: range)
        }
      }
    }
  }
  
  var tableModel: DetailsTableViewModel! {
    didSet {
      descriptionHeightConstraint.constant = tableModel.descriptionHeight!
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    backgroundColor = UIColor.clearColor()
    contentView.backgroundColor = UIColor.clearColor()
    contentView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth] // because, screw iOS 7
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
    let string = url.absoluteString
    if string.rangeOfString("#") != nil {
      delegate?.descriptionCellDidTapHashtag(String((string).characters.dropFirst()))
    } else if string.rangeOfString("@") != nil {
      delegate?.descriptionCellDidTapUsername(String((string).characters.dropFirst()))
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
