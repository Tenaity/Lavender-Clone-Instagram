//
//  FollowVC.swift
//  Lavender
//
//  Created by Van Muoi on 6/4/22.
//

import Foundation
import UIKit
import Firebase

private let reuseIdentifier: String = "FollowCell"

class FollowLikeVC: UITableViewController {
    
    
    // MARK: Propertis
    
    enum ViewingMode: Int {
        
        case Following
        case Followers
        case Likes
        
        init(index: Int) {
            switch index {
            case 0: self = .Following
            case 1: self = .Followers
            case 2: self = .Likes
            default: self = .Following
            }
        }
    }
    
    var postId: String?
    var viewFollowers = false
    var uid: String?
    var users = [User]()
    var viewingMode: ViewingMode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register cell class
        tableView.register(FollowLikeCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        // configure title vc
        configureNavigationTitle(with: viewingMode)
        // fetch User
        fetchUsers()

        // clear separator tableview
        tableView.separatorColor = .clear
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let user = users[indexPath.row]
        let vc = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        vc.user = user
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! FollowLikeCell
        cell.delegate = self
        cell.user = users[indexPath.row]
        return cell
    }
    
    // MARK: Handle
    
    func configureNavigationTitle(with viewingMode: ViewingMode) {
        switch viewingMode {
        case .Following:
            navigationItem.title = "Following"
        case .Followers:
            navigationItem.title = "Followers"
        case .Likes:
            navigationItem.title = "Likes"
        }
    }
    
    // MARK: API
    
    func getDatabaseReference() -> DatabaseReference? {
        
        guard let viewingMode = self.viewingMode else { return nil }
        
        switch viewingMode {
        case .Following:
            return USER_FOLLOWING_REF
        case .Followers:
            return USER_FOLLOWER_REF
        case .Likes:
            return POST_LIKES_REF
        }
    }
    
    func fetchUser(with uid: String) {
        Database.fetchUser(with: uid, completion: { user in
            self.users.append(user)
            self.tableView.reloadData()
        })
    }
    
    func fetchUsers() {

        guard let ref = getDatabaseReference(),
              let viewingMode = self.viewingMode else { return }

        switch viewingMode {
            
        case .Followers, .Following:
            guard let uid = self.uid else { return }
            
            ref.child(uid).observeSingleEvent(of: .value) {
                snapshot in
                
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach({ snapshot in
                    let userId = snapshot.key
                    self.fetchUser(with: userId)
                    
                })
            }
        case .Likes:
            guard let postId = self.postId else { return }
            
            ref.child(postId).observe(.childAdded) {
                snapshot in
                let uid = snapshot.key
                self.fetchUser(with: uid)
            }
        }
    }
}

extension FollowLikeVC: FollowCellDelegate {
    func handleFollowTapped(for cell: FollowLikeCell) {
        guard let user = cell.user else { return }
        if user.isFollowed {
            user.unfollow()
            cell.followButton.setTitle("Follow", for: .normal)
            cell.followButton.setTitleColor(.white, for: .normal)
            cell.followButton.layer.borderWidth = 0
            cell.followButton.backgroundColor = UIColor.rgbPrimary()
        } else {
            user.follow()
            cell.followButton.setTitle("Following", for: .normal)
            cell.followButton.setTitleColor(.black, for: .normal)
            cell.followButton.layer.borderWidth = 0.5
            cell.followButton.layer.borderColor = UIColor.rgbPrimary().cgColor
            cell.followButton.backgroundColor = .white
        }
    }
}
