//
//  settings.swift
//  weChat
//
//  Created by 洪森達 on 2018/7/17.
//  Copyright © 2018年 sen. All rights reserved.
//

import UIKit
import SVProgressHUD

class settings: UITableViewController {

   
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var fullName: UILabel!
    
    @IBOutlet weak var deleteBtnOutlet: UIButton!
    
    
    @IBOutlet weak var avatarStatusSwitch: UISwitch!
    
    @IBOutlet weak var versionLabel: UILabel!
    
    
    
    
    let userDefaults = UserDefaults.standard
    var firstLoad: Bool?
    var avatarSwitchStatus: Bool = false
    
   
    
    override func viewDidAppear(_ animated: Bool) {
        if FUser.currentUser() != nil {
            setupUI()
            loadUserDefaults()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

      navigationController?.navigationBar.prefersLargeTitles = true
        tableView.tableFooterView = UIView()
        
    }

    //MARK: TABLE DELEGATE
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 0.0
        }
        
        return 30
        
    }
    
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 1 {
            
            return 5
        }else{
               return 2
        }

    }


    //MARK: IBACTION
    
    
    
    
    
    
    
    
    @IBAction func showAvatarSwitchValue(_ sender: UISwitch) {
  
      avatarSwitchStatus = sender.isOn
        //save user defaults
        saveUserDefaults()
    }
    
    @IBAction func cleanCacheBtn(_ sender: Any) {
        
        do{
            let files = try FileManager.default.contentsOfDirectory(atPath: getDocumentURL().path)
             let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            for file in files {
                
                try FileManager.default.removeItem(atPath: "\(getDocumentURL().path)/\(file)")
            }
            
            SVProgressHUD.showSuccess(withStatus: "Cache cleaned!")
        }catch{
            SVProgressHUD.showError(withStatus: "Couldnt clean Media files.")
        }
        
    }
    
    
    @IBAction func tellAFriendBtn(_ sender: Any) {
        
        let text = "Hey! Lets chat on weChhats\(kAPPURL)"
        let objectsToShare: [Any] = [text]
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.setValue("Lets Chat on weChat", forKey: "subject")
        self.present(activityViewController, animated: true, completion: nil)

    }
    
    
    
    
    @IBAction func deleteAccountBtn(_ sender: Any) {
        
        let optionMenu = UIAlertController(title: "Delete Account", message: "Are you sure you wnat to delete the account?", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
           self.deletUser()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        
        if (UI_USER_INTERFACE_IDIOM() == .pad )
        {
            if let currentPopoverPresentController = optionMenu.popoverPresentationController {
                
                currentPopoverPresentController.sourceView = deleteBtnOutlet
                currentPopoverPresentController.sourceRect = deleteBtnOutlet.bounds
                currentPopoverPresentController.permittedArrowDirections = .up
                self.present(optionMenu, animated: true, completion: nil)
                
            }
            
        }else{
            
            present(optionMenu, animated: true, completion: nil)
            
        }

    }
    
    
    @IBAction func LogoutBtn(_ sender: Any) {
        FUser.logOutCurrentUser { (SUCCESS) in
            
            if SUCCESS {
                
                //show login view
                
                DispatchQueue.main.async {
                  self.showLoginView()
                }
            }
        }
        
    }
    
    func showLoginView(){
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginPage")
        
        self.present(vc, animated: true, completion: nil)
        
        
    }
    
    
    //MARK: SetupUI
    
    func setupUI(){
        
        let currentUser = FUser.currentUser()!
        fullName.text = currentUser.fullname
        if currentUser.avatar != "" {
            imageFromData(pictureData: currentUser.avatar) { (image) in
                
                if image != nil {
                    self.avatarImageView.image = image!.circleMasked
                }
            }
        }
        //set app version
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = version
        }
    }
    
    //MARK: Delete User
    
    func deletUser() {
        
        //delete locally
        userDefaults.removeObject(forKey: kPUSHID)
        userDefaults.removeObject(forKey: kCURRENTUSER)
        userDefaults.synchronize()
        //delete from firebase
        
        reference(.User).document(FUser.currentId()).delete()
        FUser.deleteUser { (error) in
            if error != nil {
                DispatchQueue.main.async {
                    SVProgressHUD.showError(withStatus: "couldnt delete the user")
                }
                return
            }
            
            self.showLoginView()
        }
        
    }
    
    
    //MARK: UserDefaults
    
    func saveUserDefaults(){
        
        userDefaults.set(avatarSwitchStatus, forKey: kSHOWAVATAR)
        userDefaults.synchronize()
        
    }
    
    func loadUserDefaults(){
        
        firstLoad = userDefaults.bool(forKey: kFIRSTRUN)
        
        if !firstLoad!{
            userDefaults.set(true, forKey: kFIRSTRUN)
            userDefaults.set(avatarSwitchStatus, forKey: kSHOWAVATAR)
            userDefaults.synchronize()
        }
        
        avatarSwitchStatus = userDefaults.bool(forKey: kSHOWAVATAR)
        avatarStatusSwitch.isOn = avatarSwitchStatus
        
        
    }
    
    
}
