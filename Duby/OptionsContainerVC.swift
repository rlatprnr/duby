//
//  OptionsContainerVC.swift
//  Duby
//
//  Created by Harsh Damania on 2/8/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

class OptionsContainerVC: UIViewController {
   
    override func viewDidLoad() {
        (navigationController as! DubyNavVC).barColor = .White
        view.addSubview(UINavigationBar.dubyWhiteBar())

        edgesForExtendedLayout = .None
    }
    
}
