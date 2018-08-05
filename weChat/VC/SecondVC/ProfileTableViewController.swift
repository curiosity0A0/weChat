//
//  ProfileTableViewController.swift
//  weChat
//
//  Created by 洪森達 on 2018/7/17.
//  Copyright © 2018年 sen. All rights reserved.
//

import UIKit
import SVProgressHUD

class ProfileTableViewController: UITableViewController {

  
    
    @IBOutlet weak var fullNameLabel: UILabel!
    
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var messageBtn: UIButton!
    
    @IBOutlet weak var callBtn: UIButton!
    
    @IBOutlet weak var blockBtn: UIButton!
    
    
    
    var user: FUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        setupUI()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
     
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 0
        }else{
            
            return 30
        }
    }
    
    
    
    //IBACtion
    
   
    
    @IBAction func messageBtnPressed(_ sender: Any) {
        if !checkBlockedStatus(withUser: user!) {
            let chatVC = ChatViewController()
            chatVC.titleName = user!.firstname
            chatVC.memberidsToPush = [FUser.currentId(),user!.objectId]
            chatVC.memberids = [FUser.currentId(),user!.objectId]
            chatVC.chatRoomId = startPrivateChat(user1: FUser.currentUser()!, user2: user!)
            chatVC.isGroup = false
            chatVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(chatVC, animated: true)
            
        }else{
            
            SVProgressHUD.showError(withStatus: "This user is not available for chat!")
            
        }
        
       
    }
    
    @IBAction func callBtnPressed(_ sender: Any) {
          print("call user\(user!.fullname)")
    }
    
    @IBAction func blockUserBtnPressed(_ sender: Any) {
        
        var BlockUsers = FUser.currentUser()!.blockedUsers
       
        if BlockUsers.contains(user!.objectId) {
            
            BlockUsers.remove(at: BlockUsers.index(of:user!.objectId)!)

        }else{
            BlockUsers.append(user!.objectId)
        }
        
        updateCurrentUserInFirestore(withValues: [kBLOCKEDUSERID:BlockUsers]) { (error) in
            
            if error != nil {
                DispatchQueue.main.async {
                    
                    print(error!.localizedDescription)
                    return
                }
            }
            
            self.updatedBlockStatus()
            
        }
        
        blockUser(userToBlock: user!)
        
    }
    
    
    func setupUI(){
        
        if user != nil {
            
            fullNameLabel.text = user!.fullname
            phoneNumberLabel.text = user!.phoneNumber
            
            updatedBlockStatus()
            
            if user!.avatar != "" {
                
                imageFromData(pictureData: user!.avatar) { (image) in
                    
                    if image != nil {
                        DispatchQueue.main.async {
                            self.avatarImageView.image = image!.circleMasked
                        }
                        
                    }else{
                        
                        DispatchQueue.main.async {
                            self.avatarImageView.image = UIImage(named: "avatarPlaceholder")
                        }
                    }

                }
            }
        }

    }
    
    
    
    func updatedBlockStatus() {
        
        if user!.objectId != FUser.currentId() {
            self.blockBtn.isHidden = false
            self.messageBtn.isHidden = false
            self.callBtn.isHidden = false
        }else{
            self.blockBtn.isHidden = true
            self.messageBtn.isHidden = true
            self.callBtn.isHidden = true
            
        }
        
        if FUser.currentUser()!.blockedUsers.contains(user!.objectId) {
            
            blockBtn.setTitle("Unblock User", for: .normal)
        }else{
            
            blockBtn.setTitle("Block User", for: .normal)
        }
        
    }

} //end of the class
