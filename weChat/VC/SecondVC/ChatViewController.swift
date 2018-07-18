//
//  ChatViewController.swift
//  weChat
//
//  Created by 洪森達 on 2018/7/18.
//  Copyright © 2018年 sen. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import IQAudioRecorderController
import IDMPhotoBrowser
import AVFoundation
import AVKit
import FirebaseFirestore


class ChatViewController: JSQMessagesViewController, UIGestureRecognizerDelegate {

        //part 2 
    var outgoingBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    var incomingBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
      //fix for iphone x
    override func viewDidLayoutSubviews() {
        perform(Selector(("jsq_updateCollectionViewInsets")))
    }
    //end of iphone x
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(named: "Back"), style: .plain, target: self, action: #selector(self.backAction))]
        
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        //part 1
        self.senderId = FUser.currentId()
        self.senderDisplayName = FUser.currentUser()!.firstname
        
        //swipe
        let target = self.navigationController?.interactivePopGestureRecognizer!.delegate
        let pan = UIPanGestureRecognizer(target: target, action:Selector("handleNavigationTransition:"))
        pan.delegate = self
        self.view.addGestureRecognizer(pan)
        self.navigationController?.interactivePopGestureRecognizer!.isEnabled = false
        
        //fix for iphone x
        let constraints = perform(Selector(("toolbarBottomLayoutGuide")))?.takeUnretainedValue() as! NSLayoutConstraint
        constraints.priority = UILayoutPriority(1000)
        self.inputToolbar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        //end of iphone x
        
        //custom send Button
        self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "mic"), for: .normal)
        self.inputToolbar.contentView.rightBarButtonItem.setTitle("", for: .normal)
        
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.children.count == 1 {
            return false
        }
        return true
    }
    
    
    
    //MARK:JSQMessage delegate func
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
       
        let opeitonMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { (action) in
            print("Camera")
        }
        let sharePhote = UIAlertAction(title: "Phote Libaray", style: .default) { (action) in
            print(" Phote Libaray")
        }
        
        let shareVideo = UIAlertAction(title: "Video Libaray", style: .default) { (action) in
            print("Video Libaray")
        }
        
        let shareLocaiton = UIAlertAction(title: "Share Location", style: .default) { (action) in
            print("Share Location")
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("Cancel")
        }
        
         takePhotoOrVideo.setValue(UIImage(named: "camera"), forKey: "image")
         sharePhote.setValue(UIImage(named: "picture"), forKey: "image")
         shareVideo.setValue(UIImage(named: "video"), forKey: "image")
         shareLocaiton.setValue(UIImage(named: "location"), forKey: "image")
        
        opeitonMenu.addAction(takePhotoOrVideo)
        opeitonMenu.addAction(sharePhote)
         opeitonMenu.addAction(shareVideo)
         opeitonMenu.addAction(shareLocaiton)
         opeitonMenu.addAction(cancel)
        
       
        
        //for iPad not to crash
        
        if (UI_USER_INTERFACE_IDIOM() == .pad ) {
            
            if let currentPopoverpresentionController = opeitonMenu.popoverPresentationController{
                
                currentPopoverpresentionController.sourceView =
                self.inputToolbar.contentView.leftBarButtonItem
                currentPopoverpresentionController.sourceRect =
                    self.inputToolbar.contentView.leftBarButtonItem.bounds
                
                currentPopoverpresentionController.permittedArrowDirections = .up
                self.present(opeitonMenu, animated: true, completion: nil)
                
                
            }
        }else{
            
            self.present(opeitonMenu, animated: true, completion: nil)
        }
        
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        if text != "" {
            
       self.sendMessage(text: text, date: date, picture: nil, location: nil, video: nil, audio: nil)
            updateSendBtn(isSend: false)
        }else{
            
            print("audio message")
            
        }
    }
    
    //MARK: send Messages
    
    func sendMessage(text: String? , date: Date , picture: UIImage? , location: String? , video : NSURL? , audio : String?){
        
        
    }
    
    
    
    
    //MARK: -IBACTION
    @objc func backAction() {
        
        navigationController?.popViewController(animated: true)
        
    }

    //MARK: CustomSendBtn
    
    override func textViewDidChange(_ textView: UITextView) {
        
        if textView.text != "" {
            
            updateSendBtn(isSend: true)
        }else{
            updateSendBtn(isSend: false)
        }
        
        
        
    }
    
    
    
    
    func updateSendBtn(isSend: Bool){
        
        if isSend {
            self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "send"), for: .normal)
        }else{
             self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "mic"), for: .normal)
            
        }
        
    }


} //end of the class

//fix iphonex
extension JSQMessagesInputToolbar {
    override open func didMoveToWindow() {
        super.didMoveToWindow()
        guard let window = window else { return }
        if #available(iOS 11.0, *) {
            let anchor = window.safeAreaLayoutGuide.bottomAnchor
            bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: anchor, multiplier: 1.0).isActive = true
        }
    }
}
//fix iphonex
