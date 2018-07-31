//
//  AudioViewController.swift
//  weChat
//
//  Created by 洪森達 on 2018/7/29.
//  Copyright © 2018年 sen. All rights reserved.
//

import Foundation
import IQAudioRecorderController

class AudioViewController{
    
    var delegate: IQAudioRecorderViewControllerDelegate
    
    init(delegate_: IQAudioRecorderViewControllerDelegate) {
        self.delegate = delegate_
    }
    
    func presentAudioRecorder(target:UIViewController) {
        let controller = IQAudioRecorderViewController()
        controller.delegate = delegate
        controller.title = "Record"
        controller.maximumRecordDuration = kAUDIOMAXDURATION
        controller.allowCropping = true
        
        target.presentBlurredAudioRecorderViewControllerAnimated(controller)
    }

    
}
