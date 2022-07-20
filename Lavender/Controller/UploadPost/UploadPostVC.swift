//
//  UploadPostVC.swift
//  Lavender
//
//  Created by Van Muoi on 5/14/22.
//

import UIKit
import Firebase

class UploadPostVC: UIViewController, UITextViewDelegate {
    
    // MARK: Properties
    let noInternetConnectionView: SnackbarView = NoInternetConnectionView()
    
    enum UploadAction: Int {
        case UploadPost
        case SaveChanges
        
        init(index: Int) {
            switch index {
            case 0: self = .UploadPost
            case 1: self = .SaveChanges
            default: self = .UploadPost
            }
        }
    }
    
    var uploadAction: UploadAction!
    var selectedImage: UIImage?
    var inEditMode = false
    var postToEdit: Post?
    
    let photoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    let captionTextView: UITextView = {
       let tv = UITextView()
        tv.font = UIFont.boldSystemFont(ofSize: 12)
        
        return tv
    }()
    
    let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.rgbNormal()
        button.setTitle("Share", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleUploadAction), for: .touchUpInside)
       return button
    }()
    
    // MARK: UITextView
    
    func textViewDidChange(_ textView: UITextView) {
        guard !textView.text.isEmpty else {
            actionButton.isEnabled = false
            actionButton.backgroundColor = UIColor.rgbNormal()
            return
        }
        actionButton.isEnabled = true
        actionButton.backgroundColor = UIColor.rgbPrimary()
    }

    // MARK: Handlerfi
    
    @objc func dismissEditVC() {
        dismiss(animated: true, completion: nil)
    }
    
    func updateUserFeeds(with postId: String) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // database value
        let values = [postId: 1]
        
        // update follower feeds
        USER_FOLLOWER_REF.child(currentUid).observe(.childAdded) { snapshot in
            let followerUid = snapshot.key
            USER_FEED_REF.child(followerUid).updateChildValues(values)
            
        }
        
        // update current feeds
        USER_FEED_REF.child(currentUid).updateChildValues(values)
    }
    
    func checkInternet() {
        
        DispatchQueue.main.async {
            if InternetConnectionManager.isConnectedToNetwork(){
                print("Connected")
            }else{
                print("Not Connected")
                // Create new Alert
                var dialogMessage = UIAlertController(title: "Opps, no connection", message: "You should connect internet!", preferredStyle: .alert)
                
                // Create OK button with action handler
                let openWifi = UIAlertAction(title: "Open wifi", style: .default, handler: { (action) -> Void in
                    if let url = URL(string: "App-Prefs:root=WIFI") {
                        if UIApplication.shared.canOpenURL(url) {
                           let url =  UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                 })
                
                let cancelButton = UIAlertAction(title: "Cancel", style: .default, handler: { (action) -> Void in
                    print("Cancel button tapped")
                })
                
                //Add OK button to a dialog message
                dialogMessage.addAction(openWifi)
                
                dialogMessage.addAction(cancelButton)
                // Present Alert to
                self.present(dialogMessage, animated: true, completion: nil)
            }
        }
    }
    
    func handleUploadPost() {

        guard let caption = captionTextView.text,
              let postImg = photoImageView.image,
              let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let captionLow = caption.lowercased()
        
        let arr = ["sex", "xxx", "cac", "lon", "pussy", "dick", "dit", "fuck", "du", "chich"]
        
        var newCaption = ""
        
        arr.forEach { item in
            if captionLow.contains(item) {
               newCaption = captionLow.replacingOccurrences(of: item, with: "**")
            }
        }
        
        if newCaption.isEmpty {
            newCaption = captionLow
        }
        
        // image upload data
        guard let uploadData = postImg.jpegData(compressionQuality:0.5) else { return }
        
        // creation date
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        // update storage
        let filename = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("post_images").child(filename)
        storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
            
            // handle error
            if let error = error {
                print("----> Failed to upload image to storage with error", error.localizedDescription)
                return
            }
            
            // image url
            storageRef.downloadURL(completion: { [weak self] (url, err) in
                
                guard let self = self else { return }
                guard let downloadURL = url else {
                    print("an error ocured")
                    return
                }
                
                let downloadURLString = downloadURL.absoluteString
                
                let values = ["caption": newCaption,
                             "creationDate": creationDate,
                             "likes": 0,
                             "imageUrl": downloadURLString,
                             "ownerUid": currentUid] as [String: AnyObject]
                
                let postId = POSTS_REF.childByAutoId()
                guard let postKey = postId.key else { return }
                // upload information to database
                postId.updateChildValues(values, withCompletionBlock: { (err, ref) in
                    
                    // update information to database
                    USER_POSTS_REF.child(currentUid).updateChildValues([postKey: 1])
                    
                    // update user-feed
                    self.updateUserFeeds(with: postKey)
                    
                    // upload hashtag to server
                    self.uploadHashtagToServer(withPostId: postKey)
                    
                    // upload mention notification to server
                    if caption.contains("@") {
                        self.uploadMentionNotification(forPostId: postKey, withText: caption, isForComment: false)
                    }
                    
                    // return to home feed
                    self.dismiss(animated: true, completion: {
                        self.tabBarController?.selectedIndex = 0
                    })
                })
            })
                
        }
    }
    
    func handleSaveChanges() {
        guard let postId = self.postToEdit?.postId else { return }
        let updatedCaption = captionTextView.text
        
        uploadHashtagToServer(withPostId: postId)
        
        POSTS_REF.child(postId).child("caption").setValue(updatedCaption, withCompletionBlock: { [weak self] _,_  in
            guard let self = self else { return }
            self.dismiss(animated: true, completion: nil)
        })
        
        
    }
    
    func buttonSelector(uploadAction: UploadAction) {
        switch uploadAction {
        case .UploadPost:
            handleUploadPost()
        case .SaveChanges:
            handleSaveChanges()
        }
    }
    
    @objc func handleUploadAction() {
        buttonSelector(uploadAction: uploadAction)
    }
    
    // MARK: Init

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ReachabilityHandler.shared.startListening()
        ReachabilityHandler.shared.onNetworkStateChanged = { [weak self] isReachable in
            self?.handleNetworkState(isReachable: isReachable)
        }
        
        view.backgroundColor = .white
        // configure view
        configureViewComponents()
        
        // text view delegate
        captionTextView.delegate = self
        // load image
        loadImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ReachabilityHandler.shared.startListening()
        if uploadAction == .SaveChanges {
            configLoadContentEditPost()
        } else {
            actionButton.setTitle("Share", for: .normal)
            navigationItem.title = "Upload Post"
        }
    }
    
    func configLoadContentEditPost() {
        guard let post = postToEdit else { return }
        photoImageView.loadImage(with: post.imageUrl)
        captionTextView.text = post.caption
        actionButton.setTitle("Save changes", for: .normal)
        navigationItem.title = "Edit"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissEditVC))
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    func configureViewComponents() {
        view.addSubview(photoImageView)
        photoImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 92, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        
        view.addSubview(captionTextView)
        captionTextView.anchor(top: view.topAnchor, left: photoImageView.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 92, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 100)
        
        view.addSubview(actionButton)
        actionButton.anchor(top: photoImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 24, paddingBottom: 0, paddingRight: 24, width: 0, height: 40)
    }
    
    func loadImage() {
        guard let selectedImage = selectedImage else {
            return
        }
        photoImageView.image = selectedImage
    }
    
    // MARK: API
    
    func uploadHashtagToServer(withPostId postId: String) {
        guard let caption = captionTextView.text else { return }
        
        let words: [String] = caption.components(separatedBy: .whitespacesAndNewlines)
        
        for var word in words {
            if word.hasPrefix("#") {
                word = word.trimmingCharacters(in: .punctuationCharacters)
                word = word.trimmingCharacters(in: .symbols)
                
                let hashtagValues = [postId: 1]
                
                HASHTAG_POST_REF.child(word.lowercased()).updateChildValues(hashtagValues)
            }
        }
    }

}

private extension UploadPostVC {
    func handleNetworkState(isReachable: Bool) {
        var content: NoInternetContent {
            return NoInternetContent(message: "Opps, no connection")
        }
        guard !isReachable else {
            noInternetConnectionView.hide()
            return
        }
        noInternetConnectionView.show(content: content)
        checkInternet()
    }
}

