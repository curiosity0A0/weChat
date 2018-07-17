//
//  LoginPage.swift
//  weChat
//
//  Created by 洪森達 on 2018/7/16.
//  Copyright © 2018年 sen. All rights reserved.
//

import UIKit
import ProgressHUD
import Firebase

class LoginPage: UIViewController{

  
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var confirmLine: UIView!
    @IBOutlet weak var segment: UISegmentedControl!
    
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    @IBOutlet weak var comfirmTextField: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        
        loginBtn.layer.cornerRadius = 5
        loginBtn.clipsToBounds = true
        
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: mainView.frame.height + 20)
       
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

   
    }
    
    

    @IBAction func SwitchLoginWay(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
        
            comfirmTextField.isHidden = true
            confirmLine.isHidden = true
            loginBtn.setTitle("Log in", for: .normal)
        case 1:
            comfirmTextField.isHidden = false
            confirmLine.isHidden = false
            loginBtn.setTitle("Register", for: .normal)
        default:
            break
        }
        
    }
    
    @IBAction func loginAndRegister(_ sender: UIButton) {
        
        dismissKeyboard()
        switch segment.selectedSegmentIndex {
        case 0:
             dismissKeyboard()
            if emailTextField.text != "" && passwordTextField.text != "" {
                loginUser()
                print("Login")
            }else{
                
                alert(Message: "Please enter all field.")
                
            }
            
            
        case 1:
             dismissKeyboard()
            if emailTextField.text != "" && passwordTextField.text != ""  && comfirmTextField.text != ""  {
                if comfirmTextField.text == passwordTextField.text && (passwordTextField.text?.count)! >= 8{
        
                    registerUser()
                    
                }else{
                    
                    alert(Message: "Passwords and confirm are not same or passwords need to be 8+ characters")
                }
             
            }else{
                
                alert(Message: "Please enter all field." )
            }
         
        default:
            break
        }

    }
    
    @IBAction func backGroundTap(_ sender: Any) {
        
        dismissKeyboard()
        
    }
    
    
    
    
    //Helper
    
    func alert(Message: String) {
        
        let alert = UIAlertController(title: "Error", message: Message, preferredStyle: .alert)
        
        let confirm = UIAlertAction(title:"confirm", style: .cancel, handler: nil)
        
        alert.addAction(confirm)
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    func dismissKeyboard(){
        
        view.endEditing(false)
    }
    
    func cleanTextField() {
        
        emailTextField.text = ""
        passwordTextField.text = ""
        comfirmTextField.text = ""
        
        
    }
    
    func loginUser(){
        ProgressHUD.show("Loading...")
        FUser.loginUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error) in
            if error != nil {
                
                
                DispatchQueue.main.async {
                self.alert(Message: error!.localizedDescription)
                }
              
            }
            
            DispatchQueue.main.async {
               
                self.goToApp()
                
            }
       
    
            
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
    
    
    func registerUser(){
       performSegue(withIdentifier: "goToProfile", sender: self)
        ProgressHUD.dismiss()
         dismissKeyboard()
        cleanTextField()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToProfile" {
            
            if let destination = segue.destination as? ProfileVC {
                
                destination.email = emailTextField.text
                destination.passwords = passwordTextField.text
            }
        }
    }


} // end of the class
