//
//  ViewController.swift
//  sharepic
//
//  Created by steven on 9/8/2016.
//  Copyright © 2016 allyouneedapp. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import FBSDKCoreKit
import FBSDKShareKit
import UserNotifications

class MainViewController: CommonVC, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CustomToolBarActionDelegate, GIDSignInUIDelegate, GIDSignInDelegate, UITextFieldDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate , UITableViewDelegate, UITableViewDataSource{
    
    //Constants
    let blackBgViewTag: Int = 77

    @IBOutlet weak var btnContactUs: UIButton!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var btnAlbums: UIButton!
    
    @IBOutlet weak var viewAlbumChoose: UIView!
    @IBOutlet weak var viewMoreChoose: UIView!
    @IBOutlet weak var viewContactUsChoose: UIView!
    
    @IBOutlet weak var viewSignup: UIView!
    
    @IBOutlet weak var viewSuggestSticker: UIView!
    
    @IBOutlet weak var activatorForLoadingImages: UIActivityIndicatorView!
    
    @IBOutlet weak var ImgDimEffectBackground: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var albumChooseViewHight: NSLayoutConstraint!
    
    var toolBar: CustomToolBarAction!

    
    var images_loadTime = [PHAsset]()
    var images_cameraRoll = [PHAsset]()
    var images_myPhotoStream = [PHAsset]()
    var images_dropbox = [PHAsset]()
    var images_recentlyDeleted = [PHAsset]()
    var images_screenshots = [PHAsset]()
    
    var selected_imageSource = [PHAsset]()
    
    var photoCount : Int = 0
    var photos : [PHAsset] = [PHAsset]()
    var allAlbums : [AlbumNameContent] = []
    var launchVC : UIViewController!
    
//    let serial_queue = dispatch_queue_create("loadImage_from_album_serial_queue", nil)
    
    @IBOutlet weak var viewCollectionImages: UICollectionView!
    
    @IBOutlet weak var txtInputStickerName: FormTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.white
        
        let sb = UIStoryboard.init(name: "LaunchScreen", bundle: nil)
        launchVC = sb.instantiateViewController(withIdentifier: "LaunchScreen")
        self.navigationController?.view.addSubview(launchVC.view)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.permissionAllowed), name: NSNotification.Name(rawValue: "AuthorizedPhotoLibraryAccess"), object: nil)
        
        //for permission
        let mediaPermission = PermissionScope()
        mediaPermission.addPermission(PhotosPermission(), message: "We use this to pick the image on your album")

        mediaPermission.show({ (finished, results) in
            
            if results[0].status == PermissionStatus.authorized {
                DispatchQueue.main.async(execute: {
                    self.getAllAlbumNames()
                    self.launchVC.view.removeFromSuperview()
                })
            }
            }, cancelled: { (results) in
                self.launchVC.view.removeFromSuperview()
        })
        
        ImgDimEffectBackground.isHidden = true
        
        setUI()
        
        toolBar = CustomToolBarAction(toolBarItems: [btnContactUs, btnMore, btnAlbums], delegate: self)

    }
    
    func initializeGoogleSigninUI() {
        //Google Signup
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        // Uncomment to automatically sign in the user.
        //GIDSignIn.sharedInstance().signInSilently()
        
        // TODO(developer) Configure the sign-in button look/feel
        // ...
    }
    
    func initializeFacebookSigninUI() {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initializeGoogleSigninUI()
        preImageLoad()

    }
    
    func permissionAllowed(){
        self.getAllAlbumNames()
        preImageLoad()
        launchVC.view.removeFromSuperview()
    }
    
    func preImageLoad() {
        activatorForLoadingImages.isHidden = false
        var _count: Int = 0
        self.images_loadTime = []
        CommonUtil.getSyncPhotosForCameraRoll(false, searchCompletion: {(photoCount) in
            _count = photoCount
            }, enumerateHandler: { (asset) in
                if self.images_loadTime.count == _count - 1 {
                    self.activatorForLoadingImages.isHidden = true
                }
                self.images_loadTime.append(asset)
        })
        
        self.activatorForLoadingImages.isHidden = true
        selected_imageSource = images_loadTime
        viewCollectionImages.reloadData()
    }
    
    
    func loadPhotos() {
//        activatorForLoadingImages.isHidden = false
//        var _count: Int = 0
//        CommonUtil.getSyncPhotosForCameraRoll(false, searchCompletion: {(photoCount) in
//            _count = photoCount
//            }, enumerateHandler: { (asset) in
//                if self.images_loadTime.count == _count - 1 {
//                    self.activatorForLoadingImages.isHidden = true
//                }
//                self.images_loadTime.append(asset)
//        })
//        if _count == 0 {
//            self.activatorForLoadingImages.isHidden = true
//        }
//        selected_imageSource = images_loadTime
//        viewCollectionImages.reloadData()        
        //set album sub menu pictures and its count
        DispatchQueue.global().async(execute: {
            CommonUtil.getSyncPhotosForCameraRoll(false, searchCompletion: nil, enumerateHandler: { (asset) in
                self.images_cameraRoll.append(asset)
            })
            if self.images_cameraRoll.count != 0 {
                self.allAlbums.append(AlbumNameContent(name: "Camera Roll",count: self.images_cameraRoll.count))
            }

        })

        DispatchQueue.global().async(execute: {
            CommonUtil.getSyncPhotosForAlbum("My Photo Stream", searchCompletion: { (albumFound, photoCount) in
                DispatchQueue.main.async(execute: {
                   
                })
                }, enumerateHandler: {(asset) in
                    self.images_myPhotoStream.append(asset)
            })
            if self.images_myPhotoStream.count != 0 {
                self.allAlbums.append(AlbumNameContent(name: "My photo" , count: self.images_myPhotoStream.count))
            }
        })

        DispatchQueue.global().async(execute: {
            CommonUtil.getSyncPhotosForAlbum("Dropbox", searchCompletion: { (albumFound, photoCount) in
                DispatchQueue.main.async(execute: {
                    
                })
                }, enumerateHandler: { (asset) in
                    self.images_dropbox.append(asset)
            })
            if self.images_dropbox.count != 0 {
                self.allAlbums.append(AlbumNameContent(name: "DropBox", count: self.images_dropbox.count))
            }
        })

        DispatchQueue.global().async(execute: {
            CommonUtil.getSyncPhotosForScreenshots({ (photoCount) in
                DispatchQueue.main.async(execute: {
                   
                })
                }, enumerateHandler: { (asset) in
                    self.images_screenshots.append(asset)
            })
            if self.images_screenshots.count != 0 {
                self.allAlbums.append(AlbumNameContent(name: "Screenshot" , count: self.images_screenshots.count))
            }
        })
        
    }
    
    //get all AlbumNames from device
    func getAllAlbumNames() {
        self.allAlbums.removeAll()
        DispatchQueue.global().async(execute: {
            CommonUtil.getAllAlbumNamesAndCounts({ (name, count) in
                if count != 0 {
                    self.allAlbums.append(AlbumNameContent(name: name, count: count))
                }
            })
            self.loadPhotos()
        })
    }
    
    
    //MARK: - SetUI
    func setUI() {
        
        SharePicUtil.setShadow(viewAlbumChoose)
        //setup constrain for the viewContactUsChoose
        let subContactButtons = viewContactUsChoose.subviews
        for subButton in subContactButtons {
            SharePicUtil.setShadow(subButton)
            
            if subButton.tag == 3 || subButton.tag == 4 {
                subButton <- Bottom(20).to(btnContactUs, .top).when{Device().IS_4_INCHES_OR_SMALLER()}
            }
        }
        
        //setup constrain for the viewMoreChoose
        let subMoreButtons = viewMoreChoose.subviews
        for subButton in subMoreButtons {
            SharePicUtil.setShadow(subButton)
            
            if subButton.tag == 3 {//if rate button
                subButton <- Bottom(20).to(btnMore, .top).when{Device().IS_4_INCHES_OR_SMALLER()}
            }
        }
        
        viewSignup.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        viewSuggestSticker.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        viewSuggestSticker.viewWithTag(200)?.layer.cornerRadius = 5 //suggest sticker button
        viewSuggestSticker.viewWithTag(200)?.clipsToBounds = true
        viewSuggestSticker.viewWithTag(300)?.layer.cornerRadius = 5 //cancel button
        viewSuggestSticker.viewWithTag(300)?.clipsToBounds = true
    }
    
    //MARK: - UIAction
    @IBAction func onToolBarBtnClick(_ sender: UIButton) {
        
        if (sender == btnCamera) {
            let cameraVC = self.storyboard?.instantiateViewController(withIdentifier: "CameraVC")
            navigationController?.pushViewController(cameraVC!, animated: true)
        }
    }
    
    @IBAction func onClickContactUsSubMenu(_ sender: UIButton) {
        let tag = sender.tag
        switch tag {
        case 1:
            //suggest sticker
            if let _ = SharePicUtil.currentUser {
                // User is signed in.
                (self.viewSuggestSticker.viewWithTag(100) as! FormTextField).text = ""
                self.viewSuggestSticker.isHidden = false
            } else {
                // No user is signed in.
                self.showSignupView()
            }

            break
        case 2:
            //email
            let systemVersion = UIDevice.current.systemVersion
            let model = UIDevice.current.modelName
            let toRecipents = [CONTACT_EMAIL]
            let mc = MFMailComposeViewController()
            mc.mailComposeDelegate = self
            mc.setSubject("Support PalPic App: iOS \(APP_Version)")
            mc.setToRecipients(toRecipents)
            mc.setMessageBody("Dear, \n \n \n System Version: iOS \(systemVersion) \n Model: \(model)", isHTML: false)
            present(mc, animated: true, completion: nil)
            
            break
        case 3:
            //like fanpage
            
            let http_url = URL(string: "https://www.facebook.com/palpicapp")!
            let scheme_url = URL(string: "https://www.facebook.com/palpicapp")!
            
            if UIApplication.shared.canOpenURL(scheme_url) {
                UIApplication.shared.openURL(scheme_url)
            }
            else {
                UIApplication.shared.openURL(http_url)
            }
            break
        case 4:
            //follow us
            
            let http_url = URL(string: "https://www.instagram.com/")
            let schema_url = URL(string: "instagram://user?username=palpicapp")
            
            if UIApplication.shared.canOpenURL(schema_url!) {
                UIApplication.shared.openURL(schema_url!)
            }
            else {
                UIApplication.shared.openURL(http_url!)
            }
            break
        default:
            break
        }
    }
    
    @IBAction func onClickMoreSubMenu(_ sender: UIButton) {
        let tag = sender.tag
        switch tag {
        case 1:
            //tell a friend
            let actionSheet = UIActionSheet(title: "Choose Option", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Facebook", "Twitter", "Email")
            actionSheet.show(in: view)
            break
        case 2:
            //gift the app
            if let _ = SharePicUtil.currentUser {
                try! FIRAuth.auth()!.signOut()
                FBSDKLoginManager().logOut()
                
                let alert = UIAlertController(title: "SharePic", message: "Sign-out complete", preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "SharePic", message: "You are not Sign-in", preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
            
            break
        case 3:
            //rate the app

            if let checkURL = URL(string: "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\(appID)&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8") {
                if UIApplication.shared.canOpenURL(checkURL) {
                    UIApplication.shared.openURL(checkURL)
                    print("url successfully opened")
                }
            } else {
                print("invalid url")
            }

            break
        default:
            break
        }
    }
    
    
    //MARK: - UICollectionViewDelegate & DataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selected_imageSource.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recent_photo", for: indexPath) as! RecentPhotoCollectionViewCell
        
        let imageManager = PHCachingImageManager()
        let options = PHImageRequestOptions()
        options.deliveryMode = .fastFormat
        options.isSynchronous = true
        var _image: UIImage!
        imageManager.requestImage(for: selected_imageSource[(indexPath as NSIndexPath).row],
                                          targetSize: CGSize(width: collectionView.frame.size.width / 4, height: collectionView.frame.size.width / 4),
                                          contentMode: .aspectFill,
                                          options: options,
                                          resultHandler: {
                                            image, info in
                                            _image = image
        })
        cell.photo.image = _image
        cell.photo.contentMode = .scaleAspectFill
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.size.width / 4
        let height = width
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = selected_imageSource[(indexPath as NSIndexPath).row]
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CropVC") as! CropVC
        
        let imageManager = PHCachingImageManager()
        let options = PHImageRequestOptions()
        options.deliveryMode = .fastFormat
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true
        CommonFunc.startWaitingMBProgressHud(on: UIApplication.shared.keyWindow!, andTag: "imageLoad", title:"Photo Loading...", isBlockView: true)
        DispatchQueue.main.asyncAfter(deadline: .now() , execute: {
            imageManager.requestImage(for: asset,
                                      targetSize: CGSize(width: asset.pixelWidth,
                                                         height: asset.pixelHeight),
                                      contentMode: .aspectFit,
                                      options: options,
                                      resultHandler: {
                                        image, info in
                                        if let _image = image {
                                            vc.originalImage = _image
                                            self.navigationController?.pushViewController(vc, animated: true)
                                        }
                                        CommonFunc.commitWaitingMBProgressHud(withTag: "imageLoad")
            })

        })
    }
    
    //MARK: - CustomToolBarAction Delegate
    func didSelectedToolBarItem(_ item: UIButton) {
        if (item == btnContactUs) {
            btnContactUs.setImage(UIImage(named: "contactUsPress"), for: UIControlState())
            viewContactUsChoose.isHidden = false
            ImgDimEffectBackground.isHidden = false
            
            let bgview = UIView(frame: CGRect(x: 0, y: STATUSBAR_HEIGHT, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - STATUSBAR_HEIGHT - TOOLBAR_HEIGHT1))
            bgview.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            bgview.tag = blackBgViewTag
            self.view.insertSubview(bgview, at: 2) //above the gallery view
        }
        else if (item == btnMore) {
            btnMore.setImage(UIImage(named: "morePress"), for: UIControlState())
            viewMoreChoose.isHidden = false
            ImgDimEffectBackground.isHidden = false
            
            let bgview = UIView(frame: CGRect(x: 0, y: STATUSBAR_HEIGHT, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - STATUSBAR_HEIGHT - TOOLBAR_HEIGHT1))
            bgview.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            bgview.tag = blackBgViewTag
            self.view.insertSubview(bgview, at: 2)
        }
        else if (item == btnAlbums) {
            viewCollectionImages.isUserInteractionEnabled = false
            self.albumChooseViewHight.constant = CGFloat(44 * self.allAlbums.count)
            self.allAlbums.sort { $0.count > $1.count}
            self.tableView.reloadData()
            btnAlbums.setImage(UIImage(named: "albumsPress"), for: UIControlState())
            viewAlbumChoose.isHidden = false
        }
    }
    
    func didDeselectToolBarItem(_ item: UIButton) {
        if (item == btnContactUs) {
            btnContactUs.setImage(UIImage(named: "contactUs"), for: UIControlState())
            viewContactUsChoose.isHidden = true
            ImgDimEffectBackground.isHidden = true
            
            self.view.viewWithTag(blackBgViewTag)?.removeFromSuperview()
        }
        else if (item == btnMore) {
            btnMore.setImage(UIImage(named: "more"), for: UIControlState())
            viewMoreChoose.isHidden = true
            ImgDimEffectBackground.isHidden = true
            
            self.view.viewWithTag(blackBgViewTag)?.removeFromSuperview()
        }
        else if (item == btnAlbums) {
            btnAlbums.setImage(UIImage(named: "albums"), for: UIControlState())
            viewAlbumChoose.isHidden = true
            viewCollectionImages.isUserInteractionEnabled = true
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        toolBar.deSelectItem(btnAlbums)
        toolBar.deSelectItem(btnMore)
        toolBar.deSelectItem(btnContactUs)
    }
    
    @IBAction func toMainVC(_ segue: UIStoryboardSegue) {
        
    }
    
    //MARKL -
    
    //MARK: - Signup View
    var initSignupView_onceToken: Int = 0
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
        
        DispatchQueue.once(token: "signup_once") {
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
                    else {
                        CommonFunc.showMBProgressHud(on: self.view, withText: "Register Failed!", delay: 2.0)
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
            if let error = (error as? NSError) {
                if ((error.userInfo["error_name"] as? String) == ERROR_USER_NOT_FOUND) || ((error.userInfo["error_name"] as? String) == ERROR_WRONG_PASSWORD) {
                    
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
    
    
    //MARK: - Facebook login
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        // ...
        if let currentToken = FBSDKAccessToken.current(){
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: currentToken.tokenString)
            
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
        else {
            CommonFunc.showMBProgressHud(on: self.view, withText: "Failed to take token", delay: 2.0)
        }
    }
    
    //MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - Tell A Friend ActionSheetDelegate
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        
        if buttonIndex == 1 {
            //click facebook
            let content = FBSDKShareLinkContent()
            content.contentURL = URL(string: AppStoreUrl)
            FBSDKShareDialog.show(from: self, with: content, delegate: nil)
            
        }
        else if buttonIndex == 2 {
            //click twitter
            if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
                let twitterSheetObj = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                twitterSheetObj?.setInitialText(AppStoreUrl)
                present(twitterSheetObj!, animated: true, completion: nil)
            }
            else {
                UIAlertView(title: "SharePic", message: "Please configure twitter account in Phone Setting", delegate: nil, cancelButtonTitle: "Ok").show()
            }
        }
        else if buttonIndex == 3 {
            //click Email
            let toRecipents = [String]()
            
            let mc = MFMailComposeViewController()
            mc.mailComposeDelegate = self
            mc.setSubject("Check this app: PalPic")
            mc.setMessageBody("Hi, \n \n I love PalPic app. It’s wonderful to share wonderful moment with friend and can put a meaningful sticker. Here is the link: \(AppStoreUrl)", isHTML: false)
            mc.setToRecipients(toRecipents)
            present(mc, animated: true, completion: nil)
            
        }
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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allAlbums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumNameCell") as! AlbumNameCell
        let item = self.allAlbums[indexPath.item]
        if item.count == 0 {
            
        }
        cell.lblAlbumName.text = item.name
        cell.lblContentNumber.text = String(item.count)
        cell.selectionStyle = .none
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selected_imageSource.removeAll()
        let item = self.allAlbums[indexPath.item]
        if item.name == "Camera Roll" {
            self.selected_imageSource = self.images_cameraRoll
        } else if item.name == "DropBox"{
            self.selected_imageSource = self.images_dropbox
        } else if item.name == "My photo"{
            self.selected_imageSource = self.images_myPhotoStream
        } else if item.name == "Screenshot"{
            self.selected_imageSource = self.images_screenshots
        } else {
            CommonUtil.getSyncPhotosForAlbum(item.name , searchCompletion: { (status, count) in
                self.photoCount = count
            }) { (asset) in
                self.selected_imageSource.append(asset)
            }
        }
        self.viewCollectionImages.reloadData()
        viewAlbumChoose.isHidden = true
        toolBar.deSelectItem(btnAlbums)
    }
    @IBAction func unwindFromFinishUp(_ segue: UIStoryboardSegue) {
        
    }
    
    class AlbumNameContent: NSObject {
        var name : String!
        var count : Int!
        override init() {
            super.init()
        }
        init(name : String, count : Int) {
            self.name = name
            self.count = count
        }
    }
}

    public extension UIDevice {
        var modelName: String {
            var systemInfo = utsname()
            uname(&systemInfo)
            let machineMirror = Mirror(reflecting: systemInfo.machine)
            let identifier = machineMirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8 , value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
            switch identifier {
            case "iPod5,1":
                return "iPod Touch 5"
            case "iPod7,1":
                return "iPod Touch 6"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":
                return "iPhone 4"
            case "iPhone4,1":
                return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":
                return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":
                return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":
                return "iPhone 5s"
            case "iPhone7,2":
                return "iPhone 6"
            case "iPhone7,1":
                return "iPhone 6 Plus"
            case "iPhone8,1":
                return "iPhone 6s"
            case "iPhone8,2":
                return "iPhone 6s Plus"
            case "iPhone8,4":
                return "iPhoneSE"
            case "iPhone9,1", "iPhone9,3":
                return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":
                return "iPhone 7 Plus"
                
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":
                return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":
                return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":
                return "iPad 4"
                
                
            case "iPad4,1", "iPad4,2", "iPad4,3":
                return "iPad Air"
            case "iPad5,3", "iPad5,4":
                return "iPad Air 2"
                
            case "iPad2,5", "iPad2,6", "iPad2,7":
                return "iPad Mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":
                return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":
                return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":
                return "iPad Mini 4"
        
            case "iPad6,3", "iPad6,4":
                return "iPadPro9Inch"
            case "iPad6,7", "iPad6,8":
                return "iPad Pro"
                
            case "i386", "x86_64":
                return "Simulator"
            default:
                return identifier
            }
        }
    }

