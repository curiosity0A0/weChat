//
//  settings.swift
//  weChat
//
//  Created by 洪森達 on 2018/7/17.
//  Copyright © 2018年 sen. All rights reserved.
//

import UIKit

class settings: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

      navigationController?.navigationBar.prefersLargeTitles = true
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
    }


    //MARK: IBACTION
    
    
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
    
}
