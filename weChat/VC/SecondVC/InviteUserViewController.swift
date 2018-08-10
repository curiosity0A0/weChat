//
//  InviteUserViewController.swift
//  weChat
//
//  Created by 洪森達 on 2018/8/10.
//  Copyright © 2018年 sen. All rights reserved.
//

import UIKit
import SVProgressHUD
import Firebase


class InviteUserViewController: UITableViewController,UserTabelCellDelegate {

    
    @IBOutlet weak var headerView: UIView!
    
    
    
    
    var allUsers: [FUser] = []

    var allUsersGroupped = NSDictionary() as! [String:[FUser]]
    var sectionTitleList: [String] = []
    var newMemberIds : [String] = []
    var currentMemberids: [String] = []
    var group:NSDictionary!
    
    override func viewWillAppear(_ animated: Bool) {
        //load func
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        loadUsers(filter: kCITY)
        SVProgressHUD.dismiss()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Users"
        tableView.tableFooterView = UIView()
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneBtnPressed))]
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        currentMemberids = group[kMEMBERS] as! [String]
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
     
        return self.allUsersGroupped.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        let sectionTitle = self.sectionTitleList[section]
        let users = self.allUsersGroupped[sectionTitle]
        
        
        return users!.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UserTabelCell

      
            let sectionTtile = self.sectionTitleList[indexPath.section]
            let users = allUsersGroupped[sectionTtile]
    
        
        
        
        cell.delegate = self
        cell.generate(fuser: users![indexPath.row], indexPath: indexPath)
        return cell
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
 
            return sectionTitleList[section]
    
        
    }
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {

            return sectionTitleList
        
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        
        return index
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let sectionTitle = self.sectionTitleList[indexPath.section]
        let users = self.allUsersGroupped[sectionTitle]
        let selectedUserr = users![indexPath.row]
        
        if currentMemberids.contains(selectedUserr.objectId){
            SVProgressHUD.showError(withStatus: "Already in the group!")
            return
        }
        
        if let cell = tableView.cellForRow(at: indexPath){
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
            }else{
                cell.accessoryType = .checkmark
            }
        }
        //add /remove users
        
        let selected = newMemberIds.contains(selectedUserr.objectId)
        if selected {
            //remove
            newMemberIds.remove(at: newMemberIds.index(of: selectedUserr.objectId)!)
        }else{
            //add to array
            newMemberIds.append(selectedUserr.objectId)
            
        }
        
        
        self.navigationItem.rightBarButtonItem?.isEnabled = newMemberIds.count > 0
        
    }
    
    
    
    
    
  
    //IBACTIONS
    
    @IBAction func segmentController(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            loadUsers(filter: kCITY)
        case 1:
            loadUsers(filter: kCOUNTRY)
        case 2 :
            loadUsers(filter: "")
        default:
            return
        }
    }
    
    @objc func doneBtnPressed(){
        
    }
    
    
    
    
    //MARK: USERTABLEVIEW DELEGATE
    
    func didTapAvatarImage(indexPath: IndexPath) {
       
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileTableViewController") as! ProfileTableViewController
            let sectionTtile = self.sectionTitleList[indexPath.section]
            let users = allUsersGroupped[sectionTtile]
        vc.user = users![indexPath.row]
        
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    func loadUsers(filter: String) {
        
        SVProgressHUD.show()
        var query: Query!
        
        switch filter {
        case kCITY:
            query = reference(.User).whereField(kCITY, isEqualTo: FUser.currentUser()!.city).order(by: kFIRSTNAME, descending: false)
        case kCOUNTRY:
            query = reference(.User).whereField(kCOUNTRY, isEqualTo: FUser.currentUser()!.country).order(by: kFIRSTNAME, descending: false)
        default:
            query = reference(.User).order(by: kFIRSTNAME, descending: false)
            
        }
        
        query.getDocuments { (snapShot, error) in
            
            self.allUsers = []
            self.sectionTitleList = []
            self.allUsersGroupped = [:]
            
            if error != nil {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    print(error!.localizedDescription)
                    self.tableView.reloadData()
                    return
                }
            }
            
            guard let snapshot = snapShot else {SVProgressHUD.dismiss();return }
            
            if !snapshot.isEmpty {
                
                for userDic in snapshot.documents {
                    
                    let dictionary = userDic.data() as NSDictionary
                    
                    let FuserObject = FUser(_dictionary: dictionary)
  
                    if FuserObject.objectId != FUser.currentId() || !self.currentMemberids.contains(FuserObject.objectId) {
                        
                        self.allUsers.append(FuserObject)
                    }
                    
                }
                
                //split to groups
                self.splitDataIntoSection()
                self.tableView.reloadData()
                
            }
            self.tableView.reloadData()
            SVProgressHUD.dismiss()
        }
        
    }
    
    //MARK: Helper functions
    
    fileprivate func splitDataIntoSection(){
        
        var sectionTitle : String = ""
        for i in 0..<self.allUsers.count {
            
            let currentUser = self.allUsers[i]
            let firstChar = currentUser.firstname.first!
            
            let firstCarString = "\(firstChar)"
            
            if firstCarString != sectionTitle {
                sectionTitle = firstCarString
                self.allUsersGroupped[sectionTitle] = []
                self.sectionTitleList.append(sectionTitle)
            }
            
            self.allUsersGroupped[firstCarString]?.append(currentUser)
        }
        
    }
    
    
    
    
}

    
