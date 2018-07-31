//
//  ChatsViewController.swift
//  weChat
//
//  Created by 洪森達 on 2018/7/17.
//  Copyright © 2018年 sen. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CoreLocation

class ChatsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,RecentChatsCellDelegate,UISearchResultsUpdating,CLLocationManagerDelegate{
 
    
 
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    

    @IBOutlet weak var tableView: UITableView!

    
    var recentChats: [NSDictionary] = []
    var filteredChats : [NSDictionary] = []
    var recentListener: ListenerRegistration!
    let searchController = UISearchController(searchResultsController: nil)
    override func viewWillAppear(_ animated: Bool) {
          loadRecentChats()
          tableView.tableFooterView = UIView()
        setTableViewHeader()
    }
    override func viewWillDisappear(_ animated: Bool) {
        recentListener.remove()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        appdelegate.locationManager? = CLLocationManager()
        appdelegate.locationManager?.delegate = self
        appdelegate.locationManager?.requestWhenInUseAuthorization()
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = .white
        //get rid of black bar underneath navbar
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
 
    }
    

    @IBAction func GreateNewChatBtn(_ sender: UIBarButtonItem) {
        
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UsersTabelViewController") as! UsersTabelViewController
          navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: TABEL VIEW DATA SOURCE
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            return filteredChats.count
        }else{
                return recentChats.count
        }
   
    
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RecentChatsCell
            cell.delegate = self
        var recent : NSDictionary!
        
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            recent = filteredChats[indexPath.row]
        }else{
            recent = recentChats[indexPath.row]
        }

        
        cell.generateCell(recentChat: recent, indexPath: indexPath)
        return cell
        
    }
    
    
    //MARK: TableView delegate
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        var tempDicRecent: NSDictionary!
        
        if searchController.isActive && searchController.searchBar.text != "" {
            tempDicRecent = filteredChats[indexPath.row]
        }else{
            tempDicRecent = recentChats[indexPath.row]
        }
        
        var muteTitle = "Unmute"
        var mute = false
        
        if (tempDicRecent[kMEMBERSTOPUSH] as! [String]).contains(FUser.currentId()) {
            
            muteTitle = "Mute"
            mute = true
        }
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            
            if self.searchController.isActive && self.searchController.searchBar.text != "" {
                self.filteredChats.remove(at: indexPath.row)
            }else{
                self.recentChats.remove(at: indexPath.row)
            }
            
            deleteRecentChat(recentChatDic: tempDicRecent)
            self.tableView.reloadData()
            print("Deleting....\(indexPath)")
            
        }
        
        let muteAction = UITableViewRowAction(style: .default, title: muteTitle) { (muteAciton, indexPath) in
            
        
            print("Mute \(indexPath)")
        }
        
        muteAction.backgroundColor = UIColor.blue
        return [deleteAction , muteAction]
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var recent: NSDictionary!
        
        if searchController.isActive && searchController.searchBar.text != "" {
            recent = filteredChats[indexPath.row]
        }else{
            recent = recentChats[indexPath.row]
        }
        //restart Chat
        restaratRecentChat(recent: recent)
        //show chat view
        let chatVc = ChatViewController()
        chatVc.hidesBottomBarWhenPushed = true
        chatVc.memberidsToPush = recent[kMEMBERSTOPUSH] as? [String]
        chatVc.memberids = recent[kMEMBERS] as? [String]
        chatVc.chatRoomId = recent[kCHATROOMID] as? String
        chatVc.titleName = recent[kWITHUSERFULLNAME] as? String
        chatVc.isGroup = (recent[kTYPE] as! String) == kGROUP
        navigationController?.pushViewController(chatVc, animated: true)
        
    }
    
    
    //MARK: LoadRecentChats
    
    func loadRecentChats(){
        
        recentListener = reference(.Recent).whereField(kUSERID, isEqualTo: FUser.currentId()).addSnapshotListener({ (snapShot, error) in
            
            if error != nil {
                print("\(error!.localizedDescription)")
                return
            }
            
            guard let snapshot = snapShot else { return }
            
            self.recentChats = []
            if !snapshot.isEmpty {
                
                let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: false)]) as! [NSDictionary]
                
                for recent in sorted {
                    
                    if recent[kLASTMESSAGE] as! String != "" && recent[kCHATROOMID] as! String != nil && recent[kRECENTID] as! String != nil {
                        
                        self.recentChats.append(recent)
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
             
            }
            
        })

    }
    //MARK: Custom tableViewHeader
    
    func setTableViewHeader(){
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 45))
        let buttonView = UIView(frame: CGRect(x: 0, y: 5, width: self.view.frame.width, height: 35))
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 20))

        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.3
        button.addTarget(self, action: #selector(self.groupBtnPressed) , for: .touchUpInside)
        button.setTitle("New Group", for: .normal)
        
    
        let buttonColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        button.setTitleColor(buttonColor, for: .normal)
        let lineView = UIView(frame: CGRect(x: 0, y: headerView.frame.height - 1, width: self.view.frame.width, height: 1))
        lineView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        buttonView.addSubview(button)
       
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: button, attribute: .centerY, relatedBy: .equal, toItem: buttonView, attribute: .centerY, multiplier: 1.0, constant: 0))
        constraints.append(NSLayoutConstraint(item: button, attribute: .right, relatedBy: .equal, toItem: buttonView, attribute: .right, multiplier: 1.0, constant: -8))
        NSLayoutConstraint.activate(constraints)
        headerView.addSubview(buttonView)
//        headerView.addSubview(lineView)
        tableView.tableHeaderView = headerView

    }
    
    @objc func groupBtnPressed(){
        print("hello")
        
        
    }
    
    //MARK: RecentChats Cell Delegate
    
    func didTapAvatarImage(indexPath: IndexPath) {
        
        let recentChat:NSDictionary!//
       
        if searchController.isActive && searchController.searchBar.text != "" {
            
            recentChat = filteredChats[indexPath.row]
        }else{
            recentChat = recentChats[indexPath.row]
        }
 
        if recentChat[kTYPE] as! String == kPRIVATE {
            reference(.User).document(recentChat[kWITHUSERUSERID] as! String).getDocument { (snapShot, error) in
                
                if error != nil {
                    print("\(error!.localizedDescription)")
                }
                
                guard let snapshot = snapShot else { return }
                
                if snapshot.exists {
                    
                    let userDic = snapshot.data() as! NSDictionary
                    let tempUser = FUser(_dictionary: userDic)
                    self.showUserProfile(user: tempUser)
                }
                
            }
            
        }
        
        
    }
    
    func showUserProfile(user:FUser) {
        let profileVc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileTableViewController") as! ProfileTableViewController
        profileVc.user = user
        
        navigationController?.pushViewController(profileVc, animated: true)
        
    }
    //MARK : Search updating
    
    func filterContentForSearchText(searchText: String , scope: String = "All") {
        
        filteredChats = recentChats.filter({ (recentChat) -> Bool in
            return (recentChat[kWITHUSERFULLNAME] as! String).lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    
    
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }

}
