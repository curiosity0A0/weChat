//
//  ViewController.swift
//  weChat
//
//  Created by 洪森達 on 2018/7/13.
//  Copyright © 2018年 sen. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate{
 
    
    @IBOutlet weak var login: UIButton!
    
    @IBOutlet weak var pageView: UIPageControl!
    
    var collectionImage = ["1","2","3"]

    @IBOutlet weak var collectionView: UICollectionView!
   
    override func viewWillLayoutSubviews() {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    override func viewWillAppear(_ animated: Bool) {
        
        login.layer.cornerRadius = 15
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ShowCell
        cell.generate(cellString: collectionImage[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
      
        var pageNumber = collectionView.contentOffset.x / collectionView.frame.width
        
        pageView.currentPage = Int(pageNumber)
    }
    
    
    
    
    


}

