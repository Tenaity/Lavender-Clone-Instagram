//
//  ChatController.swift
//  Lavender
//
//  Created by Van Muoi on 6/30/22.
//

import Foundation
import UIKit
import Firebase

private let reuseIdentifer = "ChatCell"

class ChatController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: Properties
    
    var user: User?
    var messages = [Message]()
    
    lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.frame = CGRect(x:0, y:0, width: 100, height: 55)
        containerView.addSubview(sendButton)
        sendButton.anchor(top: nil, left: nil, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 50, height: 0)
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        containerView.addSubview(messageTextField)
        messageTextField.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: sendButton.leftAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 4, width: 0, height: 0)
        
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        containerView.addSubview(separatorView)
        separatorView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        return containerView
    }()
    
    let messageTextField: UITextField = {
       let tf = UITextField()
        tf.placeholder = "Enter message..."
        return tf
    }()
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return button
    }()
    
    
    // MARK: Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.backgroundColor = .white
        
        collectionView.register(ChatCell.self, forCellWithReuseIdentifier: reuseIdentifer)
        
        configNavigationBar()
        
        observeMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: UICollectionView
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        let message = messages[indexPath.row]
        
        height = estimateFrameForText(message.messageText).height + 20
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifer, for: indexPath) as! ChatCell
        cell.message = messages[indexPath.row]
        configMessage(cell: cell, message: messages[indexPath.row])
        return cell
    }
    
    // MARK: Handle
    
    // wrapcontent textfield
    func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    @objc func handleSend() {
        uploadMessageToServer()
        messageTextField.text = nil
    }
    
    func configMessage(cell: ChatCell, message: Message) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        cell.bubbleWidthAnchor?.constant = estimateFrameForText(message.messageText).width + 32
        cell.frame.size.height = estimateFrameForText(message.messageText).height + 20
        
        if message.fromId == currentUid {
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.bubbleView.backgroundColor = UIColor.rgbPrimary()
            cell.textView.textColor = .white
            cell.profileImageView.isHidden = true
        } else {
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.bubbleView.backgroundColor = UIColor.rgbNormal()
            cell.textView.textColor = .black
            cell.profileImageView.isHidden = false
        }
    }
    
    @objc func handleInfoTapped() {
        let userProfileController = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileController.user = user
        navigationController?.pushViewController(userProfileController, animated: true)
    }
    
    func configNavigationBar() {
        guard let user = self.user else { return }
        
        navigationItem.title = user.username
        
        let infoButton = UIButton(type: .infoLight)
        infoButton.tintColor = .black
        infoButton.addTarget(self, action: #selector(handleInfoTapped), for: .touchUpInside)
        let infoBarButtonItem = UIBarButtonItem(customView: infoButton)
        
        navigationItem.rightBarButtonItem = infoBarButtonItem
    }
    
    // MARK: API
    
    func uploadMessageToServer() {
        guard let messageText = messageTextField.text,
        let currentUid = Auth.auth().currentUser?.uid,
        let userUid = self.user?.uid else { return }
        
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        let messageValues = ["creatitonDate": creationDate,
                             "fromId": currentUid,
                             "toId": userUid,
                             "messageText": messageText] as [String: Any]
        
        let messageRef = MESSAGES_REF.childByAutoId()
        
        print("----> user \(userUid)")
        
        messageRef.updateChildValues(messageValues)
        
        
        
        USER_MESSAGES_REF.child(currentUid).child(userUid).updateChildValues([messageRef.key!: 1])
        
        USER_MESSAGES_REF.child(userUid).child(currentUid).updateChildValues([messageRef.key!: 1])
    }
    
    func observeMessages() {
        guard let currentUid = Auth.auth().currentUser?.uid,
            let chatPartnerId = self.user?.uid else { return }
        
        USER_MESSAGES_REF.child(currentUid).child(chatPartnerId).observe(.childAdded) { snapshot in
            
            let messageId = snapshot.key
            
            self.fetchMessage(withMessageId: messageId)
        }
    }
    
    func fetchMessage(withMessageId messageId: String) {
        MESSAGES_REF.child(messageId).observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
            let message = Message(dictionary: dictionary)
            self.messages.append(message)
            self.collectionView.reloadData()
        }
    }
    
}
