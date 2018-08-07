//
//  newGroupViewController.swift
//  weChat
//
//  Created by 洪森達 on 2018/8/8.
//  Copyright © 2018年 sen. All rights reserved.
//

import UIKit
import SVProgressHUD

class newGroupViewController: UIViewController {

    @IBOutlet weak var editAvatarBtnOutlet: UIButton!
    
    @IBOutlet weak var groupIconImageView: UIImageView!
    
    @IBOutlet weak var groupSubjectTextField: UITextField!
    
    @IBOutlet weak var participantLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var memberIds: [String] = []
    var allMembers: [FUser] = []
    var groupIcon: UIImage?

   
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        groupIconImageView.isUserInteractionEnabled = true
        let tapGesturer = UITapGestureRecognizer(target: self, action: #selector(self.groupiconTap))
        groupIconImageView.addGestureRecognizer(tapGesturer)
        let dismiss = UITapGestureRecognizer(target: self, action: #selector(self.dismisskeyBoard))
        view.addGestureRecognizer(dismiss)
        updateParticipantsLabel()
    }
    
    
    //MARK: -HelperFunctions
   
    func updateParticipantsLabel(){
        participantLabel.text = "PARTICIPANTS:\(allMembers.count)"
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(self.createBtnPressed))]
        self.navigationItem.rightBarButtonItem?.isEnabled = allMembers.count > 0
    }
    
    
    func showIconOptions(){
      let optionMenu = UIAlertController(title: "Chiise Group Icon", message: nil, preferredStyle: .actionSheet)
        let takePhotoAction = UIAlertAction(title: "Take/Choose Photo", style: .default) { (alert) in
            print("work")
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            
        }
        
        if groupIcon != nil {
            let resetAction = UIAlertAction(title: "Reset", style: .default) { (alert) in
                
                self.groupIcon = nil
                self.groupIconImageView.image = UIImage(named: "cameraIcon")
                self.editAvatarBtnOutlet.isHidden = true
            }
            optionMenu.addAction(resetAction)
        }
        
        optionMenu.addAction(takePhotoAction)
        optionMenu.addAction(cancel)
        
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            
            if let currentPopoverPresentController = optionMenu.popoverPresentationController{
                currentPopoverPresentController.sourceView = editAvatarBtnOutlet
                currentPopoverPresentController.sourceRect = editAvatarBtnOutlet.bounds
                currentPopoverPresentController.permittedArrowDirections = .up
                self.present(optionMenu, animated: true, completion: nil)
                
            }
            
        }else{
            
            self.present(optionMenu, animated: true, completion: nil)
        }
        
        
        
    }
    
    //MARK:IBACTIONS
    
    @objc func dismisskeyBoard(){
        view.endEditing(true)
    }
    
    
    @objc func createBtnPressed(_ sender: Any){
        
        if groupSubjectTextField.text != "" {
//            SVProgressHUD.show()
            memberIds.append(FUser.currentId())
            
            let avatarData = UIImage(named: "groupIcon")?.jpegData(compressionQuality: 0.5)
            var avatarString = avatarData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            if groupIcon != nil {
                let avatarData = groupIcon!.jpegData(compressionQuality: 0.5)
                     avatarString = avatarData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            }
            
            
            let groupId = UUID().uuidString
            //Create Group
            let group = Group(groupID: groupId, subject: groupSubjectTextField.text!, ownerId: FUser.currentId(), members: memberIds, avatar: avatarString!)
            
            group.saveGroup()
            //create group recent
            
            startGroupChat(group: group)
            
            let chatVC = ChatViewController()
            chatVC.titleName = group.groupDictionary[kNAME] as? String
            chatVC.memberids = group.groupDictionary[kMEMBERS] as? [String]
            chatVC.memberidsToPush = group.groupDictionary[kMEMBERS] as? [String]
            chatVC.chatRoomId = groupId
            chatVC.isGroup = true
            chatVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(chatVC, animated: true)
            
            
        }else{
            SVProgressHUD.showError(withStatus: "Subject is required!")
        }
    }
    @objc func groupiconTap(){
        showIconOptions()
    }
    
    @IBAction func editBtnPressed(_ sender: Any) {
        
       showIconOptions()
        
    }
    

}

extension newGroupViewController: UICollectionViewDelegate,UICollectionViewDataSource{
   
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allMembers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! GroupMembersCollectionViewCell
            cell.delegate = self
            cell.generateCell(user: allMembers[indexPath.row], indexPath: indexPath)
        return cell
    }

    
}

extension newGroupViewController:GroupMemberCollectionViewCellDelegate {
    func didClickDeleteButton(indexPath: IndexPath) {
        allMembers.remove(at: indexPath.row)
        memberIds.remove(at: indexPath.row)
        collectionView.reloadData()
        updateParticipantsLabel()
    }
    
    

}
