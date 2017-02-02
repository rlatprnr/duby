//
//  PMSearchCell.swift
//  Duby
//
//  Created by Aziz on 9/12/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import Foundation


protocol PMSearchCellDelegate : class {
  func searchCellDidSearch(cell: PMSearchCell, text: String)
  func searchCellDidClear(cell: PMSearchCell)
}

class PMSearchCell: UITableViewCell, UITextFieldDelegate {
  @IBOutlet var textField: UITextField!
  
  var user: DubyUser!
  weak var delegate: PMSearchCellDelegate!
  
  
  class func height() -> CGFloat {
    return 44
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  func update(delegate: PMSearchCellDelegate?, placeholder: String) {
    self.delegate = delegate
    textField.placeholder = placeholder
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    
    let text = textField.text
    if (text!.characters.count == 0) {
      delegate?.searchCellDidClear(self)
    } else {
      delegate?.searchCellDidSearch(self, text: text!)
    }
    
    return false
  }
  
  func textFieldShouldClear(textField: UITextField) -> Bool {
    dispatch_async(dispatch_get_main_queue(),{
      textField.resignFirstResponder()
    })
    delegate?.searchCellDidClear(self)
    return true
  }
}