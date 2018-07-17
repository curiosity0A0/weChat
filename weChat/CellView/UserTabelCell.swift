//
//  UserTabelCell.swift
//  weChat
//
//  Created by 洪森達 on 2018/7/17.
//  Copyright © 2018年 sen. All rights reserved.
//

import UIKit


protocol UserTabelCellDelegate{
    func didTapAvatarImage(indexPath:IndexPath)
}

class UserTabelCell: UITableViewCell {

    
    var indexPath:IndexPath!
    let tapGetureRecognizer = UITapGestureRecognizer()
    var delegate: UserTabelCellDelegate?
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var fullNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        tapGetureRecognizer.addTarget(self, action: #selector(self.avatarTap))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapGetureRecognizer)
      
    }

    
    func generate(fuser:FUser,indexPath:IndexPath){
        
        self.indexPath = indexPath
        self.fullNameLabel.text = fuser.fullname
        
        if fuser.avatar != "" {
            
            imageFromData(pictureData: fuser.avatar) { (image) in
                if image != nil {
                    
                    DispatchQueue.main.async {
                        self.avatarImageView.image = image!.circleMasked
                    }
                    
                }
             
            }
        }else{
            
            avatarImageView.image = UIImage(named: "avatarPlaceholder")
        }
        
        
        
        
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    //helper
    
    @objc func avatarTap(){
        delegate!.didTapAvatarImage(indexPath: indexPath)
    }

}
