//
//  FullScreenImageVC.swift
//  Duby
//
//  Created by Anurag Kamasamudram on 3/6/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

class FullScreenImageVC: UIViewController, UIScrollViewDelegate {

    var image : UIImage?
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!

    var profileImageView : UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        scrollview.maximumZoomScale = 6
        
        if image != nil {
            profileImageView = UIImageView(frame: UIScreen.mainScreen().bounds)
            profileImageView?.image = image
            profileImageView?.contentMode = UIViewContentMode.ScaleAspectFit
            scrollview.addSubview(profileImageView!)
            
            profileImageView?.userInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: "imageViewTapped")
            profileImageView?.addGestureRecognizer(tapGesture)
        }
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return profileImageView
    }
    
    func imageViewTapped() {
        if scrollview.zoomScale > 1.0 {
            scrollview.setZoomScale(1.0, animated: true)
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
}