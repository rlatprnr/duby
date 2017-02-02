//
//  SearchHeaderView.swift
//  Duby
//
//  Created by Anurag Kamasamudram on 3/19/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

@objc protocol SearchHeaderViewProtocol {
    func segValueChanged(index: Int)
}

class SearchHeaderView: UICollectionReusableView {

    /* Outlets */
    @IBOutlet weak var segControl: UISegmentedControl!
    @IBOutlet weak var sepA: UIView!
    @IBOutlet weak var sepB: UIView!

    /* Variables */
    var delegate : SearchHeaderViewProtocol?
    
    override func awakeFromNib() {
        
        /* Set text color & font of selected/unselected tabs */
        segControl.setTitleTextAttributes([NSFontAttributeName:UIFont.openSans(14), NSForegroundColorAttributeName:UIColor.dubyBlue()], forState: .Normal)
        segControl.setTitleTextAttributes([NSFontAttributeName:UIFont.openSans(14), NSForegroundColorAttributeName:UIColor.whiteColor()], forState: .Selected)
        
//        var rA = sepA.frame;
//        var rB = sepB.frame;
//        
//        rA.origin.x = frame.size.width * 0.33;
//        rB.origin.x = frame.size.width * 0.66;
//        
//        sepA.frame = rA;
//        sepB.frame = rB;
    }
    
    override func layoutSubviews() {
        var rA = sepA.frame;
        var rB = sepB.frame;
        
        rA.origin.x = frame.size.width * 0.33;
        rB.origin.x = frame.size.width * 0.66;
        
        sepA.translatesAutoresizingMaskIntoConstraints = true;
        sepB.translatesAutoresizingMaskIntoConstraints = true;
        
        sepA.frame = rA;
        sepB.frame = rB;
    }
    
    /* MARK:-Segmented Control Delegates */
    @IBAction func segControlValueChanged(sender: AnyObject) {
        delegate?.segValueChanged(segControl.selectedSegmentIndex)
    }
}
