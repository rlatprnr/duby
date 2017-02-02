//
//  DubyFlowLayout.swift
//  Duby
//
//  Created by Harsh Damania on 2/11/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

/// Setup when a pinterest type collection view was on the table. WE DO NOT USE THIS ANYWHERE
class DubyFlowLayout: UICollectionViewFlowLayout {
  
  var totalHeight: CGFloat = 0
  
  override func awakeFromNib() {
    minimumInteritemSpacing = 8
    minimumLineSpacing = 8
    
    sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
  }
  
  override func collectionViewContentSize() -> CGSize {
    return CGSize(width: CGRectGetWidth(UIScreen.mainScreen().bounds), height: totalHeight/2)
  }
  
  override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    let attributes = super.layoutAttributesForElementsInRect(rect)! as [UICollectionViewLayoutAttributes]
    for att in attributes {
      if att.representedElementKind == nil {
        let indexPath = att.indexPath
        att.frame = layoutAttributesForItemAtIndexPath(indexPath)!.frame
        
        totalHeight += CGRectGetHeight(att.frame)
      }
    }
    
    return attributes
  }
  
  override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
    let attributes = super.layoutAttributesForItemAtIndexPath(indexPath)! as UICollectionViewLayoutAttributes
    
    if indexPath.item < 2 {
      var frame = attributes.frame
      frame.origin.y = 8
      attributes.frame = frame
      return attributes
    }
    
    let aboveCellIndexPath = NSIndexPath(forItem: indexPath.item-2, inSection: 0)
    
    let cellAboveFrame = layoutAttributesForItemAtIndexPath(aboveCellIndexPath)!.frame
    let originY = CGRectGetMaxY(cellAboveFrame) + 8
    
    if CGRectGetMinY(attributes.frame) <= originY {
      return attributes // top 2 crept in
    }
    
    var newFrame = attributes.frame
    newFrame.origin.y = originY
    attributes.frame = newFrame
    
    return attributes
  }
  
}
