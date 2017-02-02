//
//  PassersVC.swift
//  Duby
//
//  Created by Aziz on 2015-08-23.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

//follow button
//back button fix

import UIKit
 

class PassersVC: UITableViewController, PasserCellDelegate {
  var dubyId: String?
  var users: [DubyUser] = []
  var followingIds = Set<String>()
  
  let cellIdentifier = "PasserCell"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Passers"
    
    setupAppearance()
    
    let tracker = GAI.sharedInstance().defaultTracker
    tracker.set(kGAIScreenName, value: "Passers")
    tracker.set("event", value: "opened")
    tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject: AnyObject])
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    UIApplication.sharedApplication().statusBarStyle = .LightContent
    tableView.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
    reload()
    
  }
  
  func setupAppearance() {
 //   self.navigationItem.title = "Passers"
//    self.navigationItem.backBarButtonItem?.title = ""
    
    navigationController?.navigationBar.translucent = true
    navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
    navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
    (navigationController as! DubyNavVC).barColor = .Clear
    
    //(navigationController as! DubyNavVC).barColor = .White
    view.addSubview(UINavigationBar.dubyWhiteBar())
    
    edgesForExtendedLayout = .None
    
    tableView.backgroundColor = UIColor.clearColor()
  }
  
  
  func reload() {
    print("loading \(dubyId!)")
    MBProgressHUD.showHUDAddedTo(view, animated: true)
    DubyDatabase.getPassers(dubyId: dubyId!) { (users, followingIds, error) -> Void in
      MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
      print(users)
      print(followingIds)
      if let users = users, followingIds = followingIds {
        self.users = users
        self.followingIds = self.followingIds.union(followingIds)
        self.tableView.reloadData()
      }
    }
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return users.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! PasserCell
    let user = users[indexPath.row]
    cell.updateCell(user, following: followingIds.contains(user.objectId), delegate: self)
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let user = users[indexPath.row]
    navigationController?.pushToProfileVC(user: user)
  }
  
  func passerCellDidFollow(cell: PasserCell, user: DubyUser) {
    let objectId = user.objectId
    if (followingIds.contains(objectId)) {
      followingIds.remove(objectId)
      PFCloud.callFunctionInBackground("unfollow", withParameters: ["followingId": objectId])
        { (obj, error) -> Void in
      }
    } else {
      followingIds.insert(objectId)
      PFCloud.callFunctionInBackground("follow", withParameters: ["toFollowId": objectId])
        { (obj, error) -> Void in
      }
    }
    
    self.tableView.reloadData()
  }
  
}