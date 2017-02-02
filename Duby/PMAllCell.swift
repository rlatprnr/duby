//
//  PMAllCell.swift
//  Duby
//
//  Created by Aziz on 9/11/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import Foundation


protocol PMAllCellDelegate : class {
  func allCellDidSelect(cell: PMAllCell)
}

class PMAllCell: UITableViewCell {
  @IBOutlet var selectButton: UIButton!
  
  var user: DubyUser!
  weak var delegate: PMAllCellDelegate!
  
  
  class func height() -> CGFloat {
    return 40
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    selectButton.layer.cornerRadius = 5
    selectButton.layer.borderWidth = 0.5
    selectButton.layer.borderColor = UIColor(white: 0.75, alpha: 1).CGColor
    selectButton.layer.masksToBounds = true
    
  }
  
  func update(selected: Bool, delegate: PMAllCellDelegate?) {
    self.delegate = delegate

    
    if (selected) {
      selectButton.backgroundColor = UIColor.dubyGreen()
    } else {
      selectButton.backgroundColor = UIColor.clearColor()
    }
  }
  
  @IBAction func selectTouchUp() {
    delegate?.allCellDidSelect(self)
  }
}