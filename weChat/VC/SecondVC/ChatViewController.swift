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
import ProgressHUD
import SVProgressHUD



class ChatViewController: JSQMessagesViewController, UIGestureRecognizerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{


    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
  
    
    var outgoingBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    var incomingBubble = JSQMessagesBubbleImageFactory()?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
    var chatRoomId: String!
    var memberids : [String]!
    var memberidsToPush : [String]!
    var titleName: String!
    var isGroup: Bool?
    var group: NSDictionary?
    var withUsers: [FUser] = []
    
    var typinglistener: ListenerRegistration?
    var updatedChatListener: ListenerRegistration?
    var newChatListener: ListenerRegistration?
    
    var typingCounter = 0
    let legitTypes = [kAUDIO,kVIDEO,kTEXT,kLOCATION,kPICTURE]
    
    var maxMessageNumber = 0
    var minMessageNUmber = 0
    var loadOld = false
    var loadedMessageCounter = 0
    
    var messages: [JSQMessage] = []
    var objectMessage: [NSDictionary] = []
    var loadedMessage: [NSDictionary] = []
    var allPictureMessages : [String] = []
    
    var initialLoadCompleted = false
    var jsqAvaTarDictionary: NSMutableDictionary?
    var avatarImageDictionary: NSMutableDictionary?
    var showAvatar = true
    var firstLoad: Bool?
    
    let leftBarButtonVIew: UIView = {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        return view
        
        }()
    
    let avatarBtn: UIButton = {
        let button = UIButton()
            button.frame = CGRect(x: 0, y: 10, width: 25, height: 25)
        
        return button
    }()
    
    let titileLabel: UILabel = {
        let titile = UILabel(frame: CGRect(x: 30, y: 10, width: 140, height: 15))
        titile.textAlignment = .left
        titile.font = UIFont(name: titile.font.fontName, size: 14)
        return titile
    }()
    
    let subtitle : UILabel = {
        let subtitle = UILabel(frame: CGRect(x: 30, y: 25, width: 140, height: 15))
        subtitle.textAlignment = .left
        subtitle.font = UIFont(name: subtitle.font.fontName, size: 10)
        return subtitle
    }()
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        clearRecentCounter(chatRoomId: chatRoomId)
    }
    override func viewWillDisappear(_ animated: Bool) {
        clearRecentCounter(chatRoomId: chatRoomId)
    }
    
      //fix for iphone x
    override func viewDidLayoutSubviews() {
        perform(Selector(("jsq_updateCollectionViewInsets")))
    }
    //end of iphone x
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SVProgressHUD.show()
        
        createTypingObserver()
        JSQMessagesCollectionViewCell.registerMenuAction(#selector(delete))
        
        navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(named: "Back"), style: .plain, target: self, action: #selector(self.backAction))]
        
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
 
        jsqAvaTarDictionary = [:]
        
        if isGroup! {
            getCurrentGroup(withId: chatRoomId)
        }
        
        setCustomTitle()
        
        
        
        self.senderId = FUser.currentId()
        self.senderDisplayName = FUser.currentUser()!.firstname
        
  
      
      
//        let pan = UISwipeGestureRecognizer(target: target, action:Selector("handleNavigationTransition:"))
            //pan
//        let target = navigationController?.interactivePopGestureRecognizer!.delegate
//        let pan = UIPanGestureRecognizer(target: target, action:Selector("handleNavigationTransition:"))
//             pan.delegate = self
        

              //swipe
        let swipe = UISwipeGestureRecognizer(target: self, action:#selector(self.poNavigation))
            swipe.direction = UISwipeGestureRecognizer.Direction.right

        
        self.view.addGestureRecognizer(swipe)
        self.navigationController?.interactivePopGestureRecognizer!.isEnabled = true
        
        //fix for iphone x
        let constraints = perform(Selector(("toolbarBottomLayoutGuide")))?.takeUnretainedValue() as! NSLayoutConstraint
        constraints.priority = UILayoutPriority(1000)
        self.inputToolbar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        //end of iphone x
        
        //custom send Button
        self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "mic"), for: .normal)
        self.inputToolbar.contentView.rightBarButtonItem.setTitle("", for: .normal)
        
        loadMessage()
        
        
    }
    
    @objc func poNavigation(){
        
        navigationController?.popViewController(animated: true)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.children.count == 1 {
            return false
        }
        return true
    }
    
    //MARK : -JSQMessage dataSource
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let data = messages[indexPath.row]
       
            //set text color
        print(FUser.currentId())
        print(data.senderId)
        if data.senderId == FUser.currentId() {
            
            cell.textView?.textColor = .white
        }else{
            cell.textView?.textColor = .black
        }
        
        
        return cell
    }
        //display messages
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        
        return messages[indexPath.row]
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let data = messages[indexPath.row]
        if data.senderId == FUser.currentId() {
            return outgoingBubble
        }else{
            
            return incomingBubble
        }
    }
    
    // top date
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        if indexPath.item % 3 == 0 {
            let message = messages[indexPath.row]
            return JSQMessagesTimestampFormatter.shared()?.attributedTimestamp(for: message.date)
        }
        return nil
     
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        if indexPath.item % 3 == 0 {
            
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
                return 0.0
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        
        let message = objectMessage[indexPath.row]
        let status: NSAttributedString!
        let attributedStringColor = [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
        
        switch message[kSTATUS] as! String{
        case kDELIVERED:
            status = NSAttributedString(string: kDELIVERED)
        case kREAD:
            let statusText = "Read" + " " + readTimeFrom(dateString: message[kREADDATE] as! String)
            status = NSAttributedString(string: statusText, attributes: attributedStringColor)
            
        default:
            status = NSAttributedString(string:"✓")
        }
        
        if indexPath.row == (messages.count - 1){
            return status
        } else{
              return NSAttributedString(string: "")
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        
        let data = messages[indexPath.row]
        if data.senderId == FUser.currentId() {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }else{
            return 0.0
        }
    }
    
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = messages[indexPath.row]
        var avatar: JSQMessageAvatarImageDataSource
        
        if let testAvatar = jsqAvaTarDictionary!.object(forKey: message.senderId) {
            avatar = testAvatar as! JSQMessageAvatarImageDataSource
        }else{
            avatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "avatarPlaceholder"), diameter: 70)
        }
        return avatar
        
    }
    
    
    
    //MARK:JSQMessage delegate func
    
    

    override func didPressAccessoryButton(_ sender: UIButton!) {
        
        let camera = Camera(delegate_: self)
        
        
        let opeitonMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { (action) in
           
            camera.PresentMultyCamera(target: self, canEdit: false)
         
        }
        let sharePhote = UIAlertAction(title: "Phote Libaray", style: .default) { (action) in
            camera.PresentPhotoLibrary(target: self, canEdit: false)
            
           
        }
        
        let shareVideo = UIAlertAction(title: "Video Libaray", style: .default) { (action) in
            camera.PresentVideoLibrary(target: self, canEdit: false)
         
        }
        
        let shareLocaiton = UIAlertAction(title: "Share Location", style: .default) { (action) in
            if self.haveAccessToUuserLocation() {
                if self.appDelegate.coordinates?.latitude == nil {
                      ProgressHUD.showError("Please give access tp location in Settings")
                
                }else{
                      self.sendMessage(text: nil, date: Date(), picture: nil, location: kLOCATION, video: nil, audio: nil)
                }
              
            }
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
            
            let audioVC = AudioViewController(delegate_: self)
            audioVC.presentAudioRecorder(target: self)
            
        }
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        
            //load more messages
            loadMoreMessages(maxNumber: maxMessageNumber, minNumber: minMessageNUmber)
            self.collectionView.reloadData()
        
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
     
        
        let messageDictionary = objectMessage[indexPath.row]
        let messageType = messageDictionary[kTYPE] as! String
        switch messageType {
        case kPICTURE:
               print("tap message at \(indexPath)")
            let message = messages[indexPath.row]
            let mediaItem = message.media as! JSQPhotoMediaItem
            let photos = IDMPhoto.photos(withImages: [mediaItem.image])
            let browser = IDMPhotoBrowser(photos: photos)
            
            self.present(browser!, animated: true, completion: nil)
            
            
        case kLOCATION:
            let message = messages[indexPath.row]
            let mediaItem = message.media as! JSQLocationMediaItem
            
            let mapView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapViewViewController") as! MapViewViewController
                mapView.location = mediaItem.location
            
            self.navigationController?.pushViewController(mapView, animated: true)
            
        case kVIDEO:
       
            let message = messages[indexPath.row]
            let mediaItem = message.media as! VideoMessage
            let player = AVPlayer(url: mediaItem.fileURL! as! URL)
            let moviewPlayer = AVPlayerViewController()
            
            let session = AVAudioSession.sharedInstance()
            
            try! session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            moviewPlayer.player = player
           self.present(moviewPlayer, animated: true) {
                moviewPlayer.player!.play()
            }
            
        default:
            print("unknow message tapped")
        }
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, at indexPath: IndexPath!) {
        
            let senderId = messages[indexPath.row].senderId
            var selectedUser:FUser?
            if senderId == FUser.currentId() {
                
            selectedUser = FUser.currentUser()
           
            }else{
                for user in withUsers {
                    
                    if user.objectId == senderId {
                        selectedUser = user
                    }
                }
             
        }
        
        //show user profile
        presentUserProfile(forUser: selectedUser!)
    }
    //for multimedia messages
    
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        super.collectionView(collectionView, shouldShowMenuForItemAt: indexPath)
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if messages[indexPath.row].isMediaMessage{
            if action.description == "delete:"{
                return true
            }else{
                return false
            }
        }else{
            if action.description == "delete:" || action.description == "copy:"{
                return true
            }else{
                return false
            }
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didDeleteMessageAt indexPath: IndexPath!) {
        let messageId = objectMessage[indexPath.row][kMESSAGEID] as! String
        objectMessage.remove(at: indexPath.row)
        messages.remove(at: indexPath.row)
        //delete from firebase
        OutgoingMessages.deleteMessage(withID: messageId, chatRoomId: chatRoomId)
    }
    
    
    //MARK: send Messages
    
    func sendMessage(text: String? , date: Date , picture: UIImage? , location: String? , video : NSURL? , audio : String?){
        
        var outgoingMessage: OutgoingMessages?
        let currentUser = FUser.currentUser()!
        //text message
        
        if let text = text {
            outgoingMessage = OutgoingMessages(message: text, senderId: currentUser.objectId, senderName: currentUser.firstname, date: date, status: kDELIVERED, type: kTEXT)
            
        }
        
        if let pic = picture {
            
            uploadImage(image: pic, chatRoomId: chatRoomId, view: self.navigationController!.view) { (imageLink) in
                
                if imageLink != nil {
                    
                    let text = "[\(kPICTURE)]"
                    
                    outgoingMessage = OutgoingMessages(message: text, pictureLink: imageLink!, senderId: FUser.currentId(), senderName: FUser.currentUser()!.fullname, date: date, status: kDELIVERED, type: kPICTURE)
                        JSQSystemSoundPlayer.jsq_playMessageSentSound()
                    self.finishSendingMessage()
                    outgoingMessage?.sendMessage(chatRoomId: self.chatRoomId, messageDictionary: outgoingMessage!.messageDictionary, memberIds: self.memberids, memberToPush: self.memberidsToPush)
                }
                
            }
            return
        }
        
        
        if let video = video {
            
            
            let videoData = NSData(contentsOfFile: video.path!)
            let thumbnail = videoThumbnail(video: video).jpegData(compressionQuality: 0.3)
            uploadVideo(Video: videoData!, chatRoomId: chatRoomId, view: self.navigationController!.view) { (videoLink) in
                
                if videoLink != nil {
                    let text = "[\(kVIDEO)]"
                    outgoingMessage = OutgoingMessages(message: text, video: videoLink!, senderId: FUser.currentId(), senderName: FUser.currentUser()!.fullname, date: date, status: kDELIVERED, type: kVIDEO, thumNail: thumbnail as! NSData)
                    JSQSystemSoundPlayer.jsq_playMessageSentSound()
                    self.finishSendingMessage()
                    outgoingMessage?.sendMessage(chatRoomId: self.chatRoomId, messageDictionary:(outgoingMessage?.messageDictionary)!, memberIds: self.memberids, memberToPush: self.memberidsToPush)
                }
            }
            return
        }
        
        //send audio
        
        if let audioPath = audio {
            
            uploadAudio(AutioPath: audioPath, chatRoomId: chatRoomId, view: (self.navigationController?.view!)!) { (audioLink) in
                
                if audioLink != nil {
                    let text = "[\(kAUDIO)]"
                    
                    outgoingMessage = OutgoingMessages(message: text, audio: audioLink!, senderId: FUser.currentId(), senderName: FUser.currentUser()!.fullname, date: date, status: kDELIVERED, type: kAUDIO)
                    JSQSystemSoundPlayer.jsq_playMessageSentSound()
                    self.finishSendingMessage()
                    outgoingMessage?.sendMessage(chatRoomId: self.chatRoomId, messageDictionary: (outgoingMessage?.messageDictionary)!, memberIds: self.memberids, memberToPush: self.memberidsToPush)
                }
            }
            return
        }
        
        
        //senf location message
        
        if location != nil {
          appDelegate.locationManagerStart()
            if let lat: NSNumber = NSNumber(value:appDelegate.coordinates!.latitude),let long: NSNumber = NSNumber(value:appDelegate.coordinates!.longitude) {
                
                let text = "[\(kLOCATION)]"
                outgoingMessage = OutgoingMessages(message: text, lat: lat, long: long, senderId: FUser.currentId(), senderName: FUser.currentUser()!.fullname, date: date, status: kDELIVERED, type: kLOCATION)
                
            }

        }
        
        
        
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.finishSendingMessage()
        outgoingMessage!.sendMessage(chatRoomId: chatRoomId, messageDictionary: outgoingMessage!.messageDictionary, memberIds: memberids, memberToPush: memberidsToPush)
        
    }
    
    //MARK: listening to new chat
    
    func listenForNewChat(){

        var lastMessageDate = ""
        if loadedMessage.count > 0 {
            
            lastMessageDate = loadedMessage.last![kDATE] as! String
        }
        
        newChatListener = reference(.Message).document(FUser.currentId()).collection(chatRoomId).whereField(kDATE, isGreaterThan: lastMessageDate).addSnapshotListener({ (snaoShit, error) in
            
            if error != nil {
                print("error\(error!.localizedDescription)")
            }
            
            
            guard let snapshot = snaoShit else { return }
            
            if !snapshot.isEmpty {
                
                for diff in snapshot.documentChanges {
                    if (diff.type == .added){
                        let item = diff.document.data() as NSDictionary
                        if let type = item[kTYPE] {
                            if self.legitTypes.contains(type as! String) {
                                if type as! String == kPICTURE {
                                    self.addNewPictureMessageLink(like: item[kPICTURE] as! String)
                                }
                                if self.insertInitialLoadMessages(messageDictionary: item) {
                                    
                                    JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                                    
                                }
                                
                                self.finishReceivingMessage()
                                
                            }
                        }
                    }
                }
            }
        })

        
    }
    
    
    
    //MARK: LoadMessages
    
    func loadMessage(){
        
        //to update message status
        
        updatedChatListener = reference(.Message).document(FUser.currentId()).collection(chatRoomId).addSnapshotListener({ (snapShot, error) in
            guard let snapshot = snapShot else { return }
            if !snapshot.isEmpty {
                snapshot.documentChanges.forEach({ (diff) in
                    
                
                    if diff.type == .modified {
                        self.updateMessage(messageDictionary: diff.document.data() as! NSDictionary)
                        
                    }

                })

            }
        })
        // get last 11 message
        reference(.Message).document(FUser.currentId()).collection(chatRoomId).order(by: kDATE, descending: true).limit(to: 11).getDocuments { (snapShot, error) in
            
            if error != nil {
                print("\(error!.localizedDescription)")
            }
            
            guard let snapshot = snapShot else {
                self.initialLoadCompleted = true
                 SVProgressHUD.dismiss()
                self.listenForNewChat()
                return
            }
            
            let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray ).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [NSDictionary]
            //remove bad messages
            self.loadedMessage = self.removeBadMessages(allMessages: sorted)
            
            //insert Messages
            self.insertMessages()
            self.finishReceivingMessage(animated: true)
            self.initialLoadCompleted = true
                 SVProgressHUD.dismiss()
            self.getPictureMessages()
            
            //get old messages in backgroud
            self.getOldMessageInBackGround()
            //start listening for new chats 
            self.listenForNewChat()
            
        }
    }
    
    
    //MARK: InsertMessages
    func insertMessages(){
        maxMessageNumber = loadedMessage.count - loadedMessageCounter //11 , 9
        minMessageNUmber = maxMessageNumber - kNUMBEROFMESSAGES //1 , 0
        
        print("\(maxMessageNumber),\(minMessageNUmber)")
        if minMessageNUmber < 0 {
            minMessageNUmber = 0
        }
        
        
        for i in minMessageNUmber ..< maxMessageNumber { // 1...11 , 0...9
            
            let messageDictionary = loadedMessage[i]
            
            insertInitialLoadMessages(messageDictionary: messageDictionary)
            
            loadedMessageCounter += 1  //11 , 10
            
            //insertMessage
            
        }
            print("\(loadedMessageCounter),\(loadedMessage.count)")
        self.showLoadEarlierMessagesHeader = (loadedMessageCounter != loadedMessage.count)
        
        
        
    }
    
    func insertInitialLoadMessages(messageDictionary: NSDictionary) -> Bool {
        
        //check if incoming
        let incomingMessagee = incomingMessage(collectionView_: self.collectionView)
        
        if (messageDictionary[kSENDERID] as! String ) != FUser.currentId() {
            
            OutgoingMessages.updatMessage(withId: messageDictionary[kMESSAGEID] as! String, chatRoomId: chatRoomId, memberIds: memberids)
            
        }
        
        
        let message = incomingMessagee.createMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
        if message != nil {
            
            objectMessage.append(messageDictionary) //original message from firebase
            messages.append(message!) //transfer to jsqMessage from original message
        }
        
        
      return isIncoming(messageDictionary:messageDictionary)
    }
    
    
    func updateMessage(messageDictionary: NSDictionary ) {
        
        for index in 0 ..< objectMessage.count {
            let temp = objectMessage[index]
            if messageDictionary[kMESSAGEID] as! String == temp[kMESSAGEID] as! String {
                
                objectMessage[index] = messageDictionary
                
                self.collectionView.reloadData()
            }
        }
        
    }
    
    
    
    
    
    //MARK: LoadMoreMessages
    
    func loadMoreMessages(maxNumber:Int,minNumber: Int) {
        if loadOld {
            maxMessageNumber = minNumber - 1
            minMessageNUmber = maxMessageNumber - kNUMBEROFMESSAGES
        }
        
        if minMessageNUmber < 0 {
            minMessageNUmber = 0
        }
        
        for i in (minMessageNUmber ... maxMessageNumber).reversed(){
                  let messageDictionary = loadedMessage[i]
                insertNewMessage(messageDictionary: messageDictionary)
            loadedMessageCounter += 1
        }
        
        loadOld = true
        self.showLoadEarlierMessagesHeader = (loadedMessageCounter != loadedMessage.count)
       
    }
    
    func insertNewMessage(messageDictionary: NSDictionary){
        let incominggMessage = incomingMessage(collectionView_: self.collectionView!)
        let message = incominggMessage.createMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
        objectMessage.insert(messageDictionary, at: 0)
        messages.insert(message!, at: 0)
        
        
    }
    
    
    
    //MARK: - GET OLD MESSAGES IN BACKGROUND()
    
    func getOldMessageInBackGround(){
        if loadedMessage.count > 10 {
            let firstMessageDate = loadedMessage.first![kDATE] as! String
            reference(.Message).document(FUser.currentId()).collection(chatRoomId).whereField(kDATE, isLessThan: firstMessageDate ).getDocuments { (snapShot, error) in
                
                guard let snapShot = snapShot else { return }
            
                let sorted = ((dictionaryFromSnapshots(snapshots: snapShot.documents))as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [NSDictionary]
                self.loadedMessage = self.removeBadMessages(allMessages: sorted) + self.loadedMessage
                
                //get the picture messages
                self.getPictureMessages()
                self.maxMessageNumber = self.loadedMessage.count - self.loadedMessageCounter - 1    //15 11 3        0...3
                self.minMessageNUmber = self.maxMessageNumber - kNUMBEROFMESSAGES  //0
              
                
            }
            
           
        }
        
    }
    
    
    
    
    
    
    //MARK: -IBACTION
    @objc func backAction() {
        clearRecentCounter(chatRoomId: chatRoomId)
        removeListeners()
        navigationController?.popViewController(animated: true)
 
        
    }
    
    @objc func infoButoonPressed(){
        let madiaVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PictureCollectionViewController") as! PictureCollectionViewController
            madiaVC.allImageLinks = allPictureMessages
    
        self.navigationController?.pushViewController(madiaVC, animated: true)
        
    }
    
    @objc func showGroup(){
        
        let groupVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GroupViewController") as! GroupViewController
        
            groupVC.group = group!
            self.navigationController?.pushViewController(groupVC, animated: true)
        
    }
    
    @objc func showUserProfile(){
        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileTableViewController") as! ProfileTableViewController
        profileVC.user = withUsers.first
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    
    func presentUserProfile(forUser: FUser) {
        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileTableViewController") as! ProfileTableViewController
        profileVC.user = forUser
        self.navigationController?.pushViewController(profileVC, animated: true)
        
    }
    
    
    
    //MARK: Typing indicator
    
    
    func createTypingObserver() {
        
        typinglistener = reference(.Typing).document(chatRoomId).addSnapshotListener({ (snapShot, error) in
            
            guard let snapshot = snapShot else { return }
            
            if snapshot.exists {
                
                for data in snapshot.data() {
                    
                    if data.key != FUser.currentId() {
                        
                        let typing = data.value as! Bool
                        self.showTypingIndicator = typing
                        if typing {
                            
                            self.scrollToBottom(animated: true)
                        }
                        
                        
                    }
                    
                }
                
            }else{
                
                reference(.Typing).document(self.chatRoomId).setData([FUser.currentId():false])
            }
            
            
            
            
            
            
        })
        
        
        
    }
    
    
    func typingCounterStart(){
        typingCounter += 1
        typingCounterSave(typing: true)
        self.perform(#selector(self.typingCounterStop), with: nil, afterDelay: 2.0)
        
    }
   @objc func typingCounterStop(){
    
    typingCounter -= 1
    if typingCounter == 0 {
        typingCounterSave(typing: false)
        
    }
        
    }
    func typingCounterSave(typing:Bool){
        reference(.Typing).document(chatRoomId).updateData([FUser.currentId(): typing])
    }
    
    
    
    //MARK: UITextViewDelegate
        //觀察是否typing...
    override func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
       typingCounterStart()
        return true
    }
    
    //MARK: Location access
    
    func haveAccessToUuserLocation() -> Bool {
        
        if appDelegate.locationManager != nil {
            return true
        }else{
            ProgressHUD.showError("Please give access tp location in Settings")
            return false
            
        }
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    //MARK: UpdateUI
    
    func setCustomTitle() {
        leftBarButtonVIew.addSubview(avatarBtn)
        leftBarButtonVIew.addSubview(titileLabel)
        leftBarButtonVIew.addSubview(subtitle)
        
        let infobutton = UIBarButtonItem(image:UIImage(named: "info"), style: .plain, target: self, action: #selector(self.infoButoonPressed))
        self.navigationItem.rightBarButtonItem = infobutton
        let leftBarButtomItem = UIBarButtonItem(customView: leftBarButtonVIew)
        self.navigationItem.leftBarButtonItems?.append(leftBarButtomItem)
        
        if isGroup! {
            avatarBtn.addTarget(self, action: #selector(self.showGroup), for: .touchUpInside)
        }else{
            
             avatarBtn.addTarget(self, action: #selector(self.showUserProfile), for: .touchUpInside)
        }
        
        getUsersFromFirestore(withIds: memberids) { (withUser) in
            
            self.withUsers = withUser
            self.getAvatarImages()
            if !self.isGroup! {
                self.setUIForSingleChat()
            }
            
        }
        
    }
    
    func setUIForSingleChat() {
        
        let withUser = withUsers.first!
        imageFromData(pictureData: withUser.avatar) { (image) in
            
            if image != nil {
                avatarBtn.setImage(image!.circleMasked, for: .normal)
            }
        }
        
        titileLabel.text = withUser.fullname
        if withUser.isOnline {
            
            subtitle.text = "Online"
        }else{
            subtitle.text = "offline"
        }

    }
    
    func setUIForGroupChat(){
        imageFromData(pictureData: group![kAVATAR] as! String) { (image) in
            if image != nil {
                DispatchQueue.main.async {
                self.avatarBtn.setImage(image!.circleMasked, for: .normal)
                }
            }
        }
        
        titileLabel.text = titleName   
        titileLabel.frame = CGRect(x: 30, y: 15, width: 140, height: 15)
        
        subtitle.text = ""
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
    
    //MARK :Helper func
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {   //GOD..
        
        let video = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL
        let picture = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        sendMessage(text: nil, date: Date(), picture: picture, location: nil, video: video, audio: nil)
        picker.dismiss(animated: true, completion: nil)
        
        
    }
    func getAvatarImages() {
        
        if showAvatar {
            
            collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize(width: 30, height: 30)
            collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: 30, height: 30)
           //get currentUserAvatar
            avatarImageFrom(fUser: FUser.currentUser()!)
            
            for user in withUsers {
                
                avatarImageFrom(fUser: user)
                
            }
        }

    }
    
    func avatarImageFrom(fUser:FUser){
        if fUser.avatar != "" {
            dataImageFromString(pictureString: fUser.avatar) { (imageData) in
                
                if imageData == nil {
                    return
                }
                
                if self.avatarImageDictionary != nil {
                    //update avatar if we had one
                    self.avatarImageDictionary!.removeObject(forKey: fUser.objectId)
                    self.avatarImageDictionary!.setObject(imageData!, forKey: fUser.objectId as NSCopying)
                }else{
                    self.avatarImageDictionary = [fUser.objectId: imageData!]
                }
                //create JSQAvatars
                self.createJSQAvatars(avatarDictionary: self.avatarImageDictionary)

                
            }
        }
        
    }
    
    func createJSQAvatars(avatarDictionary: NSMutableDictionary?) {
        let defautlAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "avatarPlaceholder"), diameter: 70)
        if avatarDictionary != nil {
            
            for userid in memberids {
                
                if let avatarimageData = avatarDictionary![userid] {
                    let jsqAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(data: avatarimageData as! Data), diameter: 70)
                    self.jsqAvaTarDictionary?.setValue(jsqAvatar, forKey: userid)
                }else{
                    self.jsqAvaTarDictionary?.setValue(defautlAvatar, forKey: userid)
                    
                }
            }
            
            self.collectionView.reloadData()
        }
    }
    //MARK: HELP FUNC
    
    func addNewPictureMessageLink(like: String){
        allPictureMessages.append(like)
    }
    
    func getPictureMessages(){
        
        allPictureMessages = []
        
        for message in loadedMessage {
            
            if message[kTYPE] as! String == kPICTURE {
                allPictureMessages.append(message[kPICTURE] as! String)
            }
            
        }
    }
    
    func readTimeFrom(dateString: String) -> String {
        let date = dateFormatter().date(from: dateString)
        let currentDateFormate = dateFormatter()
        currentDateFormate.dateFormat = "HH:mm"
        
        return currentDateFormate.string(from: date!)
    }
    
    
    
    
    
    func removeBadMessages(allMessages : [NSDictionary]) -> [NSDictionary] {
        
        var tempMessages = allMessages
        
        for message in tempMessages {
            if message[kTYPE] != nil {
                
                if !self.legitTypes.contains(message[kTYPE] as! String ) {
                    
                    //remove the message
                    tempMessages.remove(at: tempMessages.index(of: message)!)
                    
                }
                
            }else{
                
                tempMessages.remove(at: tempMessages.index(of: message)!)
            }
        }
        return tempMessages
    }
    
    
    func isIncoming(messageDictionary : NSDictionary) -> Bool {
        if FUser.currentId() == messageDictionary[kSENDERID] as! String {
            return false
        }else{
            return true
        }
    }

    
    func removeListeners(){
        
        if typinglistener != nil {
            
            typinglistener!.remove()
        }
        
        if newChatListener != nil {
            newChatListener!.remove()
        }
        
        
        if updatedChatListener != nil {
            
            updatedChatListener?.remove()
        }
        
    }
    
    
    func getCurrentGroup(withId: String){
        reference(.Group).document(withId).getDocument { (snapShot, error) in
            guard let snapshot = snapShot else { return }
            
            if snapshot.exists {
                self.group = snapshot.data() as! NSDictionary
                self.setUIForGroupChat()
            }
            
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
extension ChatViewController: IQAudioRecorderViewControllerDelegate {
    func audioRecorderController(_ controller: IQAudioRecorderViewController, didFinishWithAudioAtPath filePath: String) {
         controller.dismiss(animated: true, completion: nil)
  
        self.sendMessage(text: nil, date: Date(), picture: nil, location: nil, video: nil, audio: filePath)
        
    }
    
    func audioRecorderControllerDidCancel(_ controller: IQAudioRecorderViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

}
