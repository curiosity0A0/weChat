//
//  MyGroup.swift
//  weChat
//
//  Created by 洪森達 on 2018/8/8.
//  Copyright © 2018年 sen. All rights reserved.
//

import Foundation
import FirebaseFirestore

class Group {
    let groupDictionary: NSMutableDictionary
    
    init(groupID: String , subject: String , ownerId:String , members: [String],avatar:String) {
        
        groupDictionary = NSMutableDictionary(objects: [groupID,subject,ownerId,members,members,avatar], forKeys: [kGROUPID as NSCopying,kNAME as NSCopying,kOWNERID as NSCopying,kMEMBERS as NSCopying,kMEMBERSTOPUSH as NSCopying,kAVATAR as NSCopying])
    }
    
    func saveGroup(){
        
        let date = dateFormatter().string(from: Date())
        groupDictionary[kDATE] = date
        
        reference(.Group).document(groupDictionary[kGROUPID] as! String).setData(groupDictionary as! [String:Any])
        
    }
    
    class func updateGroup(groupID:String , withValuse: [String:Any]){
        
        reference(.Group).document(groupID).updateData(withValuse)
        
    }
    
    
}
