//
//  EditLabelSegemntedControlCell.swift
//  Duby
//
//  Created by Harsh Damania on 2/3/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

class EditLabelSegemntedControlCell: UITableViewCell {
  
  weak var delegate: CellDelegate?
  
  @IBOutlet weak var segmentedControlWidthConstraint: NSLayoutConstraint!
  @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
  @IBOutlet weak var infoLabel: UILabel!
  @IBOutlet weak var iconImageView: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    contentView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
    
    genderSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
    genderSegmentedControl.setTitleTextAttributes([NSFontAttributeName : UIFont.openSans(13)], forState: .Normal)
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  @IBAction func genderChanged(sender: AnyObject) {
    let isMale = genderSegmentedControl.selectedSegmentIndex == 0
    delegate?.genderUpdated!(isMale)
    
    if isMale {
      infoLabel.text = "Male"
    } else {
      infoLabel.text = "Female"
    }
  }
  
  func setCellData(data: [String: AnyObject?]) {
    if data["control"] as! Bool {
      genderSegmentedControl.selectedSegmentIndex = data["selectedSegment"] as! Int
      segmentedControlWidthConstraint.constant = 100
    } else {
      genderSegmentedControl.hidden = true
      segmentedControlWidthConstraint.constant = 0
    }
    
    infoLabel.text = data["text"] as? String
    iconImageView.image = UIImage(named: data["image"] as! String)
  }
  
}
