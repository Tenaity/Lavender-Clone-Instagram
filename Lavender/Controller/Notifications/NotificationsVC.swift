//
//  NotificationsVC.swift
//  Lavender
//
//  Created by Van Muoi on 5/14/22.
//

import UIKit
import Firebase

private let reuseIdentifier = "NotificationCell"

class NotificationsVC: UITableViewController, NotificationCellDelegate {
    
    // MARK: Properties
    
    var timer: Timer?
    
    var notifications = [Notification]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorColor = .clear
        
        navigationItem.title = "Notifications"
        
        tableView.register(NotificationCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        fetchNotifications()
        
    }
    
    // MARK: Table view datasource
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NotificationCell
        cell.notification = notifications[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        
        userProfileVC.user = notification.user
        
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    // MARK: Notification Delegate
    
    func handlePostTapped(for cell: NotificationCell) {
        guard let notification = cell.notification else { return }
        let feedVC = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
        feedVC.viewSinglePost = true
        feedVC.post = notification.post
        navigationController?.pushViewController(feedVC, animated: true)
    }
    
    func handleReloadTable() {
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleNotificationSorted), userInfo: nil, repeats: false)
    }
    
    @objc func handleNotificationSorted() {
        self.notifications.sorted(by: { (notification1, notification2) -> Bool in
            return notification1.creationDate > notification2.creationDate
        })
        tableView.reloadData()
    }
    
    func handleFollowTapped(for cell: NotificationCell) {
        guard let user = cell.notification?.user else { return }
        
        if user.isFollowed {
            // handle unfollow
            user.unfollow()
            cell.followButton.config(didFollow: false)
        } else {
            // handle follow
            user.follow()
            cell.followButton.config(didFollow: true)
        }
    }
    
    // MARK: API
    
    func fetchNotifications() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        NOTIFICATIONS_REF.child(currentUid).observe(.childAdded) { snapshot in
            
            let notificationID = snapshot.key
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject>,
                  let uid = dictionary["uid"] as? String else { return }
            
            Database.fetchUser(with: uid, completion: { user in
                
                // if notification is for post
                if let postId = dictionary["postId"] as? String {
                    Database.fetchPost(with: postId, completion: { post in
                        let notification = Notification(user: user, post: post, dictionary: dictionary)
                        self.notifications.append(notification)
                        self.handleReloadTable()
                    })
                } else {
                    let notification = Notification(user: user, dictionary: dictionary)
                    self.notifications.append(notification)
                    self.handleReloadTable()
                }
            })
            NOTIFICATIONS_REF.child(currentUid).child(notificationID).child("checked").setValue(1)
        }
        
    }
}
