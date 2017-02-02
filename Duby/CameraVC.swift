//
//  CameraVC.swift
//  Duby
//
//  Created by Aziz on 2015-05-26.
//  Copyright (c) 2015 PragmaOnce, LLC. All rights reserved.
//
//
//import UIKit
//import GPUImage
//
//class CameraVC: UIViewController {
//    
//    lazy var camera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPresetHigh, cameraPosition: AVCaptureDevicePosition.Back)
//    
//    lazy var cameraView = GPUImageView(frame: CGRect.zeroRect);
//    lazy var progressView = UIView(frame: CGRect.zeroRect);
//    lazy var toolbar = UIToolbar(frame: CGRect.zeroRect)
//    
//    var progressConstraint: NSLayoutConstraint?
//    
//    let timeStep = 0.1
//    let maxTime = 6.0
//    var timer: NSTimer?
//    var timeElapsed = 0.0
//    var recording = false
//
//    var writer: GPUImageMovieWriter?
//    var movie: GPUImageMovie?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        setupViews()
//        setupCamera()
//        camera.startCameraCapture()
//    }
//    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        timer?.invalidate()
//        timer = NSTimer.scheduledTimerWithTimeInterval(timeStep, target: self, selector: "secondsUp", userInfo: nil, repeats: true)
//    }
//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        timer?.invalidate();
//    }
//    
//    func setupViews() {
//        cameraView.setTranslatesAutoresizingMaskIntoConstraints(false);
//        cameraView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
//        self.view.addSubview(cameraView);
//
//        progressView.setTranslatesAutoresizingMaskIntoConstraints(false);
//        progressView.backgroundColor = UIColor.dubyGreen()
//        self.view.addSubview(progressView)
//        
//        
//        setupToolbar()
//        toolbar.barStyle = UIBarStyle.Black
//        toolbar.setTranslatesAutoresizingMaskIntoConstraints(false)
//        self.view.addSubview(toolbar)
//    
//        
//        let bindings = ["cameraView" : cameraView, "progressView" : progressView, "toolbar" : toolbar]
//        
//        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[cameraView]|",
//            options: NSLayoutFormatOptions(0),
//            metrics: nil,
//            views: bindings))
//        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[cameraView]|",
//            options: NSLayoutFormatOptions(0),
//            metrics: nil,
//            views: bindings))
//        
//        
//        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[progressView]",
//            options: NSLayoutFormatOptions(0),
//            metrics: nil,
//            views: bindings))
//        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[progressView(5)]-44-|",
//            options: NSLayoutFormatOptions(0),
//            metrics: nil,
//            views: bindings))
//        
//        
//        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[toolbar]|",
//            options: NSLayoutFormatOptions(0),
//            metrics: nil,
//            views: bindings))
//        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[toolbar(44)]|",
//            options: NSLayoutFormatOptions(0),
//            metrics: nil,
//            views: bindings))
//        
//        
//        self.updateProgress(0.5)
//    }
//    
//    func setupToolbar() {
//        var cancelItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Done, target: nil, action: "actionBack");
//        var resetItem = UIBarButtonItem(title: "Reset", style: UIBarButtonItemStyle.Done, target: nil, action: "actionReset");
//        var switchItem = UIBarButtonItem(title: "Switch", style: UIBarButtonItemStyle.Done, target: nil, action: "actionSwitch");
//        var doneItem = UIBarButtonItem(title: "Done!", style: UIBarButtonItemStyle.Done, target: nil, action: "actionDone");
//        var spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
//        
//        toolbar.items = [cancelItem, spacer, resetItem, spacer, switchItem, spacer, doneItem]
//    }
//    
//    func updateProgress(progress: CGFloat) {
//        if(progressConstraint != nil) {
//            self.view.removeConstraint(progressConstraint!);
//        }
//        
//        progressConstraint = NSLayoutConstraint(item: progressView,
//            attribute: NSLayoutAttribute.Width,
//            relatedBy: NSLayoutRelation.Equal,
//            toItem: self.view,
//            attribute: NSLayoutAttribute.Width,
//            multiplier: progress,
//            constant: 0)
//        
//        self.view.addConstraint(progressConstraint!)
//        
//        UIView.animateWithDuration(timeStep, animations: { () -> Void in
//            self.view.layoutIfNeeded()
//        })
//    }
//    
//    func setupCamera() {
//        camera.outputImageOrientation = UIInterfaceOrientation.Portrait;
//        camera.addTarget(cameraView)
//    }
//    
//    func setupRecording() {
//        var moviePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/mov.m4v")
//        var movieURL = NSURL(fileURLWithPath: moviePath)
//        NSFileManager.defaultManager().removeItemAtPath(moviePath, error: nil)
//        
//        writer = GPUImageMovieWriter(movieURL: movieURL, size: CGSizeMake(480, 480))
//        writer.setst
//        
//        
//        
//    }
//    
//    func secondsUp() {
//        if (recording) {
//            timeElapsed += timeStep
//            println(timeElapsed)
//            
//            
//            self.updateProgress(CGFloat(timeElapsed)/CGFloat(maxTime))
//        }
//    }
//    
//    func actionBack() {
//        println("Back")
//    }
//    
//    func actionReset() {
//        println("Reset")
//    }
//    
//    func actionSwitch() {
//        println("Switch")
//        camera.rotateCamera()
//    }
//    
//    func actionDone() {
//        println("Done")
//    }
//    
//    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
//        recording = true
//        
//    }
//    
//    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
//        recording = false;
//    }
//    
//    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
//        recording = false
//        
//    }
//}
