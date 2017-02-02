//
//  ChangePasswordVC.swift
//  Duby
//
//  Created by Harsh Damania on 2/9/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit


class ChangePasswordVC: UIViewController {

    @IBOutlet weak var emailButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        (navigationController as! DubyNavVC).barColor = .White
        view.addSubview(UINavigationBar.dubyWhiteBar())

        emailButton.layer.cornerRadius = 10
        emailButton.layer.borderColor = UIColor.dubyBlue().CGColor
        emailButton.layer.borderWidth = 1
        
        emailButton.setTitle("Send email to \(DubyUser.currentUser.email)", forState: .Normal)
    }

    @IBAction func emailButtonPressed(sender: AnyObject) {
        // send forgot pass request
        DubyDatabase.forgotPassword(DubyUser.currentUser.email)
        UIAlertView(title: "Password Reset", message: "Please check your email and follow the instructions to reset your password", delegate: self, cancelButtonTitle: OK).show()
    }
}
