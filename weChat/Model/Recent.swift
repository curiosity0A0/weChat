//
//  Recent.swift
//  weChat
//
//  Created by 洪森達 on 2018/7/17.
//  Copyright © 2018年 sen. All rights reserved.
//

import Foundation

func startPrivateChat(user1: FUser , user2 : FUser) -> String {
    
    let userid1 = user1.objectId
    let userid2 = user2.objectId
    var chatRoomID = ""
    let value = userid1.compare(userid2).rawValue
    
    if value < 0 {
        
        chatRoomID = userid1 + userid2
    }else{
        chatRoomID = userid2 + userid1
    }
    
    let members = [userid1,userid2]
 
    
    //create recent chat
    createRecent(members: members, chatroomID: chatRoomID, withUserUserName: "", type: kPRIVATE, users: [user1,user2], avatarOfGroup: nil)

    return chatRoomID
}

func createRecent(members: [String],chatroomID: String, withUserUserName: String, type: String , users:[FUser]? , avatarOfGroup:String?){
    
    
        var tempMembers = members
    reference(.Recent).whereField(kCHATROOMID, isEqualTo: chatroomID).getDocuments { (snapShot, error) in
        guard let snapshot = snapShot else { return }
        
        if error != nil {
            print(error!.localizedDescription)
        }
        if !snapshot.isEmpty {
            
            for recent in snapshot.documents {
                
                let currentRecent = recent.data() as NSDictionary
                if let currentUserID = currentRecent[kUSERID] {
                    
                    if tempMembers.contains(currentUserID as! String) {
                        
                        tempMembers.remove(at: tempMembers.index(of: currentUserID as! String)!)
                    }
                }
            }
            
        }
        
        for userId in tempMembers {
            
            //create recent Items
            createRecentItems(userid: userId, chatRoomId: chatroomID, members: members, withUserUserName: withUserUserName, type: type, users: users, avatarOfGroup: avatarOfGroup)
        }
    }

}

func createRecentItems(userid: String , chatRoomId: String , members: [String] , withUserUserName: String , type: String , users: [FUser]? , avatarOfGroup: String?){
    
    let localRef = reference(.Recent).document()
    let recentId = localRef.documentID
    
    let date = dateFormatter().string(from: Date())
    
    var recent: [String:Any]!
    
    if type == kPRIVATE {
        //private
        var withUser: FUser?
        
        if users != nil && users!.count > 0 {
            if userid == FUser.currentId() {
                //for current User
                withUser = users!.last!
            }else{
                
                withUser = users!.first!
            }
        }
        
        recent = [kRECENTID: recentId , kUSERID : userid , kCHATROOMID : chatRoomId , kMEMBERS : members , kMEMBERSTOPUSH : members , kWITHUSERFULLNAME: withUser!.fullname ,kWITHUSERUSERID: withUser!.objectId , kLASTMESSAGE : "" , kCOUNTER : 0 , kDATE : date , kTYPE : type , kAVATAR: withUser!.avatar ] as [String:Any]
        
        
    }else{
        
        //group
        
        if avatarOfGroup != nil {
            recent = [kRECENTID: recentId,kUSERID: userid , kCHATROOMID: chatRoomId , kMEMBERS : members , kMEMBERSTOPUSH : members , kWITHUSERFULLNAME : withUserUserName , kLASTMESSAGE: "" ,kCOUNTER : 0 , kDATE : date , kTYPE: type , kAVATAR: avatarOfGroup!] as [String:Any]
        }
        
    }
    
    localRef.setData(recent)
    
    
}

//group
func startGroupChat(group:Group){
    let chatRoomId = group.groupDictionary[kGROUPID] as! String
    let members = group.groupDictionary[kMEMBERS] as! [String]
    
    createRecent(members: members, chatroomID: chatRoomId, withUserUserName: group.groupDictionary[kNAME] as! String, type: kGROUP, users: nil, avatarOfGroup: group.groupDictionary[kAVATAR] as? String)
}
func createRecentsForNewMembers(groupID:String , groupName: String , memberToPush:[String],avatar: String){
    
    createRecent(members: memberToPush, chatroomID: groupID, withUserUserName: groupName, type: kGROUP, users: nil, avatarOfGroup: avatar)
}






//Restart chat

func restaratRecentChat(recent: NSDictionary) {
    
    if recent[kTYPE] as! String == kPRIVATE {
        
        createRecent(members: recent[kMEMBERSTOPUSH] as! [String], chatroomID: recent[kCHATROOMID] as! String, withUserUserName: recent[kWITHUSERFULLNAME] as! String, type: kPRIVATE, users: [FUser.currentUser()!], avatarOfGroup: nil)
    }
    
    if recent[kTYPE] as! String == kGROUP {
        
        createRecent(members: recent[kMEMBERSTOPUSH] as! [String], chatroomID: recent[kCHATROOMID] as! String, withUserUserName: recent[kWITHUSERFULLNAME] as! String, type: kGROUP, users: nil, avatarOfGroup: recent[kAVATAR] as! String)
    }
    
    
}

//updateRecent

func updateRecent(chatRoomId: String,lastMessage: String) {
    
    reference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapShot, error) in
        guard let snapshot = snapShot else{ return }
        
        if !snapshot.isEmpty{
            
            for recent in snapshot.documents {
                let currentRecent = recent.data() as NSDictionary
                
                updateRecentItem(recent: currentRecent, lastMessage: lastMessage)
                
            }
            
        }
    }
    
}




func updateRecentItem(recent: NSDictionary,lastMessage:String) {
    
    let date = dateFormatter().string(from: Date())
    var counter = recent[kCOUNTER] as! Int
    if recent[kUSERID] as? String != FUser.currentId() {
        
        counter += 1
    }
    let values = [kLASTMESSAGE: lastMessage , kCOUNTER : counter , kDATE: date] as! [String:Any]
    reference(.Recent).document(recent[kRECENTID] as! String).updateData(values)
    
    
    
    
    
    
}






//Delete recent

func deleteRecentChat(recentChatDic: NSDictionary){
    
    if let recentId = recentChatDic[kRECENTID]{
        
        reference(.Recent).document(recentId as! String).delete()
    }

}


//clear counter

func clearRecentCounter(chatRoomId: String) {
    
    reference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapShot, error) in
        guard let snapshot = snapShot else{ return }
        
        if !snapshot.isEmpty{
            
            for recent in snapshot.documents {
                let currentRecent = recent.data() as NSDictionary
                if currentRecent[kUSERID] as? String == FUser.currentId() {
                    clearRecentCounterItem(recent: currentRecent)
                }
            }
            
        }
    }
    
}


func clearRecentCounterItem(recent: NSDictionary){
    reference(.Recent).document(recent[kRECENTID] as! String).updateData([kCOUNTER:0])
}

func updateExistingRecentWithNewValue(chatRoomID:String,members: [String], withValue: [String:Any]){
    
    reference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomID).getDocuments { (snapshot, error) in
        guard let snapShot = snapshot else { return }
        
        
        if !snapShot.isEmpty{
            
            for recent in snapShot.documents {
                let recent = recent.data() as NSDictionary
                updateRecent(recentID: recent[kRECENTID] as! String, withValue: withValue)
                
            }
        }
        
        
    }
    
    
}

func updateRecent(recentID:String , withValue: [String:Any]){
    
    reference(.Recent).document(recentID).updateData(withValue)
}

func blockUser(userToBlock: FUser){
    
    let userid1 = FUser.currentId()
    let userid2 = userToBlock.objectId
    var chatRoomID = ""
    let value = userid1.compare(userid2).rawValue
    
    if value < 0 {
        
        chatRoomID = userid1 + userid2
    }else{
        chatRoomID = userid2 + userid1
    }
    
    getRecentsFor(ChatRoomId: chatRoomID)

}

func getRecentsFor(ChatRoomId: String ){
    reference(.Recent).whereField(kCHATROOMID, isEqualTo: ChatRoomId).getDocuments { (snapshot, error) in
        guard let snapShot = snapshot else { return }
        
        
        if !snapShot.isEmpty{
            
            for recent in snapShot.documents {
                let recent = recent.data() as NSDictionary
                deleteRecentChat(recentChatDic: recent)
                
            }
        }
        
        
    }
    
}
