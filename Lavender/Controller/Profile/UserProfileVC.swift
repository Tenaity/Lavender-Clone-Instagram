//
//  UserProfileVC.swift
//  Lavender
//
//  Created by Van Muoi on 5/15/22.
//

import UIKit
import Firebase
import grpc

private let reuseIdentifier = "Cell"
private let headerIdentifier = "UserProfileHeader"

class UserProfileVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    // MARK: Properties
    
    var user: User?
    var posts = [Post]()
    let noInternetConnectionView: SnackbarView = NoInternetConnectionView()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ReachabilityHandler.shared.startListening()
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
        ReachabilityHandler.shared.startListening()
        ReachabilityHandler.shared.onNetworkStateChanged = { [weak self] isReachable in
            self?.handleNetworkState(isReachable: isReachable)
        }
        // Register cell classes
        self.collectionView!.register(UserPostCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView.register(UserProfileHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        // backgound color
        self.collectionView?.backgroundColor = .white
        
        configRefreshControl()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "gear"), style: .plain, target: self, action: #selector(handleLogout))
        
        // fetch user data
        if user == nil {
            fetchCurrentUserData()
        }
        // fetch posts
        fetchPosts()
    }
    
    // MARK: UICollectionViewFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    
    // MARK: UICollectionView
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let feedVC = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
        feedVC.viewSinglePost = true
        feedVC.post = posts[indexPath.row]
        feedVC.userProfileController = self
        navigationController?.pushViewController(feedVC, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UserPostCell
        cell.post = posts[indexPath.row]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        // declare header
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! UserProfileHeaderCell
        // set delegate
        header.delegate = self
        header.postCount = posts.count
        // set the user in header
        header.user = user
        navigationItem.title = user?.username
        
        return header
    }
    
    // MARK: Handlers
    
    
    @objc func handleLogout() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
            do {
                try Auth.auth().signOut()
                self.dismiss(animated: true)
                let loginVC = LoginVC()
                let navController = UINavigationController(rootViewController: loginVC)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
//                self.navigationController.remove
//                self.navigationController?.pushViewController(loginVC, animated: true)
            } catch {
                print("Fail to signout")
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func handleRefreshControl() {
        posts.removeAll()
//        self.currentKey = nil
        fetchPosts()
        collectionView.reloadData()
        self.collectionView.refreshControl?.endRefreshing()
    }
    
    func configRefreshControl() {
        // configure refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    // MARK: API
    
    func fetchPosts() {
        
        var uid: String!
        
        if let user = self.user {
            uid = user.uid
        } else {
            uid = Auth.auth().currentUser?.uid
        }
        
        USER_POSTS_REF.child(uid).observe(.childAdded) { snapshot in
            
            let postId = snapshot.key
            
            Database.fetchPost(with: postId, completion: { post in
                self.posts.append(post)
                self.posts.sort(by: { (post1, post2) -> Bool in
                    return post1.creationDate > post2.creationDate
                })
                self.collectionView.reloadData()
            })

        }
        
        
    }
    
    func fetchCurrentUserData() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("users").child(currentUid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
            let uid = snapshot.key
            let user = User(uid: uid, dictionary: dictionary)
            self.user = user
            self.navigationItem.title = user.username
            self.collectionView.reloadData()
        } )
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
    
}

extension UserProfileVC: UserProfileHeaderDelegate {
    func handleFollowersTapped(for header: UserProfileHeaderCell) {
        let vc = FollowLikeVC()
        vc.viewingMode = FollowLikeVC.ViewingMode.init(index: 1)
        vc.uid = user?.uid
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func handleFollowingTapped(for header: UserProfileHeaderCell) {
        let vc = FollowLikeVC()
        vc.viewingMode = FollowLikeVC.ViewingMode.init(index: 0)
        vc.uid = user?.uid
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func setUserStats(for header: UserProfileHeaderCell) {
        guard let uid = header.user?.uid else { return }
        var numberOfFollowers: Int!
        var numberOfFollowing: Int!
        
        // get number of followers
        USER_FOLLOWER_REF.child(uid).observe(.value) { snapshot in
            if let snapshot = snapshot.value as? Dictionary<String, AnyObject> {
                numberOfFollowers = snapshot.count
            } else {
                numberOfFollowers = 0
            }
            
            let attributedText = NSMutableAttributedString(string: "\(String(describing: numberOfFollowers!))\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
            header.followersLabel.attributedText = attributedText
        }
        
        // get number of following
        USER_FOLLOWING_REF.child(uid).observe(.value) { snapshot in
            if let snapshot = snapshot.value as? Dictionary<String, AnyObject> {
                numberOfFollowing = snapshot.count
            } else {
                numberOfFollowing = 0
            }
            let attributedText = NSMutableAttributedString(string: "\(String(describing: numberOfFollowing!))\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
            header.followingLabel.attributedText = attributedText
        }
    }
    
    
    func handleEditFollowTapped(for header: UserProfileHeaderCell) {
        guard let user = header.user else { return }

        if header.editProfileFollowButton.titleLabel?.text == "Edit Profile" {
            let editProfileController = EditProfileController()
            editProfileController.user = user
            editProfileController.userProfileController = self
            let navigationController = UINavigationController(rootViewController: editProfileController)
            
            navigationController.modalPresentationStyle = .overFullScreen
            
            self.present(navigationController, animated: true, completion: nil)
            
        }
        else {
            user.checkIfUserIsFollowed(completion: { followed in
                if followed {
                    header.editProfileFollowButton.setTitle("Follow", for: .normal)
                    user.unfollow()
                } else {
                    header.editProfileFollowButton.setTitle("Following", for: .normal)
                    user.follow()
                }
            })
        }
    }
    
}

private extension UserProfileVC {
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
