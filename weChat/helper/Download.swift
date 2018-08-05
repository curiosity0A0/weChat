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
import SVProgressHUD


let storage = Storage.storage()

//image

func uploadImage(image:UIImage, chatRoomId: String , view: UIView ,completion: @escaping(_ imageLink: String?) -> Void) {
    
    let progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
         progressHUD.mode = .determinateHorizontalBar
    
    let dateString = dateFormatter().string(from: Date())
    let photoFileName = "PictureMessages/" + FUser.currentId() + "/" + chatRoomId + "/" + dateString + ".jpg"
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

func downLoadImage(ImageuUrl: String , completion:@escaping(_ image:UIImage?) -> Void) {
    
    let imageUrl = NSURL(string: ImageuUrl)
   
    let imageFileName = (ImageuUrl.components(separatedBy: "%").last!).components(separatedBy: "?").first!

    
    if fileExistsAtPath(path: imageFileName) {
        //exist
        if let contentsOfFile = UIImage(contentsOfFile: fileInDocumentsDirectory(fileName: imageFileName)) {
            
            completion(contentsOfFile)
        }else{
            print("couldnt gerate image")
            completion(nil)
        }
        
        
    }else{
        //doesnt exist
        let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
        
        downloadQueue.async {
            let data = NSData(contentsOf: imageUrl! as URL)
            if data != nil {
                var docURL = getDocumentURL()
                docURL = docURL.appendingPathComponent(imageFileName, isDirectory: false)
                data!.write(to: docURL, atomically: true)
                let imageToReturn = UIImage(data: data! as Data)
                DispatchQueue.main.async {
                    print("successful")
                    completion(imageToReturn)
                }
                
            }else{
                
                DispatchQueue.main.async {
                    print("no image in database")
                    completion(nil)
                }
                
            }
        }
        
    }
 
}
//video
func uploadVideo(Video: NSData , chatRoomId: String , view: UIView ,completion: @escaping(_ videoLing: String?) -> Void) {
    
    let progressHud = MBProgressHUD.showAdded(to: view, animated: true)
        progressHud.mode = .determinateHorizontalBar
    let dateString = dateFormatter().string(from: Date())
    let videoFileName = "VideoMessages/" + FUser.currentId() + "/" + chatRoomId + "/" + dateString + ".mov"
    
    let storageRef = storage.reference(forURL: kFILEREFERENCE).child(videoFileName)
    var task: StorageUploadTask!
    task = storageRef.putData(Video as Data, metadata: nil, completion: { (metadata, error) in
        
        task.removeAllObservers()
        progressHud.hide(animated: true)
        if error != nil {
            print("error couldnt upload video\(error!.localizedDescription)")
            return
        }
        
        storageRef.downloadURL(completion: { (url, error) in
            
            if error != nil {
                print("downloadUrl is error\(error!.localizedDescription)")
            }
            guard let downloadURL = url else {
                completion(nil)
                return
            }
            
            completion(downloadURL.absoluteString)
            
            
            
        })
        
        
    })
    
    task.observe(StorageTaskStatus.progress) { (snapshot) in
        
    
        progressHud.progress = Float((snapshot.progress?.completedUnitCount)!) / Float((snapshot.progress?.totalUnitCount)!)
    }
    
}

func videoThumbnail(video: NSURL) -> UIImage {
    
    let asset = AVURLAsset(url: video as URL, options: nil)
    
    let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
    
    let time = CMTimeMakeWithSeconds(0.5, preferredTimescale: 1000)
    var actualTime = CMTime.zero
    
    var image: CGImage?
    
    do{
        image =  try imageGenerator.copyCGImage(at: time, actualTime: &actualTime)
    }catch let error as NSError{
        print(error.localizedDescription)
        
    }
    let thumbnail = UIImage(cgImage: image!)
    
    return thumbnail

}


//MARK: downloadVideo

func downLoadVideo(videoURL: String , completion:@escaping(_ isReadyToPlay:Bool , _ videoFileName: String) -> Void) {
    
    let videoUrl = NSURL(string: videoURL)

    let videoFileName = (videoURL.components(separatedBy: "%").last!).components(separatedBy: "?").first!
  
    
    if fileExistsAtPath(path: videoFileName) {
        //exist
        completion(true,videoFileName)
        
    }else{
        //doesnt exist
        let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
        
        downloadQueue.async {
            let data = NSData(contentsOf: videoUrl! as URL)
            if data != nil {
                var docURL = getDocumentURL()
                docURL = docURL.appendingPathComponent(videoFileName, isDirectory: false)
                data!.write(to: docURL, atomically: true)
             
                DispatchQueue.main.async {
                    completion(true,videoFileName)
                }
                
            }else{
                
                DispatchQueue.main.async {
                
                   print("no video in firedase")
                }
                
            }
        }
        
    }
    
}
//Audio messages

func uploadAudio(AutioPath: String , chatRoomId: String , view: UIView ,completion: @escaping(_ AudioLing: String?) -> Void) {
    
    let progressHud = MBProgressHUD.showAdded(to: view, animated: true)
    progressHud.mode = .determinateHorizontalBar
    let dateString = dateFormatter().string(from: Date())
    let AudioFileName = "AudioMessages/" + FUser.currentId() + "/" + chatRoomId + "/" + dateString + ".mp3"
    
    let storageRef = storage.reference(forURL: kFILEREFERENCE).child(AudioFileName)
    var task: StorageUploadTask!
    let audio = NSData(contentsOfFile: AutioPath)
    task = storageRef.putData(audio! as Data, metadata: nil, completion: { (metadata, error) in
        
        task.removeAllObservers()
        progressHud.hide(animated: true)
        if error != nil {
            print("error couldnt upload video\(error!.localizedDescription)")
            return
        }
        
        storageRef.downloadURL(completion: { (url, error) in
            
            if error != nil {
                print("downloadUrl is error\(error!.localizedDescription)")
            }
            guard let downloadURL = url else {
                completion(nil)
                return
            }
            
            completion(downloadURL.absoluteString)
            
            
            
        })
        
        
    })
    
    task.observe(StorageTaskStatus.progress) { (snapshot) in
        
        
        progressHud.progress = Float((snapshot.progress?.completedUnitCount)!) / Float((snapshot.progress?.totalUnitCount)!)
    }
    
}


//download audio

func downLoadAudio(audioURl: String , completion:@escaping(_ audioFillName:String?) -> Void) {
    
    let audioUrl = NSURL(string: audioURl)

    let audioFileName = (audioURl.components(separatedBy: "%").last!).components(separatedBy: "?").first!
  
    
    if fileExistsAtPath(path: audioFileName) {
        //exist
          completion(audioFileName)
        
        
    }else{
        //doesnt exist
        let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
        
        downloadQueue.async {
            let data = NSData(contentsOf: audioUrl! as URL)
            if data != nil {
                var docURL = getDocumentURL()
                docURL = docURL.appendingPathComponent(audioFileName, isDirectory: false)
                data!.write(to: docURL, atomically: true)
                DispatchQueue.main.async {
                    print("successful")
                    completion(audioFileName)
                }
                
            }else{
                
                DispatchQueue.main.async {
                    print("no audio in database")
                    completion(nil)
                }
                
            }
        }
        
    }
    
}




//Helpers

func fileInDocumentsDirectory(fileName: String) -> String {
    let fileUrl = getDocumentURL().appendingPathComponent(fileName)
           
    return fileUrl.path
}

func getDocumentURL() -> URL {
    let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
  
    return documentURL!
}

func fileExistsAtPath(path: String) -> Bool {
    
    var doesExist = false
    
    let filePath = fileInDocumentsDirectory(fileName: path)
    let fileManager = FileManager.default
    
    if fileManager.fileExists(atPath: filePath){
        
        doesExist = true
    }else{
        doesExist = false
    }
    
    return doesExist
    
    
}
