//
//  UIViewControllerEXT.swift
//  weChat
//
//  Created by 洪森達 on 2018/8/1.
//  Copyright © 2018年 sen. All rights reserved.
//

import UIKit


extension UIViewController {
    func shouldPresentLoadingView(_ status:Bool){
        var fadeVeiw: UIView?
        if status == true {
            
         let window = UIApplication.shared.keyWindow
            
            
            
            fadeVeiw = UIView(frame: CGRect(x: 0, y: 0, width: (window?.frame.width)!, height: (window?.frame.height)!))
            
            fadeVeiw?.backgroundColor = UIColor.black
            fadeVeiw?.alpha = 0.0
            fadeVeiw?.tag = 99
            
            let spinner = UIActivityIndicatorView()
            spinner.color = UIColor.white
            spinner.style = .whiteLarge
            spinner.center = view.center
            view.addSubview(fadeVeiw!)
            fadeVeiw?.addSubview(spinner)
            spinner.startAnimating()
            fadeVeiw?.fadeTo(alphaValue: 0.7, withDuration: 0.2)
            
            
        }else{
            
            
            for view in view.subviews {
                if view.tag == 99 {
                    
                    UIView.animate(withDuration: 0.2, animations: {
                        view.alpha = 0.0
                    }) { (finished) in
                        view.removeFromSuperview()
                    }
                    
                }
            }
            
        }
        
    }
    
}
