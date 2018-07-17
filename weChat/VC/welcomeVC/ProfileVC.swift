//
//  ProfileVC.swift
//  weChat
//
//  Created by 洪森達 on 2018/7/16.
//  Copyright © 2018年 sen. All rights reserved.
//

import UIKit
import ProgressHUD

class ProfileVC: UIViewController {

    var email : String!
    var passwords : String!
    var avatarImage: UIImage?
   
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var nameText: UITextField!
    
    @IBOutlet weak var surnameText: UITextField!
    
    @IBOutlet weak var countryText: UITextField!
    
    @IBOutlet weak var cityText: UITextField!
    
    @IBOutlet weak var phoneText: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: mainView.frame.height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()


    }
    
    @IBAction func cancel(_ sender: Any) {
        dismissKeyboard()
        cleanTextField()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func doneBtn(_ sender: UIButton) {
        
        dismissKeyboard()
        ProgressHUD.show("Registering...")
        
        if nameText.text != "" && surnameText.text != "" && countryText.text != "" && cityText.text != "" && phoneText.text != "" {
            FUser.registerUserWith(email: email!, password: passwords!, firstName: nameText.text!, lastName: surnameText.text!) { (error) in
                
                if error != nil {
                    DispatchQueue.main.async {
                        ProgressHUD.dismiss()
                        ProgressHUD.showError(error?.localizedDescription)
                        return
                    }
                }
                
                self.registerUser()
                
                
                
            }
            
        }else{
            
            ProgressHUD.showError("All fields are required!")
        }
        
    }
    
    
    //MARK: HELPER
    
    func dismissKeyboard(){
        
        view.endEditing(false)
    }
    
    func cleanTextField() {
        
        nameText.text = ""
        surnameText.text = ""
        countryText.text = ""
        cityText.text = ""
        phoneText.text = ""
    }
    
    func registerUser(){
        
        let fullName = nameText.text! + " " + surnameText.text!
        var tempdic : Dictionary = [kFIRSTNAME: nameText.text!,kLASTNAME: surnameText.text!,
            kFULLNAME: fullName , kCOUNTER: countryText.text! , kCITY : cityText.text!,
        kPHONE: phoneText.text!] as! [String: Any]
        
        if avatarImage == nil {
            
            imageFromInitials(firstName: nameText.text, lastName: surnameText.text) { (image) in
                
                let avatarImG = image.jpegData(compressionQuality: 0.7)
                let avatarString = avatarImG?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                tempdic[kAVATAR] = avatarString
                //finishRegistration
                self.finishRegisteration(withValues: tempdic)
            }
        }else{
            let avatarData = avatarImage?.jpegData(compressionQuality: 0.7)
            let avatarStrings = avatarData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            
            tempdic[kAVATAR] = avatarStrings
            //finishRegistration
              self.finishRegisteration(withValues: tempdic)
        }
        
    }
    
    
    func finishRegisteration(withValues: [String: Any]){
        
        updateCurrentUserInFirestore(withValues: withValues) { (error) in
            if error != nil {
                DispatchQueue.main.async {
                    ProgressHUD.showError(error!.localizedDescription)
                }
                return
            }
        }
        
        DispatchQueue.main.async {
            ProgressHUD.dismiss()
            //goto Main VC
            self.goToApp()
        }
        
        
    }
    
    
    
    func goToApp(){
        ProgressHUD.dismiss()
        cleanTextField()
        dismissKeyboard()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID:FUser.currentId()])
        let vc  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainVC") as! UITabBarController
        present(vc, animated: true, completion: nil)
        // goto main view
        print("goto main view")
    }


}
