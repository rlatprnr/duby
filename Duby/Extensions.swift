//
//  Extensions.swift
//  Duby
//
//  Created by Harsh Damania on 3/22/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

//MAKR: Color
extension UIColor {
    class func dubyBlue() -> UIColor {
        return UIColor(red: 0/255.0, green: 89/255.0, blue: 169/255.0, alpha: 1.0)
    }
  
    class func newDubyBlue() -> UIColor {
      return UIColor(red:0.23, green:0.60, blue:0.76, alpha:1.0)
    }
  
    class func dubyGreen() -> UIColor {
        return UIColor(red: 151/255.0, green: 199/255.0, blue: 44/255.0, alpha: 1.0)
    }
    
    class func dubyGray() -> UIColor {
        return UIColor(red: 174/255.0, green: 170/255.0, blue: 166/255.0, alpha: 1.0)
    }
    
    class func dubyLightGray() -> UIColor {
        return UIColor(red: 236/255.0, green: 237/255.0, blue: 238/255.0, alpha: 1.0)
    }
    
    func alpha(alpha: CGFloat) -> UIColor {
        var r: CGFloat = 0
        var b: CGFloat = 0
        var g: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return UIColor(red: r, green: g, blue: b, alpha: alpha)
    }
}

//MARK: font
extension UIFont {
    class func openSans(size: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans", size: size)!
    }
    
    class func openSansLight(size: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-Light", size: size)!
    }
    
    class func openSansSemiBold(size: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-SemiBold", size: size)!
    }
  
    class func openSansBold(size: CGFloat) -> UIFont {
      return UIFont(name: "OpenSans-Bold", size: size)!
    }
  
    class func lato(size: CGFloat) -> UIFont {
        return UIFont(name: "Lato", size: size)!
    }
}

//MARK: String
extension String {
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    func isEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        return NSPredicate(format:"SELF MATCHES %@", emailRegEx).evaluateWithObject(self)
    }
    
    func getHashtags() -> [String] {
        let words = self.characters.split {$0 == " "}.map { String($0) }
        let alphanumericSet = NSCharacterSet.alphanumericCharacterSet()
        
        var hashtags = [String]()
        for word in words {
            if word[0] == "#" && word.characters.count > 1 {
                let hashtagWord = word.substringFromIndex(self.startIndex.advancedBy(1))
                let wordComponents = hashtagWord.componentsSeparatedByCharactersInSet(alphanumericSet.invertedSet)
                let hashtag = wordComponents.first!
                hashtags.append(hashtag.lowercaseString)
            }
        }
        
        return hashtags
    }
    
    func getSize(maxHeight: CGFloat, maxWidth: CGFloat, font: UIFont) -> CGSize {
        return self.boundingRectWithSize(CGSizeMake(maxWidth, maxHeight), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil).size
    }
    
    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = self.startIndex.advancedBy(r.startIndex)
            let endIndex = startIndex.advancedBy(r.endIndex - r.startIndex)
            
            return self[Range(start: startIndex, end: endIndex)]
        }
    }
}

// MARK: Array
extension Array {
    
    func unique <T: Equatable> () -> [T] {
        var result = [T]()
        
        for item in self {
            
            if !result.contains(item as! T) {
                result.append(item as! T)
            }
        }
        
        return result
    }
}

//MARK: Navigation Controller
extension UINavigationController {
    
    func pushToProfileVC(user user: DubyUser?) {
        
        if user != nil && user?.objectId != "" {
            let profileVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ProfileVC") as! ProfileVC
            profileVC.user = user
            
            pushViewController(profileVC, animated: true)
        }
    }
    
    func pushToDetailsVC(duby duby: Duby?) {
        if duby != nil && duby?.objectId != "" {
            let detailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("DetailsTableVC") as! DetailsTableVC
            detailsVC.selectedDuby = duby
            
            pushViewController(detailsVC, animated: true)
        }
    }
    
    func pushToDubyDetailsVC(duby duby: Duby?) {
        if duby != nil && duby?.objectId != "" {
            let dubyDetailsvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("DubyDetailsCollectionVC") as! DubyDetailsCollectionVC
            dubyDetailsvc.duby = duby
            
            pushViewController(dubyDetailsvc, animated: true)
        }
    }
  
    func pushToDubyPassersVC(duby duby: Duby?) {
      if duby != nil && duby?.objectId != "" {
        let dubyDetailsvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PassersVC") as! PassersVC
        dubyDetailsvc.dubyId = duby?.objectId
        
        pushViewController(dubyDetailsvc, animated: true)
      }
    }
  
    func presentTips(tipType: TipsControllers) {
        let deviceName = Constants.currentDeviceModelName()
        let tipsImage = UIImage.tipsImage(tipType, deviceName: deviceName as String)
        
        if tipsImage != nil {
            let tipsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("TipsVC") as! TipsVC
            tipsVC.tipType = tipType
            tipsVC.modalTransitionStyle = .CrossDissolve
            tipsVC.modalPresentationStyle = .OverCurrentContext
            
            tabBarController?.presentViewController(tipsVC, animated: true, completion: nil)
        }
    }
}

//MARK: Navigation Controller
extension UINavigationBar {
    
    class func dubyWhiteBar() -> UINavigationBar {
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: -64, width: CGRectGetWidth(UIScreen.mainScreen().bounds), height: 64))
        navBar.tintColor = UIColor.blackColor()
        navBar.backgroundColor = UIColor.whiteColor()
        navBar.translucent = false
        navBar.layer.name = "duby"
        
        return navBar
    }
}

//MARK: UIImage
extension UIImage {
    class func userPlaceholder() -> UIImage {
        return UIImage(named: "user_placeholder")!
    }
    
    class func heartbeat() -> UIImage {
        return UIImage(named: "heartbeat")!
    }
    
    class func dubyPlaceholder() -> UIImage {
        return UIImage(named: "placeholder-duby")!
    }
    
    class func solidImage(size: CGSize, color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        UIGraphicsBeginImageContext(rect.size);
        let context = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillRect(context, rect);
        
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image;
    }
    
    class func getWhiteNavBarImage(navBarHeight: CGFloat) -> UIImage {
        return UIImage.solidImage(CGSize(width: CGRectGetWidth(UIScreen.mainScreen().bounds), height: navBarHeight), color: UIColor.whiteColor())
    }
    
    class func tipsImage(tipType: TipsControllers, deviceName: String) -> UIImage? {
        
        var nameSuffix = ""
        if deviceName == DEVICE_TYPE_SCREEN_4 {
            nameSuffix = "-4"
        } else if deviceName == DEVICE_TYPE_SCREEN_5 {
            nameSuffix = "-5"
        } else if deviceName == DEVICE_TYPE_SCREEN_6 {
            nameSuffix = "-6"
        } else  if deviceName == DEVICE_TYPE_SCREEN_6_PLUS {
            nameSuffix = "-6-plus"
        }
        
        let imageName = "\(tipType.stringValue)\(nameSuffix)"
        print(imageName)
        print(deviceName)
        
        return UIImage(named: imageName)
    }
  
  
  class func resizedImageToFillWithBounds(image: UIImage, bounds: CGSize) -> UIImage {
    
    let aspectRatio = image.size.width / image.size.height
    let newImageWidth = aspectRatio * bounds.height
    let newSize = CGSize(width: newImageWidth, height: bounds.height)
    
    // Create a new image context and draw the image into the "bounds" instead of "newSize" as was done in the case of the Aspect Fit method.
    UIGraphicsBeginImageContextWithOptions(bounds, true, 0)
    
    let xCoord = -(newImageWidth - bounds.width) / 2
    image.drawInRect(CGRect(origin: CGPoint(x:xCoord, y:0), size: newSize))
    
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
  }
}

//MARK: UIImageView
extension UIImageView {
    
    /**
        Cancels any image currently being loaded for the image view and sets image asynchronously using SDWebImage. If image exists, animates a fade in transition, or else simply displays it. Completion handler called after setting image in case additional data is needed
    */
    func setImageWithURLString(url: String, placeholderImage: UIImage?, completion: ((UIImage?, NSError?, SDImageCacheType?) -> Void)? ) {
        self.sd_cancelCurrentImageLoad()
        
        if url.characters.count > 0 {
            self.sd_setImageWithURL(NSURL(string: url), placeholderImage: placeholderImage) { (returnedImage, error, cacheType, _) -> Void in
                if returnedImage != nil {
                    UIView.transitionWithView(self, duration: cacheType == .None ? 0.33 : 0, options: .TransitionCrossDissolve, animations: { () -> Void in
                        self.image = returnedImage
                    }, completion: nil)
                }
                
                completion?(returnedImage, error, cacheType)
            }
        } else {
            if placeholderImage != nil {
                self.image = placeholderImage
            }
            
            completion?(nil, NSError(domain: "No image url", code: 1234, userInfo: nil), nil)
            return
        }
        
        
    }
}
