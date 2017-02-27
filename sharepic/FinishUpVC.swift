//
//  FinishUpVC.swift
//  sharepic
//
//  Created by steven on 20/8/2016.
//  Copyright © 2016 allyouneedapp. All rights reserved.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift
import FBSDKLoginKit
import FBSDKCoreKit
import FBSDKShareKit

extension String {
    func language() -> String? {
        if self.isEmpty {
            return nil
        }
        let tagger = NSLinguisticTagger(tagSchemes: [NSLinguisticTagSchemeLanguage], options: 0)
        tagger.string = self
        return tagger.tag(at: 0, scheme: NSLinguisticTagSchemeLanguage, tokenRange: nil, sentenceRange: nil)
    }
}

class FinishUpVC: CommonVC, CustomToolBarActionDelegate, StevenImageEditorDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, GIDSignInUIDelegate,  GIDSignInDelegate, UITextFieldDelegate, MFMailComposeViewControllerDelegate, DNDDragSourceDelegate, DNDDropTargetDelegate {

    @IBOutlet weak var viewPanel: UIView!
    @IBOutlet weak var scrollBar: UIScrollView!
    @IBOutlet weak var viewRecentStickers: UIView!
    
    @IBOutlet weak var btnAddSticker: UIButton!
    @IBOutlet weak var btnAddWord: UIButton!
    @IBOutlet weak var btnFontEdit: UIButton!
    
    @IBOutlet weak var tableResults: UITableView!
    
    
    fileprivate var toolBar: CustomToolBarAction!
    
    var originalImage: UIImage! {
        didSet {
            if imgEditor != nil {
                imgEditor.changeImage(with: originalImage)
            }
        }
    }
    fileprivate(set) var imgEditor: StevenImageEditor!
    fileprivate(set) var stickerImgTool: StevenStickerTool!
    fileprivate(set) var addWordImgTool: StevenTextTool!
    
    fileprivate(set) var dragAndDropController: DNDDragAndDropController!
    
    //MARK: -
    @IBOutlet weak var searchBarSticker: UISearchBar!
    var recentStickersGroup: [String: [Sticker]] = [String: [Sticker]]();
    var resultStickersGroup: [String: [Sticker]] = [String: [Sticker]]()
    
    //MARK: -
    var recentFonts: [UIFont] = [UIFont]();
    @IBOutlet weak var constrainForTableViewTop: NSLayoutConstraint! //.Sticker->0, .Font->-44
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnSaveAndShare: UIButton!
    var isAddingSticker = false {
        didSet {
            if isAddingSticker {
                btnBack.isHidden = true
                btnSaveAndShare.setTitle("Dismiss", for: UIControlState())
//                viewRecentStickers.isHidden = true
            }
            else if !isEditingWord{
                btnBack.isHidden = false
                btnSaveAndShare.setTitle("Save & Share", for: UIControlState())
            }
        }
    }
    
    var isEditingWord = false {
        didSet {
            if isEditingWord {
                btnBack.isHidden = true
                btnSaveAndShare.setTitle("Dismiss", for: UIControlState())
            }
            else if !isAddingSticker{
                btnBack.isHidden = false
                btnSaveAndShare.setTitle("Save & Share", for: UIControlState())
            }
        }
    }
    
    var allFonts: [String: [UIFont]] =
        ["en":
            [UIFont(name: "Helvetica-Bold", size: 16)!,
            UIFont(name: "AppleColorEmoji", size: 16)!,
            UIFont(name: "Arial-ItalicMT", size: 16)!,
            UIFont(name: "IowanOldStyle-Bold", size: 16)!,
            UIFont(name: "Georgia-Bold", size: 16)!,
            UIFont(name: "SnellRoundhand-Bold", size: 16)!,
            UIFont(name: "BrushScriptMT", size: 16)!,
            UIFont(name: "Chalkduster", size: 16)!,
            UIFont(name: "CopperPlate-Bold", size: 16)!,
            UIFont(name: "American Typewriter", size: 16)!,
            UIFont(name: "Herculanum", size: 16)!,
            UIFont(name: "Apple-Chancery", size: 16)!,
            UIFont(name: "Krungthep", size: 16)!,
            UIFont(name: "Papyrus", size: 16)!,
//            UIFont(name: "Y.OzFontNL", size: 16)!,
            UIFont(name: "Zapfino", size: 16)!,
            UIFont(name: "THBaijam-Bold", size: 16)!,
            UIFont(name: "THChakraPetch-Bold", size: 16)!,
            UIFont(name: "THKodchasal-Bold", size: 16)!,
            UIFont(name: "THMaliGrade6-Bold", size: 16)!,
            UIFont(name: "Bandal", size: 16)!,
            UIFont(name: "Eunjin", size: 16)!,
            UIFont(name: "EunjinNakseo", size: 16)!,
            UIFont(name: "drfont_daraehand", size: 16)!
            ],
         "th":
            [UIFont(name: "Helvetica-Bold", size: 16)!,
            UIFont(name: "AppleColorEmoji", size: 16)!,
            UIFont(name: "Krungthep", size: 16)!,
            UIFont(name: "THBaijam-Bold", size: 16)!,
            UIFont(name: "THChakraPetch-Bold", size: 16)!,
            UIFont(name: "THKodchasal-Bold", size: 16)!,
            UIFont(name: "THMaliGrade6-Bold", size: 16)!,
            UIFont(name: "THCharmofAU", size: 16)!,
            UIFont(name: "THCharmonman-Bold", size: 16)!,
            UIFont(name: "THFahkwang-Bold", size: 16)!,
            UIFont(name: "THK2DJuly8-Bold", size: 16)!,
            UIFont(name: "THKrub-Bold", size: 16)!,
            UIFont(name: "THNiramitAS-Bold", size: 16)!,
            UIFont(name: "THSarabunPSK-Bold", size: 16)!
            ],
         "ja": [UIFont(name: "Helvetica-Bold", size: 16)!,
            UIFont(name: "AppleColorEmoji", size: 16)!,
            UIFont(name: "IowanOldStyle-Bold", size: 16)!,
            UIFont(name: "Georgia-Bold", size: 16)!,
            UIFont(name: "BrushScriptMT", size: 16)!,
//            UIFont(name: "Y.OzFontNL", size: 16)!
            ],
         "zh-Hans": [UIFont(name: "Helvetica-Bold", size: 16)!,
            UIFont(name: "AppleColorEmoji", size: 16)!,
            UIFont(name: "IowanOldStyle-Bold", size: 16)!,
            UIFont(name: "Georgia-Bold", size: 16)!,
            UIFont(name: "BrushScriptMT", size: 16)!,
//            UIFont(name: "Y.OzFontNL", size: 16)!
            ],
         "ko": [
            UIFont(name: "Helvetica-Bold", size: 16)!,
            UIFont(name: "AppleColorEmoji", size: 16)!,
            UIFont(name: "BrushScriptMT", size: 16)!,
            UIFont(name: "Bandal", size: 16)!,
            UIFont(name: "Bangwool", size: 16)!,
            UIFont(name: "Eunjin", size: 16)!,
            UIFont(name: "EunjinNakseo", size: 16)!,
            UIFont(name: "Guseul", size: 16)!,
            UIFont(name: "drfont_daraehand", size: 16)!
            ],
         "ru":
            [UIFont(name: "Helvetica-Bold", size: 16)!,
            UIFont(name: "AppleColorEmoji", size: 16)!,
            UIFont(name: "IowanOldStyle-Bold", size: 16)!,
            UIFont(name: "Georgia-Bold", size: 16)!,
            UIFont(name: "SnellRoundhand-Bold", size: 16)!,
            UIFont(name: "BrushScriptMT", size: 16)!,
            UIFont(name: "CopperPlate-Bold", size: 16)!,
            UIFont(name: "American Typewriter", size: 16)!,
//            UIFont(name: "Y.OzFontNL", size: 16)!
            ],
         "all":
            [UIFont(name: "Helvetica-Bold", size: 16)!,
            UIFont(name: "AppleColorEmoji", size: 16)!,
            UIFont(name: "Arial-ItalicMT", size: 16)!,
            UIFont(name: "IowanOldStyle-Bold", size: 16)!,
            UIFont(name: "Georgia-Bold", size: 16)!,
            UIFont(name: "SnellRoundhand-Bold", size: 16)!,
            UIFont(name: "BrushScriptMT", size: 16)!,
            UIFont(name: "Chalkduster", size: 16)!,
            UIFont(name: "CopperPlate-Bold", size: 16)!,
            UIFont(name: "American Typewriter", size: 16)!,
            UIFont(name: "Herculanum", size: 16)!,
            UIFont(name: "Apple-Chancery", size: 16)!,
            UIFont(name: "Krungthep", size: 16)!,
            UIFont(name: "Papyrus", size: 16)!,
//            UIFont(name: "Y.OzFontNL", size: 16)!,
            UIFont(name: "Zapfino", size: 16)!,
            UIFont(name: "THBaijam-Bold", size: 16)!,
            UIFont(name: "THChakraPetch-Bold", size: 16)!,
            UIFont(name: "THKodchasal-Bold", size: 16)!,
            UIFont(name: "THMaliGrade6-Bold", size: 16)!,
            UIFont(name: "Bandal", size: 16)!,
            UIFont(name: "Eunjin", size: 16)!,
            UIFont(name: "EunjinNakseo", size: 16)!,
            UIFont(name: "drfont_daraehand", size: 16)!,
            UIFont(name: "THCharmofAU", size: 16)!,
            UIFont(name: "THCharmonman-Bold", size: 16)!,
            UIFont(name: "THFahkwang-Bold", size: 16)!,
            UIFont(name: "THK2DJuly8-Bold", size: 16)!,
            UIFont(name: "THKrub-Bold", size: 16)!,
            UIFont(name: "THNiramitAS-Bold", size: 16)!,
            UIFont(name: "THSarabunPSK-Bold", size: 16)!,
            UIFont(name: "Bangwool", size: 16)!,
            UIFont(name: "Guseul", size: 16)!,
            ]
    ]
    
    //MARK: -
    @IBOutlet weak var lblSelectedStickerTitle: UILabel!
    @IBOutlet weak var collectionViewStickerResults: UICollectionView!
    var stickersForATitle = [Sticker]()
    
    @IBOutlet weak var viewShareWithFriends: UIView!
    @IBOutlet weak var viewSuggestSticker: UIView!
    
    @IBOutlet weak var viewSignup: UIView!
    
    var saved_img: UIImage!
    var saved_localPath: URL!
    
    enum SearchMode: Int {
        case font = 0
        case sticker
    }
    var searchMode: SearchMode = .sticker
    
    let colors = ["4A90E2", "4AA4E2", "4AB9E2", "4ACDE2", "4ae2e2", "4ae2bc", "4ae296", "4ae270", "4ae24a",
                  "70e24a", "96e24a", "bce24a", "e2e24a", "e2bc4a", "e2964a", "e2704a", "e24a4a", "e24a70",
                  "e24a96", "e24abc", "e24ae2", "bc4ae2", "964ae2", "704ae2", "4a4ae2", "4a70e2", "ffffff",
                  "cccccc", "999999", "666666", "333333", "323260", "324960", "326060", "326049", "326032",
                  "496032", "606032", "604932", "603232", "603249", "603260", "493260", "0000ff", "0055ff",
                  "00aaff", "00ffff", "00ffaa", "00ff55", "00ff00", "55ff00", "aaff00", "ffff00", "ffaa00",
                  "ff5500", "ff0000", "ff0055", "ff00aa", "ff00ff", "aa00ff", "5500ff"];
    var lastestColorInHex: String?
    var interstitial: GADInterstitial!
    var once_token: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let once_inSelf = String(format: "%p", self)
        DispatchQueue.once(token:  once_inSelf) {
            self.toolBar = CustomToolBarAction(toolBarItems: [self.btnAddSticker, self.btnAddWord], delegate: self)
            
            if let _ = self.originalImage {
                
                self.viewPanel.frame = CGRect(x: 0, y: NAVIGATIONBAR_HEIGHT + STATUSBAR_HEIGHT, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - TOOLBAR_HEIGHT - SCROLLBAR_HEIGHT - 20 - NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT)// 20 for recent title above scroll view
                
                self.imgEditor = StevenImageEditor(image: self.originalImage, delegate: self)
                self.imgEditor.show(in: self, on: self.viewPanel)
                self.imgEditor.setWorkingViewForMultipleTools()
                
                self.stickerImgTool = StevenStickerTool(imageEditor: self.imgEditor)
                self.addWordImgTool = StevenTextTool(imageEditor: self.imgEditor)
                
                self.imgEditor.tools = [self.addWordImgTool, self.stickerImgTool];
            }
            
            self.viewPanel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FinishUpVC.tapOnOutside)));
            self.viewPanel.isUserInteractionEnabled = true
            
            self.scrollBar.superview?.clipsToBounds = true
            
            let searchTextField = self.searchBarSticker.value(forKey: "_searchField") as? UITextField
            if let _ = searchTextField {
                searchTextField!.clearButtonMode = .whileEditing
            }
            
            self.viewShareWithFriends.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            
            NotificationCenter.default.addObserver(self, selector: #selector(FinishUpVC.stickerActivated), name: NSNotification.Name(rawValue: kNOTIFICATION_STEVEN_STICKER_ACTIVATED), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(FinishUpVC.textItemActivated), name: NSNotification.Name(rawValue: kNOTIFICATION_STEVEN_TEXTITEM_ACTIVATED), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(FinishUpVC.allTextItemsRemoved), name: NSNotification.Name(rawValue: kNOTIFICATION_STEVEN_ALLTEXTITEM_REMOVED), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(FinishUpVC.allStickerItemsRemoved), name: NSNotification.Name(rawValue: kNOTIFICATION_STEVEN_ALLSTICKERITEM_REMOVED), object: nil)
            
            self.setUI()
            
            //set dragAnddrop controller
            self.dragAndDropController = DNDDragAndDropController()
            self.dragAndDropController.registerDropTarget(self.imgEditor.workingview, with: self)
            
            //Right after coming from Filter Page, Show Recent Sticker Bar
            if let _ = Stickers.sharedInstance.fmdb {
//                CommonFunc.startWaitingMBProgressHud(on: UIApplication.shared.keyWindow!, andTag: "loading", title:"Optimizing app...", detail: "May take a few minutes \n for first time use",isBlockView: true)
                CommonFunc.startWaitingMBProgressHud(on: UIApplication.shared.keyWindow!, andTag: "loading", title: "Optimizing app...", isBlockView: true)
                DispatchQueue.main.asyncAfter(deadline: .now() , execute: {
                    _ = Stickers.sharedInstance.loadStickersToDB()
                    self.setupRecentStickerBar()
                CommonFunc.commitWaitingMBProgressHud(withTag: "loading")
                })
            }
            
        }
  /*
        if traitCollection.forceTouchCapability == .available {

            registerForPreviewing(with: self, sourceView: tableResults)
        }
        else {
            alertController = UIAlertController(title: "3D Touch Not Available", message: "Unsupported device.", preferredStyle: .alert)
        }
       
    */
        IQKeyboardManager.sharedManager().enable = false
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-9318863419427951/4563413824")
        let request = GADRequest()
//        request.testDevices = [ kGADSimulatorID, "2077ef9a63d2b398840261c8221a0c9b" ]
        interstitial.load(request)

    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.sharedManager().enable = true
    }
    
    func setUI() {
        viewSignup.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        viewSuggestSticker.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        viewSuggestSticker.viewWithTag(200)?.layer.cornerRadius = 5 //suggest sticker button
        viewSuggestSticker.viewWithTag(200)?.clipsToBounds = true
        viewSuggestSticker.viewWithTag(300)?.layer.cornerRadius = 5 //cancel button
        viewSuggestSticker.viewWithTag(300)?.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initializeGoogleSigninUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK; -
    func initializeGoogleSigninUI() {
        //Google Signup
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        // Uncomment to automatically sign in the user.
        //GIDSignIn.sharedInstance().signInSilently()
        
        // TODO(developer) Configure the sign-in button look/feel
        // ...
    }
    
    //MARK: - SetUp RecentSticker/Color Bar
    let MaxNumberOfRecentSticker: Int = 20
    func setupRecentStickerBar() {
        let recentStickers = Stickers.sharedInstance.recentStickers(MaxNumberOfRecentSticker)
        if recentStickers.isEmpty {
            return
        }
        
        scrollBar.superview?.isHidden = false
        
        btnFontEdit.isHidden = true
        scrollBar.superview! <- Height(100)
//        scrollBar <- Left(0)
        
        for subview in scrollBar.subviews {
            self.dragAndDropController.unregisterDragSource(subview)
            subview.removeFromSuperview()
        }
        
        scrollBar.frame = CGRect(x: 0, y: 20, width: SCREEN_WIDTH, height: SCROLLBAR_HEIGHT)
        scrollBar.backgroundColor = UIColor.white
        scrollBar.showsHorizontalScrollIndicator = false
        
        //set sub menus
        let W: CGFloat = 80
        var x: CGFloat = 0;
        
        for sticker in recentStickers {
            let stickerItemView = ToolBarMenuItem(frame: CGRect(x: x+5, y: 0+5, width: W-10, height: W-10), target: nil, action: nil, isGapSupport: false, isTitleSupport: false)
            
            stickerItemView.identity = sticker.id
            stickerItemView.iconView.image = sticker.image
            
            scrollBar.addSubview(stickerItemView)
            
            x += W
            
            //register as DragAndDrop Datasource
            let longGesture = UILongPressGestureRecognizer()
            longGesture.minimumPressDuration = 0.3
            self.dragAndDropController.registerDragSource(stickerItemView, with: self, drag: longGesture)
        }
        
        scrollBar.contentSize = CGSize(width: x, height: 0)
        scrollBar.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    func setupColorBar(isWithFont: Bool = false) {
        scrollBar.superview?.isHidden = false
        scrollBar.superview! <- Height(SCROLLBAR_HEIGHT)
        
        for subview in scrollBar.subviews {
            subview.removeFromSuperview()
        }
        
        scrollBar.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCROLLBAR_HEIGHT)
        scrollBar.backgroundColor = UIColor.clear
        scrollBar.showsHorizontalScrollIndicator = false
        
        //set sub menus
        let H: CGFloat = 80
        let W: CGFloat = 64
        var x: CGFloat = 0;
        
        if isWithFont {

            btnFontEdit.isHidden = false
            x = 80
//            scrollBar <- Left(80)
            
        }
        else {
            
            btnFontEdit.isHidden = true
            x = 0
//            scrollBar <- Left(0)
        }
        
        for color in colors {
            let colorItemView = ToolBarMenuItem(frame: CGRect(x: x, y: 0, width: H, height: W), target: self, action: #selector(FinishUpVC.didTapOnColorItem(_:)), isGapSupport: false, isTitleSupport: false)
            
            colorItemView.identity = color
            colorItemView.iconView.backgroundColor = UIColor(hex: color)
            scrollBar.addSubview(colorItemView)
            x += W
        }
        
        scrollBar.contentSize = CGSize(width: x, height: 0)
        
        //scroll to the lastest color
        var index = 0
        if let hexColor = lastestColorInHex {
            if let _index = colors.index(of: hexColor) {
                index = _index
            }
        }
        scrollBar.setContentOffset(CGPoint(x: CGFloat(index) * W, y: 0), animated: true)
    }
    
    //MARK: - UIAction
    @IBAction func onClickFont() {
        searchMode = .font
        recentFonts = SharePicUtil.recentFonts(5)
        
        constrainForTableViewTop.constant = -44
        
        tableResults.isHidden = false
        tableResults.alpha = 0.95
        
        tableResults.reloadData()
        isEditingWord = true
    }
    
    @IBAction func onSaveAndShare(_ sender: UIButton) {
        if isAddingSticker {
            uninstallAddStickerEnv()
            isAddingSticker = false
            setupRecentStickerBar()
            return
        }
        if isEditingWord {
            
            uninstallAddingTextEnv()
            isEditingWord = false
            setupRecentStickerBar()
            return
        }
        
        stickerImgTool.deactiveCurrentActivatedSticker()
        addWordImgTool.deactiveCurrentActivatedTextView()
        if interstitial.isReady {
            bgMusic.stop()
            interstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
        CommonFunc.startWaitingMBProgressHud(on: self.view, andTag: "saving_img", isBlockScreen: true)
        imgEditor.done ({ (image, error) in
            if let _ = image {
                
                ALAssetsLibrary().writeImage(toSavedPhotosAlbum: image!.cgImage, orientation: ALAssetOrientation(rawValue: image!.imageOrientation.rawValue)!,
                    completionBlock:{ (path, error) -> Void in
                        self.saved_localPath = path!
                })
                
                self.saved_img = image
                
                CommonFunc.commitWaitingMBProgressHud(withTag: "saving_img")
                
                var userIdRecord: String
                if let _ = SharePicUtil.currentUser {
                    userIdRecord = SharePicUtil.currentUser.uid
                } else{
                    userIdRecord = "NotRegisterUser"
                }
                print(userIdRecord)
                // add use sticker to firebase
                let stickerIds = self.stickerImgTool.addedStickerId()

                if stickerIds!.count > 0 {
                    SharePicUtil.setStickerUse(userIdRecord, stickersId: stickerIds!, completion: { (error, ref) in })
                }

                self.viewShareWithFriends.isHidden = false
                self.btnSaveAndShare.isHidden = true
            }
            else {
                CommonFunc.commitWaitingMBProgressHud(withTag: "saving_img")
                CommonFunc.showMBProgressHud(on: self.view, withText: "Error", delay: 2.0)
            }
        })
    }
    
    @IBAction func onFilter(_ sender: UIButton) {
        viewStage.isFinishingUp = true
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onBack(_ sender: UIButton) {
        
//        let alert = UIAlertController(title: "Confirm!", message: "Are you sure you want to back? \nYou will lose your existing edit.", preferredStyle: .Alert)
//        let okAction = UIAlertAction(title: "Yes", style: .Default) { (action) in
//            let self_index = self.navigationController?.viewControllers.indexOf(self)
//            let filterVC = self.navigationController?.viewControllers[self_index! - 1] as! FilterVC
//            filterVC.stickerWordVC = nil;
//            
//            self.navigationController?.popViewControllerAnimated(true)
//        }
//        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
//            return
//        }
//        
//        alert.addAction(okAction)
//        alert.addAction(cancelAction)
//        
//        self.presentViewController(alert, animated: true, completion: nil)
        
        if btnSaveAndShare.isHidden {//screen for after clicking save&share is displayed
            viewSignup.isHidden = true
            viewSuggestSticker.isHidden = true
            viewShareWithFriends.isHidden = true
            btnSaveAndShare.isHidden = false
            return
        }
        
        let block: DTAlertViewButtonClickedBlock = {(alertView, buttonIndex, cancelButtonIndex) in
            
            if buttonIndex == cancelButtonIndex {
                alertView?.dismiss()
            }
            else {
                let self_index = self.navigationController?.viewControllers.index(of: self)
                let filterVC = self.navigationController?.viewControllers[self_index! - 1] as! FilterVC
                filterVC.stickerWordVC = nil;
                viewStage.isFinishingUp = false
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
        
        DTAlertView(block: block, title: "Confirm!", message: "Are you sure you want to back? \nYou will lose your existing edit.", cancelButtonTitle: "Cancel", positiveButtonTitle: "Yes").show()
        
    }
    
    func didSelectedToolBarItem(_ item: UIButton) {
        if item == btnAddSticker {
            
            btnAddSticker.setImage(UIImage(named: "addStickerPress"), for: UIControlState())
            setupAddStickerEnv()
            isAddingSticker = true
        }
        else if item == btnAddWord {
            addWordImgTool.addNewText()
            setupAddTextEnv()
        }
    }
    
    func didDeselectToolBarItem(_ item: UIButton) {
        if item == btnAddSticker {
            btnAddSticker.setImage(UIImage(named: "addSticker"), for: UIControlState())
            uninstallAddStickerEnv()
            isAddingSticker = false
        }
        else if item == btnAddWord {
            isEditingWord = false
        }
    }
    
    //MARK: - Add/Recent Sticker Handling
    func setupAddStickerEnv() {
        searchMode = .sticker
        
        searchBarSticker.isHidden = false
        
        //https://trello.com/c/2EjLb6hV/15-after-press-add-sticker-the-search-table-should-populate-the-list-of-recent-and-the-word-by-alphabetical-order
        stickerResultsWithKeyword("")
        scrollBar.superview?.isHidden = true
        
//        setupRecentStickerBar()
    }
    
    fileprivate func stickerResultsWithKeyword(_ keyword: String) {
        constrainForTableViewTop.constant = 0
        
        tableResults.isHidden = false
        tableResults.alpha = 0.9
        
        recentStickersGroup = Stickers.sharedInstance.grouplizeByTitle(Stickers.sharedInstance.predictsInRecentStickers(keyword, count: 20))!
        resultStickersGroup = Stickers.sharedInstance.grouplizeByTitle(Stickers.sharedInstance.fetchStickers(keyword))!
        
        tableResults.reloadData()
    }
    
    func uninstallAddStickerEnv() {
        
        searchBarSticker.resignFirstResponder()
        searchBarSticker.isHidden = true
        tableResults.isHidden = true
        scrollBar.superview?.isHidden = true
        
        toolBar.deSelectItemWithoutDelegateCall(btnAddSticker)
        btnAddSticker.setImage(UIImage(named: "addSticker"), for: UIControlState())
        
        lblSelectedStickerTitle.superview?.isHidden = true
        collectionViewStickerResults.isHidden = true
    }
    
    func stickerActivated() {
        toolBar.deSelectItem(btnAddSticker)
        uninstallAddStickerEnv()
        
        setupColorBar()
        
        addWordImgTool.deactiveCurrentActivatedTextView()
    }
    
    func showStickersCollectionForASelectedTitle(_ stickers: [Sticker], title: String) {
        //hide table view
        tableResults.isHidden = true
        
        //show title label and its stickers collection
        //https://trello.com/c/8U3LekVg/13-pls-make-new-ui-exactly-match-with-the-sketch-file-size-each-square-distance-from-edge-transparency-shape-of-color-panal
        //        lblSelectedStickerTitle.superview?.hidden = false
        lblSelectedStickerTitle.superview?.isHidden = true
        lblSelectedStickerTitle.text = title
        
        stickersForATitle = stickers
        collectionViewStickerResults.isHidden = false
        collectionViewStickerResults.reloadData()
        
        //show recent stickers
        scrollBar.superview?.isHidden = true
//        setupRecentStickerBar()
    }
    
    func hideStickersCollection() {
        
    }
    
    //MARK: - TextItem Handling
    func setupAddTextEnv() {
        searchMode = .font
        
        searchBarSticker.isHidden = true
        tableResults.isHidden = true
        scrollBar.superview?.isHidden = true
        collectionViewStickerResults.isHidden = true
    }
    
    func uninstallAddingTextEnv() {
        
//        addWordImgTool.activeTextView().remove()
        addWordImgTool.deactiveCurrentActivatedTextView()
        stickerImgTool.deactiveCurrentActivatedSticker()
        toolBar.deSelectItem(btnAddWord)
        addWordImgTool.hideInputView()
        tableResults.isHidden = true
    }
    
    func textItemActivated() {
        toolBar.deSelectItem(btnAddSticker)
        uninstallAddStickerEnv()
        
        setupColorBar(isWithFont: true)
        
        stickerImgTool.deactiveCurrentActivatedSticker()
    }
    
    func allTextItemsRemoved() {
        addWordImgTool.deactiveCurrentActivatedTextView()
        stickerImgTool.deactiveCurrentActivatedSticker()
        
        toolBar.deSelectItem(btnAddSticker)
        uninstallAddStickerEnv()
        
        btnAddWord.isSelected = false
        
        setupRecentStickerBar()
    }
    
    func allStickerItemsRemoved() {
        addWordImgTool.deactiveCurrentActivatedTextView()
        stickerImgTool.deactiveCurrentActivatedSticker()
        
        toolBar.deSelectItem(btnAddSticker)
        uninstallAddStickerEnv()
        
        btnAddSticker.isSelected = false
        
        setupRecentStickerBar()
    }
    
    func tapOnOutside() {
        if addWordImgTool.isEditing() {
            
            if addWordImgTool.activeTextView().text.isEmpty {
                
            }
            else {
                setupColorBar(isWithFont: true)
            }
            
            stickerImgTool.deactiveCurrentActivatedSticker()
            
            toolBar.deSelectItem(btnAddWord)
            
            addWordImgTool.hideInputView()
            
            searchBarSticker.isHidden = true
            tableResults.isHidden = true
            
            lblSelectedStickerTitle.superview?.isHidden = true
            collectionViewStickerResults.isHidden = true
        }
        else {
            addWordImgTool.deactiveCurrentActivatedTextView()
            stickerImgTool.deactiveCurrentActivatedSticker()
            
            toolBar.deSelectItem(btnAddSticker)
            uninstallAddStickerEnv()
            
            btnAddWord.isSelected = false
            
            //https://trello.com/c/fOZAvdHi/5-after-place-sticker-or-word-please-elsewhere-to-deactivate-the-color-panel-i-want-it-to-show-recent-panel-during-deactivate-colo
            setupRecentStickerBar()
        }
    }
    
    @IBAction func onShareWithMyFriends(_ sender: UIButton) {
        let tag = sender.tag
        switch tag {
        case 100: //share via facebook
            
            let photoShare = FBSDKSharePhoto()
            photoShare.image = saved_img
            photoShare.isUserGenerated = true
            let content: FBSDKSharePhotoContent = FBSDKSharePhotoContent()
            content.photos = [photoShare]
            FBSDKShareDialog.show(from: self, with: content, delegate: nil)
            
            break
        case 101: //share via instagram

            let instagramUrl = URL(string: "instagram://app")!
            if UIApplication.shared.canOpenURL(instagramUrl) {
                let caption = "PalPic"
                let escapedPath = saved_localPath.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                let escapedCaption = caption.addingPercentEscapes(using: String.Encoding.utf8)
                let instagramUrl = URL(string: String(format: "instagram://library?AssetPath=%@&InstagramCaption=%@", escapedPath!, escapedCaption!))
                if UIApplication.shared.canOpenURL(instagramUrl!) {
                    UIApplication.shared.openURL(instagramUrl!)
                }
            }
            else {
                UIAlertView(title: nil, message: "Can not open the Instagram", delegate: nil, cancelButtonTitle: "Ok").show()
            }
            
            break
        case 102: //share via email
            let toRecipents = [String]()
            
            let mc = MFMailComposeViewController()
            mc.mailComposeDelegate = self
            mc.setSubject("My wonderful moment")
            mc.setMessageBody("I wanna share this image with you...", isHTML: false)
            mc.addAttachmentData(UIImageJPEGRepresentation(saved_img, 0.8)!, mimeType: "image/jpeg", fileName: "takenFromPalPic")
            mc.setToRecipients(toRecipents)
            present(mc, animated: true, completion: nil)
            break
        case 103: //suggestSticker
            if let _ = SharePicUtil.currentUser {
                //check if there is no add word, show suggest sticker view, otherwise hidden
                
                let texts = self.addWordImgTool.addedTextViews()
                if texts?.count == 0 {
                    self.viewSuggestSticker.isHidden = false
                }
                else {
                    var wordsToAdd = [String]()
                    
                    for _textView in texts! {
                        wordsToAdd.append(_textView.text)
                    }
                    
                    //upload these stickers - stickersToAdd to server
                    CommonFunc.startWaitingMBProgressHud(on: self.view, andTag: "suggestSticker", isBlockView: true)
                    SharePicUtil.setSuggestedWords(SharePicUtil.currentUser.uid, suggestedWords: wordsToAdd, completion: { (error, ref) in
                        
                        CommonFunc.commitWaitingMBProgressHud(withTag: "suggestSticker")
                        if let _ = error {
                            CommonFunc.showMBProgressHud(on: self.view, withText: "Suggestion Failed!", delay: 2.0)
                        }
                        else {
                            CommonFunc.showMBProgressHud(on: self.view, withText: "Sucessfully suggested!", delay: 2.0)
                            self.viewSuggestSticker.isHidden = true
                        }
                        
                    })
                }
                
            } else {
                // No user is signed in.
                self.showSignupView()
            }
            break
        case 104: //share via startOver
            bgMusic.play()
            self.performSegue(withIdentifier: "unwindFromFinishUp", sender: sender)
            break
        default:
            break
        }
    }
    
    //MARK: - DragAndDrop Delegate
    func draggingView(for operation: DNDDragOperation) -> UIView? {
        let selectedStickerItem = operation.dragSourceView as! ToolBarMenuItem
        
        let dragView = ToolBarMenuItem(frame: CGRect(x: 0, y: 0, width: 90, height: 90), target: nil, action: nil, isGapSupport: false, isTitleSupport: false)
        dragView.identity = selectedStickerItem.identity
        dragView.iconView.image = selectedStickerItem.iconView.image
        
        dragView.alpha = 0
        UIView.animate(withDuration: 0.2, animations: { 
            dragView.alpha = 1
        }) 
        return dragView
    }
    
    func dragOperationWillCancel(_ operation: DNDDragOperation) {
        operation.removeDraggingViewAnimated(withDuration: 0.2) { (draggingView) in
            draggingView.alpha = 0
            draggingView.center = operation.convert(operation.dragSourceView.center, from: self.scrollBar)
        }
    }
    
    func dragOperation(_ operation: DNDDragOperation, didDropInDropTarget target: UIView) {
        let view = operation.draggingView
        let stickerItem = view as! ToolBarMenuItem
        let sticker_id = stickerItem.identity
        let sticker = Stickers.sharedInstance.sticker(sticker_id!)
//        stickerImgTool.placeSticker(onPanel: sticker!.image)
        stickerImgTool.placeSticker(onPanel: sticker!.image,stickerId: sticker!.id)
//        stickerImgTool.changeActivedStickerColor(with: UIColor.white)
        
        sticker?.saveAsRecent()
        
        operation.removeDraggingView()
        target.layer.borderColor = UIColor.clear.cgColor
        target.layer.borderWidth = 0.0
    }
    
    func dragOperation(_ operation: DNDDragOperation, didEnterDropTarget target: UIView) {
        target.layer.borderColor = UIColor.yellow.cgColor
        target.layer.borderWidth = 2.0
    }
    
    func dragOperation(_ operation: DNDDragOperation, didLeaveDropTarget target: UIView) {
        target.layer.borderColor = UIColor.clear.cgColor
        target.layer.borderWidth = 0.0
    }
    
    //MARK: - UITableView Delegate & Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
//    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if section == 0 {
//            return "Recent"
//        }
//        else if section == 1 {
//            return "Result"
//        }
//        return nil
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
//            switch searchMode {
//            case .Sticker:
//                return recentStickersGroup.count
//            case .Font:
//                return recentFonts.count
//            }
        }
        else if section == 1 {
            switch searchMode {
            case .sticker:
                return resultStickersGroup.count
            case .font:
                if let activeTV = addWordImgTool.activeTextView() {
                    if let lang = (activeTV.text as NSString).detectLanguage() {
                        let allLangs = [String](allFonts.keys)
                        if allLangs.contains(lang) {
                            return allFonts[lang]!.count
                        }
                        else {
                            return allFonts["en"]!.count
                        }
                    } else {
                        return allFonts["all"]!.count
                    }
                }
            }
        }

        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "sharepic_cell")!
        cell.textLabel?.font = UIFont(name: "Helvetica-Bold", size: 16)!
        
        switch searchMode {
        case .sticker:
//            let recent_titles = [String](recentStickersGroup.keys).sort{$0 < $1}
            let result_titles = [String](resultStickersGroup.keys).sorted{$0 < $1}
            if (indexPath as NSIndexPath).section == 0 {//Recent
//                if recent_titles.count == 0{
//                    return cell
//                }
//                cell.textLabel?.text = recent_titles[indexPath.row]
            }
            else if (indexPath as NSIndexPath).section == 1 {//Result
                if result_titles.count == 0{
                    return cell
                }
                cell.textLabel?.text = result_titles[(indexPath as NSIndexPath).row]
            }
            break;
        case .font:
            if (indexPath as NSIndexPath).section == 0 {//Recent
//                if recentFonts.count == 0 {
//                    return cell
//                }
//                cell.textLabel?.text = recentFonts[indexPath.row].fontName
//                cell.textLabel?.font = recentFonts[indexPath.row]
            }
            else if (indexPath as NSIndexPath).section == 1 {//All
                if allFonts.count == 0{
                    return cell
                }
                if let activeTV = addWordImgTool.activeTextView() {
                    let text = activeTV.text
                    if let lang = (activeTV.text as NSString).detectLanguage() {
                        let allLangs = [String](allFonts.keys)
                        if allLangs.contains(lang) {
                            cell.textLabel?.font = allFonts[lang]![indexPath.row]
                        }
                        else {
                            cell.textLabel?.font = allFonts["en"]![indexPath.row]
                        }
                    } else{
                        cell.textLabel?.font = allFonts["all"]![indexPath.row]
                    }
                    cell.textLabel?.text = text
                }
            }
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        switch searchMode {
        case .sticker:
            let title = cell?.textLabel?.text
            if (indexPath as NSIndexPath).section == 0 {//Recent
//                showStickersCollectionForASelectedTitle(recentStickersGroup[title!]!, title: title!)
            }
            else if (indexPath as NSIndexPath).section == 1 {//Result
                showStickersCollectionForASelectedTitle(resultStickersGroup[title!]!, title: title!)
            }
            break
        case .font:
            if (indexPath as NSIndexPath).section == 0 {//Recent
                addWordImgTool.setFontForActivatedTextView(recentFonts[(indexPath as NSIndexPath).row])
            }
            else if (indexPath as NSIndexPath).section == 1 {//Result
                if let activeTV = addWordImgTool.activeTextView() {
                    if let lang = (activeTV.text as NSString).detectLanguage() {
                        
                        let allLangs = [String](allFonts.keys)
                        
                        if allLangs.contains(lang) {
                            addWordImgTool.setFontForActivatedTextView(allFonts[lang]![indexPath.row])
                            SharePicUtil.saveAsRecentFont(allFonts[lang]![indexPath.row])
                        }
                        else {
                            addWordImgTool.setFontForActivatedTextView(allFonts["en"]![indexPath.row])
                            SharePicUtil.saveAsRecentFont(allFonts["en"]![indexPath.row])
                        }
                    } else {
                        addWordImgTool.setFontForActivatedTextView(allFonts["all"]![indexPath.row])
                        SharePicUtil.saveAsRecentFont(allFonts["all"]![indexPath.row])
                    }
                }
            }
            isEditingWord = false
            break
        }
        tableResults.isHidden = true
        searchBarSticker.resignFirstResponder()
    }
    
    
    
    //MARK: - UISearchBar Deleagte
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        stickerResultsWithKeyword(searchText)
    }
    
//    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
//        searchBar.resignFirstResponder()
//        
//        hideStickersCollection()
//        
//        recentStickersGroup.removeAll()
//        resultStickersGroup.removeAll()
//        tableResults.reloadData()
//        
//        tableResults.hidden = true
//    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    //MARK: - UICollectionView DataSource & Delegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickersForATitle.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StickerResultCollectionViewCell", for: indexPath) as! StickerResultCollectionViewCell
        let sticker = stickersForATitle[(indexPath as NSIndexPath).row]
        
        cell.sticker = sticker
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.size.width / 2
        let height = width
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //...
        let cell = collectionView.cellForItem(at: indexPath) as! StickerResultCollectionViewCell
//        stickerImgTool.placeSticker(onPanel: cell.sticker.image)
        stickerImgTool.placeSticker(onPanel: cell.sticker.image,stickerId:cell.sticker.id)
//        stickerImgTool.changeActivedStickerColor(with: UIColor.white)
        
        //save as recent sticker
        cell.sticker.saveAsRecent()
        toolBar.deSelectItem(btnAddSticker)
        setupColorBar()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    //MARK: - Did Tap On Recent/Color Item in the scrollBar
    func didTapOnRecentStickerItem(_ tap: UITapGestureRecognizer) {
        let toolbarItem = tap.view as! ToolBarMenuItem
        let sticker_id = toolbarItem.identity
        let sticker = Stickers.sharedInstance.sticker(sticker_id!)
//        stickerImgTool.placeSticker(onPanel: sticker!.image)
        stickerImgTool.placeSticker(onPanel: sticker!.image, stickerId: sticker_id)
//        stickerImgTool.changeActivedStickerColor(with: UIColor.white)
        
        sticker?.saveAsRecent()
        setupRecentStickerBar()
//        setupColorBar()
    }
    
    func didTapOnColorItem(_ tap: UITapGestureRecognizer) {
        let toolbarItem = tap.view as! ToolBarMenuItem
//        if toolbarItem.identity == "font" {
//            onClickFont()
//        }
//        else {
//            let hex_color = toolbarItem.identity
//            let color = UIColor(hex: hex_color)
//            stickerImgTool.changeActivedStickerColorWith(color)
//            addWordImgTool.setFillColorForActivatedTextView(color)
//        }
        
        //https://trello.com/c/dmvjdw0L/14-font-change-should-be-fix-don-t-move-with-color-panel
        let hex_color = toolbarItem.identity
        let color = UIColor(hex: hex_color)
        
        lastestColorInHex = hex_color
        
        stickerImgTool.changeActivedStickerColor(with: color)
        addWordImgTool.setFillColorForActivatedTextView(color)
    }
    
    //MARK: - Signup View
    func showSignupView() {
        
        viewSignup.isHidden = false
        
        let txtEmail = viewSignup.viewWithTag(100) as! FormTextField
        let txtPw = viewSignup.viewWithTag(101) as! FormTextField
        let btnRegister = viewSignup.viewWithTag(102) as! UIButton
        let btnLogin = viewSignup.viewWithTag(103) as! UIButton
        let btnCancel = viewSignup.viewWithTag(104) as! UIButton
        let btnFbLogin = viewSignup.viewWithTag(105) as! UIButton
        let btnGoogleLogin = viewSignup.viewWithTag(106) as! UIButton
        
        //setui
        txtEmail.text = ""
        txtPw.text = ""
        
        let once_inSelf = String(format: "%p", self)
        DispatchQueue.once(token: once_inSelf) {
            btnRegister.layer.cornerRadius = 5
            btnRegister.clipsToBounds = true
            btnLogin.layer.cornerRadius = 5
            btnLogin.clipsToBounds = true
            btnCancel.layer.cornerRadius = 5
            btnCancel.clipsToBounds = true
            btnFbLogin.layer.cornerRadius = 5
            btnFbLogin.clipsToBounds = true
            btnGoogleLogin.layer.cornerRadius = 8
            btnGoogleLogin.clipsToBounds = true
            
            btnRegister.addTarget(self, action: #selector(MainViewController.onRegister(_:)), for: .touchUpInside)
            btnCancel.addTarget(self, action: #selector(MainViewController.onCancel(_:)), for: .touchUpInside)
            btnLogin.addTarget(self, action: #selector(MainViewController.onLogin(_:)), for: .touchUpInside)
            btnFbLogin.addTarget(self, action: #selector(MainViewController.onFBLogin(_:)), for: .touchUpInside)
            btnGoogleLogin.addTarget(self, action: #selector(MainViewController.onGoogleLogin(_:)), for: .touchUpInside)
        }
    }
    
    func onRegister(_ sender: UIButton) {
        let email = (viewSignup.viewWithTag(100) as! FormTextField).text
        let password = (viewSignup.viewWithTag(101) as! FormTextField).text
        
        if !CommonFunc.isEmail(with: email) {
            CommonFunc.showMBProgressHud(on: self.view, withText: "Email Type is wrong!", delay: 2.0)
            return
        }
        
        if password == "" {
            CommonFunc.showMBProgressHud(on: self.view, withText: "Input Passoword!", delay: 2.0)
            return
        }
        
        CommonFunc.startWaitingMBProgressHud(on: self.view, andTag: "signup", isBlockView: true)
        FIRAuth.auth()?.createUser(withEmail: email!, password: password!) { (user, error) in
            CommonFunc.commitWaitingMBProgressHud(withTag: "signup")
            if let _ = error {
                if let info = (error as? NSError)?.userInfo {
                    if (info["error_name"] as! String) == ERROR_EMAIL_ALREADY_IN_USE {
                        CommonFunc.showMBProgressHud(on: self.view, withText: "Such Email is already taken!", delay: 2.0)
                    }
                }
                else {
                    CommonFunc.showMBProgressHud(on: self.view, withText: "Server Connection Error!", delay: 2.0)
                }
            }
            else {
                CommonFunc.showMBProgressHud(on: self.view, withText: "Sucessfully Registered!", delay: 2.0)
                self.viewSignup.isHidden = true
                SharePicUtil.setUserData(user!.uid, email: user!.email!, FBName: "Nil", completion: nil) //UPDATE00001
            }
        }
    }
    
    func onLogin(_ sender: UIButton) {
        try! FIRAuth.auth()!.signOut()
        
        let email = (viewSignup.viewWithTag(100) as! FormTextField).text
        let password = (viewSignup.viewWithTag(101) as! FormTextField).text
        
        if !CommonFunc.isEmail(with: email) {
            CommonFunc.showMBProgressHud(on: self.view, withText: "Email Type is wrong!", delay: 2.0)
            return
        }
        
        if password == "" {
            CommonFunc.showMBProgressHud(on: self.view, withText: "Input Passoword!", delay: 2.0)
            return
        }
        
        CommonFunc.startWaitingMBProgressHud(on: self.view, andTag: "signing", isBlockView: true)
        FIRAuth.auth()?.signIn(withEmail: email!, password: password!) { (user, error) in
            CommonFunc.commitWaitingMBProgressHud(withTag: "signing")
            if let _ = error {
                if (((error as! NSError).userInfo["error_name"] as? String) == ERROR_USER_NOT_FOUND) || (((error as! NSError).userInfo["error_name"] as? String) == ERROR_WRONG_PASSWORD) {
                    
                    CommonFunc.showMBProgressHud(on: self.view, withText: "Email or Password is incorrect!", delay: 2.0)
                }
                else {
                    CommonFunc.showMBProgressHud(on: self.view, withText: "Server Connection Error!", delay: 2.0)
                }
            }
            else {
                CommonFunc.showMBProgressHud(on: self.view, withText: "Sucessfully Logged in!", delay: 2.0)
                self.viewSignup.isHidden = true
            }
        }
    }
    
    func onCancel(_ sender: UIButton) {
        viewSignup.isHidden = true
    }
    
    func onFBLogin(_ sender: UIButton) {
        
    }
    
    func onGoogleLogin(_ sender: UIButton) {
        
    }
    
    //MARK: - Suggest Sticker
    @IBAction func onSuggestStickerAction(_ sender: UIButton) {
        
        switch sender.tag {
        case 200:
            //suggest sticker
            let txtInputSticker: FormTextField = viewSuggestSticker.viewWithTag(100) as! FormTextField
            let stickerName = txtInputSticker.text
            
            if stickerName == "" {
                CommonFunc.showMBProgressHud(on: self.view, withText: "Input Sticker Name to Suggest", delay: 2.5)
                return
            }
            
            //suggest sticker to server
            CommonFunc.startWaitingMBProgressHud(on: self.view, andTag: "suggestSticker")
            SharePicUtil.setSuggestedWord(SharePicUtil.currentUser.uid, suggestedWord: stickerName!, completion: { (error, ref) in
                
                CommonFunc.commitWaitingMBProgressHud(withTag: "suggestSticker")
                
                if let _ = error {
                    CommonFunc.showMBProgressHud(on: self.view, withText: "Suggestion Failed!", delay: 2.0)
                }
                else {
                    CommonFunc.showMBProgressHud(on: self.view, withText: "Sucessfully suggested!", delay: 2.0)
                    FIRAnalytics.setUserPropertyString("True", forName: "suggestStickerUser")
                    self.viewSuggestSticker.isHidden = true
                }
                
            })
            break;
        case 300:
            //cancel
            viewSuggestSticker.isHidden = true
            break;
        default:
            break
        }
    }
    
    //MARK: - Google Signin Delegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            CommonFunc.showMBProgressHud(on: self.view, withText: error.localizedDescription, delay: 2.0)
            return
        }
        
        let authentication = user.authentication
        let credential = FIRGoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!,
                                                                     accessToken: (authentication?.accessToken)!)
        
        CommonFunc.startWaitingMBProgressHud(on: self.view, andTag: "loginWithGoogle", isBlockView: true)
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            CommonFunc.commitWaitingMBProgressHud(withTag: "loginWithGoogle")
            if let error = error {
                CommonFunc.showMBProgressHud(on: self.view, withText: error.localizedDescription, delay: 2.0)
                return
            }
            
            CommonFunc.showMBProgressHud(on: self.view, withText: "Sucessfully Logged in!", delay: 2.0)
            self.viewSignup.isHidden = true
            SharePicUtil.setUserData(user!.uid, email: user!.email!, FBName: "Nil", completion: nil) //UPDATE00001
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!,
                withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
        
    }
    
    //MARK: - Facebook login
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        // ...
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        
        CommonFunc.startWaitingMBProgressHud(on: self.view, andTag: "loginWithFB", isBlockView: true)
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            CommonFunc.commitWaitingMBProgressHud(withTag: "loginWithFB")
            if let error = error {
                CommonFunc.showMBProgressHud(on: self.view, withText: error.localizedDescription, delay: 2.0)
                return
            }
            
            CommonFunc.showMBProgressHud(on: self.view, withText: "Sucessfully Logged in!", delay: 2.0)
            self.viewSignup.isHidden = true
            // start get Facebook user info START UPDATE00001
            let graphRequest:FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"name,email"])
            
            graphRequest.start(completionHandler: { (connection, result, error) -> Void in
                
                if ((error) != nil)
                {
                    print("Error: \(error)")
                }
                else
                {
                    let data:[String:String] = result as! [String : String]
                    print(data)
                    SharePicUtil.setUserData(user!.uid, email: "Nil", FBName: data["name"]!, completion: nil) //UPDATE00001
                }
            })
            
            // END UPDATE00001
        }
    }
    
    //MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - MailComposeViewController Delegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch result {
        case .sent:
            break
        case .saved:
            break
        case .cancelled:
            break
        case .failed:
            UIAlertView(title: nil, message: "Mail delivery failed!", delegate: nil, cancelButtonTitle: "Ok").show()
            break
        }
        
        controller.dismiss(animated: true, completion: nil)
        
    }
}
