//
//  BackgroundContainverVC.swift
//  Duby
//
//  Created by Harsh Damania on 1/17/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

class BackgroundContainverVC: UIViewController {

    // background for login/sign up
    @IBOutlet weak var backgroundImageView: UIImageView!
    private var blurredImage: Bool = false {
        didSet {
            UIView.transitionWithView(backgroundImageView, duration: 0.33, options: .TransitionCrossDissolve, animations: { () -> Void in
                self.backgroundImageView.image = UIImage(named: self.blurredImage == true ? "image-background-login-blurred" : "image-background-login-sharp")
            }, completion: nil)
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "blurBackground", name: "blurImage", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sharpenBackground", name: "sharpImage", object: nil)
    }
    
    func blurBackground() {
        blurredImage = true
    }
    
    func sharpenBackground() {
        blurredImage = false
    }
    
//    override func  presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
//        println("presentin NEW VC MAFAK");
//    }
}
