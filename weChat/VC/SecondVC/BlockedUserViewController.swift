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
    
    var blockUserArray: [FUser] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        tabelView.tableFooterView = UIView()
        navigationItem.largeTitleDisplayMode = .never
        loadUsers()
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
        return blockUserArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UserTabelCell
        cell.delegate = self
        cell.generate(fuser: blockUserArray[indexPath.row], indexPath: indexPath)
        
        return cell
    }

    
}
extension BlockedUserViewController:UserTabelCellDelegate {
    func didTapAvatarImage(indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileTableViewController") as! ProfileTableViewController
            vc.user = blockUserArray[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
