//
//  DubyCollectionViewCell.swift
//  Duby
//
//  Created by Harsh Damania on 2/2/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

protocol DubyCollectionViewCellDelegate: class {
  func collectionViewCellDidTapPassers(duby: Duby)
}

class DubyCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet weak var dubyCountButton: UIButton!
  @IBOutlet weak var dubyImageView: UIImageView!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var cameraImageView: UIImageView!
  
  private var duby: Duby = Duby()
  var index: Int?
  weak var delegate: DubyCollectionViewCellDelegate?
  
  override func awakeFromNib() {
    dubyCountButton.imageView?.contentMode = .ScaleAspectFit
    dubyImageView.clipsToBounds = true
    dubyImageView.backgroundColor = UIColor.dubyLightGray()
  }
  
  func setData(duby: Duby) {
    self.duby = duby
    
    cameraImageView.hidden = duby.videoURL == ""
    
    dubyImageView.sd_cancelCurrentImageLoad()
    dubyImageView.image = nil
    descriptionLabel.text = ""
    
    if duby.imageURL != "" { // if no image, we show the duby messsage
      descriptionLabel.text = ""
      dubyImageView.setImageWithURLString(duby.imageURL, placeholderImage: UIImage.dubyPlaceholder(), completion: nil)
    } else {
      descriptionLabel.text = duby.description
    }
    
    
    let count = duby.usersSharedToCount
    dubyCountButton.setTitle("\(Constants.getCountText(count))", forState: .Normal)
    
    dubyCountButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit;
    dubyCountButton.setImage(UIImage(named: "usersSmall")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
    dubyCountButton.tintColor = UIColor.whiteColor()
    
    dubyCountButton.superview?.hidden = false
  }
  
  func setAddDubyProperties() {
    dubyImageView.image = UIImage(named: "icon-plus")
    dubyCountButton.superview?.hidden = true
  }
  
  @IBAction func countButtonPressed(sender: AnyObject) {
    delegate?.collectionViewCellDidTapPassers(duby)
  }
  
  
}
