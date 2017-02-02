//
//  PMSendVC.swift
//  Duby
//
//  Created by Aziz on 9/11/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

//implement counting of pmduby times

import UIKit
 

protocol PMSendVCDelegate : class {
  func sendVCDidComplete()
}

class PMSendVC : UIViewController, UITableViewDataSource, UITableViewDelegate, PMUserCellDelegate, PMAllCellDelegate, PMSearchCellDelegate {
  @IBOutlet var tableView: UITableView!
  @IBOutlet var footer: UIView!
  @IBOutlet var footerLabel: UILabel!
  @IBOutlet var footerHeightConstraint: NSLayoutConstraint!

  
  var originalFollowers: [DubyUser]?
  var originalSesh: [DubyUser]?
  
  var followers = [String: [DubyUser]]()
  var sesh = [DubyUser]()
  var indices = [String]()
  
  var selected = Set<String>()
  var allSelected = false
  
  var inSearchMode = false
  
  var params: [NSObject:AnyObject]!
  var delegate: PMSendVCDelegate?
  
  let userCellIden = "PMUserCell"
  let allCellIden = "PMAllCell"
  let searchCellIden = "PMSearchCell"
  
  
  let letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters)
  
  
  
  required init(params: [NSObject:AnyObject]?, delegate: PMSendVCDelegate?) {
    self.params = params
    self.delegate = delegate
    super.init(nibName: "PMSendVC", bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Send Duby To.."
    
    edgesForExtendedLayout = .None
    
    navigationController?.navigationBar.translucent = true
    navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
    navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
    navigationController?.navigationBar.shadowImage = UIImage()
    
    (navigationController as! DubyNavVC).barColor = .NewBlue
    view.addSubview(UINavigationBar.dubyWhiteBar())
    
    let cancelItem = UIBarButtonItem(title: "Cancel", style: .Done, target: self, action: "cancel");
    self.navigationItem.leftBarButtonItem = cancelItem;
    
    
    tableView.registerNib(UINib(nibName: userCellIden, bundle: nil), forCellReuseIdentifier: userCellIden)
    tableView.registerNib(UINib(nibName: allCellIden, bundle: nil), forCellReuseIdentifier: allCellIden)
    tableView.registerNib(UINib(nibName: searchCellIden, bundle: nil), forCellReuseIdentifier: searchCellIden)
    tableView.sectionIndexColor = UIColor.lightGrayColor()
    tableView.contentInset = UIEdgeInsetsMake(0, 0, footer.frame.size.height, 0)
    
    footer.backgroundColor = UIColor.dubyGreen()
    footerHeightConstraint.constant = 0
    
    search(nil)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    UIApplication.sharedApplication().statusBarStyle = .Default
  }
  
  func cancel() {
    delegate?.sendVCDidComplete()
  }
  
  func search() {
    DubyDatabase.getFollowersAndSesh(nil) { (followers, sesh, error) -> Void in
      self.process(nil, followers: followers, sesh: sesh)
    }
  }
  
  func search(queryText: String?) {
    
    if (queryText == nil && originalFollowers != nil && originalSesh != nil) {
      process(queryText, followers: originalFollowers, sesh: originalSesh)
      return
    }
    
    MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    DubyDatabase.getFollowersAndSesh(queryText) { (followers, sesh, error) -> Void in
      MBProgressHUD.hideHUDForView(self.view, animated: true)
      self.process(queryText, followers: followers, sesh: sesh)
    }
  }
  
  func process(queryText: String?, followers: [DubyUser]?, sesh: [DubyUser]?) {
    if let followers = followers, sesh = sesh {
      let sorted = followers.reduce([String: [DubyUser]](), combine: { (sorted, user) -> [String: [DubyUser]] in
        var tmpSorted = sorted
        print(user.username)
        let index = Array(user.username.uppercaseString.characters)[0]
        
        let trueIndex = self.letters.contains(index) ? String(index) : "#"
        
        if tmpSorted[trueIndex] == nil {
          tmpSorted[trueIndex] = [DubyUser]()
        }
        
        tmpSorted[trueIndex]!.append(user)
        
        return tmpSorted
      })
      
      self.followers = sorted
      self.indices = Array(sorted.keys).sort{ $0 < $1 }
      if (self.indices.count != 0 && self.indices[0] == "#") {
        self.indices.removeAtIndex(0);
        self.indices.append("#")
      }
      
      self.sesh = sesh
      
      if (queryText == nil) {
        self.originalFollowers = followers
        self.originalSesh = sesh
      }
      
      if (self.tableView != nil) {
       self.tableView.reloadData()
      }
      
    }
  }
  
  @IBAction func sendTouchUp(button: UIButton!) {
    if (!allSelected) {
      params["userIds"] = Array(selected)
    }
    
    button.enabled = false
    PFCloud.callFunctionInBackground("sendPMAll", withParameters: params, block: { (resp, error) -> Void in
      if (error == nil) {
        MBProgressHUD.hideHUDForView(self.view, animated: true);
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "PMComposerVC")
        tracker.set("event", value: "pm_created")
        tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject: AnyObject])
      } else {
        MBProgressHUD.hideHUDForView(self.view, animated: true);
        print(error);
      }
      
      button.enabled = true
    })
    
    let tracker = GAI.sharedInstance().defaultTracker
    tracker.set(kGAIScreenName, value: "PMComposerVC")
    tracker.set("event", value: "pm_created")
    tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject: AnyObject])
    
    self.delegate?.sendVCDidComplete()
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    
    switch (indexPath.row) {
    case 0:
      return PMSearchCell.height()
    case 1:
      return PMAllCell.height()
    case 2:
      return PMUserCell.height()
    default:
      return PMUserCell.height()
    }
    
  }
  
  func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]! {
    return indices
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return indices.count + 3
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch (section) {
    case 0:
      return 1;
    case 1:
      return inSearchMode ? 0 : 1;
    case 2:
      return inSearchMode ? 0 : sesh.count;
    default:
      let index = indices[section-3]
      return followers[index]!.count
    }
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    switch(section) {
    case 0:
      return 0;
    case 1:
      return inSearchMode ? 0 : 20
    case 2:
      return inSearchMode ? 0 : 20
    default:
      return 20
    }
  }
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 20))
    label.backgroundColor = UIColor(white: 1, alpha: 0.9)
    label.font = UIFont.openSansSemiBold(16)
    label.textColor = UIColor.newDubyBlue()
    
    switch (section) {
    case 0:
      break;
    case 1:
      label.text = "   My Duby Story";
    case 2:
      label.text = "   My Sesh"
    default:
      let index = indices[section-3]
      label.text = "   \(index)"
    }
    
    return label
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let section = indexPath.section
    let row = indexPath.row
    
    
    switch(section) {
    case 0:
      let searchCell = tableView.dequeueReusableCellWithIdentifier(searchCellIden) as! PMSearchCell
      searchCell.update(self, placeholder: "Search your followers")
      return searchCell
    case 1:
      let allCell = tableView.dequeueReusableCellWithIdentifier(allCellIden) as! PMAllCell
      allCell.update(allSelected, delegate: self)
      return allCell
    case 2:
      let userCell = tableView.dequeueReusableCellWithIdentifier(userCellIden) as! PMUserCell
      let user = sesh[row]
      userCell.update(user, selected: selected.contains(user.objectId), delegate: self)
      return userCell
    default:
      let userCell = tableView.dequeueReusableCellWithIdentifier(userCellIden) as! PMUserCell
      
      let index = indices[section-3]
      let user = followers[index]![row]
      
      userCell.update(user, selected: selected.contains(user.objectId), delegate: self)
      return userCell
    }
  }
  
  func userCellDidSelect(cell: PMUserCell, user: DubyUser) {
    allSelected = false
    footer.backgroundColor = UIColor.newDubyBlue()
    
    let id = user.objectId
    if selected.contains(id) {
      selected.remove(id)
      
      if selected.count == 0 {
        footerHeightConstraint.constant = 0
        UIView.animateWithDuration(Double(0.25), animations: {
          self.view.layoutIfNeeded()
        })
      }
    } else {
      selected.insert(id)
      
      footerHeightConstraint.constant = 58
      UIView.animateWithDuration(Double(0.25), animations: {
        self.view.layoutIfNeeded()
      })
    }
    
    tableView.reloadData()
  }
  
  func allCellDidSelect(cell: PMAllCell) {
    if (allSelected) {
      allSelected = false
      footerHeightConstraint.constant = 0
      UIView.animateWithDuration(Double(0.25), animations: {
        self.view.layoutIfNeeded()
      })
    } else {
      selected.removeAll(keepCapacity: true)
      allSelected = true
      
      footer.backgroundColor = UIColor.dubyGreen()
      footerHeightConstraint.constant = 58
      UIView.animateWithDuration(Double(0.25), animations: {
        self.view.layoutIfNeeded()
      })
      
    }
    
    tableView.reloadData()
  }
  
  func searchCellDidSearch(cell: PMSearchCell, text: String) {
    inSearchMode = true
    search(text)
  }
  
  func searchCellDidClear(cell: PMSearchCell) {
    inSearchMode = false
    search(nil)
  }
  
}