//
//  HashtagsVC.swift
//  Duby
//
//  Created by Aziz on 2015-06-01.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit


class HashtagsVC: UICollectionViewController, SearchCellDelegate, UICollectionViewDelegateFlowLayout {
  let reuseIdentifier = "searchCell"
  
  var hashtag: String!
  var dubies = [Duby]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    self.title = "#" + hashtag
    
    (navigationController as! DubyNavVC).barColor = .White
    view.addSubview(UINavigationBar.dubyWhiteBar())
    
    edgesForExtendedLayout = .None
    
    collectionView?.contentInset = UIEdgeInsetsMake(8, 6, 8, 6)
    collectionView?.backgroundColor = UIColor.clearColor()
    collectionView?.backgroundView = nil
    collectionView?.registerNib(UINib(nibName: "SearchCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
    self.collectionView!.collectionViewLayout = UICollectionViewFlowLayout()
    
    // Do any additional setup after loading the view.
    
    
    DubyDatabase.getDubysWithHashtag(hashtag, limit: 50, page: 0) { (dubies, error) -> Void in
      print(dubies)
      if dubies != nil {
        self.dubies = dubies!
        self.collectionView?.reloadData()
      }
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    UIApplication.sharedApplication().statusBarStyle = .Default
  }
  
  
  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    //#warning Incomplete method implementation -- Return the number of sections
    return 1
  }
  
  
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    //#warning Incomplete method implementation -- Return the number of items in the section
    return dubies.count
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    var width = CGRectGetWidth(UIScreen.mainScreen().bounds)
    width -= 24 // 8px padding on either side and 8px in the middle
    width /= 2
    
    return CGSize(width: width, height: 240 + (width - 145)) // constant height for now
  }
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! SearchCell
    cell.setDubyData(dubies[indexPath.row])
    cell.index = indexPath.item
    cell.delegate = self
    
    return cell
  }
  
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    navigationController?.pushToDetailsVC(duby: dubies[indexPath.item])
  }

  func searchCellDidTapUser(cellIndex: Int) {
    navigationController?.pushToProfileVC(user: dubies[cellIndex].createdBy)
  }
  
  func searchCellDidTapPassers(duby: Duby) {
    navigationController?.pushToDubyPassersVC(duby: duby)
  }
}



