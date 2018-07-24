//
//  UsersTabelViewController.swift
//  weChat
//
//  Created by 洪森達 on 2018/7/17.
//  Copyright © 2018年 sen. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD

class UsersTabelViewController: UITableViewController,UISearchResultsUpdating,UserTabelCellDelegate{
 


   
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var filterSegment: UISegmentedControl!
    
    
    var allUsers: [FUser] = []
    var filterUsers: [FUser] = []
    var allUsersGroupped = NSDictionary() as! [String:[FUser]]
    var sectionTitleList: [String] = []
    let searchController = UISearchController(searchResultsController: nil)
    
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        navigationItem.largeTitleDisplayMode = .never
        self.title = "Users"
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        loadUsers(filter: kCITY)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            
            return 1
        }else{
            
        return allUsersGroupped.count
        }
     
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if searchController.isActive && searchController.searchBar.text != "" {
            
            return filterUsers.count
        }else{
            
                // find sectionTitle
            let sectionTitle = self.sectionTitleList[section]
            //user for given title
            let user = self.allUsersGroupped[sectionTitle]
            return user!.count
        }
        
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UserTabelCell
        var user: FUser
        
        if searchController.isActive && searchController.searchBar.text != "" {
                user = filterUsers[indexPath.row]
           
        }else{
            
                let sectionTtile = self.sectionTitleList[indexPath.section]
               let users = allUsersGroupped[sectionTtile]
            user = users![indexPath.row]
        }
        
        
        
        cell.delegate = self
        cell.generate(fuser: user, indexPath: indexPath)
        return cell
    }
    
    //tabel delegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return ""
            
        }else{
            return sectionTitleList[section]
        }

    }
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return nil
            
        }else{
            return sectionTitleList
        }
        
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        
        return index
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var user: FUser
        
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filterUsers[indexPath.row]
            
        }else{
            
            let sectionTtile = self.sectionTitleList[indexPath.section]
            let users = allUsersGroupped[sectionTtile]
            user = users![indexPath.row]
        }
        
        //
        
        startPrivateChat(user1: FUser.currentUser()!, user2: user)
        
        
    }
    
    
    
    //MARK: Load Users
    
    func loadUsers(filter: String) {
        
        ProgressHUD.show()
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
                    ProgressHUD.dismiss()
                    print(error?.localizedDescription)
                    self.tableView.reloadData()
                    return
                }
            }
            
            guard let snapshot = snapShot else { ProgressHUD.dismiss();return }
            
            if !snapshot.isEmpty {
                
                for userDic in snapshot.documents {
                    
                    let dictionary = userDic.data() as NSDictionary
                    
                    let FuserObject = FUser(_dictionary: dictionary)
                    
                    if FuserObject.objectId != FUser.currentId() {
                        
                          self.allUsers.append(FuserObject)
                    }
                  
                }
                
                //split to groups
                self.splitDataIntoSection()
                self.tableView.reloadData()
            
            }
            self.tableView.reloadData()
            ProgressHUD.dismiss()
        }

    }
    
    
    
    
    
    
    
    //MARK: Search func 
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        
        filterUsers = allUsers.filter({ (user) -> Bool in
            return user.firstname.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
    
    //IBAction
    
    @IBAction func filterSegment(_ sender: UISegmentedControl) {
        
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
    
    //MARK: UserTabelViewCellDelegate
    
    func didTapAvatarImage(indexPath: IndexPath) {
       
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileTableViewController") as! ProfileTableViewController
        var user: FUser
        
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filterUsers[indexPath.row]
            
        }else{
            
            let sectionTtile = self.sectionTitleList[indexPath.section]
            let users = allUsersGroupped[sectionTtile]
            user = users![indexPath.row]
        }
        
        vc.user = user

        self.navigationController!.pushViewController(vc, animated: true)
    }
    

}
