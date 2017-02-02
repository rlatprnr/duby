//
//  CreateImageCell.swift
//  Duby
//
//  Created by Harsh Damania on 2/22/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit
import MediaPlayer

class CreateImageCell: UITableViewCell {
    
    @IBOutlet weak var dubyImageView: UIImageView!
    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var xButton: UIButton!
    var mediaPlayer: MPMoviePlayerController?
    var dataModel: CreateModel!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.clearColor()
        contentView.backgroundColor = UIColor.clearColor()
        
        dubyImageView.image = nil
        
        imageIcon.hidden = false
        xButton.hidden = true
    }

    @IBAction func xButtonPressed(sender: AnyObject) {
        clearView()
    }
    
    /// Call if image removed or duby created
    func clearView() {
        dubyImageView.image = nil
        imageIcon.hidden = false
        xButton.hidden = true
        
        dataModel.dubyImage = nil
        dubyImageView.backgroundColor = UIColor.clearColor()
        
        mediaPlayer?.stop()
        mediaPlayer?.view.removeFromSuperview()
        mediaPlayer = nil
    }
    
    func setDubyData(image: UIImage?, videoURL: String?) {
        dubyImageView.image = image
        
        if videoURL == nil {
            mediaPlayer?.stop()
            mediaPlayer?.view.removeFromSuperview()
            mediaPlayer = nil
        } else {
            mediaPlayer = MPMoviePlayerController(contentURL: NSURL(string: videoURL!))
            mediaPlayer?.view.frame = dubyImageView.frame
            mediaPlayer?.controlStyle = MPMovieControlStyle.None//= MPMovieplayer
            mediaPlayer?.repeatMode = MPMovieRepeatMode.One
            mediaPlayer?.prepareToPlay()
            mediaPlayer?.scalingMode = .AspectFill
            self.contentView.insertSubview(mediaPlayer!.view, aboveSubview: dubyImageView)
            //self.contentView.addSubview(mediaPlayer!.view)
            mediaPlayer?.play()
        }
        
        
        if image == nil {
            clearView()
            
            dubyImageView.backgroundColor = UIColor.clearColor()
        } else {
            imageIcon.hidden = true
            xButton.hidden = false
            
            dubyImageView.backgroundColor = UIColor.blackColor().alpha(0.2)
        }
        
    }
}
