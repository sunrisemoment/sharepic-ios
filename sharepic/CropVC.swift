//
//  CropVC.swift
//  sharepic
//
//  Created by steven on 15/8/2016.
//  Copyright © 2016 allyouneedapp. All rights reserved.
//

import UIKit

class CropVC: CommonVC, StevenImageEditorDelegate{
    
    @IBOutlet weak var viewResizeOptionPanel: UIView!
    @IBOutlet weak var viewPanel: UIView!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var btnResize: UIButton!
    
    var originalImage: UIImage!
    fileprivate(set) var stevenImgEditor: StevenImageEditor!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUI()
        
        let resizedImg = SharePicUtil.fitImageToImageCropContainerSize(originalImage)
        originalImage = resizedImg
        
        if let _ = originalImage {
            stevenImgEditor = StevenImageEditor(image: originalImage, delegate: self)
            
            self.viewPanel.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - TOOLBAR_HEIGHT - NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT)
            self.viewPanel.backgroundColor = UIColor.clear
            stevenImgEditor.show(in: self, on: self.viewPanel)
        }
        else {
            assertionFailure("original image must be setted")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(cancelCrop), name: NSNotification.Name(rawValue: kCLNotificationTapOnElseClipArea), object: nil)
        viewPanel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickElseWhere)))
        
    }
    
    func onClickElseWhere() {
        self.viewResizeOptionPanel.isHidden = true
        btnResize.isSelected = false
        btnResize.setImage(UIImage(named: "resize") , for: UIControlState())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUI() {
        SharePicUtil.setShadow(viewResizeOptionPanel)
    }
    
    //MARK: -
    @IBAction func onChooseCropSize(_ sender: UIButton) {
        
        stevenImgEditor.currentTool = StevenClippingTool(imageEditor: self.stevenImgEditor)
        
        let tag = sender.tag
        switch tag {
        case 1:
            //custom
            (stevenImgEditor.currentTool as! StevenClippingTool).setRatio(0, height: 0)
            break
        case 2:
            //square
            (stevenImgEditor.currentTool as! StevenClippingTool).setRatio(1, height: 1)
            break
        case 3:
            //2:3
            (stevenImgEditor.currentTool as! StevenClippingTool).setRatio(2, height: 3)
            break
        case 4:
            //3:4
            (stevenImgEditor.currentTool as! StevenClippingTool).setRatio(3, height: 4)
            break
        case 5:
            //3:5
            (stevenImgEditor.currentTool as! StevenClippingTool).setRatio(3, height: 5)
            break
        case 6:
            //9:16
            (stevenImgEditor.currentTool as! StevenClippingTool).setRatio(9, height: 16)
            break
        case 7:
            //3:2
            (stevenImgEditor.currentTool as! StevenClippingTool).setRatio(3, height: 2)
            break
        case 8:
            //4:3
            (stevenImgEditor.currentTool as! StevenClippingTool).setRatio(4, height: 3)
            break
        case 9:
            //5:3
            (stevenImgEditor.currentTool as! StevenClippingTool).setRatio(5, height: 3)
            break
        case 10:
            //16:9
            (stevenImgEditor.currentTool as! StevenClippingTool).setRatio(16, height: 9)
            break
        case 11:
            //1.91:1
            (stevenImgEditor.currentTool as! StevenClippingTool).setRatio(1.91, height: 1)
            break
        default:
            break
        }
        
        onResize(btnResize)
    }
    
    func onNext() {
        let filterVC = self.storyboard?.instantiateViewController(withIdentifier: "FilterVC") as! FilterVC
        filterVC.originalImage = self.originalImage;
        navigationController?.pushViewController(filterVC, animated: true)
    }
    
    @IBAction func onResize(_ btnResize: UIButton) {
        btnResize.isSelected = !btnResize.isSelected
        if btnResize.isSelected {
            btnResize.setImage(UIImage(named: "resizePress") , for: UIControlState())
            viewResizeOptionPanel.isHidden = false
        }
        else {
            btnResize.setImage(UIImage(named: "resize") , for: UIControlState())
            viewResizeOptionPanel.isHidden = true
        }
    }
    
    var isProcessing = false;
    @IBAction func onRotate(_ sender: UIButton) {
        if isProcessing {
            return
        }
        isProcessing = true
        
        stevenImgEditor.currentTool = StevenRotateTool(imageEditor: self.stevenImgEditor)
        
        let currentTool = stevenImgEditor.currentTool as! StevenRotateTool
        currentTool.rotateBy90(withClockwise: false) { 
            self.stevenImgEditor.done ({ (image, error) in
                if let _ = image {
                    self.originalImage = image
                    self.isProcessing = false
                }
                else {
                    SharePicUtil.showSystemAlert(title: ERROR_ALERT, message: (error as! NSError).description, dismissButtonTitle: "Ok");
                    self.isProcessing = false
                }
            })
        }
    }
    
    @IBAction func onBack(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toMainVC", sender: self)
    }
    
    @IBAction func onDone(_ sender: UIButton) {
        if sender.titleLabel!.text == "Crop" {
            stevenImgEditor.done ({ (image, error) in
                if let _ = image {
                    self.originalImage = image
                }
                else {
                    SharePicUtil.showSystemAlert(title: ERROR_ALERT, message: (error as! NSError).description, dismissButtonTitle: "Ok");
                }
            })
        }
        else {
            self.onNext()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        stevenImgEditor.cancel()
    }
    
    func cancelCrop() {
        stevenImgEditor.cancel()
    }
    
    //MARK - StevenImageEditorDelegate
    func stevenImageEditor(_ editor: StevenImageEditor!, didSetCurrentTool tool: StevenImageToolBase!) {
        if tool is StevenClippingTool {
            btnDone.setTitle("Crop", for: UIControlState())
        }
        else {
            btnDone.setTitle("Next", for: UIControlState())
        }
    }
}
