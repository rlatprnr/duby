//
//  CommentsModel.swift
//  Duby
//
//  Created by Harsh Damania on 2/15/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit

class CommentsModel: NSObject {
    
    private var duby: Duby!
    
    var comments = [DubyComment]()
    var gettingComments = false
    var hasComments = false
    
    var canGetMoreComments = false
    var additionalComments = [DubyComment]()
    
    var commentCount: Int = 0
    
    private let limit = 30
    private var page = 0
    
    private let padding: CGFloat = 8
    private let maxTextWidthRatio: CGFloat = (200 - 16) / 320
    private let minTextHeight: CGFloat = 18
    private let minTextWidth: CGFloat = 16
    
    func getCommentsForDuby(duby: Duby, completion: (Bool) -> (Void)) {
        self.duby = duby
        
        gettingComments = true
        DubyDatabase.getComments(duby: duby, count: limit, page: page) { (comments, count, error) -> Void in
            self.gettingComments = false
            self.hasComments = true
            
            self.commentCount = count
            NSNotificationCenter.defaultCenter().postNotificationName("GotComments", object: nil, userInfo: nil)
            
            if error != nil {
                completion(false)
            } else {
                
                if comments?.count == self.limit {
                    self.canGetMoreComments = true
                    self.page++
                    self.getAdditionalComments()
                }
                
                self.comments = comments!
                completion(true)
            }
        }
    }
    
    func deleteComment(index: Int) {
        let adjustedIndex = comments.count - 1 - index;
        DubyDatabase.deleteComment(comments[adjustedIndex], completion: { (_, _) -> Void in
        });
        comments.removeAtIndex(adjustedIndex);
    }
    
    func isCommentMine(index: Int) -> Bool {
        let comment = comments[comments.count - 1 - index]
        return comment.sender.objectId == DubyUser.currentUser.objectId
    }
    
    func getAdditionalComments() {
        
        canGetMoreComments = false
        DubyDatabase.getComments(duby: duby, count: limit, page: page) { (comments, _, error) -> Void in
            
            if comments != nil {
                self.additionalComments = comments!
                
                if comments?.count == self.limit {
                    self.canGetMoreComments = true
                    self.page++
                }
            } else {
                self.canGetMoreComments = false
            }
        }
    }
    
    /// Pagination call
    func addAdditionalComments() -> Bool {
        if additionalComments.count > 0 {
            comments = comments + additionalComments
            
            additionalComments = [DubyComment]()
            
            if canGetMoreComments {
                getAdditionalComments()
            }

            return true
        } else {
            return false
        }
    }
    
    /// For CommentsVC
    func getCommentAtIndex(index: Int) -> (comment: DubyComment, selfSender: Bool) {
        let comment = comments[comments.count - 1 - index]
        return (comment, comment.sender == DubyUser.currentUser)
    }
    
    /// For DetailsTableVC because we have only 5 comments being shown there
    func getDetailsCommentAtIndex(index: Int) -> (comment: DubyComment, selfSender: Bool) {
        var maxIndex = 0
        
        if comments.count > 5 {
            maxIndex = 4
        } else {
            maxIndex = comments.count - 1
        }
        
        let comment = comments[maxIndex - index]
        return (comment, comment.sender == DubyUser.currentUser)
    }
    
    /// message size for cell
    private func getSizeForMessage(message: String) -> CGSize {
        let maxWidth = maxTextWidthRatio * CGRectGetWidth(UIScreen.mainScreen().bounds)
        
        var size = CGSize(width: minTextWidth + 2*padding, height: minTextHeight)
      
        size = Constants.getRectForText(message, font: UIFont.openSans(13), maxSize: CGSize(width: maxWidth, height: CGFloat(NSIntegerMax))).size
        
        if size.width > maxWidth {
            size.width = maxWidth
        } else if size.width < minTextWidth {
            size.width = minTextWidth
        }
        
        if size.height < minTextHeight {
            size.height = minTextHeight
        }
        
        size.height = ceil(size.height + (2*padding))
        size.width = ceil(size.width + (2*padding)) + 1
        
        return size
    }
   
    /// cell size
    func getCellSizeAtIndex(index: Int, details: Bool) -> CGSize {
        var message = ""
        
        if details {
            message = getDetailsCommentAtIndex(index).comment.message
        } else {
            message = getCommentAtIndex(index).comment.message
        }
        
        return getSizeForMessage(message)
    }
    
    /// Send comment to server
    func postComment(message: String, completion: () -> Void) {
        
        let newComment = DubyComment()
        newComment.sender = DubyUser.currentUser
        newComment.duby = duby
        newComment.message = message
        newComment.createdAt = NSDate()
        
        comments.insert(newComment, atIndex: 0)
        NSNotificationCenter.defaultCenter().postNotificationName("NewComment", object: nil, userInfo: ["objectId" : duby.objectId])
        
        
        DubyDatabase.sendComment(message, duby: duby, completion: {(comment, error) -> Void in
            if comment != nil && error == nil {
                newComment.objectId = comment!.objectId;
            }
            completion();
        })
    }
}
