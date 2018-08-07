//
//  BlockedUserViewController.swift
//  weChat
//
//  Created by 洪森達 on 2018/8/5.
//  Copyright © 2018年 sen. All rights reserved.
//

import UIKit
import SVProgressHUD

class BlockedUserViewController: UIViewController {

    @IBOutlet weak var tabelView: UITableView!
    
    
    
    
    let notificationLabel:UILabel = {
        let label = UILabel()
        label.text = "No Blocked User!"
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.isHidden = true
        return label
        }()
    
    

    
    var blockUserArray: [FUser] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        tabelView.tableFooterView = UIView()
        navigationItem.largeTitleDisplayMode = .never
        loadUsers()
        self.tabelView.addSubview(notificationLabel)
        NSLayoutConstraint.activate([
            notificationLabel.centerXAnchor.constraint(equalTo: tabelView.centerXAnchor),
            notificationLabel.centerYAnchor.constraint(equalTo: tabelView.centerYAnchor)
            ])
    }
    
    //MARK: Load BlockedUser
    
    func loadUsers(){
        if FUser.currentUser()!.blockedUsers.count > 0 {
            SVProgressHUD.show()
            getUsersFromFirestore(withIds: FUser.currentUser()!.blockedUsers) { (allBlockedUsers) in
                
                SVProgressHUD.dismiss()
                self.blockUserArray = allBlockedUsers
                self.tabelView.reloadData()
                
            }
        }
    }
    
    

}

extension BlockedUserViewController: UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        notificationLabel.isHidden = blockUserArray.count != 0
        
        return blockUserArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UserTabelCell
        cell.delegate = self
        cell.generate(fuser: blockUserArray[indexPath.row], indexPath: indexPath)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Unblock"
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        var tempBlockedUsers = FUser.currentUser()!.blockedUsers
        let userIdToUnblock = blockUserArray[indexPath.row].objectId
        tempBlockedUsers.remove(at: tempBlockedUsers.index(of:userIdToUnblock)!)
        
        blockUserArray.remove(at: indexPath.row)
        updateCurrentUserInFirestore(withValues: [kBLOCKEDUSERID:tempBlockedUsers]) { (error) in
            
            if error != nil {
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            }
            
            tableView.reloadData()
        }
        
    }
    
}
extension BlockedUserViewController:UserTabelCellDelegate {
    func didTapAvatarImage(indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileTableViewController") as! ProfileTableViewController
            vc.user = blockUserArray[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
