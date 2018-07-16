//
//  ShowCell.swift
//  weChat
//
//  Created by 洪森達 on 2018/7/13.
//  Copyright © 2018年 sen. All rights reserved.
//

import UIKit

class ShowCell: UICollectionViewCell {
    
    
    @IBOutlet weak var uiimage: UIImageView!
    
    func generate(cellString:String){
        
        uiimage.image = UIImage(named: cellString)
    }
    
}
