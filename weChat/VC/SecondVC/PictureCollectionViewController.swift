//
//  PictureCollectionViewController.swift
//  weChat
//
//  Created by 洪森達 on 2018/8/1.
//  Copyright © 2018年 sen. All rights reserved.
//

import UIKit
import IDMPhotoBrowser
import SVProgressHUD
class PictureCollectionViewController: UICollectionViewController {

    var allImages:[UIImage] = []
    var allImageLinks: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    self.navigationItem.title = "All Pictures"
        SVProgressHUD.show()
        if allImageLinks.count > 0 {
            //download image
            downLoadImages()
            
        }
        
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
    
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return allImages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PictureCollectionViewCell
        cell.generateCell(image: allImages[indexPath.row])
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      
        if let photos = IDMPhoto.photos(withImages: allImages) {
            
            let browser = IDMPhotoBrowser(photos: photos)
            browser?.displayDoneButton = false
            browser?.setInitialPageIndex(UInt(indexPath.item))
            self.present(browser!, animated: true, completion: nil)
            
        }
     
        
     
    }



  
    //MARK:DownLoadImages
    
    func downLoadImages(){
        
        for imageLink in allImageLinks {
            
            downLoadImage(ImageuUrl: imageLink) { (image) in
                
                if image != nil {
                    
                    self.allImages.append(image!)
                    self.collectionView.reloadData()
                        SVProgressHUD.dismiss()
                }
                
            }
        }
    }
}
