//
//  FirstPassTTVC.swift
//  Duby
//
//  Created by Aziz on 2015-08-26.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

class FirstPassTTVC: UIViewController {
  var passed = false
  @IBOutlet var label: UILabel!
  @IBOutlet var imageView: UIImageView!
  
  convenience init(passed: Bool) {
    self.init(nibName: "FirstPassTTVC", bundle: nil)
    self.passed = passed
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if (passed) {
      label.text = "You just passed this duby to 18 people near you!\nThe higher influence you have, the more people you pass to."
    } else {
      label.text = "You just put out someone's duby :("
      imageView.image = UIImage(named: "icon-putout-large")
    }
  }
}