//
//  BackgroundCollectionViewController.swift
//  weChat
//
//  Created by 洪森達 on 2018/8/7.
//  Copyright © 2018年 sen. All rights reserved.
//

import UIKit
import SVProgressHUD



class BackgroundCollectionViewController: UICollectionViewController {

    var backgrounds: [UIImage] = []
    let userDeFaults = UserDefaults.standard
    private let imageNameArray = ["bg1","bg2","bg3","bg4","bg5","bg6","bg7","bg8","bg9","bg10","bg11"]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageArray()
        let resetBtn = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(self.resetToDefault))
        self.navigationItem.rightBarButtonItem = resetBtn
    }
   override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return backgrounds.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! BGCollectionViewCell
    
        cell.generate(image: backgrounds[indexPath.row])
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        userDeFaults.set(imageNameArray[indexPath.row], forKey: kBACKGROUBNDIMAGE)
        userDeFaults.synchronize()
        SVProgressHUD.showSuccess(withStatus: "Set!")
    }
    
    
    //IBACTION
   @objc func resetToDefault(){
        userDeFaults.removeObject(forKey: kBACKGROUBNDIMAGE)
        userDeFaults.synchronize()
        SVProgressHUD.showSuccess(withStatus: "Set!")
        
    }
    
    
    
    
    //MARK:Helpers
    

    
    
    
    func setupImageArray(){
        for imageName in imageNameArray {
            let image = UIImage(named: imageName)
            if image != nil {
                backgrounds.append(image!)
            }
            
        }
    }
  
}
