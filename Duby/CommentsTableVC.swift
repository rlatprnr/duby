//
//  CommentsTableVC.swift
//  Duby
//
//  Created by Harsh Damania on 2/14/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

class CommentsTableVC: UITableViewController, CommentCellDelegate {
  
  private var tapGesture: UITapGestureRecognizer!
  var sender: CommentsContainerVC!
  
  var dataModel = CommentsModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.backgroundColor = UIColor.clearColor()
    
    // tap to dismiss the keyboard
    tapGesture = UITapGestureRecognizer(target: self, action: "tapped")
  }
  
  override func viewWillAppear(animated: Bool) {
    scrollToBottom()
  }
  
  func scrollToBottom() {
    if dataModel.comments.count > 0 {
      tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: dataModel.comments.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: false)
    }
    
  }
  
  func addTapGesture() {
    tableView.addGestureRecognizer(tapGesture)
  }
  
  func removeTapGesture() {
    tableView.removeGestureRecognizer(tapGesture)
  }
  
  func tapped() {
    sender.hideKeyboard()
  }
  
  func loadComments() {
    tableView.reloadData()
    scrollToBottom()
  }
  
  //MARK: cell delegate
  
  func toProfileVC(index index: Int) {
    navigationController?.pushToProfileVC(user: dataModel.getCommentAtIndex(index).comment.sender)
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataModel.comments.count
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    let size = dataModel.getCellSizeAtIndex(indexPath.row, details: false)
    
    return size.height + 8 // 4px padding on either side
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let commentInfo = dataModel.getCommentAtIndex(indexPath.row)
    let size = dataModel.getCellSizeAtIndex(indexPath.row, details: false)
    
    if commentInfo.selfSender {
      let cell = tableView.dequeueReusableCellWithIdentifier("RightCommentCell", forIndexPath: indexPath) as! RightCommentCell
      cell.index = indexPath.row
      cell.delegate = self
      cell.setData(commentInfo.comment, size: size)
      
      return cell
    } else {
      let cell = tableView.dequeueReusableCellWithIdentifier("LeftCommentCell", forIndexPath: indexPath) as! LeftCommentCell
      cell.index = indexPath.row
      cell.setData(commentInfo.comment, size: size)
      cell.delegate = self
      
      return cell
    }
  }
  
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return dataModel.isCommentMine(indexPath.row);
  }
  
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if (editingStyle == UITableViewCellEditingStyle.Delete) {
      print(indexPath.row);
      dataModel.deleteComment(indexPath.row);
      tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
    }
  }
  
  override func scrollViewDidScroll(scrollView: UIScrollView) {
    if scrollView.contentOffset.y < 50 {
      if dataModel.addAdditionalComments() {
        tableView.reloadData()
      }
    }
  }

  func commentCellDidTapUser(user: DubyUser) {
    navigationController?.pushToProfileVC(user: user)
  }
  
  func commentCellDidTapUsername(username: String) {
    DubyDatabase.getUser(username, completion: { (user, error) -> (Void) in
      print(user)
      if let dubyUser = user {
        self.navigationController?.pushToProfileVC(user: dubyUser)
      }
    })
    
  }
  
  func commentCellDidTapHashtag(hashtag: String) {
    let hashtagVC = HashtagsVC(collectionViewLayout: UICollectionViewFlowLayout())
    hashtagVC.hashtag = hashtag
    navigationController?.pushViewController(hashtagVC, animated: true)
  }
}
