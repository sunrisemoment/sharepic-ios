//
//  PopUpVC.swift
//  findtalents
//
//  Created by steven on 30/4/2016.
//  Copyright © 2016 steven. All rights reserved.
//

import UIKit

typealias ClickHandler = ((_ popupVC: PopUpVC) -> Void)

extension UIApplication {
    class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController {
            let moreNavigationController = tab.moreNavigationController
            
            if let top = moreNavigationController.topViewController , top.view.window != nil {
                return topViewController(top)
            } else if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        
        return base
    }
}

extension UIViewController {
    func addSubViewController(_ vc: UIViewController) {
        self.view.addSubview(vc.view)
        self.addChildViewController(vc)
        vc.didMove(toParentViewController: self)
    }
    
    func removeSubViewController(_ vc: UIViewController) {
        if self.view.subviews.contains(vc.view) {
            vc.view.removeFromSuperview()
        }
    }
}

public enum PopUpStyle: Int {
    case onlyOkButton = 0
    case okAndCancelButton = 1
}

class PopUpVC: UIViewController {
    
    @IBOutlet weak var btnOkay: UIButton!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    
    @IBOutlet weak var btnOkWithCancel: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    var messageForPopup: String = ""
    var titleForPopup: String = ""
    
    fileprivate var bg: UIView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
    
    fileprivate var onOKClick: ClickHandler?
    fileprivate var onCancelClick: ClickHandler?
    fileprivate var popupStyle: PopUpStyle = .onlyOkButton
    fileprivate var okBtnTitle: String?
    fileprivate var cancelBtnTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureUI()
        
        lblTitle.text = titleForPopup
        lblMessage.text = messageForPopup
        
        if let title = okBtnTitle {
            btnOkay.setTitle(title, for: UIControlState())
            btnOkWithCancel.setTitle(title, for: UIControlState())
        }
        if let title = cancelBtnTitle {
            btnCancel.setTitle(title, for: UIControlState())
        }
        
        viewContainer.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        self.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        
        switch popupStyle {
        case .onlyOkButton:
            btnOkay.isHidden = false
            btnOkWithCancel.isHidden = true
            btnCancel.isHidden = true
            break
        case .okAndCancelButton:
            btnOkay.isHidden = true
            btnOkWithCancel.isHidden = false
            btnCancel.isHidden = false
            break
        
        }
    }
    
    convenience init(title: String, message: String, style: PopUpStyle = .onlyOkButton, onOk: ClickHandler? = nil, onCancel: ClickHandler? = nil, okButtonTitle: String? = nil, cancelButtonTitle: String? = nil) {
        self.init(nibName: "PopUpWindow", bundle: nil)
        
        titleForPopup = title
        messageForPopup = message
        
        onOKClick = onOk
        onCancelClick = onCancel
        
        if let _ = okButtonTitle {
            okBtnTitle = okButtonTitle
        }
        if let _ = cancelButtonTitle {
            cancelBtnTitle = cancelButtonTitle
        }
        popupStyle = style
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.viewContainer.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func configureUI() {
        viewContainer.layer.cornerRadius = 12
        btnOkay.layer.cornerRadius = 17
        btnOkWithCancel.layer.cornerRadius = 17
        btnCancel.layer.cornerRadius = 17
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: - Action Utitiy
    func show(onViewController vc: UIViewController? = nil) {
        if let from = vc {
            bg.backgroundColor = UIColor.darkGray.withAlphaComponent(0.4)
            UIApplication.shared.keyWindow?.addSubview(bg)
            
            //add self as childview controller
            UIApplication.shared.keyWindow?.addSubview(self.view)
            from.addChildViewController(self)
//            self.didMoveToParentViewController(from)
            return
        }
        
        if let from = UIApplication.topViewController() {
            
            bg.backgroundColor = UIColor.darkGray.withAlphaComponent(0.4)
            UIApplication.shared.keyWindow?.addSubview(bg)
            
            //add self as childview controller
            UIApplication.shared.keyWindow?.addSubview(self.view)
            from.addChildViewController(self)
//            self.didMoveToParentViewController(from)
        }
        
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.2, animations: {
            self.viewContainer.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }, completion: { (flag: Bool) in
            self.view.superview?.isUserInteractionEnabled = true
            self.view.removeFromSuperview()
            self.bg.removeFromSuperview()
            self.removeFromParentViewController()
        }) 
    }
    
    //MARK: UI Action with only Okay Button
    @IBAction func onOkay(_ sender: AnyObject) {
        if let _ = onOKClick {
            onOKClick!(self)
        }
        else {
            dismiss()
        }
    }
    
    //MARK: UI Action with Okay and Cancel Button
    @IBAction func onOkWithCancel(_ sender: AnyObject) {
        if let _ = onOKClick {
            onOKClick!(self)
        }
        else {
            dismiss()
        }
    }
    
    @IBAction func onCancel(_ sender: AnyObject) {
        if let _ = onCancelClick {
            onCancelClick!(self)
        }
        else {
            dismiss()
        }
    }
}
