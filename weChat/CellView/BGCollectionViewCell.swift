//
//  BGCollectionViewCell.swift
//  weChat
//
//  Created by 洪森達 on 2018/8/7.
//  Copyright © 2018年 sen. All rights reserved.
//

import UIKit

class BGCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    func generate(image:UIImage){
        
        imageView.image = image
        
        
    }
    
}
