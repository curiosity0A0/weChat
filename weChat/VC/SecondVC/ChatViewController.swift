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


class ChatViewController: JSQMessagesViewController, UIGestureRecognizerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    
    var outgoingBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    var incomingBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
   
    
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
        self.navigationController?.interactivePopGestureRecognizer!.isEnabled = false
        
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
            print("kLOCATION mess tapped")
            
        case kVIDEO:
           print("video mess tapped")
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
                    outgoingMessage = OutgoingMessages(message: text, video: videoLink!, senderId: FUser.currentId(), senderName: FUser.currentUser()!.fullname, date: Date(), status: kDELIVERED, type: kVIDEO, thumNail: thumbnail as! NSData)
                    JSQSystemSoundPlayer.jsq_playMessageSentSound()
                    self.finishSendingMessage()
                    outgoingMessage?.sendMessage(chatRoomId: self.chatRoomId, messageDictionary:(outgoingMessage?.messageDictionary)!, memberIds: self.memberids, memberToPush: self.memberidsToPush)
                }
            }
            return
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
                                    //this is for picture message
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
        // get last 11 message
        reference(.Message).document(FUser.currentId()).collection(chatRoomId).order(by: kDATE, descending: true).limit(to: 11).getDocuments { (snapShot, error) in
            
            if error != nil {
                print("\(error!.localizedDescription)")
            }
            
            guard let snapshot = snapShot else {
                // initial loading is done
                self.initialLoadCompleted = true
                // listen for new cgats
                return
            }
            
            let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray ).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [NSDictionary]
            //remove bad messages
            self.loadedMessage = self.removeBadMessages(allMessages: sorted)
            
            //insert Messages
            self.insertMessages()
            self.finishReceivingMessage(animated: true)
            self.initialLoadCompleted = true
            
            print("we have message we have loaded \(self.messages.count)")
            
            //get pictureMessages
            
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
            
            //update message status
            
        }
        
        
        let message = incomingMessagee.createMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
        if message != nil {
            
            objectMessage.append(messageDictionary) //original message from firebase
            messages.append(message!) //transfer to jsqMessage from original message
        }
        
        
      return isIncoming(messageDictionary:messageDictionary)
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
          print("max: \(self.loadedMessageCounter) , minMessageNumber\(self.loadedMessage.count)")
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
                
                self.maxMessageNumber = self.loadedMessage.count - self.loadedMessageCounter - 1    //15 11 3        0...3
                self.minMessageNUmber = self.maxMessageNumber - kNUMBEROFMESSAGES  //0
              
                
            }
            
           
        }
        
    }
    
    
    
    
    
    
    //MARK: -IBACTION
    @objc func backAction() {
        
        navigationController?.popViewController(animated: true)
        
    }
    
    @objc func infoButoonPressed(){
        print("show image messages")
    }
    
    @objc func showGroup(){
           print("show Group")
    }
    
    @objc func showUserProfile(){
        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileTableViewController") as! ProfileTableViewController
        profileVC.user = withUsers.first
        self.navigationController?.pushViewController(profileVC, animated: true)
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
            //get avatars
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
    
    //MARK : -Helper func
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {   //GOD..
        
        let video = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL
        let picture = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        sendMessage(text: nil, date: Date(), picture: picture, location: nil, video: video, audio: nil)
        picker.dismiss(animated: true, completion: nil)
        
        
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
