//
//  EditProfile.swift
//  weChat
//
//  Created by 洪森達 on 2018/8/7.
//  Copyright © 2018年 sen. All rights reserved.
//

import UIKit
import SVProgressHUD

class EditProfile: UITableViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate{

   
    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBOutlet weak var userName: UITextField!
    
    @IBOutlet weak var userSurname: UITextField!
    
    @IBOutlet weak var emailOutlet: UITextField!
    
    @IBOutlet weak var saveOutlet: UIBarButtonItem!
    
    @IBOutlet var avatarTapGesture: UITapGestureRecognizer!
    
    
    var avatarImg: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        setupUI()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        return 4
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
//IBACTIOM
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        
        if userName.text != "" && userSurname.text != "" && emailOutlet.text != "" {
            SVProgressHUD.show()
            
            saveOutlet.isEnabled = false
            let fullName = userName.text! + " " + userSurname.text!
            var withValue = [kFIRSTNAME: userName.text!,kLASTNAME: userSurname.text!,kFULLNAME: fullName]
            if avatarImg != nil {
                
                let avatarDate = avatarImg?.jpegData(compressionQuality: 0.5)!
                let avatarString = avatarDate?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                withValue[kAVATAR] = avatarString
            }
            
            //update current user
            
            updateCurrentUserInFirestore(withValues: withValue) { (error) in
                if error != nil {
                    DispatchQueue.main.async {
                        SVProgressHUD.showError(withStatus: error!.localizedDescription)
                        print("couldn update user\(error!.localizedDescription)")
                    }
                    return
                }
                
                SVProgressHUD.showSuccess(withStatus: "Saved!")
                self.saveOutlet.isEnabled = true
                self.navigationController?.popViewController(animated: true)
            }
            
        }else{
            
            SVProgressHUD.showError(withStatus: "All fields are required!")
        }
        
        
        
        
        
    }
    
    @IBAction func avatarTap(_ sender: Any) {
         let camera = Camera(delegate_: self)
            camera.PresentPhotoLibrary(target: self, canEdit: false)
        
        print("....")
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let picture = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        self.avatarImg = picture
        picker.dismiss(animated: true, completion: nil)
        self.avatarImage.image = avatarImg?.circleMasked
    }
    
    //MARK: SETUP UI
    
    func setupUI(){
        let currentUser = FUser.currentUser()!
        avatarImage.isUserInteractionEnabled = true
        
        userName.text = currentUser.firstname
        userSurname.text = currentUser.lastname
        emailOutlet.text = currentUser.email
        if currentUser.avatar != "" {
            imageFromData(pictureData: currentUser.avatar) { (avatarImage) in
                if avatarImage != nil {
                    self.avatarImage.image = avatarImage!.circleMasked
                }
            }
           
            
        }
        
    }

}

