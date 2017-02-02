//
//  SearchModel.swift
//  Duby
//
//  Created by Harsh Damania on 2/6/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

class SearchModel: NSObject {
    
    var dubys = [Duby]()
    
    var additionalDubys = [Duby]()
    var canGetMoreDubys = false
    var page = 0
    let dubyLimit = 20
    
    var hashtag = ""
    
    private var gettingRecents = false
    private var gettingTrending = false
    private var gettingFeatured = false
    
    private enum Type {
        case Hashtag, Recent, Trending, Featured
    }
    
    private var useType: Type = .Hashtag
    
    func getRecentDubys(completion: (Bool) -> Void) {
        page = 0
        canGetMoreDubys = false
        additionalDubys = [Duby]()
        
        useType = .Recent
        
        gettingRecents = true
        gettingTrending = false
        gettingFeatured = false;
//        NSLog("Getting recent")
        DubyDatabase.getRecentDubys(dubyLimit, page: page) { (dubys, error) -> Void in
//            NSLog("Got recent")
            
            if self.gettingRecents && !self.gettingTrending && !self.gettingFeatured {
                if dubys != nil {
                    self.dubys = dubys!
                    
                    if dubys!.count == self.dubyLimit {
                        self.canGetMoreDubys = true
                        self.page++
                        self.getMoreRecentDubys()
                    } else {
                        self.canGetMoreDubys = false
                    }
                    
                    self.gettingRecents = false
                    completion(true)
                } else {
                    
                    self.gettingRecents = false
                    completion(false)
                }
            } else {
                completion(false)
            }
            
        }
    }
    
    func getTrendingDubys(completion: (Bool) -> Void) {
        useType = .Trending
        
        gettingTrending = true
        gettingRecents = false
        gettingFeatured = false;
        DubyDatabase.getTrendingDubys { (dubys, error) -> Void in
            
            if self.gettingTrending && !self.gettingRecents && !self.gettingFeatured {
                if dubys != nil {
                    self.dubys = dubys!
                    
                    self.gettingTrending = false
                    completion(true)
                } else {
                    NSLog("ERROR (getting trending dubys): ", error!)
                    
                    self.gettingTrending = false
                    completion(false)
                }
            } else {
                completion(false)
            }
        }
    }
    
    func getFeaturedDubys(completion: (Bool) -> Void) {
        useType = .Featured
        
        gettingTrending = false
        gettingRecents = false
        gettingFeatured = true
        DubyDatabase.getFeaturedDubys { (dubys, error) -> Void in
            
            if self.gettingFeatured && !self.gettingRecents && !self.gettingTrending {
                if dubys != nil {
                    self.dubys = dubys!
                    
                    self.gettingFeatured = false
                    completion(true)
                } else {
                    NSLog("ERROR (getting featured dubys): ", error!)
                    
                    self.gettingFeatured = false
                    completion(false)
                }
            } else {
                completion(false)
            }
        }
    }
    
    func getDubysWithHashtag(hashtag: String, completion: (Bool) -> Void) {
        self.hashtag = hashtag
        
        page = 0
        canGetMoreDubys = false
        additionalDubys = [Duby]()
        
        useType = .Hashtag
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.send(GAIDictionaryBuilder.createEventWithCategory(ANALYTICS_CATEGORY_API, action: ANALYTICS_ACTION_SEARCH, label: hashtag, value: nil).build() as [NSObject: AnyObject])
        
        DubyDatabase.getDubysWithHashtag(hashtag, limit: dubyLimit, page: page) { (dubys, error) -> Void in
            
            if dubys != nil {
                self.dubys = dubys!
                
                if dubys!.count == self.dubyLimit {
                    self.canGetMoreDubys = true
                    self.page++
                    self.getMoreHashtags()
                } else {
                    self.canGetMoreDubys = false
                }
                
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func getMoreHashtags() {
        canGetMoreDubys = false
        DubyDatabase.getDubysWithHashtag(hashtag, limit: dubyLimit, page: page) { (dubys, error) -> Void in
            if error != nil {
                self.canGetMoreDubys = false
            } else {
                
                self.additionalDubys = dubys!
                if dubys!.count == self.dubyLimit {
                    self.canGetMoreDubys = true
                    self.page++
                } else {
                    self.canGetMoreDubys = false
                }
            }
        }
    }
    
    func getMoreRecentDubys() {
        canGetMoreDubys = false
        
        DubyDatabase.getRecentDubys(dubyLimit, page: page) { (dubys, error) -> Void in
            if error != nil {
                self.canGetMoreDubys = false
            } else {
                
                self.additionalDubys = dubys!
                if dubys!.count == self.dubyLimit {
                    self.canGetMoreDubys = true
                    self.page++
                } else {
                    self.canGetMoreDubys = false
                }
            }
        }
    }
    
    /// pagination call to add more dubys
    func addAdditionalDubys() -> Bool {
        if useType == .Trending {
            return false
        }
        
        if additionalDubys.count > 0 {
            dubys = dubys + additionalDubys
            
            additionalDubys = [Duby]()
            
            if canGetMoreDubys {
                if useType == .Recent {
                    getMoreRecentDubys()
                } else {
                    getMoreHashtags()
                }
                
            }
            
            return true
        } else {
            return false
        }
    }
   
}
