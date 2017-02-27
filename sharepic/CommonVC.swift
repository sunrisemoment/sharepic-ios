//
//  CommonVC.swift
//  sharepic
//
//  Created by steven on 14/8/2016.
//  Copyright © 2016 allyouneedapp. All rights reserved.
//

import UIKit

class CommonVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        let imageView = UIImageView(image: UIImage(named: "bg"))
//        view.addSubview(imageView);
//        view.sendSubviewToBack(imageView)
//        imageView <- [
//            Top(0),
//            Bottom(0),
//            Left(0),
//            Right(0)
//        ]
        
        self.view.backgroundColor = UIColor(hex: "24292D")
        
        //set navigation bar
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle
    {
        return .lightContent;
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
