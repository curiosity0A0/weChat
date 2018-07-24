//
//  Download.swift
//  weChat
//
//  Created by 洪森達 on 2018/7/25.
//  Copyright © 2018年 sen. All rights reserved.
//

import Foundation
import FirebaseStorage
import Firebase
import MBProgressHUD
import AVFoundation

let storage = Storage.storage()

//image

func uploadImage(image:UIImage, chatRoomId: String , view: UIView ,completion: @escaping(_ imageLink: String?) -> Void) {
    
    let progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
         progressHUD.mode = .determinateHorizontalBar
    
    let dateString = dateFormatter().string(from: Date())
    let photoFileName = "PictureMessages/" + FUser.currentId() + "/" + chatRoomId + "/" + dateString + "/" + ".jpg"
                        //PictireMessage/fuserid/chatRoomID/2018/15/07/.jpg
    let storageRef = storage.reference(forURL: kFILEREFERENCE).child(photoFileName)
     let imageDate = image.jpegData(compressionQuality: 0.7)
    var task: StorageUploadTask!
    task = storageRef.putData(imageDate!, metadata: nil, completion: { (metadata, error) in
        task.removeAllObservers()
        progressHUD.hide(animated: true)
        if error != nil {
            print("error.uploading image \(error!.localizedDescription)")
            return
        }
        
        storageRef.downloadURL(completion: { (url, error) in
            guard let downloadUrl = url else {
                completion(nil)
                return
                
            }
            
            completion(downloadUrl.absoluteString)
    
        })
        
    })
    
    task.observe(StorageTaskStatus.progress) { (snapShot) in
        progressHUD.progress = Float((snapShot.progress?.completedUnitCount)!) / Float((snapShot.progress?.totalUnitCount)!)
    }
}








