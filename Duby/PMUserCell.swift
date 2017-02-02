//
//  PMUserCell.swift
//  Duby
//
//  Created by Aziz on 9/11/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import Foundation


protocol PMUserCellDelegate : class {
  func userCellDidSelect(cell: PMUserCell, user: DubyUser)
}

class PMUserCell: UITableViewCell {
  @IBOutlet var usernameLabel: UILabel!
  @IBOutlet var userImageView: UIImageView!
  @IBOutlet var selectButton: UIButton!
  @IBOutlet var influenceLabel: UILabel!
  @IBOutlet var locationLabel: UILabel!
  
  var user: DubyUser!
  weak var delegate: PMUserCellDelegate!
  
  
  class func height() -> CGFloat {
    return 55
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    selectButton.layer.cornerRadius = 5
    selectButton.layer.borderWidth = 0.5
    selectButton.layer.borderColor = UIColor(white: 0.75, alpha: 1).CGColor
    selectButton.layer.masksToBounds = true
    
    userImageView.layer.cornerRadius = CGRectGetWidth(userImageView.frame)/2
    userImageView.layer.borderWidth = 0.5
    userImageView.layer.borderColor = UIColor.newDubyBlue().CGColor
    userImageView.layer.masksToBounds = true
  }
  
  func update(user: DubyUser, selected: Bool, delegate: PMUserCellDelegate?) {
    self.user = user
    self.delegate = delegate
    
    usernameLabel.text = user.username
    locationLabel.text = user.location
    influenceLabel.text = "\(user.influence)"
    
    userImageView.setImageWithURLString(user.profilePicURL, placeholderImage: UIImage.userPlaceholder(), completion: nil)
    
    if (selected) {
      selectButton.backgroundColor = UIColor.newDubyBlue()
    } else {
      selectButton.backgroundColor = UIColor.clearColor()
    }
    
    
    if let currentLoc = LocationManager.sharedInstance.currentLocation {
      let distance = measureDistance(from: currentLoc.coordinate, to: user.location_geo)
      if distance < 100 {
        locationLabel.text = "less than \(roundToTens(distance)) miles away"
      }
    }
  }
  
  func roundToTens(x : Double) -> Int {
    return max(10 * Int(round(x / 10.0)), 10)
  }
  
  func measureDistance(from from: CLLocationCoordinate2D, to:CLLocationCoordinate2D) -> CLLocationDistance {
    let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
    let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
    return from.distanceFromLocation(to) * 0.000621371
  }
  
  @IBAction func selectTouchUp() {
    delegate?.userCellDidSelect(self, user:user)
  }
}