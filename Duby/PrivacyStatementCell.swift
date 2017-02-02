//
//  PrivacyStatementCell.swift
//  Duby
//
//  Created by Anurag Kamasamudram on 4/19/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

class PrivacyStatementCell: UITableViewCell {

    @IBOutlet weak var privacyStatementTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        privacyStatementTextView.textContainerInset = UIEdgeInsetsMake(15, 15, 0, 15)
        
        // Attributes for all text except "privacy policy"
        let attributedStr = NSMutableAttributedString(string: PRIVACY_STATEMENT)
        attributedStr.addAttribute(NSFontAttributeName, value: UIFont.openSans(10), range: NSMakeRange(0, PRIVACY_STATEMENT.characters.count-16))
        attributedStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.lightGrayColor(), range: NSMakeRange(0, PRIVACY_STATEMENT.characters.count-16))
        
        // Attributes for "privacy policy" text
        attributedStr.addAttribute(NSFontAttributeName, value: UIFont.openSansSemiBold(10), range: NSMakeRange(PRIVACY_STATEMENT.characters.count-16, 15))
        attributedStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(PRIVACY_STATEMENT.characters.count-16, 15))
        attributedStr.addAttribute(NSLinkAttributeName, value: "https://duby.co/privacy", range: NSMakeRange(PRIVACY_STATEMENT.characters.count-16, 15))
        
        privacyStatementTextView.attributedText = attributedStr
    }
}
