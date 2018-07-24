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
 
    
    
    //MARK: sendMessage
    
    func sendMessage(chatRoomId:String, messageDictionary: NSMutableDictionary,memberIds: [String],memberToPush: [String]){
        
        let messageId = UUID().uuidString
        messageDictionary[kMESSAGEID] = messageId
        
        for memberId in memberIds {
            
            reference(.Message).document(memberId).collection(chatRoomId).document(messageId).setData(messageDictionary as! [String: Any])
            
        }
        
        //update Recent Chat
        
        
        //send push notificaiton
        
        
        
        
    }
    
    
    
    
    
    
    
}
