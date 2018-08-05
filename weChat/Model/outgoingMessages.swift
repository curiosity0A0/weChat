//
//  outgoingMessages.swift
//  weChat
//
//  Created by 洪森達 on 2018/7/20.
//  Copyright © 2018年 sen. All rights reserved.
//

import Foundation


class OutgoingMessages {
    
    let messageDictionary : NSMutableDictionary
    
    //MARK: Initializers
    //Text MESSAGE
    
    init(message: String , senderId: String , senderName: String , date:Date , status: String , type: String) {
        messageDictionary = NSMutableDictionary(objects: [message,senderId,senderName,dateFormatter().string(from: date),status,type], forKeys: [kMESSAGE as! NSCopying,kSENDERID as! NSCopying , kSENDERNAME as! NSCopying , kDATE as! NSCopying , kSTATUS as! NSCopying , kTYPE as! NSCopying ])
        
    }
    
    //picture message
    init(message: String, pictureLink: String, senderId: String , senderName: String , date:Date , status: String , type: String) {
        messageDictionary = NSMutableDictionary(objects: [message,pictureLink,senderId,senderName,dateFormatter().string(from: date),status,type], forKeys: [kMESSAGE as! NSCopying,kPICTURE as! NSCopying,kSENDERID as! NSCopying , kSENDERNAME as! NSCopying , kDATE as! NSCopying , kSTATUS as! NSCopying , kTYPE as! NSCopying ])
        
    }
 
    //video message

    init(message: String, video: String, senderId: String , senderName: String , date:Date , status: String , type: String ,thumNail: NSData) {
      
        let picThumb = thumNail.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        messageDictionary = NSMutableDictionary(objects: [message,video,senderId,senderName,dateFormatter().string(from: date),status,type ,picThumb], forKeys: [kMESSAGE as! NSCopying,kVIDEO as! NSCopying,kSENDERID as! NSCopying , kSENDERNAME as! NSCopying , kDATE as! NSCopying , kSTATUS as! NSCopying , kTYPE as! NSCopying , kTHUMBNAIL as! NSCopying])
        
    }
    
    //audio message
    
    init(message: String, audio: String, senderId: String , senderName: String , date:Date , status: String , type: String) {
        messageDictionary = NSMutableDictionary(objects: [message,audio,senderId,senderName,dateFormatter().string(from: date),status,type], forKeys: [kMESSAGE as! NSCopying,kAUDIO as! NSCopying,kSENDERID as! NSCopying , kSENDERNAME as! NSCopying , kDATE as! NSCopying , kSTATUS as! NSCopying , kTYPE as! NSCopying ])
        
    }
    
    //location message
    
    
    init(message: String, lat: NSNumber, long: NSNumber,senderId: String , senderName: String , date:Date , status: String , type: String) {
        messageDictionary = NSMutableDictionary(objects: [message,lat,long,senderId,senderName,dateFormatter().string(from: date),status,type], forKeys: [kMESSAGE as! NSCopying,kLATITUDE as! NSCopying,kLONGITUDE as! NSCopying,kSENDERID as! NSCopying , kSENDERNAME as! NSCopying , kDATE as! NSCopying , kSTATUS as! NSCopying , kTYPE as! NSCopying ])
        
    }
    
    //MARK: sendMessage
    
    func sendMessage(chatRoomId:String, messageDictionary: NSMutableDictionary,memberIds: [String],memberToPush: [String]){
        
        let messageId = UUID().uuidString
        messageDictionary[kMESSAGEID] = messageId
        
        for memberId in memberIds {
            
            reference(.Message).document(memberId).collection(chatRoomId).document(messageId).setData(messageDictionary as! [String: Any])
            
        }
        
        //update Recent Chat
            updateRecent(chatRoomId: chatRoomId, lastMessage: messageDictionary[kMESSAGE] as! String)
        
        //send push notificaiton
    }
    
    class func deleteMessage(withID : String , chatRoomId: String) {
            reference(.Message).document(FUser.currentId()).collection(chatRoomId).document(withID).delete()
    }
    
    class func updatMessage(withId: String, chatRoomId: String , memberIds: [String]){
        
        let readDate = dateFormatter().string(from: Date())
        let values = [kSTATUS: kREAD , kREADDATE: readDate]
        for userid in memberIds {
            
            reference(.Message).document(userid).collection(chatRoomId).document(withId).getDocument { (snapShot, error) in
                
                guard let snapshot = snapShot else { return }
                
                if snapshot.exists {
                    reference(.Message).document(userid).collection(chatRoomId).document(withId).updateData(values)
                }
                
                
            }
        }
        
    }
    

}
