//
//  CameraVC.swift
//  sharepic
//
//  Created by steven on 14/8/2016.
//  Copyright © 2016 allyouneedapp. All rights reserved.
//

import UIKit

class CameraVC: CommonVC, SCRecorderDelegate, SCRecorderToolsViewDelegate{
    
    enum FlashState: Int {
        case on = 1
        case auto = 2
        case off = 3
    }
    
    enum CameraToggle: Int {
        case front = 1
        case back  = 2
    }
    
    @IBOutlet weak var btnFlashToggle: UIButton!
    @IBOutlet weak var btnCameraToggle: UIButton!
    @IBOutlet weak var btnShutter: UIButton!
    
    @IBOutlet weak var preview: UIView!
    fileprivate var recorder: SCRecorder!
    fileprivate var recordToolsView: SCRecorderToolsView!
    fileprivate var focusBoxLayer: CALayer!
    fileprivate var focusBoxAnimation: CAAnimation!
    
    @IBOutlet weak var imgFlashToggle: UIImageView!
    
    fileprivate(set) var flashState: FlashState = .auto
    fileprivate(set) var isBackCamera: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUI()
        setRecorder()
    }
    
    func setUI() {
        //setting Flash Toggle button between shutter and camera
//        let screen_width = self.view.frame.size.width
//        let between = screen_width / 2 - btnShutter.frame.size.width / 2 - 15 - btnCameraToggle.frame.size.width
//        btnFlashToggle <- Right(between / 2 - btnFlashToggle.frame.size.width / 2 + btnCameraToggle.frame.size.width + 15).to(self.view, .Right)
        
        //set lines on the preview screen
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height - TOOLBAR_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT
        
        let line1 = UIView(frame: CGRect(x: width/3 - 1, y: (STATUSBAR_HEIGHT + NAVIGATIONBAR_HEIGHT), width: 2, height: height))
        let line2 = UIView(frame: CGRect(x: width/3*2 - 1, y: (STATUSBAR_HEIGHT + NAVIGATIONBAR_HEIGHT), width: 2, height: height))
        let line3 = UIView(frame: CGRect(x: 0, y: height/3 + (STATUSBAR_HEIGHT + NAVIGATIONBAR_HEIGHT - 1), width: width, height: 2))
        let line4 = UIView(frame: CGRect(x: 0, y: height/3*2 + (STATUSBAR_HEIGHT + NAVIGATIONBAR_HEIGHT - 1), width: width, height: 2))
        line1.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        line2.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        line3.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        line4.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        
        self.view.addSubview(line1)
        self.view.addSubview(line2)
        self.view.addSubview(line3)
        self.view.addSubview(line4)
        
    }
    
    func setRecorder() {
        recorder = SCRecorder()
        recorder.flashMode = .auto
        
        preview.frame = CGRect(x: 0, y: 20, width: self.view.frame.size.width, height: self.view.frame.size.height - TOOLBAR_HEIGHT - STATUSBAR_HEIGHT)
        recorder.previewView = preview
        recorder.mirrorOnFrontCamera = true
        recorder.device = .back
        
    }
    
    func initSCRecorderToolsView() {
        if recordToolsView == nil {
            recordToolsView = SCRecorderToolsView(frame: preview.bounds)
            recordToolsView.autoresizingMask = [.flexibleBottomMargin, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleWidth]
            recordToolsView.recorder = recorder
            recordToolsView.tapToFocusEnabled = true
            recordToolsView.doubleTapToResetFocusEnabled = false
            recordToolsView.showsFocusAnimationAutomatically = true
            recordToolsView.delegate = self
            preview.addSubview(recordToolsView)
            
            let focusBox = CALayer()
            focusBox.cornerRadius = 30
            focusBox.bounds = CGRect(x: 0, y: 0, width: 60, height: 60)
            focusBox.borderWidth = 2
            focusBox.borderColor = UIColor.white.cgColor
            focusBox.opacity = 0
            view.layer.addSublayer(focusBox)
            
            let focusBoxAnimation = CABasicAnimation(keyPath: "opacity")
            focusBoxAnimation.duration = 0.75
            focusBoxAnimation.autoreverses = false
            focusBoxAnimation.repeatCount = 0
            focusBoxAnimation.fromValue = NSNumber(value: 1 as Float)
            focusBoxAnimation.toValue = NSNumber(value: 0 as Float)
            
            self.focusBoxLayer = focusBox
            self.focusBoxAnimation = focusBoxAnimation
        }
    }
    
    func showFocusBox() {
        if let _ = focusBoxLayer {
            focusBoxLayer.removeAllAnimations()
            
            //move layer to the touch point
            CATransaction.begin()
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
            var currentFocusPoint = CGPoint(x: 0.5, y: 0.5)
            
            if (recorder.focusSupported) {
                currentFocusPoint = recorder.focusPointOfInterest
            }
            else {
                currentFocusPoint = recorder.exposurePointOfInterest
            }
            
            var viewPoint = recorder.convertPointOfInterest(toViewCoordinates: currentFocusPoint)
            viewPoint = view.convert(viewPoint, from: recorder.previewView)
            focusBoxLayer.position = viewPoint
            CATransaction.commit()
        }
        
        if let _ = focusBoxAnimation {
            focusBoxLayer.add(focusBoxAnimation, forKey: "animateOpacity")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initSCRecorderToolsView()
        recorder.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        recorder.stopRunning()
        recordToolsView .removeFromSuperview()
        recordToolsView = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - UIAction
    @IBAction func onClickBack(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onShutter(_ sender: UIButton) {
        recorder.capturePhoto { (error, _image) in
            if let image = _image {
                let imgWithRightOrientation = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: .right);
                self.gotoCropVC(imgWithRightOrientation)
            }
            else {
                SharePicUtil.showSystemAlert(title: "Error", message: (error as! NSError).description, dismissButtonTitle: "Ok")
            }
        }
    }
    
    @IBAction func onFlashToggle(_ sender: UIButton) {
        switch flashState {
        case .auto:
            flashState = .on
            imgFlashToggle.image = UIImage(named: "flashOn")
            recorder.flashMode = .on
            break
        case .on:
            flashState = .off
            imgFlashToggle.image = UIImage(named: "flashOff")
            recorder.flashMode = .off
            break
        case .off:
            flashState = .auto
            imgFlashToggle.image = UIImage(named: "flashAuto")
            recorder.flashMode = .auto
            break
        }
    }
    
    @IBAction func onCamera(_ sender: UIButton) {
        isBackCamera = !isBackCamera
        if (isBackCamera) {
            recorder.device = .back
            btnFlashToggle.isHidden = false
            imgFlashToggle.isHidden = false
        }
        else {
            recorder.device = .front
            btnFlashToggle.isHidden = true
            imgFlashToggle.isHidden = true
        }
    }
    
    func gotoCropVC(_ image: UIImage) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CropVC") as! CropVC
        vc.originalImage = image
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - SCRecorder Delegate
    func recorderShouldAutomaticallyRefocus(_ recorder: SCRecorder) -> Bool {
        return true
    }
    
    //MARK: - SCRecorder Tools View Delegate
    func recorderToolsView(_ recorderToolsView: SCRecorderToolsView, didTapToFocusWith gestureRecognizer: UIGestureRecognizer) {
        showFocusBox()
    }
}
