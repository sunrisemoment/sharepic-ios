//
//  FilterVC.swift
//  sharepic
//
//  Created by steven on 19/8/2016.
//  Copyright © 2016 allyouneedapp. All rights reserved.
//

import UIKit
import GPUImage

struct viewStage {
    
    static var isFinishingUp: Bool = false
}

class FilterVC: CommonVC, StevenImageEditorDelegate {
    
    let filters : OrderedDictionary = [
                    "Instant"    :Instant,
                    "Transfer"   :Transfer,
                    "Fade"       :Fade,
                    "Vivid"     :Chrome,
                    "Process"    :Process,
                    "Vignette"   :Vignette,
                    "Bright"      :Curve,
                    "Sepia"      :Sepia,
                    // Haze
                    "Mono"       :Mono,
                    "Light Gray"      :Tonal,
                    //Emboss
                    //Toon
                    "Linear"     :Linear
                    //sketch
                   ]
    
    let extra_filters = ["Toon","Emboss", "Haze", "Sketch"]
    
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var viewPanel: UIView!
    @IBOutlet weak var scrollFilterChoose: UIScrollView!
    
    var originalImage: UIImage!
    fileprivate(set) var stevenImgEditor: StevenImageEditor!
    
    var currentSelectedFilter: ToolBarMenuItem!
    var stickerWordVC: FinishUpVC!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let _ = originalImage {
            self.viewPanel.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - SCROLLBAR_HEIGHT - NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT)
            
            stevenImgEditor = StevenImageEditor(image: originalImage, delegate: self)
            stevenImgEditor.show(in: self, on: viewPanel)
            stevenImgEditor.currentTool = StevenFilterTool(imageEditor: stevenImgEditor)
            
            setupMenu()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if viewStage.isFinishingUp {
                btnBack.isHidden = true
                btnNext.setTitle("Resume", for: UIControlState())
        } else {
                btnBack.isHidden = false
                btnNext.setTitle("Next", for: UIControlState())
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let serial_queue = DispatchQueue(label: "process_gpu_image", attributes: [])
    func setupMenu() {
        scrollFilterChoose.frame = CGRect(x: 0, y: SCREEN_HEIGHT - FILTERBAR_HEIGHT, width: SCREEN_WIDTH, height: FILTERBAR_HEIGHT)
        scrollFilterChoose.showsHorizontalScrollIndicator = false
        
        //set sub menus
        let W: CGFloat = 75
        var x: CGFloat = 0;
        
        let iconThumbnail = originalImage.aspectFill(CGSize(width: 50*SCALE, height: 50*SCALE))
        
        //set default filters
        let filterItemView = ToolBarMenuItem(frame: CGRect(x: x, y: 0, width: W, height: W), target: self, action: #selector(FilterVC.tappedFilterItem(_:)))
        filterItemView.titleLabel.text = "No Filter"
        filterItemView.identity = "No Filter"
        scrollFilterChoose.addSubview(filterItemView)
        x += W
        
        DispatchQueue.global().async(execute: {
            let iconImage = StevenFilterTool.filteredImage(iconThumbnail, with: None)
            filterItemView.iconView.image = iconImage
        });
        
        for index in 0...filters.count - 1 {
            let filterItemView = ToolBarMenuItem(frame: CGRect(x: x, y: 0, width: W, height: W), target: self, action: #selector(FilterVC.tappedFilterItem(_:)))
            filterItemView.titleLabel.text = filters.key(at: UInt(index)) as? String
            filterItemView.identity = filters.key(at: UInt(index)) as! String
            scrollFilterChoose.addSubview(filterItemView)
            x += W
            
            DispatchQueue.global().async(execute: {
                let iconImage = StevenFilterTool.filteredImage(iconThumbnail, with: self.filters.object(at: UInt(index)) as! STEVEN_FILTER)
                filterItemView.iconView.image = iconImage
            });
        }
        
        //set extra filters
        for filter in extra_filters {
            let filterItemView = ToolBarMenuItem(frame: CGRect(x: x, y: 0, width: W, height: W), target: self, action: #selector(FilterVC.tappedFilterItem(_:)))
            filterItemView.titleLabel.text = filter
            filterItemView.identity = filter
            scrollFilterChoose.addSubview(filterItemView)
            x += W
            
            DispatchQueue.global().async(execute: {
                let iconImage = self.imageProcessedWithGPUImageFilter(iconThumbnail!, which_filter: filter)
                filterItemView.iconView.image = iconImage
            });
        }
        
        scrollFilterChoose.contentSize = CGSize(width: x, height: 0)
    }
    
    @IBAction func onBack(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onNext(_ sender: UIButton) {
        
        self.stevenImgEditor.doneRetainingCurrentTool ({ (image, error) in
//            self.originalImage = image?.deepCopy()
            
            if let _ = self.stickerWordVC {
                self.stickerWordVC.originalImage = image?.deepCopy()
                self.navigationController?.pushViewController(self.stickerWordVC, animated: true)
            }
            else {                
                self.stickerWordVC = self.storyboard?.instantiateViewController(withIdentifier: "FinishUpVC") as! FinishUpVC
                self.stickerWordVC.originalImage = image?.deepCopy()
                self.navigationController?.pushViewController(self.stickerWordVC, animated: true)
            }
        })
    }
    
    func tappedFilterItem(_ gesture: UITapGestureRecognizer) {
        
        let filterItem = gesture.view as! ToolBarMenuItem
        
        if let _ = currentSelectedFilter {
            currentSelectedFilter.selected = false
        }
        currentSelectedFilter = filterItem
        filterItem.selected = true
        
        if extra_filters.contains(filterItem.identity) {
            let filtered_img = imageProcessedWithGPUImageFilter((stevenImgEditor.currentTool as! StevenFilterTool).originalImage(), which_filter: filterItem.identity)
            stevenImgEditor.imageView.image = filtered_img
        }
        else {
            if let filter = filters[filterItem.identity] {
                (stevenImgEditor.currentTool as! StevenFilterTool).setFilter(filter as! STEVEN_FILTER)
            }
            else {
                (stevenImgEditor.currentTool as! StevenFilterTool).setFilter(None)
            }
        }
    }
    
    func imageProcessedWithGPUImageFilter(_ image: UIImage, which_filter: String) -> UIImage {
        let imageSource = GPUImagePicture(image: image)
        
        var filter: GPUImageFilter!
        if which_filter == "Toon" {
            filter = GPUImageToonFilter()
        }
        else if which_filter == "Erosion" {
            filter = GPUImageErosionFilter()
        }
        else if which_filter == "Emboss" {
            filter = GPUImageEmbossFilter()
        }
        else if which_filter == "Mosaic" {
            filter = GPUImageMosaicFilter()
        }
        else if which_filter == "Haze" {
            filter = GPUImageHazeFilter()
        }
        else if which_filter == "Sketch" {
            filter = GPUImageSketchFilter()
        }
        else if which_filter == "Solarize" {
            filter = GPUImageSolarizeFilter()
        }
        else if which_filter == "Grayscale" {
            filter = GPUImageGrayscaleFilter()
        }
        else if which_filter == "Bilateral" {
            filter = GPUImageBilateralFilter()
        }
        
        imageSource?.addTarget(filter)
        filter.useNextFrameForImageCapture()
        imageSource?.processImage()
        
        return filter.image(byFilteringImage: image)
    }
    
}
