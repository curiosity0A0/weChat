//
//  LoginPage.swift
//  weChat
//
//  Created by 洪森達 on 2018/7/16.
//  Copyright © 2018年 sen. All rights reserved.
//

import UIKit

class LoginPage: UIViewController {

  
    
    @IBOutlet weak var confirmLine: UIView!
    @IBOutlet weak var segment: UISegmentedControl!
    
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    @IBOutlet weak var comfirmTextField: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        
        loginBtn.layer.cornerRadius = 5
        loginBtn.clipsToBounds = true
        
        
        
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
        
        switch segment.selectedSegmentIndex {
        case 0:
            if emailTextField.text != "" && passwordTextField.text != "" {
                
                print("Login")
            }else{
                
                alert(Message: "Please enter all field.")
                
            }
            
            
        case 1:
            
            if emailTextField.text != "" && passwordTextField.text != ""  && comfirmTextField.text != ""  {
                if comfirmTextField.text == passwordTextField.text {
                       print("Register")
                    
                }else{
                    
                    alert(Message: "Passwords and confirm are not same")
                }
             
            }else{
                
                alert(Message: "Please enter all field." )
            }
         
        default:
            break
        }
        
        
        
        
        
    }
    
    
    //Helper
    
    func alert(Message: String) {
        
        let alert = UIAlertController(title: "Error", message: Message, preferredStyle: .alert)
        
        let confirm = UIAlertAction(title:"confirm", style: .cancel, handler: nil)
        
        alert.addAction(confirm)
        present(alert, animated: true, completion: nil)
        
    }



}
