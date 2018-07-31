//
//  PictureCollectionViewCell.swift
//  weChat
//
//  Created by 洪森達 on 2018/8/1.
//  Copyright © 2018年 sen. All rights reserved.
//

import UIKit

class PictureCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imageView: UIImageView!
    func generateCell(image:UIImage) {
        
        self.imageView.image = image
        
        
    }
    
    
    
}
