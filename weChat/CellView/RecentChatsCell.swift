//
//  RecentChatsCell.swift
//  weChat
//
//  Created by 洪森達 on 2018/7/17.
//  Copyright © 2018年 sen. All rights reserved.
//

import UIKit
protocol RecentChatsCellDelegate{
    func didTapAvatarImage(indexPath:IndexPath)
}

class RecentChatsCell: UITableViewCell {

    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBOutlet weak var fullNameLabel: UILabel!
    
    @IBOutlet weak var lastMessageLabel: UILabel!
    
    @IBOutlet weak var messageCounterLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var messageCounterBGView: UIView!
    
    
    var indexPath: IndexPath!
    let tapGestureRecognizer = UITapGestureRecognizer()
    var delegate: RecentChatsCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
      
        messageCounterBGView.layer.cornerRadius = messageCounterBGView.frame.width / 2
        tapGestureRecognizer.addTarget(self, action: #selector(self.avatarTap))
        avatarImage.isUserInteractionEnabled = true
        avatarImage.addGestureRecognizer(tapGestureRecognizer)
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    //MARK: Generate cell
    
    func generateCell(recentChat: NSDictionary , indexPath: IndexPath){
        self.indexPath = indexPath
        
        self.fullNameLabel.text = recentChat[kWITHUSERFULLNAME] as? String
        self.lastMessageLabel.text = recentChat[kLASTMESSAGE] as? String
       // self.messageCounterLabel.text = recentChat[kCOUNTER] as? String
        if let avatarString = recentChat[kAVATAR]{
            imageFromData(pictureData: avatarString  as! String ) { (image) in
                
                if image != nil {
                    self.avatarImage.image = image!.circleMasked
                }
            }
        }
        
        if recentChat[kCOUNTER] as! Int != 0 {
            self.messageCounterLabel.text = "\(recentChat[kCOUNTER] as! Int)"
            self.messageCounterBGView.isHidden = false
            self.messageCounterLabel.isHidden = false
        }else{
        
            self.messageCounterBGView.isHidden = true
            self.messageCounterLabel.isHidden = true
            
        }
        
        var date: Date!
        
        if let created = recentChat[kDATE] {
            
            if (created as! String).count != 14 {
                date = Date()
            }else{
                date = dateFormatter().date(from: created as! String)!
            }
        }else{
            date = Date()
        }
        
        
        self.dateLabel.text = timeElapsed(date: date)
        
        
        
    }
    
    @objc func avatarTap() {
        
        delegate!.didTapAvatarImage(indexPath: indexPath)
        print("touch...\(indexPath)")
        
    }
    
    

}
