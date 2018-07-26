//
//  PhotoMediaItem.swift
//  weChat
//
//  Created by 洪森達 on 2018/7/26.
//  Copyright © 2018年 sen. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class PhotoMediaItem: JSQPhotoMediaItem {
    override func mediaViewDisplaySize() -> CGSize {
        let defualtSize:CGFloat = 256
        var thimbSize: CGSize = CGSize(width: defualtSize, height: defualtSize)
        
        if (self.image != nil && self.image.size.height > 0 && self.image.size.width > 0) {
            
            let aspect: CGFloat = self.image.size.width / self.image.size.height // 256/130 = 1.9    130/256 = 0.5
            
            if (self.image.size.width > self.image.size.height) {  //                        256 130     130 256
                thimbSize = CGSize(width: defualtSize, height: defualtSize / aspect)
            }else{                         //256                  128
                
                thimbSize = CGSize(width: defualtSize * aspect, height: defualtSize)
                                        //128 (256 * 0.5)          // 256
            }
            
        }
        
        return thimbSize
    }
}
