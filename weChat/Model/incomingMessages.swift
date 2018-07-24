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
            print("create text maeesage")
           message = createTextMessag(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
        case kPICTURE:
        //create picture maeesage
              print("create picture maeesage")
        case kVIDEO:
        //create video maeesage
            print("create video maeesage")
        case kAUDIO:
        //create audio maeesage
              print(" //create audio maeesage")
        case kLOCATION:
        //create location maeesage
              print("//create location maeesage")
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
    
    
    
}
