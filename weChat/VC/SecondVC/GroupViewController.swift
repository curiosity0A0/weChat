//
//  GroupViewController.swift
//  weChat
//
//  Created by 洪森達 on 2018/8/10.
//  Copyright © 2018年 sen. All rights reserved.
//

import UIKit
import SVProgressHUD

class GroupViewController: UIViewController {

    @IBOutlet var tapGestureIcon: UITapGestureRecognizer!
    
    @IBOutlet weak var avatarIcon: UIImageView!
    
    @IBOutlet weak var subjectTextField: UITextField!
    
    @IBOutlet weak var editBtn: UIButton!
    
    
    
    var group:NSDictionary!
    var gropIcon:UIImage?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        avatarIcon.isUserInteractionEnabled = true
        avatarIcon.addGestureRecognizer(tapGestureIcon)
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Invite", style: .plain, target: self, action: #selector(self.inviteUsers))]
        setupUI()
        
    }
    
    
    //IBACTION...
    
    
    
    @objc func inviteUsers(){
        
        
        let userVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InviteUserViewController") as! InviteUserViewController
        
            userVC.group = group
            self.navigationController?.pushViewController(userVC, animated: true)
    
    }

    @IBAction func tapGesture(_ sender: Any) {
        showIconOptions()
    }
    
    
    @IBAction func editBtnPressed(_ sender: Any) {
        showIconOptions()
    }
    
    @IBAction func SaveBtnPress(_ sender: Any) {
    }
    
    
    
    
    //MARK: helpers
    func setupUI() {
        
        self.title = "Group"
        subjectTextField.text = group[kNAME] as? String
       
        imageFromData(pictureData: group[kAVATAR] as! String) { (avatar) in
            
            if avatar != nil {
                
                self.avatarIcon.image = avatar!.circleMasked
            }
        }
        
        
        
        
    }
    
    func showIconOptions(){
        let optionMenu = UIAlertController(title: "Chiise Group Icon", message: nil, preferredStyle: .actionSheet)
        let takePhotoAction = UIAlertAction(title: "Take/Choose Photo", style: .default) { (alert) in
            print("work")
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            
        }
        
        if gropIcon != nil {
            let resetAction = UIAlertAction(title: "Reset", style: .default) { (alert) in
                
                self.gropIcon = nil
                self.avatarIcon.image = UIImage(named: "cameraIcon")
                self.editBtn.isHidden = true
            }
            optionMenu.addAction(resetAction)
        }
        
        optionMenu.addAction(takePhotoAction)
        optionMenu.addAction(cancel)
        
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            
            if let currentPopoverPresentController = optionMenu.popoverPresentationController{
                currentPopoverPresentController.sourceView = editBtn
                currentPopoverPresentController.sourceRect = editBtn.bounds
                currentPopoverPresentController.permittedArrowDirections = .up
                self.present(optionMenu, animated: true, completion: nil)
                
            }
            
        }else{
            
            self.present(optionMenu, animated: true, completion: nil)
        }
        
        
        
    }
    
}
