//
//  PMSendVC.swift
//  Duby
//
//  Created by Aziz on 9/11/15.
//  Copyright (c) 2015 PragmaOnce, LLC. All rights reserved.
//

//implement counting of pmduby times

import UIKit


@objc protocol LocalUsersVCDelegate {
  func localUsersVCDidFinish()
}


class LocalUsersVC : UIViewController, UITableViewDataSource, UITableViewDelegate, PMUserCellDelegate, PMSearchCellDelegate {
  @IBOutlet var tableView: UITableView!
  @IBOutlet var footer: UIView!
  @IBOutlet var footerLabel: UILabel!
  @IBOutlet var footerHeightConstraint: NSLayoutConstraint!

  
  weak var delegate: LocalUsersVCDelegate?
  
  var users = [DubyUser]()
  
  var selected = Set<String>()
  
  var inSearchMode = false
  
  
  let userCellIden = "PMUserCell"
  let searchCellIden = "PMSearchCell"
  
  required init() {
    super.init(nibName: "LocalUsersVC", bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Follow Users Near You"
    
    edgesForExtendedLayout = .None
    
    navigationController?.navigationBar.translucent = true
    navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
    navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
    navigationController?.navigationBar.shadowImage = UIImage()
    
    (navigationController as! DubyNavVC).barColor = .NewBlue
    view.addSubview(UINavigationBar.dubyWhiteBar())
        
    
    tableView.registerNib(UINib(nibName: userCellIden, bundle: nil), forCellReuseIdentifier: userCellIden)
    tableView.registerNib(UINib(nibName: searchCellIden, bundle: nil), forCellReuseIdentifier: searchCellIden)
    tableView.sectionIndexColor = UIColor.lightGrayColor()
    tableView.contentInset = UIEdgeInsetsMake(0, 0, footer.frame.size.height, 0)
    
    footer.backgroundColor = UIColor.dubyGreen()
//    footerHeightConstraint.constant = 0
    
    
    let skipButton = UIBarButtonItem(title: "Skip", style: .Plain, target: self, action: "skip")
    navigationItem.rightBarButtonItem = skipButton
    
    search(nil)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    UIApplication.sharedApplication().statusBarStyle = .Default
  }
  
  func search() {
    DubyDatabase.getLocalUsers { (users, error) -> Void in
      if let users = users {
        self.users = users
        self.tableView.reloadData()
      }
    }
  }
  
  func skip() {
    self.dismissViewControllerAnimated(true, completion: { () -> Void in
      self.delegate?.localUsersVCDidFinish()
    })
  }
  
  func search(queryText: String?) {
    if (queryText == nil) {
      search()
      return
    }
    
    MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    DubyDatabase.searchUsers(queryText!) { (users, error) -> Void in
      MBProgressHUD.hideHUDForView(self.view, animated: true)
      if let users = users {
        self.users = users
        self.tableView.reloadData()
      }
    }
  }
  
  
  @IBAction func sendTouchUp(button: UIButton!) {
    MBProgressHUD.showHUDAddedTo(view, animated: true)
    
    PFCloud.callFunctionInBackground("followAll", withParameters: ["userIds" : Array(selected)]) { (resp, error) -> Void in
      MBProgressHUD.hideHUDForView(self.view, animated: true)
      self.dismissViewControllerAnimated(true, completion: { () -> Void in
        self.delegate?.localUsersVCDidFinish()
      })
    }
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    
    switch (indexPath.section) {
    case 0:
      return PMSearchCell.height()
    case 1:
      return PMUserCell.height()
    default:
      return 20
    }
  }
  
  
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch (section) {
    case 0:
      return 1;
    case 1:
      return users.count
    default:
      return 0
    }
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 20
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
      label.text = "   Users";
    default:
      break;
    }
    
    return label
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let section = indexPath.section
    let row = indexPath.row
    
    
    switch(section) {
    case 0:
      let searchCell = tableView.dequeueReusableCellWithIdentifier(searchCellIden) as! PMSearchCell
      searchCell.update(self, placeholder: "Search any user")
      return searchCell
    case 1:
      let userCell = tableView.dequeueReusableCellWithIdentifier(userCellIden) as! PMUserCell
      let user = users[row]
      userCell.update(user, selected: selected.contains(user.objectId), delegate: self)
      return userCell
    default:
      return UITableViewCell()
    }
  }
  
  func userCellDidSelect(cell: PMUserCell, user: DubyUser) {
    footer.backgroundColor = UIColor.newDubyBlue()
    
    let id = user.objectId
    if selected.contains(id) {
      selected.remove(id)
    } else {
      selected.insert(id)
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