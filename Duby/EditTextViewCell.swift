//
//  EditTextViewCell.swift
//  Duby
//
//  Created by Harsh Damania on 2/3/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

class EditTextViewCell: UITableViewCell, UITextViewDelegate {
  
  let initialHeight: CGFloat = 28
  var textHeight: CGFloat = 28
  weak var delegate: CellDelegate?
  var oldText = ""
  var newText = ""
  var type = ""
  
  @IBOutlet weak var placeholder: UILabel!
  @IBOutlet weak var iconImageView: UIImageView!
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    contentView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
    
    textView.textContainerInset = UIEdgeInsetsMake(4, 0, 0, 0)
    textView.delegate = self
    textView.scrollEnabled = false
    textView.tintColor = UIColor.blackColor()
  }
  
  
  
  func setCellData(data: [String: AnyObject?]) {
    iconImageView.image = UIImage(named: data["image"] as! String)
    textView.text = data["text"] as! String
    type = data["type"] as! String
    
    if type == "mail" {
      textView.keyboardType = .EmailAddress
      textView.spellCheckingType = .No
      textView.autocapitalizationType = .None
      textView.autocorrectionType = .No
    }
    
    if type == "username" {
      textView.spellCheckingType = .No
      textView.autocapitalizationType = .None
      textView.autocorrectionType = .No
    }
    
    placeholder.hidden = true
    if type == "bio" {
      placeholder.text = "Enter Bio"
      if textView.text == "" {
        placeholder.hidden = false
      }
    } else if type == "firstname" {
      placeholder.text = "Enter First Name"
      if textView.text == "" {
        placeholder.hidden = false
      }
    } else if type == "lastname" {
      placeholder.text = "Enter Last Name"
      if textView.text == "" {
        placeholder.hidden = false
      }
    }
    
    oldText = textView.text
  }
  
  func textViewDidChange(textView: UITextView) {
    if type == "username" {
      textView.text = textView.text.lowercaseString
    }
  }
  
  func textViewDidBeginEditing(textView: UITextView) {
    placeholder.hidden = true
  }
  
  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    if text == "\n" {
      textView.resignFirstResponder()
      return false
    }
    
    var adjustedText: NSString = textView.text
    
    if text != "" { // something added
      adjustedText = "\(adjustedText)\(text)"
    } else { // text deleted
      adjustedText = adjustedText.substringToIndex(range.location)
    }
    
    if type == "username" {
      if adjustedText.length > 12 {
        return false
      }
      
      var cantcontain = [" ", "@", "!", "#", "$", "%", "^", "&", "*", "(", ")", "+", "=", "~"]
      
      if cantcontain.contains(text) {
        return false;
      }
      
//      NSRange lowercaseCharRange = [string rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]];
//      
//      if (lowercaseCharRange.location != NSNotFound) {
//        textField.text = [textField.text stringByReplacingCharactersInRange:range
//          withString:[string uppercaseString]];
//        return NO;
//      }

      
    }
    
    //        var cantcontain = [" ", "@", "!", "#", "$", "%", "^", "&", "*", "(", ")", "+", "=", "~"]
    //        if type == "username" && contains(cantcontain ,adjustedText as String) {
    //            return false;
    //        }
    
    if adjustedText.length > 140 {
      return false
    }
    
    if type == "bio" {
      let textPadding: CGFloat = 8
      var height = Constants.getHeightForText(adjustedText, width: textView.contentSize.width - 10, font: textView.font!) + textPadding
      height = height < initialHeight ? initialHeight : height
      if height != textHeight {
        delegate?.updateBioCellHeight!(height + 20)
        textHeight = height
      }
    }
    
    newText = textView.text
    return true
  }
  
  func textViewDidEndEditing(textView: UITextView) {
    print("new \(newText) old \(oldText) text \(textView.text)")
    
    if textView.text == "" {
      placeholder.hidden = false
    } else {
      placeholder.hidden = true
    }
    
    
    if oldText != textView.text {
      if type == "bio" {
        
        delegate?.bioUpdated!(textView.text)
      } else if type == "firstname" {
        
        delegate?.firstnameUpdated!(textView.text)
      } else if type == "lastname" {
        
        delegate?.lastnameUpdated!(textView.text)
      }  else if type == "username" {
        if textView.text == "" {
          textView.text = oldText
          UIAlertView(title: "Invalid Username", message: "Cannot have a blank username", delegate: self, cancelButtonTitle: OK).show()
        } else {
          delegate?.usernameUpdated!(textView.text)
        }
        
      } else if type == "mail" {
        if textView.text.isEmail() {
          delegate?.emailUpdated!(textView.text)
        } else {
          UIAlertView(title: "Invalid Email", message: ERROR_MESSAGE_INVALID_EMAIL, delegate: self, cancelButtonTitle: OK).show()
          textView.text = oldText
          placeholder.hidden = true
        }
      }
    }
  }
  
}
