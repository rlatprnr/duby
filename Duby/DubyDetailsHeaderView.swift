//
//  DubyDetailsHeaderView.swift
//  Duby
//
//  Created by Harsh Damania on 2/8/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit
import MapKit

class DubyDetailsHeaderView: UICollectionReusableView, MKMapViewDelegate {
  
  @IBOutlet weak var userImageView: UIImageView!
  @IBOutlet weak var dubyImageView: UIImageView!
  
  @IBOutlet weak var heartbeatImageView: UIImageView!
  
  @IBOutlet weak var dubyLocationLabel: UILabel!
  @IBOutlet weak var dubyDescription: UILabel!
  
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var mapCenterButton: UIButton!
  
  @IBOutlet weak var percentLabel: UILabel!
  @IBOutlet weak var graphLabel: UILabel!
  @IBOutlet weak var totalLabel: UILabel!
  @IBOutlet weak var disabledLabel: UILabel!
  
  var duby = Duby()
  var usersSharedTo = [DubyUser]()
  weak var sender: DubyDetailsCollectionVC!
  var zoomLevel = 8
  
  override func awakeFromNib() {
    userImageView.layer.cornerRadius = CGRectGetWidth(userImageView.frame)/2
    userImageView.layer.borderColor = UIColor.dubyGreen().CGColor
    userImageView.layer.borderWidth = 2
    userImageView.layer.masksToBounds = true
    userImageView.image = UIImage.userPlaceholder()
    
    userImageView.userInteractionEnabled = true
    userImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userImageTapped"))
    
    dubyDescription.text = ""
    percentLabel.text = "0"
    graphLabel.text = "0"
    totalLabel.text = "0"
  }
  
  func setDubyData(data: Duby) {
    duby = data
    
    userImageView.setImageWithURLString(duby.createdBy.profilePicURL, placeholderImage: UIImage.userPlaceholder(), completion: nil)
    dubyImageView.setImageWithURLString(duby.imageURL, placeholderImage: UIImage.dubyPlaceholder(), completion: nil)
    
    var percent: Float = data.usersSharedToCount > 0 ? Float(data.shareCount) / Float(data.usersSharedToCount) * 100 : 0
    percent = percent > 100 ? 100 : percent
    percentLabel.text = NSString(format: "%.2f", percent) as String
    
    heartbeatImageView.tintColor = UIColor.darkGrayColor()
    heartbeatImageView.image = UIImage(named: "heart")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
    graphLabel.text = "\(duby.shareCount)"
    totalLabel.text = "\(duby.usersSharedToCount)"
    
    dubyDescription.text = duby.description
    dubyLocationLabel.text = duby.location
  }
  
  func setUserShareData(usersSharedTo: [DubyUser], zoomLevel: Int) {
    self.usersSharedTo = usersSharedTo
    self.zoomLevel = zoomLevel
    setMap()
  }
  
  /// set the map annotations
  func setMap() {
    
    if (duby.createdBy.dubyTrackDisabled) {
      mapView.hidden = true
      return;
    }
    
    mapView.removeAnnotations(mapView.annotations)
    
    //var zoomRect = MKMapRectNull
    for user in usersSharedTo {
      if (user.objectId == duby.createdBy.objectId) {
        continue
      }
      print("loc")
      print(user.location_geo)
      
      let offLocation = Constants.getRandomDirection().getOffsetCoordinate(user.location_geo)
      
      let annotation = MKPointAnnotation()
      annotation.coordinate = offLocation
      mapView.addAnnotation(annotation)
    }
    
    //mapView.showAnnotations(mapView.annotations, animated: false)
    
    mapView.delegate = self
    //mapView.showsUserLocation = true
    //mapView.setCenterCoordinate(duby.locationGeo, animated: true)
    print("setting zoom lvl \(zoomLevel)")
    mapView.setCenterCoordinate(duby.locationGeo, zoomLevel: CUnsignedLong(zoomLevel), animated: true)
    
    
//    var mapRegion = MKCoordinateRegionMake(duby.locationGeo, MKCoordinateSpanMake(0.2, 0.2))
//    mapView.setRegion(mapRegion, animated: true)
  }
  
  @IBAction func centerMapPressed(sender: AnyObject) {
    
    if mapView.annotations.count > 0 {
      //mapView.showAnnotations(mapView.annotations, animated: true)
    }
  }
  
  func userImageTapped() {
    if !sender.userSignedUp {
      sender.navigationController?.pushToProfileVC(user: duby.createdBy)
    }
    
  }
  
  //MARK: mapview
  
  // set the green markers
  func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView! {
    if !(annotation is MKUserLocation) {
      
      let pin = MKAnnotationView(annotation: annotation, reuseIdentifier: "duby-marker")
      pin.image = UIImage(named: "duby-marker")
      pin.canShowCallout = false
      
      return pin
    } else {
      return nil
    }
  }
  
  func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    if  (Int(mapView.zoomLevel()) > zoomLevel) {
      mapView.setCenterCoordinate(mapView.centerCoordinate, zoomLevel: CUnsignedLong(zoomLevel), animated: true)
    }
  }
}
