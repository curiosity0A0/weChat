//
//  GroupMembersCollectionViewCell.swift
//  weChat
//
//  Created by 洪森達 on 2018/8/8.
//  Copyright © 2018年 sen. All rights reserved.
//

import UIKit

protocol GroupMemberCollectionViewCellDelegate {
    func didClickDeleteButton(indexPath:IndexPath)
}


class GroupMembersCollectionViewCell: UICollectionViewCell {
    
    
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    var indextPath : IndexPath!
    var delegate: GroupMemberCollectionViewCellDelegate?
    
    
    
    func generateCell(user:FUser,indexPath:IndexPath){
        
        self.indextPath = indexPath
        if user != nil {
        nameLabel.text = user.fullname
        }
        if user.avatar != "" {
            
            imageFromData(pictureData: user.avatar) { (avatar) in
                if avatar != nil {
                   
                    DispatchQueue.main.async {
                    self.avatarImageView.image = avatar!.circleMasked
                    }
                 
                }
            }
        }
      
        
        
    }
    
    
    @IBAction func deleteBtnPressed(_ sender: Any) {
        delegate!.didClickDeleteButton(indexPath: indextPath)
    }
    
    
    
    
    
    
}
