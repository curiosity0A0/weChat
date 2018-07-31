//
//  incomingMessages.swift
//  weChat
//
//  Created by 洪森達 on 2018/7/20.
//  Copyright © 2018年 sen. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class incomingMessage {
    var collectionView: JSQMessagesCollectionView
    
    init(collectionView_: JSQMessagesCollectionView) {
        
        self.collectionView = collectionView_
        
    }
    
    
    //MARK: CreateMessage
    
    func createMessage(messageDictionary: NSDictionary , chatRoomId: String) -> JSQMessage? {
        
        var message: JSQMessage?
        
        
        let type = messageDictionary[kTYPE] as! String
        
        switch type {
        case kTEXT:
            //create text maeesage
           message = createTextMessag(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
        case kPICTURE:
        //create picture maeesage
            message = createPictureMessage(messageDictionary: messageDictionary)
        case kVIDEO:
        //create video maeesage
           message = createVideoMessage(messageDictionary: messageDictionary)
        case kAUDIO:
            message = createAudioMessage(messageDictionary: messageDictionary)
        case kLOCATION:
            message = createLocationMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
        default:
            print("Unknow message type")
        }

        if message != nil {
            return message
        }else{
            return nil
        }
    }
    
    //MARK: Create Message types
    
    func createTextMessag(messageDictionary: NSDictionary , chatRoomId: String) -> JSQMessage {
        
        let name = messageDictionary[kSENDERNAME] as? String
        let userid = messageDictionary[kSENDERID] as? String
        var date: Date!
        
        if let created = messageDictionary[kDATE] {
            if (created as! String).count != 14 {
                date = Date()
            }else{
                date = dateFormatter().date(from: created as! String)
            }
        }else{
            
            date = Date()
        }
        
        let text = messageDictionary[kMESSAGE] as! String
        
        return JSQMessage(senderId: userid, senderDisplayName: name, date: date, text: text)
    }
    
    
    func createPictureMessage(messageDictionary: NSDictionary) -> JSQMessage {
        let name = messageDictionary[kSENDERNAME] as? String
        let userid = messageDictionary[kSENDERID] as? String
        
        var date: Date!
        
        if let created = messageDictionary[kDATE] {
            if (created as! String).count != 14 {
                date = Date()
            }else{
                date = dateFormatter().date(from: created as! String)
            }
        }else{
            
            date = Date()
        }
        let mediaItem = PhotoMediaItem(image:nil)
            mediaItem?.appliesMediaViewMaskAsOutgoing = retureOutgoingStatusForUser(senderId: userid!)
//
        downLoadImage(ImageuUrl: messageDictionary[kPICTURE] as! String) { (image) in
            
            if image != nil {
                mediaItem?.image = image
                self.collectionView.reloadData()
            }
        }
        
        return JSQMessage(senderId: userid, senderDisplayName: name, date: date, media: mediaItem)
    }
    
    
    func createVideoMessage(messageDictionary: NSDictionary) -> JSQMessage {
        let name = messageDictionary[kSENDERNAME] as? String
        let userid = messageDictionary[kSENDERID] as? String
        
        var date: Date!
        
        if let created = messageDictionary[kDATE] {
            if (created as! String).count != 14 {
                date = Date()
            }else{
                date = dateFormatter().date(from: created as! String)
            }
        }else{
            
            date = Date()
        }
        
        let videoURL = NSURL(fileURLWithPath: messageDictionary[kVIDEO] as! String)

        let mediaItem = VideoMessage(withFileURL: videoURL, maskOutgoing: retureOutgoingStatusForUser(senderId: userid!))

        downLoadVideo(videoURL: messageDictionary[kVIDEO] as! String) { (isReadyToPlay, fileName) in
            
            let url = NSURL(fileURLWithPath: fileInDocumentsDirectory(fileName: fileName))
            mediaItem.status = kSUCCESS
            mediaItem.fileURL = url
            imageFromData(pictureData: messageDictionary["thumbnail"] as! String, withBlock: { (image) in
              
                if image != nil {
                    mediaItem.image = image!
                    self.collectionView.reloadData()
                }
           
                
            })
            
            self.collectionView.reloadData()
        }
        
        return JSQMessage(senderId: userid, senderDisplayName: name, date: date, media: mediaItem)
    }
    
    
    //create AUDIO MESSAGE
    func createAudioMessage(messageDictionary: NSDictionary) -> JSQMessage {
        let name = messageDictionary[kSENDERNAME] as? String
        let userid = messageDictionary[kSENDERID] as? String
        
        var date: Date!
        
        if let created = messageDictionary[kDATE] {
            if (created as! String).count != 14 {
                date = Date()
            }else{
                date = dateFormatter().date(from: created as! String)
            }
        }else{
            
            date = Date()
        }
        
        let audioItem = JSQAudioMediaItem(data: nil)
        audioItem.appliesMediaViewMaskAsOutgoing = retureOutgoingStatusForUser(senderId:userid!)
        
        let audioMessage = JSQMessage(senderId: userid!, displayName: name!, media: audioItem)
        
        downLoadAudio(audioURl: messageDictionary[kAUDIO] as! String) { (fileName) in
            
            guard let filename = fileName else { return }
            let url = NSURL(fileURLWithPath: fileInDocumentsDirectory(fileName: filename))
            let audioData = try? Data(contentsOf: url as URL)
                audioItem.audioData = audioData
            self.collectionView.reloadData()
            
        }
        
        return audioMessage!
    }
    
    //Create Location Message
    
    func createLocationMessage(messageDictionary: NSDictionary , chatRoomId: String) -> JSQMessage {
        
        let name = messageDictionary[kSENDERNAME] as? String
        let userid = messageDictionary[kSENDERID] as? String
        var date: Date!
        
        if let created = messageDictionary[kDATE] {
            if (created as! String).count != 14 {
                date = Date()
            }else{
                date = dateFormatter().date(from: created as! String)
            }
        }else{
            
            date = Date()
        }
        
        let text = messageDictionary[kMESSAGE] as! String
        let latitude = messageDictionary[kLATITUDE] as? Double
        let longitude = messageDictionary[kLONGITUDE] as? Double
        
        let mediaItem = JSQLocationMediaItem(location: nil)
            mediaItem?.appliesMediaViewMaskAsOutgoing = retureOutgoingStatusForUser(senderId: userid!)
        
        let location = CLLocation(latitude: latitude!, longitude: longitude!)
        mediaItem?.setLocation(location, withCompletionHandler: {
            self.collectionView.reloadData()
        })
        
        return JSQMessage(senderId: userid!, senderDisplayName: name, date: date, media: mediaItem)
    }
    

    
    //MARK: Helper
    func retureOutgoingStatusForUser(senderId: String) -> Bool {
     
        return senderId == FUser.currentId()
    }
    
}
