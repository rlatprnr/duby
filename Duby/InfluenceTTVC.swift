//
//  ProfileTTVC.swift
//  Duby
//
//  Created by Aziz on 2015-08-26.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

class InfluenceTTVC: UIViewController {
  @IBOutlet var infLabel: UILabel!
  @IBOutlet var reachLabel: UILabel!
  @IBOutlet var descLabel: UILabel!
  
  var user: DubyUser!
  
  convenience init(user: DubyUser) {
    self.init(nibName: "InfluenceTTVC", bundle: nil)
    
    self.user = user
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    infLabel.text = "\(user.influence)"
    reachLabel.text = "\(user.totalReach)"
    
    descLabel.text = "Your influence is your duby score.\nYour score goes up when you post popular dubys and gain followers. If your duby posts are not popular your score will go down. \n\nWhenever you post a new duby picture or video it goes to exactly \(user.influence) people near you physically."
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
}