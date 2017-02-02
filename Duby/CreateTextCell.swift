//
//  CreateTextCell.swift
//  Duby
//
//  Created by Harsh Damania on 2/22/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

class CreateTextCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var descriptionPlaceholder: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var charCountLabel: UILabel!

    var dataModel: CreateModel!
    
    private let characterLimit = 420
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.clearColor()
        contentView.backgroundColor = UIColor.clearColor()
        
        descriptionTextView.backgroundColor = UIColor.clearColor()
        descriptionTextView.delegate = self
        descriptionTextView.textContainerInset = UIEdgeInsetsZero
        descriptionTextView.textContainer.lineFragmentPadding = 0
        descriptionTextView.text = ""
        
        charCountLabel.text = "\(420)"
        charCountLabel.alpha = 0
    }
    
    /// Call if duby created
    func clearView() {
        descriptionPlaceholder.hidden = false
        descriptionTextView.text = ""
    }

    //MARK: textview
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        UIView.transitionWithView(charCountLabel, duration: 0.33, options: .TransitionCrossDissolve, animations: { () -> Void in
            self.charCountLabel.alpha = 1
        }) { (_) -> Void in
            
        }
        
        descriptionPlaceholder.hidden = true
        
        charCountLabel.text = "\(characterLimit - textView.text.characters.count)"
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        
        UIView.transitionWithView(charCountLabel, duration: 0.33, options: .TransitionCrossDissolve, animations: { () -> Void in
            self.charCountLabel.alpha = 0
        }) { (_) -> Void in
                
        }
        
        if textView.text == "" {
            descriptionPlaceholder.hidden = false
        } else {
            descriptionPlaceholder.hidden = true
        }
        
        dataModel.dubyDescription = textView.text
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        var adjustedText: NSString = textView.text
        if text != "" { // something added
            adjustedText = "\(adjustedText)\(text)"
        } else { // text deleted
            adjustedText = adjustedText.substringToIndex(range.location)
        }
        
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        if adjustedText.length > characterLimit {
            return false
        }
        
        charCountLabel.text = "\(characterLimit - adjustedText.length)"
        
        return true
    }

}
