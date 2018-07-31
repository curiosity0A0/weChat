//
//  ViewEXT.swift
//  weChat
//
//  Created by 洪森達 on 2018/8/1.
//  Copyright © 2018年 sen. All rights reserved.
//

import UIKit

extension UIView {
    
    func fadeTo(alphaValue: CGFloat ,withDuration duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.alpha = alphaValue
        }
}
}
