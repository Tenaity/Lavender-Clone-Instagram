//
//  FeedVC.swift
//  Lavender
//
//  Created by Van Muoi on 5/15/22.
//

import UIKit
import Firebase
import ActiveLabel

private let reuseIdentifier = "Cell"

class FeedVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, FeedCellDelegate {
    
    // MARK: - Properties
    
    var posts = [Post]()
    var viewSinglePost = false
    var post: Post?
    var currentKey: String?
    var userProfileController: UserProfileVC?
    
    let noInternetConnectionView: SnackbarView = NoInternetConnectionView()
    
//    let noInternetConnectionView: SnackbarView = NoInternetConnectionView()
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ReachabilityHandler.shared.startListening()
    }
    
    override func viewDidLoad() {
        
        ReachabilityHandler.shared.startListening()
        ReachabilityHandler.shared.onNetworkStateChanged = { [weak self] isReachable in
            self?.handleNetworkState(isReachable: isReachable)
        }
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        
        self.collectionView!.register(FeedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        configureNavigationBar()
        
        // configure refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        // fetch posts
        if !viewSinglePost {
            fetchPosts()
        }
        
        updateUserFeeds()
    }
    
    // MARK: UICollectionViewFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        let height = width + 8 + 8 + 40 + 50 + 60
        return CGSize(width: width, height: height)
    }

    // MARK: - UICollectionViewDatasource
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if posts.count > 4 {
            if indexPath.item == posts.count - 1 {
                fetchPosts()
            }
        }
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if viewSinglePost {
            return 1
        } else {
            return posts.count
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeedCell
        if viewSinglePost {
            if let post = self.post {
                cell.post = post
            }
        } else {
            cell.post = posts[indexPath.row]
        }
        handleHashTagTapped(forCell: cell)
        handleUserNameTapped(forCell: cell)
        handleMentionTapped(forCell: cell)
        cell.delegate = self
        return cell
    }
    
    // MARK: Feed Cell Delegate
    
    func handleUserNameTapped(for cell: FeedCell) {
        guard let post = cell.post else { return }
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileVC.user = post.user
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    func handleOptionsTapped(for cell: FeedCell) {
        
        guard let post = cell.post else { return }
        
        if post.ownerUid == Auth.auth().currentUser?.uid {
            
            let alertController = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
            
            alertController.addAction(UIAlertAction(title: "Delete Post", style: .destructive, handler: { [weak self] _ in
                guard let self = self else { return }
                post.deletePost()
                
                if !self.viewSinglePost {
                    self.handleRefreshControl()
                } else {
                    
                    if let userProfileController = self.userProfileController {
                        _ = self.navigationController?.popViewController(animated: true)
                        userProfileController.handleRefreshControl()
                    }
                    
                    
                }
            }))
            
            alertController.addAction(UIAlertAction(title: "Edit Post", style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                
                let uploadPostController = UploadPostVC()
                let navigationController = UINavigationController(rootViewController: uploadPostController)
                uploadPostController.inEditMode = true
                uploadPostController.postToEdit = post
                uploadPostController.uploadAction = UploadPostVC.UploadAction(index: 1)
                navigationController.modalPresentationStyle = .overFullScreen
                self.present(navigationController, animated: true, completion: nil)
                
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(alertController, animated: true, completion: nil)
        }
        
    }
    
    func configureLikesLabel(with likes: Int, cell: FeedCell) {
        if likes > 1 {
            cell.likesLabel.text = "\(likes) likes"
        } else {
            cell.likesLabel.text = "\(likes) like"
        }
    }
    
    func handleLikeTapped(for cell: FeedCell, isDoubleTap: Bool) {
        
        guard let post = cell.post else { return }
        
        if post.didLike {
            
            // double tap again not remove the like
            if !isDoubleTap {
                post.adjustLike(addLike: false) { likes in
                    self.configureLikesLabel(with: likes, cell: cell)
                    cell.likeButton.setImage(UIImage(named: "like_unselected"), for: .normal)
                }
            }
        } else {
            // handle like post
            post.adjustLike(addLike: true) {
                likes in
                self.configureLikesLabel(with: likes, cell: cell)
                cell.likeButton.setImage(UIImage(named: "like_selected"), for: .normal)
            }
        }
    }
    
    func handleConfigureLikeButton(for cell: FeedCell) {
        guard let currentUid = Auth.auth().currentUser?.uid,
              let post = cell.post,
              let postId = post.postId
        else { return }
        
        USER_LIKES_REF.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            
            // Check if post id exists in user-like struture
            
            if snapshot.hasChild(postId) {
                post.didLike = true
                cell.likeButton.setImage(UIImage(named: "like_selected"), for: .normal)
            }
        }
        
    }
    
    func handleShowLikes(for cell: FeedCell) {
        guard let post = cell.post,
              let postId = post.postId else { return }
        let followLikeVC = FollowLikeVC()
        followLikeVC.postId = postId
        followLikeVC.viewingMode = FollowLikeVC.ViewingMode.init(index: 2)
        navigationController?.pushViewController(followLikeVC, animated: true)
    }
    
    func handleCommentTapped(for cell: FeedCell) {
        guard let post = cell.post else { return }
        let commentVC = CommentVC(collectionViewLayout: UICollectionViewFlowLayout())
        commentVC.post = post
        navigationController?.pushViewController(commentVC, animated: true)
    }
    
    
    // MARK: - Handlers
    
//    func handleNetworkState(isReachable: Bool) {
//        var content: NoInternetContent {
//            return NoInternetContent(message: "Opps, no connection")
//        }
//        guard !isReachable else {
//            noInternetConnectionView.hide()
//            return
//        }
//        noInternetConnectionView.show(content: content)
////        checkInternet()
//    }
    
    func handleHashTagTapped(forCell cell: FeedCell) {
        cell.captionLabel.handleHashtagTap { [weak self] hashTag in
            guard let self = self else { return }
            let hashtagController = HashtagController(collectionViewLayout: UICollectionViewFlowLayout())
            hashtagController.hashtag = hashTag
            self.navigationController?.pushViewController(hashtagController, animated: true)
        }
    }
    
    func handleMentionTapped(forCell cell: FeedCell) {
        cell.captionLabel.handleMentionTap { [weak self] username in
            guard let self = self else { return }
            self.getMentionedUser(withUsername: username)
        }
    }
    
    func handleUserNameTapped(forCell cell: FeedCell) {
        
        guard let user = cell.post?.user else { return }
        
        guard let username = cell.post?.user.username else { return }
        
        let customType = ActiveType.custom(pattern: "^\(username)\\b")
        
        cell.captionLabel.handleCustomTap(for: customType) { _ in
            let userProfileController = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
            userProfileController.user = user
            self.navigationController?.pushViewController(userProfileController, animated: true)
        }
    }
    
    func configureNavigationBar() {

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "send2"), style: .plain, target: self, action: #selector(handleShowMessages))
        self.navigationItem.title = "Feed"
    }
    
    @objc func handleRefreshControl() {
        ReachabilityHandler.shared.startListening()
        posts.removeAll()
        self.currentKey = nil
        fetchPosts()
        collectionView.reloadData()
    }
    
    @objc func handleShowMessages() {
        let messengeController = MessageController()
        navigationController?.pushViewController(messengeController, animated: true)
    }
    
    @objc func handleLogout() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
            do {
                try Auth.auth().signOut()
                let loginVC = LoginVC()
                let navController = UINavigationController(rootViewController: loginVC)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
            } catch {
                print("Fail to signout")
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: API
    
    func updateUserFeeds() {
        ReachabilityHandler.shared.startListening()
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        USER_FOLLOWING_REF.child(currentUid).observe(.childAdded) { snapshot in
            let followingUserId = snapshot.key
            USER_POSTS_REF.child(followingUserId).observe(.childAdded, with: { snapshot in
                let postId = snapshot.key
                USER_FEED_REF.child(currentUid).updateChildValues([postId: 1])
            })
        }
        USER_POSTS_REF.child(currentUid).observe(.childAdded, with: { snapshot in
            let postId = snapshot.key
            USER_FEED_REF.child(currentUid).updateChildValues([postId: 1])
        })
    }
    
    func fetchPosts() {

        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        if currentKey == nil {
            USER_FEED_REF.child(currentUid).queryLimited(toLast: 5).observeSingleEvent(of: .value, with: { snapshot in
                self.collectionView.refreshControl?.endRefreshing()
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot,
                      let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach { snapshot in
                    let postId = snapshot.key
                    self.fetchPost(withPostId: postId)
                }
                self.currentKey = first.key
            })
        } else {
            USER_FEED_REF.child(currentUid).queryOrderedByKey().queryEnding(atValue: self.currentKey).queryLimited(toLast: 6).observeSingleEvent(of: .value, with: { snapshot in
                guard let first = snapshot.children.allObjects.first as? DataSnapshot,
                      let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                allObjects.forEach({ snapshot in
                    let postId = snapshot.key
                    if postId != self.currentKey {
                        self.fetchPost(withPostId: postId)
                    }
                })
                self.currentKey = first.key
            })
        }
    }
    
    func fetchPost(withPostId postId: String) {
        Database.fetchPost(with: postId, completion: { post in
            self.posts.append(post)
            ReachabilityHandler.shared.startListening()
            self.posts.sort(by: { (post1, post2) -> Bool in
                return post1.creationDate > post2.creationDate
            })
            self.collectionView.reloadData()
        })
    }
    
}

private extension FeedVC {
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
