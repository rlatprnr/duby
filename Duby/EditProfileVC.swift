//
//  EditProfileVC.swift
//  Duby
//
//  Created by Harsh Damania on 2/2/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

import UIKit
import MobileCoreServices

class EditProfileVC: UITableViewController, CellDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    private var dataModel: EditModel = EditModel()
    private var updatingBioHeight: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.dubyBlue(), NSFontAttributeName: UIFont.openSans(17.0)]
        let attributes = [NSForegroundColorAttributeName: UIColor.darkGrayColor(), NSFontAttributeName: UIFont.openSans(16.0)]
        doneButton.setTitleTextAttributes(attributes, forState: .Normal)
        cancelButton.setTitleTextAttributes(attributes, forState: .Normal)

        navigationController?.navigationBar.backgroundColor = UIColor.whiteColor()

        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView()
    }
    
    func privacyStatementView() -> UITextView {
        let attributedStr = NSMutableAttributedString(string: PRIVACY_STATEMENT)
//        attributedStr.addAttribute(NSLinkAttributeName, value: "https://duby.co/privacy", range: <#NSRange#>)
        let textView = UITextView(frame: CGRectMake(0, 0, CGRectGetWidth(UIScreen.mainScreen().bounds), 15))
        textView.editable = false
        textView.attributedText = attributedStr
        var frame = textView.frame
        frame.size.height = textView.contentSize.height
        textView.frame = frame
        return textView
    }

    // save data
    @IBAction func donePressed(sender: AnyObject) {
        view.userInteractionEnabled = false
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        
//        if updateEmail && newEmail != nil && newEmail!.isEmail() {
//            DubyDatabase.setEmail(newEmail!)
//        }
      
        dataModel.updateUser { (dismissViewController) -> Void in
            if dismissViewController {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
          
            NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_PROFILE_UPDATED, object: nil)

          
            self.view.userInteractionEnabled = true
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        }
    }
    
    @IBAction func cancelPressed(sender: AnyObject) {
        view.endEditing(true)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: cell delegate
    
    // cell delegates. something was updated, update model
    
    func updateBioCellHeight(newHeight: CGFloat) {
        updatingBioHeight = true
        dataModel.bioCellHeight = newHeight
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func bioUpdated(bio: String) {
        dataModel.bioUpdated(bio)
    }
    
    func usernameUpdated(newUsername: String) {
        dataModel.usernameUpdated(newUsername)
    }
    
    func emailUpdated(newEmail: String) {
        dataModel.emailUpdated(newEmail)
    }
    
    func genderUpdated(isMale: Bool) {
        dataModel.genderUpdated(isMale)
    }
    
    func firstnameUpdated(firstname: String) {
        dataModel.firstnameUpdated(firstname)
    }

    func lastnameUpdated(lastname: String) {
        dataModel.lastnameUpdated(lastname)
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 5
        } else if section == 1 {
            return 1
        } else if section == 2 {
            return 5
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 2 {
            if dataModel.bioCellHeight <= 0 {
                return EditModel.getInitialBioHeight()
            }
            
            return dataModel.bioCellHeight
        } else if indexPath.section == 2 && indexPath.row == 4 {
            return Constants.getHeightForText(PRIVACY_STATEMENT, width: CGRectGetWidth(UIScreen.mainScreen().bounds), font: UIFont.openSans(10)) + 45
        } else {
            return dataModel.cellHeight
        }
    }
    
    func updatePM(switchw: UISwitch) {
        dataModel.pmDisabledUpdated(!switchw.on)
    }
  
    func updateTrackMyDubies(switchw: UISwitch) {
      dataModel.dubyTrackUpdated(switchw.on)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("EditProfilePicCell", forIndexPath: indexPath) as! EditProfilePicCell
                cell.setCellData()
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCellWithIdentifier("EditTextViewCell", forIndexPath: indexPath) as! EditTextViewCell
                cell.setCellData(EditModel.getCellDataForIndexPath(indexPath))
                cell.delegate = self
                return cell
            } else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCellWithIdentifier("EditTextViewCell", forIndexPath: indexPath) as! EditTextViewCell
                if !updatingBioHeight {
                    cell.setCellData(EditModel.getCellDataForIndexPath(indexPath))
                }
                cell.delegate = self
                return cell
            } else if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCellWithIdentifier("EditLabelSwitchControlCell",  forIndexPath: indexPath) as! EditLabelSwitchControlCell
                cell.switche.on = !DubyUser.currentUser.pmDisabled
                cell.switche.addTarget(self, action: "updatePM:", forControlEvents: UIControlEvents.ValueChanged)
                return cell
            } else if indexPath.row == 4 {
              let cell = tableView.dequeueReusableCellWithIdentifier("EditLabelSwitchControlCell",  forIndexPath: indexPath) as! EditLabelSwitchControlCell
              cell.switche.on = DubyUser.currentUser.dubyTrackDisabled
              //cell.infoLabel.text = "Go Anonymous. \nDisables tracking and shows minimal location info"
              let style = ["red": [NSForegroundColorAttributeName: UIColor.redColor()]]
              let atrString = try! SLSMarkupParser.attributedStringWithMarkup("<red>Go Anonymous:</red> \nDisables tracking and shows minimal location info", style: style)
              cell.infoLabel.attributedText = atrString
              //print("disabled2: \(DubyUser.currentUser.dubyTrackDisabled)")
              cell.switche.addTarget(self, action: "updateTrackMyDubies:", forControlEvents: UIControlEvents.ValueChanged)
              return cell
          }
        } else  if indexPath.section == 1 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("middleCell", forIndexPath: indexPath) 
                return cell
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("EditTextViewCell", forIndexPath: indexPath) as! EditTextViewCell
                cell.setCellData(EditModel.getCellDataForIndexPath(indexPath))
                cell.delegate = self
                return cell
            }else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCellWithIdentifier("EditTextViewCell", forIndexPath: indexPath) as! EditTextViewCell
                cell.setCellData(EditModel.getCellDataForIndexPath(indexPath))
                cell.delegate = self
                return cell
            }else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCellWithIdentifier("EditTextViewCell", forIndexPath: indexPath) as! EditTextViewCell
                cell.setCellData(EditModel.getCellDataForIndexPath(indexPath))
                cell.delegate = self
                return cell
            } else if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCellWithIdentifier("EditLabelSegemntedControlCell", forIndexPath: indexPath) as! EditLabelSegemntedControlCell
                cell.setCellData(EditModel.getCellDataForIndexPath(indexPath))
                cell.delegate = self
                return cell
            } else if indexPath.row == 4 {
                let cell = tableView.dequeueReusableCellWithIdentifier("PrivacyStatementCell", forIndexPath: indexPath) as! PrivacyStatementCell
                return cell
            }
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) 
        
        // Configure the cell...
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            let actionSheet = UIActionSheet(title: "Select a Mode", delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
            actionSheet.addButtonWithTitle("Camera")
            actionSheet.addButtonWithTitle("Photo Library")
            actionSheet.addButtonWithTitle("Cancel")
            
            actionSheet.cancelButtonIndex = 2
//            if DubyUser.currentUser.profilePicURL != "" {
//                actionSheet.addButtonWithTitle("Remove Profile Picture")
//            }
            
            actionSheet.showInView(UIApplication.sharedApplication().keyWindow!)
        }
    }
    
    //MARK: action sheet
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == actionSheet.cancelButtonIndex {
            return
        }
        
        if buttonIndex == 0 {
            openCamera()
        } else if buttonIndex == 1 {
            openLibrary()
        }
    }
    
    func openCamera() {
        let picker = UIImagePickerController()
        picker.sourceType = .Camera;
        picker.mediaTypes = [kUTTypeImage as String]
        picker.allowsEditing = true
        picker.delegate = self
        picker.navigationBar.titleTextAttributes = nil
        picker.navigationBar.tintColor = nil
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func openLibrary() {
        let picker = UIImagePickerController()
        
        picker.sourceType = .PhotoLibrary;
        picker.mediaTypes = [kUTTypeImage as String]
        picker.allowsEditing = true
        picker.delegate = self
        picker.navigationBar.titleTextAttributes = nil
        picker.navigationBar.tintColor = nil
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
//    func pictureDeleted() {
//        dataModel.picUpdated(nil)
//    }
    
    //MARK: picker delegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        dataModel.picUpdated(image)
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Fade)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}
