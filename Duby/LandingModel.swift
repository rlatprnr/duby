//
//  LandingModel.swift
//  Duby
//
//  Created by Harsh Damania on 3/22/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

class LandingModel: NSObject {
    
    var userSignedUp = false
    var canGetMoreShares = false
    var ascending = false;
    
    
    // Shares
    private var shares: [DubyShare] = [DubyShare]() {
        didSet {
            validShares = [DubyShare]()
            for share in shares {
                //DubyDatabase.markShareSeen(share.objectId)
                validShares.append(share)
            }
        }
    }
    
    // Valid shares. AKA of Dubys and Users that are not null
    var validShares = [DubyShare]()
    
    override init() {
        validShares = [DubyShare]()
        
        shares = [DubyShare]()
    }
    
    /// Gets shares from server
    ///
    /// - parameter initialDubys: if user just signed up, this should be true
    /// - parameter completion: Passes back if we got the shares, if not returns error message t be displayed.
    ///
    func getShares(initialDubys initialDubys: Bool, completion: (gotShares: Bool, message: String) -> Void) {
        self.canGetMoreShares = false
        self.ascending = !self.ascending;
        DubyDatabase.getShares(skipCount: 0, completion: { (shares, error) -> Void in
            if error != nil {
                self.canGetMoreShares = false
                completion(gotShares: false, message: "Could not get Dubys :( \n Tap to Refresh.")
            } else {
                print("got dubys!! \(shares?.count)")
                
                if shares?.count != 0 {
                    self.canGetMoreShares = true
                } else {
                    self.canGetMoreShares = false
                }
                
                self.shares = shares!
                completion(gotShares: true, message: "")
            }
        })
    }
    
    /// Duby is swiped. Decides what to do. Only sends data to server if location services available
    ///
    /// - parameter index: Index of shared that was swiped
    /// - parameter shared: Whether it needs to be shared or not
    func dubySwipedAtIndex(index: Int, shared: Bool) {
        if index < validShares.count {
            DubyDatabase.voteDuby(validShares[index].duby, pass: shared, completion: { (sucess, error) -> Void in
                
            });
            
        }
    }
   
}
