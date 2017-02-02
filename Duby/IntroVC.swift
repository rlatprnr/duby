//
//  Intro2VC.swift
//  Duby
//
//  Created by Aziz on 2015-10-06.
//  Copyright (c) 2015 PragmaOnce, LLC. All rights reserved.
//

import UIKit

@objc protocol IntroVCDelegate {
  func introVCDidFinish()
}

class IntroVC: UIViewController, UIScrollViewDelegate {
  @IBOutlet var skipButton: UIButton!
  @IBOutlet var startButton: UIButton!

  @IBOutlet var pageControl: UIPageControl!
  @IBOutlet var scrollView: UIScrollView!
  
  weak var delegate: IntroVCDelegate!
  
  required init(delegate: IntroVCDelegate) {
    self.delegate = delegate
    super.init(nibName: "IntroVC", bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    startButton.alpha = 0
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    setupScrollView()
  }
  
  func setupScrollView() {

    
    let width = scrollView.frame.size.width
    let height = scrollView.frame.size.height

    for i in 0...3 {
      let containerView = UIView(frame: CGRect(x: CGFloat(i) * width, y: 0, width: width, height: height))
      
      let imageView = UIImageView(frame: CGRect(x: 0, y: 99, width: width, height: height-(99*2)))
      imageView.contentMode = .ScaleAspectFit
      imageView.image = UIImage(named: "intro_view_\(i+1)")
      
      containerView.backgroundColor = i == 3 ? UIColor.yellowColor() : UIColor.dubyBlue()
      
      containerView.addSubview(imageView)
      scrollView.addSubview(containerView)
    }
    
    scrollView.contentSize = CGSize(width: width * 4, height: height)
  }
  
  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    let width = scrollView.frame.size.width
    let page = Int(scrollView.contentOffset.x / width)
    pageControl.currentPage = page
    
    
    UIView.animateWithDuration(0.2) { () -> Void in
      self.startButton.alpha = page != 3 ? 0 : 1
      self.skipButton.alpha = page == 3 ? 0 : 1
    }
    
    //scrollView.backgroundColor = page == 3 ? UIColor.yellowColor() : UIColor.dubyBlue()
  }
  
  @IBAction func skipTouchUp() {
    delegate.introVCDidFinish()
  }
  
  @IBAction func startTouchUp() {
    delegate.introVCDidFinish()
  }
}
