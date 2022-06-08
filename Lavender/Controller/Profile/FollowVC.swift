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

class FollowVC: UITableViewController {
    
    
    // MARK: Propertis
    
    var viewFollowers = false
    var uid: String?
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register cell class
        tableView.register(FollowCell.self, forCellReuseIdentifier: reuseIdentifier)
        // configure title vc
        if viewFollowers {
            navigationItem.title = "Followers"
        } else {
            navigationItem.title = "Following "
        }
        
        // clear separator tableview
        tableView.separatorColor = .clear
        
        fetchUser()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! FollowCell
        cell.delegate = self
        cell.user = users[indexPath.row]
        return cell
    }
    
    func fetchUser() {
        
        guard let uid = self.uid else { return }
        
        var ref: DatabaseReference!
        
        if viewFollowers {
            // fetch followers
            ref = USER_FOLLOWER_REF
            
        } else {
            // fetch following
            ref = USER_FOLLOWING_REF
        }
        
        ref.child(uid).observeSingleEvent(of: .value) {
            snapshot in
            
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            allObjects.forEach({ snapshot in
                let userId = snapshot.key
                Database.fetchUser(with: userId, completion: { user in
                    self.users.append(user)
                    self.tableView.reloadData()
                })
            })
        }
    }
}

extension FollowVC: FollowCellDelegate {
    func handleFollowTapped(for cell: FollowCell) {
        guard let user = cell.user else { return }
        if user.isFollowed {
            user.unfollow()
            cell.followButton.setTitle("Follow", for: .normal)
            cell.followButton.setTitleColor(.white, for: .normal)
            cell.followButton.layer.borderWidth = 0
            cell.followButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        } else {
            user.follow()
            cell.followButton.setTitle("Following", for: .normal)
            cell.followButton.setTitleColor(.black, for: .normal)
            cell.followButton.layer.borderWidth = 0.5
            cell.followButton.layer.borderColor = UIColor.lightGray.cgColor
            cell.followButton.backgroundColor = .white
        }
    }
}
