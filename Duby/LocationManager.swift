//
//  LocationManager.swift
//  Duby
//
//  Created by Wilson on 1/12/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import CoreLocation
 

class LocationManager: NSObject, CLLocationManagerDelegate {
    var currentLocation: CLLocation?
    var legalStates = ["AK", "AZ", "CA", "CO", "CT", "DC", "DE", "GU", "HI", "IL", "MA", "MD", "ME", "MI", "MN", "MT", "NH", "NJ", "NM", "NV", "NY", "OR", "RI", "VI", "VT", "WA"]
    var legalCountries = ["US", "CA", "NL", "VI", "JM", "GU", "MX"]
    
    class var sharedInstance: LocationManager {
        struct Static {
            static var instance: LocationManager?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = LocationManager()
        }
        
        return Static.instance!
    }
    
    var locationManager: CLLocationManager
    var city = ""
    var state = ""
    var country = ""
    var countryCode: String = "" {
        didSet { // Checks for out of area
            if countryCode == "US" {
                outOfArea = !legalStates.contains(state)
            } else if legalCountries.contains(countryCode) {
                outOfArea = false
            } else {
                outOfArea = true
            }
            
        }
    }
    var outOfArea = false
    var hasLocation: Bool
    var hasLocationComponents: Bool = false
        
    var sendLocationUpdate: Bool = false { // sends user location update to server
        didSet {
            if sendLocationUpdate && DubyUser.currentUser.sessionToken != "" {
                DubyDatabase.sendUserLocationUpdate()
            }
        }
    }
    
    var locationServicesDisabled: Bool
    
    override init() {
        locationManager = CLLocationManager()
        hasLocation = false
        
        locationServicesDisabled = CLLocationManager.locationServicesEnabled() ? false : true
    }
    
    func updateLegals() {
        PFConfig.getConfigInBackgroundWithBlock { (config, error) -> Void in
//            let curVersion = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String?;
            if config?["legal_countries"] != nil && config?["legal_states"] != nil {
                self.legalCountries = config?["legal_countries"] as! [String];
                self.legalStates = config?["legal_states"] as! [String];
            }
        }
    }
    
    /// Used to start location services.
    func whereAmI() {
        locationManager.delegate = self
      startLocationManager()
        
        switch CLLocationManager.authorizationStatus() {
            case .NotDetermined:
                if locationManager.respondsToSelector("requestWhenInUseAuthorization") {
                    locationManager.requestWhenInUseAuthorization()
                } else {
                    startLocationManager()
                }
            case .Denied:
            break
//            case .Au:
//                println() // do something if not authorized
            default:
                print("") // something else
        }
    }
    
    /// Parse geo point pointer dictionary
    func getParseGeoPointDictionary() -> Dictionary<String, AnyObject> {
        return ["__type" : "GeoPoint",
            "latitude" : currentLocation!.coordinate.latitude as Double,
            "longitude" : currentLocation!.coordinate.longitude as Double]
    }
    
    /// Gets location string for user
    func getLocationString() -> (locationString: String, outOfArea: Bool) {
        
        if city == "" && country == "" && state == "" {
            return ("Somewhere", true)
        }
        
        var loc = "\(city), \(country)"
        
        if countryCode == "US" {
            loc = "\(city), \(state)"
        }
        
        return (loc, outOfArea)
    }
    
    func startLocationManager() {
      print("starting to update")
        locationManager.distanceFilter = 500;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.startUpdatingLocation()
//        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    func startSignificantLocationChanges() {
        locationManager.startMonitoringSignificantLocationChanges()
    }

    func getLocation() {
        locationManager = CLLocationManager()
        if (locationManager.respondsToSelector(Selector("requestWhenInUseAuthorization")) && CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined) {
            locationManager.requestWhenInUseAuthorization()
        } else {
            startLocationManager()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("did receive locs")
        locationManager.stopUpdatingLocation()
        startSignificantLocationChanges()
        currentLocation = locations.last
        
        if currentLocation?.horizontalAccuracy > 0 {
            hasLocation = true
            
            geoCodeLocation { (_) -> (Void) in
                
            }
        } else {
          print("not geocoding")
      }
    }
    
    /// Got location, so geo code for more human readable data
    func geoCodeLocation(completed completed: (Bool) -> (Void)) {
      print("geocding")
        CLGeocoder().reverseGeocodeLocation(currentLocation!, completionHandler: {
            (placemarks, error) in
            
            if error != nil {
                NSLog("reverse geocode error \(error!.description)")
                self.hasLocationComponents = false
                
                completed(false)
                return
            }
            
            let places = placemarks!
            if places.count > 0 {
                let place = places[0] as CLPlacemark
                
                var hasSomeLocation = false
                
                // Since we now have some new countries being supported, some data is sometimes missing.
                if place.locality == nil {
                    self.city = ""
                } else {
                    self.city = place.locality!
                }
                
                if place.administrativeArea == nil {
                    self.state = ""
                } else {
                    self.state = place.administrativeArea!
                }
                
                if place.country == nil {
                    self.country = ""
                } else {
                    self.country = place.country!
                    hasSomeLocation = true
                }
                
                if place.ISOcountryCode == nil {
                    self.countryCode = ""
                } else {
                    self.countryCode = place.ISOcountryCode!
                    hasSomeLocation = true
                }
                
                var locationString = ""
                
                
                if hasSomeLocation {
                    locationString = "\(self.city), \(self.country)"
                    if self.countryCode == "US" {
                        locationString = "\(self.city), \(self.state)"
                    }
                } else {
                    if place.thoroughfare == nil {
                        locationString = "No Location"
                    } else {
                        locationString = place.thoroughfare!
                    }
                }
                
                
                DubyUser.currentUser.location = locationString
                DubyUser.currentUser.location_geo = self.currentLocation!.coordinate
                self.hasLocationComponents = true
                self.sendLocationUpdate = true
                NSLog("Current Location: \(locationString)")
              
                NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_DID_UPDATE_LOCATION, object: nil)
                completed(true)
            }
        })
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .AuthorizedWhenInUse, CLAuthorizationStatus.AuthorizedWhenInUse:
            startLocationManager()
        default:
            print("denied")
        }

    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location failed: error: \(error.description)")
    }
}