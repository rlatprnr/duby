//
//  SearchVC.swift
//  Duby
//
//  Created by Wilson on 1/14/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

class SearchVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, UserCellDelegate, SearchCellDelegate, SearchHeaderViewProtocol {
  
  @IBOutlet weak var searchField: UITextField!
  
  private var searchHeaderView : SearchHeaderView?
  
  private var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
  private var noDubyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 30))
  
  private var tapGesture: UITapGestureRecognizer!
  
  private var dubies = [Duby]()
  private var users = [DubyUser]()
  
  var selectedIndex = 1
  
  override func viewDidLoad() {
    let translucentWhite = UIColor.whiteColor().alpha(0.6)
    
    navigationController?.navigationBar.translucent = true
    navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
    navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
    navigationController?.navigationBar.shadowImage = UIImage.solidImage(CGSize(width: CGRectGetWidth(UIScreen.mainScreen().bounds), height: 0.5), color: translucentWhite)
    (navigationController as! DubyNavVC).barColor = .Clear
    
    collectionView?.registerClass(SearchHeaderView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "searchHeaderView")
    collectionView?.registerNib(UINib(nibName: "UserCell", bundle: nil), forCellWithReuseIdentifier: "userCell")
    collectionView?.registerNib(UINib(nibName: "SearchCell", bundle: nil), forCellWithReuseIdentifier: "searchCell")
    
    edgesForExtendedLayout = .None
    
    searchField.delegate = self
    searchField.textColor = UIColor.whiteColor()
    searchField.attributedPlaceholder = NSAttributedString(string: searchField.placeholder!, attributes: [NSForegroundColorAttributeName : translucentWhite])
    
    collectionView?.backgroundColor = UIColor.clearColor()
    
    let x = CGRectGetWidth(UIScreen.mainScreen().bounds) / 2
    let y = (CGRectGetHeight(UIScreen.mainScreen().bounds) - CGRectGetMaxY(navigationController!.navigationBar.frame)) / 2
    
    activityIndicator.center = CGPoint(x: x, y: y)
    
    noDubyLabel.center = CGPoint(x: x, y: y)
    noDubyLabel.text = "No Dubys for Search"
    noDubyLabel.textColor = UIColor.whiteColor()
    noDubyLabel.font = UIFont.openSans(13)
    noDubyLabel.textAlignment = .Center
    
    noDubyLabel.hidden = true
    activityIndicator.hidden = true
    
    view.addSubview(noDubyLabel)
    view.sendSubviewToBack(noDubyLabel)
    
    // to dismiss the keyboard
    tapGesture = UITapGestureRecognizer(target: self, action: "viewTapped")
    
    //        dataModel.getTrendingDubys { (gotTrending) -> Void in
    //            if gotTrending {
    //                self.resetCollectionView()
    //            }
    //        }
    
    // getting the data and setting the selected segment to trending
    segValueChanged(1)
  }
  
  override func viewWillAppear(animated: Bool) {
    UIApplication.sharedApplication().statusBarStyle = .LightContent
    navigationController?.navigationBar.shadowImage = UIImage.solidImage(CGSize(width: CGRectGetWidth(UIScreen.mainScreen().bounds), height: 0.5), color: UIColor.whiteColor().alpha(0.6))
  }
  
  override func viewDidAppear(animated: Bool) {
    // analytics
    let tracker = GAI.sharedInstance().defaultTracker
    tracker.set(kGAIScreenName, value: "Search")
    tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject: AnyObject])
    
    super.viewDidAppear(animated)
    
    // show tips
    if !UserDefaults.hasSeenTips(.Search) {
      UserDefaults.sawTips(.Search)
      navigationController?.presentTips(.Search)
    }
    
    UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)

  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.navigationBar.shadowImage = UIImage()
  }
  
  
  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
    
    print("DID DISAPPEAR")
  }
  
  
  
  
  
  
  
  
  
  
  // send collection view back to top and reload
  func resetCollectionView() {
    collectionView!.reloadData()
    collectionView?.contentOffset = CGPoint(x: 0, y: 0)
  }
  
  func searchHashtags(queryText: String) {
    MBProgressHUD.showHUDAddedTo(view, animated: true)
    view.userInteractionEnabled = false
    searchField.userInteractionEnabled = false
    
    searchHeaderView?.segControl.selectedSegmentIndex = UISegmentedControlNoSegment
    
    DubyDatabase.getDubysWithHashtag(queryText, limit: 50, page: 0) { (dubys, error) -> Void in
      if (dubys != nil) {
        self.dubies = dubys!
        self.selectedIndex = -1
        self.resetCollectionView()
        
        /* Display/Hide No Duby Label */
        if self.dubies.count == 0 {
          self.noDubyLabel.hidden = false
        } else {
          self.noDubyLabel.hidden = true
        }
      }
      
      MBProgressHUD.hideHUDForView(self.view, animated: true)
      self.view.userInteractionEnabled = true
      self.searchField.userInteractionEnabled = true
    }
  }
  
  func searchUsers(queryText: String) {
    MBProgressHUD.showHUDAddedTo(view, animated: true)
    view.userInteractionEnabled = false
    searchField.userInteractionEnabled = false
    
    searchHeaderView?.segControl.selectedSegmentIndex = UISegmentedControlNoSegment
    
    DubyDatabase.searchUsers(queryText) { (users, error) -> Void in
      if (users != nil) {
        self.users = users!
        self.selectedIndex = -2
        self.resetCollectionView()
        
        /* Display/Hide No Duby Label */
        if self.dubies.count == 0 {
          self.noDubyLabel.hidden = false
        } else {
          self.noDubyLabel.hidden = true
        }
      }
      
      MBProgressHUD.hideHUDForView(self.view, animated: true)
      self.view.userInteractionEnabled = true
      self.searchField.userInteractionEnabled = true
    }
  }
  
  func search() {
    searchField.resignFirstResponder()
    var queryText = searchField.text!
    
    if queryText.hasPrefix("#") {
      queryText = queryText.substringFromIndex(queryText.startIndex.advancedBy(1))
      
      if queryText.characters.count == 0 {
      } else {
        searchHashtags(queryText);
      }
    } else if queryText.hasPrefix("@") {
      queryText = queryText.substringFromIndex(queryText.startIndex.advancedBy(1))
      
      if queryText.characters.count == 0 {
      } else {
        searchUsers(queryText);
      }
    } else {
      searchField.text = "#" + "\(queryText)"
      if queryText.characters.count == 0 {
      } else {
        searchHashtags(queryText);
      }
    }
    
  }
  
  // MARK:-SearchHeaderViewProtocol
  func segValueChanged(index: Int) {
    
    MBProgressHUD.showHUDAddedTo(view, animated: true)
    view.userInteractionEnabled = false
    searchField.userInteractionEnabled = false
    
    searchField.text = ""
    searchField.resignFirstResponder()
    if searchHeaderView?.segControl.selectedSegmentIndex == UISegmentedControlNoSegment {
      searchHeaderView?.segControl.selectedSegmentIndex = index
    }
    
    if index == 0 {
      DubyDatabase.getRecentDubys(0, page: 0) { (dubys, error) -> Void in
        if (dubys != nil) {
          self.dubies = dubys!
          self.selectedIndex = 0
          self.resetCollectionView()
          
          /* Display/Hide No Duby Label */
          if self.dubies.count == 0 {
            self.noDubyLabel.hidden = false
          } else {
            self.noDubyLabel.hidden = true
          }
        }
        
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        self.view.userInteractionEnabled = true
        self.searchField.userInteractionEnabled = true
      }
    } else if index == 1 {
      DubyDatabase.getTrendingDubys() { (dubys, error) -> Void in
        if (dubys != nil) {
          self.dubies = dubys!
          self.selectedIndex = 1
          self.resetCollectionView()
          
          /* Display/Hide No Duby Label */
          if self.dubies.count == 0 {
            self.noDubyLabel.hidden = false
          } else {
            self.noDubyLabel.hidden = true
          }
        }
        
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        self.view.userInteractionEnabled = true
        self.searchField.userInteractionEnabled = true
      }
    } else if index == 2 {
      DubyDatabase.getLocalDubys() { (dubys, error) -> Void in
        if (dubys != nil) {
          self.dubies = dubys!
          self.selectedIndex = 2
          self.resetCollectionView()
          
          /* Display/Hide No Duby Label */
          if self.dubies.count == 0 {
            self.noDubyLabel.hidden = false
          } else {
            self.noDubyLabel.hidden = true
          }
        }
        
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        self.view.userInteractionEnabled = true
        self.searchField.userInteractionEnabled = true
      }
    } else if index == 3 {
      DubyDatabase.getTopUsers() { (users, error) -> Void in
        if (users != nil) {
          self.users = users!
          self.selectedIndex = 3
          self.resetCollectionView()
          
          /* Display/Hide No Duby Label */
          if self.dubies.count == 0 {
            self.noDubyLabel.hidden = false
          } else {
            self.noDubyLabel.hidden = true
          }
        }
        
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        self.view.userInteractionEnabled = true
        self.searchField.userInteractionEnabled = true
      }
    }
    else {
      MBProgressHUD.hideHUDForView(self.view, animated: true)
      view.userInteractionEnabled = true
      self.searchField.userInteractionEnabled = true
    }
    
    let tracker = GAI.sharedInstance().defaultTracker
    tracker.send(GAIDictionaryBuilder.createEventWithCategory(ANALYTICS_CATEGORY_UI_ACTION, action: ANALYTICS_ACTION_UI_BUTTON_TAP, label: "search_tab_index", value: index).build() as [NSObject: AnyObject])
  }
  
  //MARK: collectionview
  
  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if selectedIndex == 3 || selectedIndex == -2 {
      return users.count
    }
    return dubies.count
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    var width = CGRectGetWidth(UIScreen.mainScreen().bounds)
    width -= 24 // 8px padding on either side and 8px in the middle
    width /= 2
    
    return CGSize(width: width, height: 240 + (width - 145)) // constant height for now
  }
  
  override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    
    
    let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "searchHeaderView", forIndexPath: indexPath) as! SearchHeaderView
    headerView.delegate = self
    searchHeaderView = headerView
    
    return headerView
  }
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    if selectedIndex == 3 || selectedIndex == -2 {
      let cell = collectionView.dequeueReusableCellWithReuseIdentifier("userCell", forIndexPath: indexPath) as! UserCell
      cell.setUserData(users[indexPath.item])
      cell.index = indexPath.item
      cell.delegate = self
      
      return cell
    }
    
    
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("searchCell", forIndexPath: indexPath) as! SearchCell
    cell.setDubyData(dubies[indexPath.item])
    cell.index = indexPath.item
    cell.delegate = self
    
    return cell
  }
  
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    if selectedIndex == 3 || selectedIndex == -2 {
      navigationController?.pushToProfileVC(user: users[indexPath.item])
    } else {
      navigationController?.pushToDetailsVC(duby: dubies[indexPath.item])
    }
  }
  
  override func scrollViewDidScroll(scrollView: UIScrollView) {
    if searchField.isFirstResponder() {
      searchField.resignFirstResponder()
    }
    
    let offset = scrollView.contentOffset.y
//    let contentHeight = scrollView.contentSize.height
//    let collectionHeight = scrollView.frame.height
    
    //        if offset > (contentHeight - collectionHeight) {
    //            if dataModel.addAdditionalDubys() {
    //                collectionView?.reloadData()
    //            }
    //        }
    
    if offset < 44 {
      searchHeaderView?.backgroundColor = UIColor(
        red: 0.141,
        green: 0.49,
        blue: 0.623,
        alpha: CGFloat(offset/44)
      )
    } else {
      searchHeaderView?.backgroundColor = UIColor(
        red: 0.141,
        green: 0.49,
        blue: 0.623,
        alpha: CGFloat(0.85)
      )
    }
    
  }
  
  //MARK: cell delegate
  
  func searchCellDidTapUser(cellIndex: Int) {
    if selectedIndex == 3 || selectedIndex == -2 {
      navigationController?.pushToProfileVC(user: users[cellIndex])
    } else {
      navigationController?.pushToProfileVC(user: dubies[cellIndex].createdBy)
    }
  }
  
  func searchCellDidTapPassers(duby: Duby) {
    navigationController?.pushToDubyPassersVC(duby: duby)
  }
  
  func userCellDidTapUser(user: DubyUser) {
    navigationController?.pushToProfileVC(user: user)
  }
  
  func userCellDidTapBoost(user: DubyUser) {
    if user.boost != nil {
      showMessage("This user has been boosted! They can now share to \(user.influence + user.boost!) people.")
    } else {
      showMessage("Every time this user shares a Duby it goes to \(user.influence) people.")
    }

  }
  
  func showMessage(string: String) {
    let alert = UIAlertController(title: "Info", message: string, preferredStyle: UIAlertControllerStyle.Alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:nil))
    self.presentViewController(alert, animated: true, completion: nil)
  }
  
  //MARK: textfield
  
  func textFieldDidBeginEditing(textField: UITextField) {
    collectionView?.setContentOffset(collectionView!.contentOffset, animated: false)
    
    //        if textField.text == "" {
    //            textField.text = "#"
    //        }
    //
    view.addGestureRecognizer(tapGesture)
    
    let keyboardDoneButtonView = UIToolbar()
    keyboardDoneButtonView.tintColor = UIColor.blackColor()
    keyboardDoneButtonView.sizeToFit()
    
    // Setup the buttons to be put in the system.
    let item = UIBarButtonItem(title: "Search", style: UIBarButtonItemStyle.Done, target: self, action: Selector("search") )
    let flex = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
    let toolbarButtons = [flex, item]
    
    //Put the buttons into the ToolBar and display the tool bar
    keyboardDoneButtonView.setItems(toolbarButtons, animated: false)
    textField.inputAccessoryView = keyboardDoneButtonView
  }
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    //        if string != "" {
    //            if count(string) > 1 {
    //                if (string as NSString).rangeOfCharacterFromSet(NSCharacterSet.alphanumericCharacterSet()).location == NSNotFound {
    //                    return false
    //                }
    //            }
    //        }
    //
    return true
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    search();
    return true
  }
  
  func textFieldDidEndEditing(textField: UITextField) {
    view.removeGestureRecognizer(tapGesture)
  }
  
  //MARK: gesture
  
  func viewTapped() {
    searchField.resignFirstResponder()
  }
  
  
}
