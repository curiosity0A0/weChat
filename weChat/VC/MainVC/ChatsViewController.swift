//
//  ChatsViewController.swift
//  weChat
//
//  Created by 洪森達 on 2018/7/17.
//  Copyright © 2018年 sen. All rights reserved.
//

import UIKit

class ChatsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    

    @IBAction func GreateNewChatBtn(_ sender: UIBarButtonItem) {
        
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UsersTabelViewController") as! UsersTabelViewController
          navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    
    

}
