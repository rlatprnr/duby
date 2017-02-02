//
//  CommentsContainerVC.swift
//  Duby
//
//  Created by Harsh Damania on 2/14/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

/// Container VC that contains the comments table VC and the textview at the bottom
class CommentsContainerVC: UIViewController, UITextViewDelegate {

    @IBOutlet weak var commentPlaceholder: UILabel!
    @IBOutlet weak var newCommentTextView: UITextView!
    
    @IBOutlet weak var commentsView: UIView!
    @IBOutlet weak var commentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentViewToBottomConstraint: NSLayoutConstraint!
    
    private var commentsTableVC: CommentsTableVC!
    
    private let initialCommentHeight: CGFloat = 28
    private var commentHeight: CGFloat = 28
    
    var duby: Duby!
    
    var dataModel: CommentsModel!
    
    var showKeyboardOnStart: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if dataModel == nil {
            dataModel = CommentsModel()
        }
        
        (navigationController as! DubyNavVC).barColor = .Clear
        edgesForExtendedLayout = .None
        
        view.backgroundColor = UIColor.clearColor()
        commentsView.backgroundColor = UIColor.clearColor()
        
        newCommentTextView.text = ""
        newCommentTextView.textColor = UIColor.whiteColor()
        newCommentTextView.tintColor = UIColor.whiteColor()
        newCommentTextView.backgroundColor = UIColor.clearColor()
        newCommentTextView.textContainerInset = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
        newCommentTextView.delegate = self
        newCommentTextView.bounces = false
        
        commentPlaceholder.hidden = false
        commentPlaceholder.textColor = UIColor.whiteColor().alpha(0.6)
        
        if !dataModel.gettingComments {
            if !dataModel.hasComments {
                getComments()
            }
        } else {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotComments", name: "GotComments", object: nil)
        }
    }
    
    // get comments maybe if needed
    func getComments() {
        dataModel.getCommentsForDuby(duby, completion: { (gotDubys) -> (Void) in
            if gotDubys {
                if self.dataModel.comments.count > 0 {
                    self.commentsTableVC.loadComments()
                } else {
                    // show message
                }
            } else {
                // show message
            }
        })
    }
    
    // got the comments, now reload the table vc
    func gotComments() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "GotComments", object: nil)
        
        if dataModel.comments.count > 0 {
            commentsTableVC.loadComments()
        } else {
            // show message
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        newCommentTextView.resignFirstResponder()
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //MARK: keyboard
    
    func keyboardWillHide(notification: NSNotification) {
        let duration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let curve = (notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber) as UInt
//        let keyboardFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
      
        // adjust the textview frame
        UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions(rawValue: curve), animations: { () -> Void in
            
            self.commentViewToBottomConstraint.constant = 0
            self.commentsTableVC.removeTapGesture()
            self.view.layoutIfNeeded()
            
        }) { (completed: Bool) -> Void in
                
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let duration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let curve = (notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber) as UInt
        let keyboardFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        // adjust the textview frame
        UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions(rawValue: curve), animations: { () -> Void in
            
            self.commentViewToBottomConstraint.constant = keyboardFrame.height
            
            self.commentsTableVC.addTapGesture()
            self.view.layoutIfNeeded()
            self.commentsTableVC.scrollToBottom()
            
        }) { (completed: Bool) -> Void in
                
        }
    }
    
    //MARK: 
    
    func hideKeyboard() {
        newCommentTextView.resignFirstResponder()
    }
    
    //MARK: textview
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == "" {
            commentPlaceholder.hidden = true
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == "" {
            commentPlaceholder.hidden = false
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" { // send pressed
            textView.resignFirstResponder()
            
            if textView.text != "" {
                dataModel.commentCount++
                dataModel.postComment(textView.text, completion: { () -> Void in
                    self.commentsTableVC.loadComments()
                    print("RELOADING");
                })
            }

            textView.text = ""
            commentPlaceholder.hidden = false
            
            commentHeight = initialCommentHeight
            commentViewHeightConstraint.constant = commentHeight + 12
            
            commentsTableVC.loadComments()
            
            return false
        }
        
        var adjustedText: NSString = textView.text
        
        if text != "" { // something added
            adjustedText = "\(adjustedText)\(text)"
        } else { // text deleted
            adjustedText = adjustedText.substringToIndex(range.location)
        }
        
        if adjustedText.length > 140 {
            return false
        }
        
        let textPadding: CGFloat = 8
        var height = Constants.getHeightForText(adjustedText, width: textView.contentSize.width - 10, font: textView.font!) + textPadding
        
        height = height < initialCommentHeight ? initialCommentHeight : height
        
        if height != commentHeight {
            commentViewHeightConstraint.constant = height + 12 // 6px padding top and bottom
            view.layoutIfNeeded()
            commentHeight = height
            
            commentsTableVC.scrollToBottom()
        }
        
        return true
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CommentsTableVC" {
            
            if dataModel == nil {
                dataModel = CommentsModel()
            }
            
            commentsTableVC = segue.destinationViewController as! CommentsTableVC
            commentsTableVC.sender = self
            commentsTableVC.dataModel = dataModel
            
        }
    }

}
