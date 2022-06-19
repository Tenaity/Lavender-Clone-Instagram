//
//  FeedVC.swift
//  Lavender
//
//  Created by Van Muoi on 5/15/22.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class FeedVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, FeedCellDelegate {
    
    // MARK: - Properties
    
    var posts = [Post]()
    var viewSinglePost = false
    var post: Post?
    
    override func viewDidLoad() {
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
        print("----> options delegate")
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
            // handle unlike post
            
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
        guard let postId = cell.post?.postId else { return }
        let commentVC = CommentVC(collectionViewLayout: UICollectionViewFlowLayout())
        commentVC.postId = postId
        navigationController?.pushViewController(commentVC, animated: true)
    }
    
    
    // MARK: - Handlers
    
    func configureNavigationBar() {
        
        if !viewSinglePost {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "send2"), style: .plain, target: self, action: #selector(handleShowMessages))
        self.navigationItem.title = "Feed"
    }
    
    @objc func handleRefreshControl() {
        posts.removeAll()
        fetchPosts()
        collectionView.reloadData()
    }
    
    @objc func handleShowMessages() {
        print("Handle message")
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
        
        USER_FEED_REF.child(currentUid).observe(.childAdded) { snapshot in
            let postId = snapshot.key
            Database.fetchPost(with: postId, completion: { post in
                self.posts.append(post)
                self.posts.sort(by: { (post1, post2) -> Bool in
                    return post1.creationDate > post2.creationDate
                })
                
                // collectionView stop refreshing
                self.collectionView.refreshControl?.endRefreshing()
                self.collectionView.reloadData()
            })
        }
    }
}
