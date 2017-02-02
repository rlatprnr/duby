//
//  DetailsTableViewModel.swift
//  Duby
//
//  Created by Harsh Damania on 1/29/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

class DetailsTableViewModel: NSObject {
  
  private var selectedDuby: Duby!
  
  private let cellPadding: CGFloat = 8.0
  
  var descriptionHeight: CGFloat?
  
  // since we also have comments in DetailsVC
  var commentModel = CommentsModel()
  
  var canDelete = false
  var canReport = false
  
  var userSignedUp: Bool = false {
    didSet {
      if userSignedUp {
        canReport = false
        canDelete = false
      }
    }
  }
  
  init(duby: Duby) {
    selectedDuby = duby
    canDelete = DubyUser.currentUser == selectedDuby.createdBy
    canReport = !selectedDuby.currentUserReported
  }
  
  func getNumberOfSections() -> Int {
    if userSignedUp {
      return 1
    }
    
    return 2
  }
  
  func getNumberOfRows(section section: Int) -> Int {
    if section == 0 {
      if selectedDuby.description != "" && selectedDuby.imageURL != "" {
        return 3
      } else {
        return 2
      }
    } else if section == 1 { // comments
      if commentModel.comments.count > 5 {
        return 5 // + 1 for "add comment" row
      } else {
        return commentModel.comments.count
      }
    }
    
    return 0
  }
  
  func heightForRowAtIndexPath(indexPath: NSIndexPath) -> CGFloat {
    if indexPath.section == 0 {
      switch indexPath.row {
      case 0:
        return CGRectGetWidth(UIScreen.mainScreen().bounds)
      case 1:
        return 40.0
      case 2:
        
        if selectedDuby.imageURL.characters.count <= 0 {
          descriptionHeight = 0
          return 0
        }
        
        descriptionHeight = Constants.getHeightForText(selectedDuby.description, width: CGRectGetWidth(UIScreen.mainScreen().bounds) - 2*16, font: UIFont.openSans(14))
        
        descriptionHeight = descriptionHeight < 26.0 ? 26.0 : descriptionHeight
        let cellHeight = descriptionHeight! + 2*cellPadding
        return cellHeight
      default:
        return 0
      }
    } else if indexPath.section == 1 {
      //            if indexPath.row != (getNumberOfRows(section: 1) - 1) {
      return commentModel.getCellSizeAtIndex(indexPath.row, details: true).height + 8
      //            }
    }
    
    return 0
  }
  
  
  /// Section Header for table view. Only used for "Recent COmments" or "No comments"
  func getHeaderView(section: Int) -> UIView {
    if section == 0 {
      return UIView(frame: CGRectZero)
    } else {
      
      if commentModel.comments.count > 0 {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: CGRectGetWidth(UIScreen.mainScreen().bounds), height: 30))
        headerView.backgroundColor = UIColor.clearColor()
        
        let separatorView = UIView(frame: CGRect(x: 0, y: 0, width: CGRectGetWidth(UIScreen.mainScreen().bounds), height: 0.5))
        separatorView.alpha = 0.6
        separatorView.backgroundColor = UIColor.whiteColor()
        headerView.addSubview(separatorView)
        
        var labelFrame = headerView.frame
        labelFrame.origin.x = 16
        labelFrame.size.height = 30
        let label = UILabel(frame: labelFrame)
        
        if commentModel.hasComments && commentModel.comments.count <= 0 {
          label.text = "No Comments"
        } else if !commentModel.hasComments || commentModel.comments.count > 0 {
          label.text = "(\(commentModel.comments.count)) Recent Comments"
        }
        
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.openSansSemiBold(15)
        headerView.addSubview(label)
        
        return headerView
      } else {
        return UIView(frame: CGRectZero)
      }
      
    }
  }
  
  /// Section footer for table view for "Add comment"
  func getFooterView(section: Int) -> UIView {
    if section == 0 {
      return UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    } else {
      let footerView = UIView(frame: CGRect(x: 0, y: 0, width: CGRectGetWidth(UIScreen.mainScreen().bounds), height: 44))
      footerView.backgroundColor = UIColor.clearColor()
      
      let separatorView = UIView(frame: CGRect(x: 0, y: 4, width: CGRectGetWidth(UIScreen.mainScreen().bounds), height: 0.5))
      separatorView.alpha = 0.6
      separatorView.backgroundColor = UIColor.whiteColor()
      footerView.addSubview(separatorView)
      
      var buttonFrame = footerView.frame
      buttonFrame.origin.x = 16
      buttonFrame.origin.y = 4
      buttonFrame.size.height = 40
      buttonFrame.size.width -= 32
      
      let button = UIButton(frame: buttonFrame)
      button.setTitle("Add a Comment", forState: .Normal)
      button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
      button.titleLabel?.font = UIFont.openSans(15)
      button.tag = 5
      footerView.addSubview(button)
      
      let rightArrow = UIImageView(image: UIImage(named: "icon-arrow-right"))
      var frame = rightArrow.frame
      frame.origin.x = CGRectGetWidth(UIScreen.mainScreen().bounds) - 16 - CGRectGetWidth(frame)
      
      rightArrow.frame = frame
      rightArrow.center = CGPoint(x: rightArrow.center.x, y: button.center.y)
      
      footerView.addSubview(rightArrow)
      
      return footerView
    }
  }
  
}
