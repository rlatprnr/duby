//
//  DubyDatabase.swift
//  Duby
//
//  Created by Harsh Damania on 1/23/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

class DubyDatabase: NSObject {
  
  //MARK: private methods that actually make the calls
  
  /// The main function that makes the required HTTP call to the Database. Everything here will NOT be on the main queue.
  /// If need perform any on the main queue with the data returned, dispatch back to there in the completion handler.
  ///
  /// - parameter method: The HTTP method to be invoked
  /// - parameter urlString: URL `String` to be invoked
  /// - parameter params: Anything that would be needed in the HTTP body
  /// - parameter completion: Completion handler. Passes in NSJSON serialized array or dictionary, OR error if one.
  ///
  private class func makeCall(method method:String, urlString: String, params: [String: AnyObject]?, completion:(AnyObject?, NSError?) -> Void) {
    
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    
    
    let url = NSURL(string: urlString)
    let mutableURLRequest = NSMutableURLRequest(URL: url!)
    
    mutableURLRequest.setValue(PARSE_APPLICATION_ID_VALUE, forHTTPHeaderField: PARSE_APPLICATION_ID_KEY)
    mutableURLRequest.setValue(PARSE_REST_API_VALUE, forHTTPHeaderField: PARSE_REST_API_KEY)
    
    if DubyUser.currentUser.sessionToken != "" {
      mutableURLRequest.setValue(DubyUser.currentUser.sessionToken, forHTTPHeaderField: "X-Parse-Session-Token")
      print("using sess: \(DubyUser.currentUser.sessionToken)")
    }
    mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    mutableURLRequest.HTTPMethod = method
    
    if params != nil {
      mutableURLRequest.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(params!, options: [])
    }
    
    print("Requesting \(urlString)")
    NSURLConnection.sendAsynchronousRequest(mutableURLRequest, queue: NSOperationQueue()) { (response, data, error) -> Void in
      if error != nil {
        completion(nil, error)
        print("error \(error)")
      } else {
        let result: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
        if result is NSDictionary {
          let json: NSDictionary = result as! NSDictionary
          if let err = json["error"] as? String {
            completion(nil, NSError(domain: err, code: 141, userInfo: nil))
          } else {
            completion(json, nil)
          }
        } else if result is NSArray {
          let array: NSArray = (try! NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)) as! NSArray
          completion(array, nil)
        } else {
          print("not array or dictionary. what?")
          completion(nil, nil)
        }
        
      }
      
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
  }
  
  /// Main function used to send up images to Parse
  ///
  /// - parameter image: UIImage type to be sent
  /// :param" urlString URL String to be sent to
  /// - parameter completion: returns NSJSON serialized dictionary
  ///
  private class func postImage(image: UIImage!, urlString: String, completion:(AnyObject?, NSError?) -> Void) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    
    let url = NSURL(string: urlString)
    let mutableURLRequest = NSMutableURLRequest(URL: url!)
    
    mutableURLRequest.setValue(PARSE_APPLICATION_ID_VALUE, forHTTPHeaderField: PARSE_APPLICATION_ID_KEY)
    mutableURLRequest.setValue(PARSE_REST_API_VALUE, forHTTPHeaderField: PARSE_REST_API_KEY)
    print("sesesion \(DubyUser.currentUser.sessionToken)")
    if DubyUser.currentUser.sessionToken != "" {
      mutableURLRequest.setValue(DubyUser.currentUser.sessionToken, forHTTPHeaderField: "X-Parse-Session-Token")
    }
    mutableURLRequest.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
    mutableURLRequest.HTTPMethod = "POST"
    
    var downSizeAmount: CGFloat = 1
    
    // adjust image compression based on User settings
    switch UserDefaults.getImageUploadQuality() {
    case .Low: downSizeAmount = 0.1
    case .Medium: downSizeAmount = 0.25
    case .High: downSizeAmount = 0.5
    }
    
    let imageData = UIImageJPEGRepresentation(image, downSizeAmount)
    print("uploading picture  \(imageData!.length) \(UserDefaults.getImageUploadQuality().stringValue)")
    
    mutableURLRequest.HTTPBody = imageData
    
    let queue = NSOperationQueue()
    
    NSURLConnection.sendAsynchronousRequest(mutableURLRequest, queue: queue) { (response, data, error) -> Void in
      if error != nil {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(nil, error)
          print("error sending image \(error!.description)")
        })
      } else {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          let json: NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)) as! NSDictionary
          completion(json, nil)
        })
      }
    }
    
    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
  }
  
  class func blockUser(userId: String, completion:(Bool, NSError?) -> Void) {
    let urlString = "\(PARSE_SERVER_URL_VALUE)/functions/block"
    DubyDatabase.makeCall(method: "POST", urlString: urlString, params: ["userId":userId]) { (response, error) -> Void in
      print(error)
      print("returned")
      if error != nil {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(false, error)
        })
      } else {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(true, nil)
        })
      }
    }
  }
  
  class func isBlocked(userId: String, completion:(Bool, NSError?) -> Void) {
    let urlString = "\(PARSE_SERVER_URL_VALUE)/functions/isBlocked"
    DubyDatabase.makeCall(method: "POST", urlString: urlString, params: ["userId":userId]) { (response, error) -> Void in
      print(error)
      print(response)
      if error != nil {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(false, error)
        })
      } else {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(true, nil)
        })
      }
    }
  }
  
  
  // MARK:-Following Dubys
  
  /// Query the Follow table to check if the current user is following this Duby
  ///
  /// - parameter completion: Passes back either the mapped list of `Follow` objects OR an error
  ///
  class func getFollowingDubys(completion:([Follow]?, NSError?)->Void) {
    let urlString = "\(PARSE_SERVER_URL_VALUE)/classes/Follow/"
    var encoded: NSString = "include=duby,duby.createdBy&where={\"user\":{\"__type\":\"Pointer\",\"className\":\"_User\",\"objectId\":\"\(DubyUser.currentUser.objectId)\"}}"
    encoded = encoded.stringByAddingPercentEscapesUsingEncoding(NSASCIIStringEncoding)!
    
    let encodedURL = "\(urlString)?\(encoded)"
    DubyDatabase.makeCall(method: "GET", urlString: encodedURL, params: nil) { (response, error) -> Void in
      if error != nil {
        completion(nil, error!)
      } else {
        var follows = [Follow]()
        follows <-- (response as! NSDictionary)["results"]
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(follows, nil)
        })
      }
    }
  }
  
  /// Query the Follow table to check if the current user is following this Duby
  ///
  /// - parameter dubyId: duby id to be checked
  /// - parameter completion: Passes either the follow id associated OR an error
  ///
  class func followingDuby(dubyId: String, completion:(String?, NSError?) -> Void) {
    let urlString = "\(PARSE_SERVER_URL_VALUE)/classes/Follow/"
    var encoded: NSString = "where={\"user\":{\"__type\":\"Pointer\",\"className\":\"_User\",\"objectId\":\"\(DubyUser.currentUser.objectId)\"},\"duby\":{\"__type\":\"Pointer\",\"className\":\"Duby\",\"objectId\":\"\(dubyId)\"}}"
    encoded = encoded.stringByAddingPercentEscapesUsingEncoding(NSASCIIStringEncoding)!
    
    let encodedURL = "\(urlString)?\(encoded)"
    DubyDatabase.makeCall(method: "GET", urlString: encodedURL, params: nil) { (response, error) -> Void in
      if error != nil {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(nil, error!)
        })
      } else {
        let objects = (response as! NSDictionary)["results"] as! NSArray
        if objects.count == 0 {
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            completion(nil, nil)
          })
        } else {
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            completion((objects[0] as! NSDictionary)["objectId"] as? String, nil)
          })
        }
      }
    }
  }
  
  //MARK: gets dubys with different conditions
  /// Simply get the duby data
  ///
  /// - parameter objectId: id of the duby to be obtained
  /// - parameter completion: returns either the Duby object OR an error
  ///
  class func getDubyInfo(objectId: String, completion:(Duby?, NSError?) -> Void) {
    let urlString = "\(PARSE_SERVER_URL_VALUE)/classes/Duby/\(objectId)"
    var encoded: NSString = "include=createdBy"
    encoded = encoded.stringByAddingPercentEscapesUsingEncoding(NSASCIIStringEncoding)!
    
    let encodedURL = "\(urlString)?\(encoded)"
    DubyDatabase.makeCall(method: "GET", urlString: encodedURL, params: nil) { (response, error) -> Void in
      if error != nil {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(nil, error)
        })
      } else {
        var duby = Duby()
        duby <-- (response as! NSDictionary)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(duby, nil)
        })
      }
    }
  }
  
  class func getDubyVoteStatus(dubyId: String, completion:(Int?, NSError?) -> Void) {
    let urlString = "\(PARSE_SERVER_URL_VALUE)/functions/voteStatus"
    DubyDatabase.makeCall(method: "POST", urlString: urlString, params: ["dubyId":dubyId]) { (response, error) -> Void in
      if error != nil {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(nil, error)
        })
      } else {
        let status = (response as! NSDictionary)["result"] as! Int?
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(status, nil)
        })
      }
    }
  }
  
  /// Get recent Dubys
  ///
  /// - parameter limit: number per page
  /// - parameter page: page count
  /// - parameter completion: Passes back either the list of Duby objects OR an error
  ///
  class func getRecentDubys(limit: Int, page: Int, completion:([Duby]?, NSError?) -> Void) {
    let urlString = "\(PARSE_SERVER_URL_VALUE)/functions/getRecent"
    let params = ["page":page]
    DubyDatabase.makeCall(method: "POST", urlString: urlString, params: params) { (response, error) -> Void in
      if error != nil {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(nil, error)
        })
        
      } else {
        var dubys = [Duby]()
        dubys <-- (response as! NSDictionary)["result"]
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(dubys, nil)
        })
      }
    }
  }
  
  /// Gets trending Dubys
  ///
  /// - parameter completion: Passes back either the list of Dubys OR an error
  ///
  class func getTrendingDubys(completion:([Duby]?, NSError?) -> Void) {
    let urlString = "\(PARSE_SERVER_URL_VALUE)/functions/getTrending"
    DubyDatabase.makeCall(method: "POST", urlString: urlString, params: nil) { (response, error) -> Void in
      if error != nil {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(nil, error)
        })
      } else {
        var dubys = [Duby]()
        dubys <-- (response as! NSDictionary)["result"]
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(dubys, nil)
        })
      }
    }
  }
  
  //Gets featured dubys
  class func getFeaturedDubys(completion:([Duby]?, NSError?) -> Void) {
    let urlString = "\(PARSE_SERVER_URL_VALUE)/functions/getFeatured"
    
    DubyDatabase.makeCall(method: "POST", urlString: urlString, params: nil) { (response, error) -> Void in
      if error != nil {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(nil, error)
        })
        
      } else {
        
        //                NSLog("Trending Dubys: %@", response as NSDictionary)
        var dubys = [Duby]()
        dubys <-- (response as! NSDictionary)["result"]
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(dubys, nil)
        })
      }
    }
  }
  
  class func getLocalDubys(completion:([Duby]?, NSError?) -> Void) {
    print("hi")
    let urlString = "\(PARSE_SERVER_URL_VALUE)/functions/getLocalDubys"
    DubyDatabase.makeCall(method: "POST", urlString: urlString, params: nil) { (response, error) -> Void in
      if error != nil {
        print(error)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(nil, error)
        })
      } else {
        print("")
        var dubys = [Duby]()
        dubys <-- (response as! NSDictionary)["result"]
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(dubys, nil)
        })
      }
    }
  }
  
  
  class func getTopUsers(completion:([DubyUser]?, NSError?) -> Void) {
    let urlString = "\(PARSE_SERVER_URL_VALUE)/functions/getTopUsers"
    
    DubyDatabase.makeCall(method: "POST", urlString: urlString, params: nil) { (response, error) -> Void in
      if error != nil {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          print(error)
          completion(nil, error)
        })
        
      } else {
        
        //                NSLog("Trending Dubys: %@", response as NSDictionary)
        var users = [DubyUser]()
        users <-- (response as! NSDictionary)["result"]
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(users, nil)
        })
      }
    }
  }
  
  class func getLocalUsers(completion:([DubyUser]?, NSError?) -> Void) {
    let urlString = "\(PARSE_SERVER_URL_VALUE)/functions/getLocalUsers"
    
    DubyDatabase.makeCall(method: "POST", urlString: urlString, params: nil) { (response, error) -> Void in
      if error != nil {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(nil, error)
        })
        
      } else {
        
        //                NSLog("Trending Dubys: %@", response as NSDictionary)
        var users = [DubyUser]()
        users <-- (response as! NSDictionary)["result"]
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(users, nil)
        })
      }
    }
  }
  
  
  /// Gets all Dubys for the user
  ///
  /// - parameter userId: user whose dubys to obtained
  /// - parameter limit: Number of dubys per page
  /// - parameter page: page count
  /// - parameter completion: Passes back (the list of Duby objects for the user AND the total number of dubys for the user) OR an error
  ///
  class func getDubysForUser(userId: String, limit: Int, skip: Int, completion:([Duby]?, Int, NSError?) -> Void) {
    
    let urlString = "\(PARSE_SERVER_URL_VALUE)/functions/getUserDubies"
    let params = ["limit" : limit, "userId": userId, "skip": skip]
    DubyDatabase.makeCall(method: "POST", urlString: urlString, params: params as? [String : AnyObject]) { (response, error) -> Void in
      if error != nil {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          print(error)
          completion(nil, 0, error)
        })
      } else {
        var dubys = [Duby]()
        dubys <-- (response as! NSDictionary)["result"]
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(dubys, dubys.count,  nil)
        })
      }
    }
    
  }
  
  /// Get all dubys associated with the hashtag
  ///
  /// - parameter hashtag: hashtag to be referenced for the dubys
  /// - parameter limit: nNumber per page
  /// - parameter page: page count
  /// - parameter completion: Passes back the list of Duby objects OR an error
  ///
  class func getDubysWithHashtag(hashtag: String, limit: Int, page: Int, completion:([Duby]?, NSError?) -> Void) {
    let urlString = "\(PARSE_SERVER_URL_VALUE)/classes/Duby"
    var encoded: NSString = "order=-createdAt&limit=\(limit)&skip=\(limit*page)&include=createdBy&where={\"hashtags\":\"\(hashtag.lowercaseString)\"}"
    encoded = encoded.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
    
    let encodedURL = "\(urlString)?\(encoded)"
    
    DubyDatabase.makeCall(method: "GET", urlString: encodedURL, params: nil) { (response, error) -> Void in
      if error != nil {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(nil, error)
        })
        
      } else {
        var dubys = [Duby]()
        dubys <-- (response as! NSDictionary)["results"]
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(dubys, nil)
        })
      }
    }
  }
  
  /// List of users that the Duby has been shared to
  ///
  /// - parameter dubyId: id of the duby whose user shared to list needed
  /// - parameter completion: Passes back list of DubyUser objects OR an error
  ///
  class func getUsersSharedToForDuby(dubyId: String, completion: ([DubyUser]?, NSError?) -> (Void)) {
    let urlString = "\(PARSE_SERVER_URL_VALUE)/classes/Duby/\(dubyId)"
    var encoded: NSString = "include=usersSharedTo.User&keys=usersSharedTo.location_geo"
    encoded = encoded.stringByAddingPercentEscapesUsingEncoding(NSASCIIStringEncoding)!
    
    let encodedURL = "\(urlString)?\(encoded)"
    
    DubyDatabase.makeCall(method: "GET", urlString: encodedURL, params: nil) { (response, error) -> Void in
      if error != nil {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(nil, error)
        })
      } else {
        var users = [DubyUser]()
        
        if (response as! NSDictionary)["usersSharedTo"] != nil {
          var usersArray = (response as! NSDictionary)["usersSharedTo"] as! Array<AnyObject>
          usersArray = Constants.removeNullPointersFromArray(usersArray)
          
          users <-- (usersArray as NSArray)
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            completion(users, nil)
          })
        } else {
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            completion([DubyUser](),nil)
          })
        }
      }
    }
  }
  
  /// Admin dubys needed for initial call
  /// WE DO NOT USE THIS ANYMORE. We now use `getInitialDubys`
  ///
  /// - parameter completion: Passes back dubys in the DubyShare objects OR an error
  ///
  class func getAdminDubys(completion: ([DubyShare]?, NSError?) -> Void) {
    let urlString = "\(PARSE_SERVER_URL_VALUE)/classes/AdminDuby"
    var encoded: NSString = "order=createdAt&include=createdBy"
    encoded = encoded.stringByAddingPercentEscapesUsingEncoding(NSASCIIStringEncoding)!
    
    let encodedURL = "\(urlString)?\(encoded)"
    
    DubyDatabase.makeCall(method: "GET", urlString: encodedURL, params: nil) { (response, error) -> Void in
      
      if error != nil {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(nil, error)
        })
      } else {
        var dubys = [Duby]()
        dubys <-- (response as! NSDictionary)["results"]
        
        var shares = [DubyShare]()
        for duby in dubys {
          var adminShare = DubyShare()
          adminShare.duby = duby
          
          shares.append(adminShare)
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(shares, nil)
        })
      }
    }
  }
  
  /// Gets initial dubys for new users who signed up
  ///
  /// - parameter completion: Passes back list of Dubys in the DubyShare object OR an error
  ///
  class func getInitialDubys(completion: ([DubyShare]?, NSError?) -> (Void)) {
    let urlString = "\(PARSE_SERVER_URL_VALUE)/functions/getInitialDubys"
    
    var stateString = LocationManager.sharedInstance.country
    if LocationManager.sharedInstance.country == "United States" {
      stateString = LocationManager.sharedInstance.state
    }
    
    let params = ["currentState": stateString]
    DubyDatabase.makeCall(method: "POST", urlString: urlString, params: params) { (response, error) -> Void in
      if error != nil {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(nil, error)
        })
      } else {
        var dubys = [Duby]()
        dubys <-- (response as! NSDictionary)["result"]
        
        var shares = [DubyShare]()
        for duby in dubys {
          if duby.createdBy.objectId != "" {
            var initialShare = DubyShare()
            initialShare.duby = duby
            
            shares.append(initialShare)
          }
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(shares, nil)
        })
      }
    }
  }
  
  /// Delete the duby
  ///
  /// - parameter objectId: duby id to be deleted
  /// - parameter completion: Passes back whether successfully deleted
  ///
  class func deleteDuby(objectId: String, completion: (Bool) -> (Void)) {
    let shareQ = dispatch_queue_create("com.duby.shareQueue", nil)
    dispatch_sync(shareQ, { () -> Void in
      let urlString = "\(PARSE_SERVER_URL_VALUE)/functions/deleteDuby"
      
      let params = ["dubyId" : objectId] as [String : AnyObject];
      
      DubyDatabase.makeCall(method: "POST", urlString: urlString, params: params) { (response, error) -> Void in
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          if response != nil {
            print("responded: \(response)");
            
            completion(true)
          } else {
            print("error deleting duby \(error?.localizedDescription)")
            completion(false)
          }
        })
      }
    })
    
    
    //        let urlString = "\(PARSE_SERVER_URL_VALUE)/classes/Duby/\(objectId)"
    //
    //        DubyDatabase.makeCall(method: "DELETE", urlString: urlString, params: nil) { (response, error) -> Void in
    //            dispatch_async(dispatch_get_main_queue(), { () -> Void in
    //                if error != nil {
    //                    completion(false)
    //                    println("error deleting \(error?.description)")
    //                } else {
    //                    println("response \(response)")
    //                    if (response as! NSDictionary)["error"] != nil {
    //                        completion(false)
    //                    } else {
    //                        completion(true)
    //                    }
    //                }
    //            })
    //        }
  }
  
  //MARK: create duby
  
  /// Create new duby
  ///
  /// - parameter image: Create with this image
  /// - parameter dubyParams: duby info that has to be created
  /// - parameter completion: Passes back whether duby was successfully created, the duby info dictionary returned by the service to add to ProfileVC OR an error
  ///
  class func createDuby(dubyParams: Dictionary<String, AnyObject>, completion:(Bool, [String: AnyObject]?, NSError?) -> Void) {
    
    //        if image != nil {
    //            DubyDatabase.postImage(image, urlString: imageString, completion: { (response, error) -> Void in
    //                if response != nil {
    //
    //                    var resp = response as! NSDictionary
    //                    var imageURL = resp["url"] as! String
    //                    var imageName = resp["name"] as! String
    //
    //                    var imageDictionary = ["name" : imageName, "__type" : "File", "url": imageURL] as Dictionary<String, AnyObject>
    //                    var updatedDubyParams = dubyParams
    //                    updatedDubyParams["content"] = imageDictionary
    //
    //                    DubyDatabase.createDubyWithUpdatedParams(updatedDubyParams, completion: { (created, newDuby, dubyError) -> Void in
    //                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
    //                            completion(created, newDuby, dubyError)
    //                        })
    //                    })
    //                }
    //            })
    //        } else {
    DubyDatabase.createDubyWithUpdatedParams(dubyParams, completion: { (created, newDuby, error) -> Void in
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        completion(created, newDuby, error)
      })
    })
    //        }
  }
  
  /// Private internal class that sends up the data (Without the image) The image is handled in `createDuby:` function and then passed here
  ///
  /// - parameter params: Duby info that has to be created
  /// - parameter completion: Passes back whether duby was successfully created, the duby info dictionary returned by the service to add to ProfileVC OR an error
  ///
  private class func createDubyWithUpdatedParams(params: [String: AnyObject], completion:(Bool, [String: AnyObject]?, NSError?) -> Void) {
    let urlString = "\(PARSE_SERVER_URL_VALUE)/classes/Duby"
    
    var newDubyParams = params
    
    DubyDatabase.makeCall(method: "POST", urlString: urlString, params: params) { (response, error) -> Void in
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        if response != nil {
          let resp = response as! NSDictionary
          if resp["objectId"] != nil {
            let objectId = resp["objectId"] as! String
            let dubyParams = ["__type" : "Pointer",
              "className" : "Duby",
              "objectId" : objectId]
            
            newDubyParams["objectId"] = objectId
            
            completion(true, newDubyParams, nil)
            
            DubyDatabase.shareDuby(dubyParams, completion: { (completed, errorShare) -> Void in
              
            })
            
            
          } else if resp["error"] != nil {
            let error = NSError(domain: "", code: resp["code"] as! Int, userInfo: NSDictionary(object: resp["error"]!, forKey: NSLocalizedDescriptionKey) as [NSObject : AnyObject])
            completion(false, nil, error)
          }
        } else {
          completion(false, nil, error)
        }
      })
    }
  }
  
  // MARK:-Forgot Password
  
  /// Forgot password
  ///
  /// - parameter email: email id for user that forgot the password
  ///
  class func forgotPassword(email: String) {
    let urlString = "\(PARSE_SERVER_URL_VALUE)/functions/forgotPass"
    let params = ["email": email]
    DubyDatabase.makeCall(method: "POST", urlString: urlString, params: params) { (response, error) -> Void in
      if error == nil {
        if let result = (response as! NSDictionary)["result"] as? NSString {
          let data = result.dataUsingEncoding(NSUTF8StringEncoding)
          let json = (try? NSJSONSerialization.JSONObjectWithData(data!, options: [])) as? NSDictionary
          if json != nil {
            if (json!.objectForKey("status") as? String) == "OK" {
              print("Password reset went through correctly")
            }
          }
        }
      } else {
        print("ERROR (setEmail): \(error)")
      }
    }
  }
  
  //MARK: share
  
  /// Get list of dubys that have been shared with the user
  ///
  /// - parameter skipCount: The number of rows to skip before getting data. WE DO NOT USE THIS ANYMORE
  /// - parameter completion: Passes back a list of DubyShare objects OR an error
  ///
  class func getShares(skipCount skipCount: Int, completion:([DubyShare]?, NSError?) -> Void) {
    
    let shareQ = dispatch_queue_create("com.duby.shareQueue", nil)
    
    dispatch_sync(shareQ, { () -> Void in
      let urlString = "\(PARSE_SERVER_URL_VALUE)/functions/getSharedWithMe2"
      
      let params = ["limit" : 15, "skip": skipCount]
      DubyDatabase.makeCall(method: "POST", urlString: urlString, params: params) { (response, error) -> Void in
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          if error != nil {
            print(error)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
              completion(nil, error)
            })
          } else {
            let result = ((response as! NSDictionary)["result"]) as! [NSArray]
            
            
            var shares = [DubyShare]()
            var dubies = [Duby]()
            
            
            let d = result.map({ (i) -> AnyObject in
              return i[1]
            })
            
            
            let s = result.map({ (i) -> AnyObject in
              return i[0]
            })
            
            
            shares <-- (s as AnyObject)
            dubies <-- (d as AnyObject)
            
            
            for index in 0..<shares.count {
              var share = shares[index]
              let duby = dubies[index]
              share.duby = duby
              shares[index] = share
            }
            
            for index in 0..<shares.count {
              _ = shares[index]
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
              completion(shares, nil)
            })
          }
        })
      }
    })
  }
  
  class func searchUsers(queryText: String, completion:([DubyUser]?, NSError?) -> Void) {
    let shareQ = dispatch_queue_create("com.duby.shareQueue", nil)
    
    dispatch_sync(shareQ, { () -> Void in
      let urlString = "\(PARSE_SERVER_URL_VALUE)/functions/searchUsers"
      
      let params = ["queryText" : queryText]
      
      DubyDatabase.makeCall(method: "POST", urlString: urlString, params: params) { (response, error) -> Void in
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          if response != nil {
            var users = [DubyUser]()
            users <-- (response as! NSDictionary)["result"]
            
            completion(users, nil)
          } else {
            print("error serching user \(error?.localizedDescription)")
            completion(nil, error)
          }
        })
      }
    })
  }
  
  
  class func getFollowersAndSesh(queryText: String?, completion:([DubyUser]?, [DubyUser]?, NSError?) -> Void) {
    let shareQ = dispatch_queue_create("com.duby.shareQueue", nil)
    
    var params = [String:String]()
    if let text = queryText {
      params["queryText"] = text
    }
    
    dispatch_sync(shareQ, { () -> Void in
      let urlString = "\(PARSE_SERVER_URL_VALUE)/functions/getFollowersAndSesh"
      
      DubyDatabase.makeCall(method: "POST", urlString: urlString, params: params) { (response, error) -> Void in
        if error != nil {
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            completion(nil, nil, error)
          })
        } else {
          let resp = response as! NSDictionary
          var followers = [DubyUser]()
          followers <-- (resp["result"] as! NSDictionary)["followers"]
          
          var sesh = [DubyUser]()
          sesh <-- (resp["result"] as! NSDictionary)["sesh"]
          
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            completion(followers, sesh, nil)
          })
        }
      }
    })
  }
  
  
  class func getFollowings(user: DubyUser, completion:([DubyUser]?, [String]?, NSError?) -> Void) {
    let shareQ = dispatch_queue_create("com.duby.shareQueue", nil)
    
    dispatch_sync(shareQ, { () -> Void in
      let urlString = "\(PARSE_SERVER_URL_VALUE)/functions/getFollowings2"
      
      let params = ["userId" : user.objectId]
      
      DubyDatabase.makeCall(method: "POST", urlString: urlString, params: params) { (response, error) -> Void in
        if error != nil {
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            completion(nil, nil, error)
          })
        } else {
          let resp = response as! NSDictionary
          //                println("NOTIFICATIONS: \(response as! NSDictionary)")
          print(resp)
          var users = [DubyUser]()
          users <-- (resp["result"] as! NSDictionary)["users"]
          
          let followingIds = (resp["result"] as! NSDictionary)["followingIds"] as! [String]
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            completion(users, followingIds, nil)
          })
        }
      }
    })
  }
  
  class func getFollowers(user: DubyUser, completion:([DubyUser]?, [String]?, NSError?) -> Void) {
    let shareQ = dispatch_queue_create("com.duby.shareQueue", nil)
    
    dispatch_sync(shareQ, { () -> Void in
      let urlString = "\(PARSE_SERVER_URL_VALUE)/functions/getFollowers2"
      
      let params = ["userId" : user.objectId]
      
      DubyDatabase.makeCall(method: "POST", urlString: urlString, params: params) { (response, error) -> Void in
        if error != nil {
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            completion(nil, nil, error)
          })
        } else {
          let resp = response as! NSDictionary
          //                println("NOTIFICATIONS: \(response as! NSDictionary)")
          var users = [DubyUser]()
          users <-- (resp["result"] as! NSDictionary)["users"]
          
          let followingIds = (resp["result"] as! NSDictionary)["followingIds"] as! [String]
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            completion(users, followingIds, nil)
          })
        }
      }
    })
  }
  
  
  /// Share Duby with people around
  ///
  /// - parameter dubyParams: The parse pointer duby object that has to be shared
  /// - parameter completion: Passes back whether it was successfully shared or not OR an error
  ///
  class func shareDuby(dubyParams: [String: AnyObject], completion:(Bool, NSError?) -> Void) {
    let shareQ = dispatch_queue_create("com.duby.shareQueue", nil)
    
    dispatch_sync(shareQ, { () -> Void in
      let urlString = "\(PARSE_SERVER_URL_VALUE)/functions/shareDuby"
      
      let params = ["dubyId" : dubyParams["objectId"],
      "userId" : DubyUser.currentUser.objectId]
      
      DubyDatabase.makeCall(method: "POST", urlString: urlString, params: params as? [String:AnyObject]) { (response, error) -> Void in
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          if response != nil {
            let dubId: AnyObject? = dubyParams["objectId"]
            print("sharing id \(dubId) \(response)")
            
            completion(true, nil)
          } else {
            print("error sharing user \(error?.localizedDescription)")
            completion(false, error)
          }
        })
      }
    })
  }
  
  class func voteDuby(duby: Duby, pass: Bool, completion: (Bool, NSError?) -> Void) {
    let shareQ = dispatch_queue_create("com.duby.shareQueue", nil)
    dispatch_sync(shareQ, { () -> Void in
      let urlString = "\(PARSE_SERVER_URL_VALUE)/functions/voteDuby"
      
      let params = ["dubyId" : duby.objectId, "pass": pass];
      
      DubyDatabase.makeCall(method: "POST", urlString: urlString, params: params as? [String : AnyObject]) { (response, error) -> Void in
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          if response != nil {
            print("responded: \(response)");
            
            
            completion(true, nil)
          } else {
            print("error sharing user \(error?.localizedDescription)")
            completion(false, error)
          }
        })
      }
    })
  }
  
  class func deleteComment(comment: DubyComment, completion: (Bool, NSError?) -> Void) {
    let shareQ = dispatch_queue_create("com.duby.shareQueue", nil)
    dispatch_sync(shareQ, { () -> Void in
      let urlString = "\(PARSE_SERVER_URL_VALUE)/functions/deleteComment"
      
      let params = ["commentId" : comment.objectId] as [String : AnyObject];
      
      DubyDatabase.makeCall(method: "POST", urlString: urlString, params: params) { (response, error) -> Void in
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          if response != nil {
            print("responded: \(response)");
            
            completion(true, nil)
          } else {
            print("error sharing user \(error?.localizedDescription)")
            completion(false, error)
          }
        })
      }
    })
  }
  
  /// Sets `seen` flag to `true` so that we do not see it again
  ///
  /// - parameter shareId: DubyShare object that needs to be marked seen
  ///
  class func markShareSeen(shareId: String) {
    let urlString = "\(PARSE_SERVER_URL_VALUE)/classes/Share/\(shareId)"
    
    DubyDatabase.makeCall(method: "PUT", urlString: urlString, params: ["seen" : true]) { (response, error) -> Void in
      print(response)
      if response != nil {
        
      }
    }
  }
  
  //MARK: Notifications
  
  /// Get list of notifications for the user
  ///
  /// - parameter page: page count
  /// - parameter completion: Passes back list of DubyNotification objects OR an error
  ///
  class func getNotifications(type type: String, completion:([DubyNotification]?, NSError?) -> Void) {
    let urlString = "\(PARSE_SERVER_URL_VALUE)/functions/getNotifications"
    let params = ["type": type]
    
    DubyDatabase.makeCall(method: "POST", urlString: urlString, params: params) { (response, error) -> Void in
      if error != nil {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(nil, error)
        })
      } else {
        //                println("NOTIFICATIONS: \(response as! NSDictionary)")
        var notifications = [DubyNotification]()
        notifications <-- (response as! NSDictionary)["result"]
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(notifications, nil)
        })
      }
    }
  }
  
  class func getPassers(dubyId dubyId: String, completion:([DubyUser]?, [String]?, NSError?) -> Void) {
    let urlString = "\(PARSE_SERVER_URL_VALUE)/functions/getPassers"
    let params = ["dubyId": dubyId]
    
    DubyDatabase.makeCall(method: "POST", urlString: urlString, params: params) { (response, error) -> Void in
      if error != nil {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(nil, nil, error)
        })
      } else {
        let resp = response as! NSDictionary
        //                println("NOTIFICATIONS: \(response as! NSDictionary)")
        var users = [DubyUser]()
        users <-- (resp["result"] as! NSDictionary)["users"]
        
        let followingIds = (resp["result"] as! NSDictionary)["followingIds"] as! [String]
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(users, followingIds, nil)
        })
      }
    }
  }
  
  class func markPMSeen(notificationId: String) {
    let urlString = "\(PARSE_SERVER_URL_VALUE)/functions/seenPM"
    let params = ["notificationId": notificationId]
    
    DubyDatabase.makeCall(method: "POST", urlString: urlString, params: params) { (response, error) -> Void in
      if error != nil {
        print(error)
      } else {
        print(response)
      }
    }
  }
  
  
  class func markNotesSeen() {
    let urlString = "\(PARSE_SERVER_URL_VALUE)/functions/seenNotes"
    
    DubyDatabase.makeCall(method: "POST", urlString: urlString, params: ["":""]) { (response, error) -> Void in
    }
  }
  
  
  /// Sets `seen` flag to `true` for notification
  ///
  /// - parameter notificationId: Notification to be marked seen
  ///
  class func markNotificationSeen(notificationId: String) {
    let urlString = "\(PARSE_SERVER_URL_VALUE)/classes/Notification/\(notificationId)"
    
    DubyDatabase.makeCall(method: "PUT", urlString: urlString, params: ["seen" : true]) { (response, error) -> Void in
      if response != nil {
        
      }
    }
  }
  
  /// If we have multiple notifications that are unseen, we perform a Parse batch operation
  ///
  /// - parameter notificationIds: List of ids to be marked seen
  ///
  class func markMultipleNotificationsSeen(notificationIds: [String]) {
    let urlString = "\(PARSE_SERVER_URL_VALUE)/batch"
    
    var requests = [Dictionary<String, AnyObject>]()
    for id in notificationIds {
      let requestDictionary: Dictionary<String, AnyObject> = ["method": "PUT", "path": "/1/classes/Notification/\(id)", "body": ["seen": true]]
      
      requests.append(requestDictionary)
    }
    
    DubyDatabase.makeCall(method: "POST", urlString: urlString, params: ["requests": requests]) { (response, error) -> Void in
    }
  }
  
  //MARK: edit user
  
  /// Update user data
  ///
  /// - parameter updateParams: List of params that have to be updated
  /// - parameter completion: Passes back the response from the server OR an error
  ///
  class func updateUser(updateParams: Dictionary<String, AnyObject>, completion:(AnyObject?, NSError?) -> Void) {
    let urlString = "\(PARSE_SERVER_URL_VALUE)/users/\(DubyUser.currentUser.objectId)"
    
    DubyDatabase.makeCall(method: "PUT", urlString: urlString, params: updateParams) { (response, error) -> Void in
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        if error != nil {
          completion(nil, error)
        } else {
          completion(response, nil)
          print("update response \(response)")
        }
      })
    }
  }
  
  /// Update user profile picture
  ///
  /// - parameter image: new user profile picture
  /// - parameter completion: Passes back server response OR an error
  class func updateProfilePicForUser(image: UIImage!, completion:(AnyObject?, NSError?) -> Void) {
    let urlString = "\(PARSE_SERVER_URL_VALUE)/files/user_image.jpg"
    
    DubyDatabase.postImage(image, urlString: urlString) { (response, error) -> Void in
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        if error != nil {
          completion(nil, error)
        } else {
          completion(response, nil)
        }
      })
    }
  }
  
  /// Updates user location. Generally should be called during app start and significant location changes.
  class func sendUserLocationUpdate() {
    let urlString = "\(PARSE_SERVER_URL_VALUE)/users/\(DubyUser.currentUser.objectId)"
    
    if LocationManager.sharedInstance.hasLocation {
      let params = ["location_geo" : LocationManager.sharedInstance.getParseGeoPointDictionary(),
        "location" : LocationManager.sharedInstance.getLocationString().locationString] as Dictionary<String, AnyObject>
      DubyDatabase.makeCall(method: "PUT", urlString: urlString, params: params) { (response, error) -> Void in
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          if error != nil {
          } else {
          }
        })
      }
    }
  }
  
  /// Gets user data
  ///
  /// - parameter userId: user whose data is requested
  /// - parameter completion: Passes back the DubyUser object received OR an error
  class func getUserInfo(userId: String, completion: (DubyUser?, NSError?) -> (Void)) {
    let urlString = "\(PARSE_SERVER_URL_VALUE)/users/\(userId)"
    
    DubyDatabase.makeCall(method: "GET", urlString: urlString, params: nil) { (response, error) -> Void in
      if error != nil {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(nil, error)
        })
      } else {
        var user = DubyUser()
        user <-- (response as! NSDictionary)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(user, nil)
        })
      }
    }
  }
  
  class func getUser(username: String, completion: (DubyUser?, NSError?) -> (Void)) {
    let urlString = "\(PARSE_SERVER_URL_VALUE)/users"
    var encoded: NSString = "where={\"username\":\"\(username)\"}"
    encoded = encoded.stringByAddingPercentEscapesUsingEncoding(NSASCIIStringEncoding)!
    //
    let encodedURL = "\(urlString)?\(encoded)"
    DubyDatabase.makeCall(method: "GET", urlString: encodedURL, params: nil) { (response, error) -> Void in
      if error != nil {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(nil, error)
        })
      } else {
        var users = [DubyUser]()
        users <-- (response as! NSDictionary)["results"]
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          if users.count == 0 {
            completion(nil, NSError(domain: "", code: 0, userInfo: nil))
          } else {
            completion(users[0], nil)
          }
        })
      }
    }
  }
  
  //MARK: comments
  
  /// Sends comment for the duby
  ///
  /// - parameter message: Comment message
  /// - parameter duby: Duby that this was commented on
  ///
  class func sendComment(message: String, duby: Duby, completion:(DubyComment?, NSError?) -> Void) {
    let commentQ = dispatch_queue_create("commentQueue", nil)
    
    dispatch_sync(commentQ, { () -> Void in
      let urlString = "\(PARSE_SERVER_URL_VALUE)/functions/addComment"
      
      let params = ["message" : message,
        "senderPointer" : DubyUser.currentUser.getParsePointerDictionary(),
        "dubyPointer" : duby.getParsePointerDictionary()] as [String: AnyObject]
      
      DubyDatabase.makeCall(method: "POST", urlString: urlString, params: params) { (response, error) -> Void in
        if error != nil {
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            completion(nil, error);
          })
        } else {
          var comment = DubyComment()
          comment <-- (response as! NSDictionary)["result"]
          
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            completion(comment, nil)
          })
        }
      }
    })
  }
  
  /// Get comments associated for duby
  ///
  /// - parameter duby: Duby whose comments are requested
  /// - parameter count: Number of commented per page
  /// - parameter page: page count
  /// - parameter completion: Passes back (list of DubyComment objects AND the total comment count for the duby) OR an error
  ///
  class func getComments(duby duby: Duby, count: Int, page: Int, completion:([DubyComment]?, Int, NSError?) -> Void) {
    
    let urlString = "\(PARSE_SERVER_URL_VALUE)/classes/Comment"
    let skipCount = count * page
    var encoded: NSString = "order=-createdAt&include=duby,sender&limit=\(count)&skip=\(skipCount)&where={\"duby\":{\"__type\":\"Pointer\",\"className\":\"Duby\",\"objectId\":\"\(duby.objectId)\"}}&count=1"
    encoded = encoded.stringByAddingPercentEscapesUsingEncoding(NSASCIIStringEncoding)!
    
    let encodedURL = "\(urlString)?\(encoded)"
    
    DubyDatabase.makeCall(method: "GET", urlString: encodedURL, params: nil) { (response, error) -> Void in
      
      if error != nil {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(nil, 0, error)
        })
      } else {
        var comments = [DubyComment]()
        comments <-- (response as! NSDictionary)["results"]
        let count: Int = (response as! NSDictionary)["count"] as! Int
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(comments, count, nil)
        })
      }
    }
  }
  
  //MARK: report duby
  
  /// Report duby, probably as inapporpriate
  ///
  /// - parameter duby: Duby that is inappropriate
  ///
  class func reportDuby(duby: Duby) {
    let shareQ = dispatch_queue_create("com.duby.shareQueue", nil)
    dispatch_sync(shareQ, { () -> Void in
      let urlString = "\(PARSE_SERVER_URL_VALUE)/functions/reportDuby"
      
      let params = ["dubyId" : duby.objectId];
      
      DubyDatabase.makeCall(method: "POST", urlString: urlString, params: params) { (response, error) -> Void in
      }
    })
    
  }
  
  //MARK: sign up
  /// Sign up using REST. WE DO NOT USE
  ///
  /// - parameter userInfo: User data for new user
  /// - parameter completion: Passes back DubyUser object of the new user OR an error
  class func signUpUser(userInfo: [String: AnyObject], completion:(DubyUser?, NSError?) -> Void) {
    let urlString = "\(PARSE_SERVER_URL_VALUE)/users"
    
    DubyDatabase.makeCall(method: "POST", urlString: urlString, params: userInfo) { (response, error) -> Void in
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        if error != nil {
          completion(nil, error)
        } else {
          
          if (response as! NSDictionary)["error"] != nil {
            let error = NSError(domain: "", code: (response as! NSDictionary)["code"] as! Int, userInfo: nil)
            error.setValue((response as! NSDictionary)["error"], forKey: NSLocalizedDescriptionKey)
            
            completion(nil, error)
          } else {
            var newUser = DubyUser()
            let databaseResponse : Dictionary<String, AnyObject> = response as! [String : AnyObject]
            var updatedInfo = userInfo + databaseResponse
            updatedInfo["updatedAt"] = updatedInfo["createdAt"]
            
            newUser <-- (updatedInfo as NSDictionary)
            
            completion(newUser, nil)
          }
          
        }
      })
    }
  }
  
  /// Checks for duplicate email
  ///
  /// - parameter email: email to be checked
  /// - parameter completion: Passes back whether email was a duplicate or not
  ///
  class func isEmailDuplicate(email: String, completion: (success: Bool) -> Void) {
    completion(success: false)
//    let urlString = "https://api.duby.co:3000/api/emailExists?email=" + email
//    urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
//    let request = NSMutableURLRequest(URL: NSURL(string: urlString)!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
//    request.HTTPMethod = "GET"
//    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue()) { (response, data, error) -> Void in
//      if error == nil {
//        print("RESPONSE: \(response)")
//        let json = (try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as? NSDictionary
//        print("DATA: \(json)")
//        if json != nil && (json?.objectForKey("status") as? String) == "EXISTS" {
//          print("DUPLICATE EMAIL")
//          completion(success: true)
//        } else {
//          print("EMAIL is available")
//          completion(success: false)
//        }
//      } else {
//        print("ERROR (checkingDuplicateEmail): \(error)")
//      }
//    }
  }
}
