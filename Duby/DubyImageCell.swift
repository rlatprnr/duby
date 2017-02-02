//
//  DubyImageCell.swift
//  Duby
//
//  Created by Harsh Damania on 1/23/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit
import MediaPlayer

protocol DubyImageCellDelegate: class {
  func imageCellDidRejectDuby()
  func imageCellDidAcceptDuby()
}

class DubyImageCell: UITableViewCell {
  
  @IBOutlet weak var dubyRejectButton: UIButton!
  @IBOutlet weak var dubyAcceptButton: UIButton!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var putoutImageVew: UIImageView!
  @IBOutlet weak var passedImageView: UIImageView!
  @IBOutlet weak var locationLabel: UILabel!
  
  
  var mediaPlayer: MPMoviePlayerController?
  
  @IBOutlet weak  var dubyImageView: UIImageView!
  var selectedDuby: Duby? {
    didSet { // If no image, we show text on the card itself
      if selectedDuby!.imageURL.characters.count > 0 {
        dubyImageView.setImageWithURLString(selectedDuby!.imageURL, placeholderImage: nil, completion: nil)
        descriptionLabel.hidden = true
        dubyImageView.backgroundColor = UIColor.blackColor().alpha(0.2)
        
        if (selectedDuby?.videoURL != "") {
          if mediaPlayer != nil {
            mediaPlayer!.stop()
            mediaPlayer!.view.removeFromSuperview()
            mediaPlayer = nil
          }
          mediaPlayer = MPMoviePlayerController(contentURL: NSURL(string: selectedDuby!.videoURL))
          mediaPlayer?.view.frame = dubyImageView.frame
          mediaPlayer?.controlStyle = MPMovieControlStyle.None//= MPMovieplayer
          mediaPlayer?.repeatMode = MPMovieRepeatMode.One
          mediaPlayer?.prepareToPlay()
          mediaPlayer?.scalingMode = .AspectFill
          self.contentView.insertSubview(mediaPlayer!.view, aboveSubview: dubyImageView)
          mediaPlayer?.play()
        }
      } else {
        descriptionLabel.hidden = false
        descriptionLabel.text = selectedDuby?.description
        dubyImageView.backgroundColor = UIColor.dubyLightGray()
      }
      
      locationLabel.text = selectedDuby!.location
      
    }
  }
  
  func removePlayer() {
    if mediaPlayer != nil {
      mediaPlayer!.stop()
      mediaPlayer!.view.removeFromSuperview()
      mediaPlayer = nil
    }
  }
  
  weak var delegate: DubyImageCellDelegate?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    backgroundColor = UIColor.clearColor()
    contentView.backgroundColor = UIColor.clearColor()
    
    dubyImageView.backgroundColor = UIColor.dubyLightGray()
    
    dubyImageView.clipsToBounds = true
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    mediaPlayer?.view.frame = dubyImageView.frame
  }
  
  func hideButtons() {
    dubyRejectButton.hidden = true
    dubyAcceptButton.hidden = true
  }
  
  func showButtons() {
    dubyRejectButton.hidden = false
    dubyAcceptButton.hidden = false
  }
  
  func setStatus(status: Int) {
    putoutImageVew.hidden = status != 2;
    passedImageView.hidden = status != 3;
  }
  
  @IBAction func dubyDenied(sender: AnyObject) {
    delegate?.imageCellDidRejectDuby()
  }
  
  @IBAction func dubyAccepted(sender: AnyObject) {
    delegate?.imageCellDidAcceptDuby()
  }
}