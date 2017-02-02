//
//  DubyView.swift
//  Duby
//
//  Created by Harsh Damania on 1/21/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

protocol DubyViewDelegate {
    func dubyActionCompleted(accepted accepted: Bool)
    func dubyTapped()
}

class DubyView: UIView {
    
    private let OUT_OF_BOUNDS_X: CGFloat = 800
    private let SWIPE_RANGE: CGFloat = 120
    
    
    var dubyImage: UIImage? {
        didSet {
            imageView.image = dubyImage
        }
    }
    
    var descriptionText: String?
    
    var dubyImageURL: String? {
        didSet {
//            if index <= 2 {
            imageView.setImageWithURLString(dubyImageURL!, placeholderImage: nil) { (_, _, _) -> Void in
                self.imageView.alpha = 1
            }

//                imageView.sd_setImageWithURL(NSURL(string: dubyImageURL!))
//            }
        }
    }

    var location: String! {
        didSet {
            locationLabel.text = location
        }
    }
    
    var commentCount: Int! {
        didSet {
            commentCountButton.setTitle("\(Constants.getCountText(commentCount))", forState: .Normal)
        }
    }
    
    var index: Int!
    var delegate: DubyViewDelegate?
    var willBeVisible: Bool = false { // about to come on. probably start loading the image
        didSet {
            if willBeVisible {
//                if index > 2 {
                imageView.setImageWithURLString(dubyImageURL!, placeholderImage: nil, completion: { (_, _, _) -> Void in
                    self.imageView.alpha = 1
                })

//                }
            }
        }
    }
    
    // is the top card. 
    // We now show the duby message if no image
    // We now bring up the black bar at the bottom if needed
    // We now set evey subviews alpha to 1
    var isTop: Bool = false {
        didSet {
            if isTop {
                let padding: CGFloat = 20
                let height: CGFloat = 30
                
                let commentX: CGFloat = 8
                let y = CGRectGetHeight(frame) - commentX - height // subtract bottom padding too = x = 8
                let commentWidth: CGFloat = 35
                
                commentCountButton.frame = CGRect(x: commentX, y: y, width: commentWidth, height: height)
                
                // set location label
                let x: CGFloat = 2*commentX + commentWidth // 2 8px padding on comment count button
                let width: CGFloat = CGRectGetWidth(frame) - x - padding
                
                locationLabel.frame = CGRect(x: x, y: y, width: width, height: height)
                
                let blackBarView = UIView(frame: CGRect(x: 0, y: CGRectGetMinY(locationLabel.frame) - 4, width: CGRectGetWidth(frame), height: CGRectGetHeight(frame) - CGRectGetMinY(locationLabel.frame) + 8))
                blackBarView.backgroundColor = UIColor.blackColor().alpha(0.6)
                addSubview(blackBarView)
                bringSubviewToFront(locationLabel)
                bringSubviewToFront(commentCountButton)
                blackBarView.hidden = true
                locationLabel.hidden = true
                commentCountButton.hidden = true
                
                // description label if no image
                if (dubyImageURL!).characters.count <= 0 {
                    imageView.backgroundColor = UIColor.whiteColor()
                    descriptionLabel.text = descriptionText!
                    descriptionLabel.textColor = UIColor.blackColor()
                    bringSubviewToFront(descriptionLabel)

                    let descX = padding
                    let descY: CGFloat = 8
                    let descWidth: CGFloat = CGRectGetWidth(frame) - (2 * padding)
                    let descHeight: CGFloat = CGRectGetMinY(locationLabel.frame) - descY - 8
                    
                    descriptionLabel.frame = CGRect(x: descX, y: descY, width: descWidth, height: descHeight)
                    
                } else {
                    descriptionLabel.text = ""
                }
            }
        }
    }

    var imageView: UIImageView!
    var locationLabel: UILabel!
    var descriptionLabel: UILabel!
    var commentCountButton: UIButton!
    var videoImageView: UIImageView!
    
    // stuff for dragging
    private var originalCenter: CGPoint = CGPointZero
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    // Everythig done programmaticly, YAY! :/
    private func customInit() {
        
        backgroundColor = UIColor.clearColor()
        clipsToBounds = false
        
        
        
        imageView = UIImageView(frame: CGRectZero)
        locationLabel = UILabel(frame: CGRectZero)
        descriptionLabel = UILabel(frame: CGRectZero)
        commentCountButton = UIButton(frame: CGRectZero)
        videoImageView = UIImageView(frame: CGRectZero)
        
        locationLabel.textAlignment = .Right
        locationLabel.text = ""
        locationLabel.textColor = UIColor.whiteColor()
        locationLabel.font = UIFont.openSans(14)
        locationLabel.minimumScaleFactor = 0.7
        
        descriptionLabel.textAlignment = .Center
        descriptionLabel.text = ""
        descriptionLabel.textColor = UIColor.blackColor()
        descriptionLabel.font = UIFont.openSans(16)
        descriptionLabel.minimumScaleFactor = 0.7
        descriptionLabel.numberOfLines = 0
//        descriptionLabel.alpha = 0
        
        commentCountButton.setTitle("\(0)", forState: .Normal)
        commentCountButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        commentCountButton.titleLabel?.font = UIFont.openSans(14)
        commentCountButton.setImage(UIImage(named: "icon-comment"), forState: .Normal)
        commentCountButton.imageView?.image = UIImage(named: "icon-comment")?.imageWithRenderingMode(.AlwaysTemplate)
        commentCountButton.titleLabel?.minimumScaleFactor = 0.7
        commentCountButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        commentCountButton.userInteractionEnabled = false
        
        imageView.image = dubyImage
        imageView.backgroundColor = UIColor.dubyLightGray()
        imageView.alpha = 0
        //TODO: adjust for placeholders later, when we get them
        imageView.contentMode = .ScaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        videoImageView.image = UIImage(named: "camera")
        videoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(imageView)
        addSubview(locationLabel)
        addSubview(descriptionLabel)
        addSubview(commentCountButton)
        addSubview(videoImageView)
        
        setConstraints()
        
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "swipingView:"))
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapped"))
        
        layer.cornerRadius = 3.0
        layer.masksToBounds = true
        layer.borderWidth = 2.0
        layer.borderColor = UIColor(white: 1.0, alpha: 0.82).CGColor
        
    }
    
    private func setConstraints() {
        let imageTrailing = NSLayoutConstraint(item: imageView, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1.0, constant: 0)
        let imageLeading = NSLayoutConstraint(item: imageView, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 0)
        let imageTop = NSLayoutConstraint(item: imageView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0)
        let imageBottom = NSLayoutConstraint(item: imageView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0)
        let vidTop = NSLayoutConstraint(item: videoImageView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 10)
        let vidRight = NSLayoutConstraint(item: videoImageView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant: -10)
        
        addConstraints([imageTrailing, imageLeading, imageTop, imageBottom, vidTop, vidRight])
    }
    
    /// Card tapped
    func tapped() {
        delegate?.dubyTapped()
    }
    
    /// Animate the location label, comment count button and description label
    func animateNeededSubviews() {
        UIView.animateWithDuration(0.33, animations: { () -> Void in
            self.locationLabel.alpha = 1
            self.commentCountButton.alpha = 1
            if (self.dubyImageURL!).characters.count <= 0 {
                self.descriptionLabel.alpha = 1
            } else {
                self.descriptionLabel.alpha = 0
            }
        })
    }
    
    /// View is about to dragged somehow
    func swipingView(gesture: UIPanGestureRecognizer) {
        let gesturePoint = gesture.translationInView(self)
        
        switch gesture.state {
            case .Began: // Just beginning the gesture, set original center
                originalCenter = center
            case .Changed: // Something is changed. Adjust view center based on drag and also adjust card rotation
                
                center = CGPoint(x: originalCenter.x + gesturePoint.x, y: originalCenter.y + gesturePoint.y)
            
                let rotationAmount = min(gesturePoint.x/CGRectGetWidth(UIScreen.mainScreen().bounds), 1)
                let rotationAngle = CGFloat(M_PI_4/4) * rotationAmount
                
                var rotationTransform = CGAffineTransformMakeRotation(rotationAngle)
                transform = CGAffineTransformMakeRotation(rotationAngle)

                self.layoutIfNeeded()
            case .Ended: // Gesture ended, now decide what to do
                if gesturePoint.x > SWIPE_RANGE { // accepted
                    UIView.animateWithDuration(0.33, animations: { () -> Void in
                        self.center = CGPoint(x: self.OUT_OF_BOUNDS_X, y: gesturePoint.y + self.center.y - 40)
                        self.layoutIfNeeded()
                    }, completion: { (_) -> Void in
                        self.removeFromSuperview()
                        self.delegate?.dubyActionCompleted(accepted: true)
                        
                        let tracker = GAI.sharedInstance().defaultTracker
                        tracker.send(GAIDictionaryBuilder.createEventWithCategory(ANALYTICS_CATEGORY_UI_ACTION, action: ANALYTICS_ACTION_UI_DUBY_SWIPE, label: "duby_passed", value: nil).build() as [NSObject: AnyObject])
                    })
                } else if gesturePoint.x < -SWIPE_RANGE { // rejected
                    UIView.animateWithDuration(0.33, animations: { () -> Void in
                        self.center = CGPoint(x: -self.OUT_OF_BOUNDS_X, y: gesturePoint.y + self.center.y + 40)
                        self.layoutIfNeeded()
                    }, completion: { (_) -> Void in
                        self.removeFromSuperview()
                        self.delegate?.dubyActionCompleted(accepted: false)
                        
                        let tracker = GAI.sharedInstance().defaultTracker
                        tracker.send(GAIDictionaryBuilder.createEventWithCategory(ANALYTICS_CATEGORY_UI_ACTION, action: ANALYTICS_ACTION_UI_DUBY_SWIPE, label: "duby_put_out", value: nil).build() as [NSObject: AnyObject])
                    })
                } else { // User wasn't too sure i guess
                    backToCenter()
                }
            case .Failed: fallthrough
            case .Possible: fallthrough
            case .Cancelled:
                backToCenter()
        }
    }
    
    /// bring the card back to the center some springiness
    func backToCenter() {
        UIView.animateWithDuration(0.33, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 40, options: UIViewAnimationOptions.TransitionNone, animations: { () -> Void in
            self.center = self.originalCenter
            self.transform = CGAffineTransformMakeRotation(0)
            self.layoutIfNeeded()
        }, completion: { (_) -> Void in
                print("decided nothing")
        })
    }
    
    // Duby is shared
    func dubyAccepted() {
        UIView.animateWithDuration(0.33, animations: { () -> Void in
            self.center = CGPoint(x: self.OUT_OF_BOUNDS_X, y: self.center.y)
            self.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4/4))
        }, completion: { (_) -> Void in
            self.removeFromSuperview()
            self.delegate?.dubyActionCompleted(accepted: true)
        })
    }
    
    // duby is rejected
    func dubyDenied() {
        UIView.animateWithDuration(0.33, animations: { () -> Void in
            self.center = CGPoint(x: -self.OUT_OF_BOUNDS_X, y: self.center.y)
            self.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4/4))
        }, completion: { (_) -> Void in
            self.removeFromSuperview()
            self.delegate?.dubyActionCompleted(accepted: false)
        })
    }

}
