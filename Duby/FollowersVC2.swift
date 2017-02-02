//
//  FollowersVC2.swift
//  Duby
//
//  Created by Aziz on 9/4/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

//follow button
//back button fix

import UIKit
 

class FollowersVC2: UITableViewController, PasserCellDelegate {
  var user : DubyUser?
  
  var users: [DubyUser] = []
  var followingIds = Set<String>()

  let cellIdentifier = "PasserCell"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupAppearance()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    UIApplication.sharedApplication().statusBarStyle = .LightContent
    tableView.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
    reload()
  }
  
  func setupAppearance() {
    
    navigationController?.navigationBar.translucent = true
    navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
    navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
    (navigationController as! DubyNavVC).barColor = .Clear
    
    //(navigationController as! DubyNavVC).barColor = .White
    view.addSubview(UINavigationBar.dubyWhiteBar())
    
    edgesForExtendedLayout = .None
    
    tableView.backgroundColor = UIColor.clearColor()
    tableView.tableFooterView = UIView()
    
    
    let seg = UISegmentedControl(items: ["Following", "Followers"])
    seg.sizeToFit()
    seg.selectedSegmentIndex = 0
    seg.addTarget(self, action: "change:", forControlEvents: .ValueChanged)
    self.navigationItem.titleView = seg;
  }
  
  
  func reload() {
    change(self.navigationItem.titleView as! UISegmentedControl)
  }
  
  func change(seg: UISegmentedControl) {
    if seg.selectedSegmentIndex == 0 {
      MBProgressHUD.showHUDAddedTo(view, animated: true)
      DubyDatabase.getFollowings(user!, completion: { (users, followingIds, error) -> Void in
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
      if let users = users, followingIds = followingIds {
          self.users = users
          self.followingIds = self.followingIds.union(followingIds)
          self.tableView.reloadData()
        }
      })
    } else {
      MBProgressHUD.showHUDAddedTo(view, animated: true)
      DubyDatabase.getFollowers(user!, completion: { (users, followingIds, error) -> Void in
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
      if let users = users, followingIds = followingIds {
          self.users = users
          self.followingIds = self.followingIds.union(followingIds)
          self.tableView.reloadData()
        }
      })
    }
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 55
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