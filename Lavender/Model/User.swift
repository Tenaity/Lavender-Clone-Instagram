//
//  User.swift
//  Lavender
//
//  Created by Van Muoi on 5/20/22.
//


import Firebase

class User {
    // attributes
    var username: String!
    var name: String!
    var profileImage: String!
    var uid: String!
    var isFollowed = false
    
    init(uid: String, dictionary: Dictionary<String, AnyObject>) {
        self.uid = uid
        if let username = dictionary["username"] as? String {
            self.username = username
        }
        if let name = dictionary["name"] as? String {
            self.name = name
        }
        if let profileImage = dictionary["profileImageUrl"] as? String {
            self.profileImage = profileImage
        }
    }
    
    func follow(){
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        guard let uid = uid else { return }
        
        isFollowed = true
     
        // add followed user to current user-following structure
        USER_FOLLOWING_REF.child(currentUid).updateChildValues([uid: 1])
     
        // add current user to followed user-follower structure
        USER_FOLLOWER_REF.child(self.uid).updateChildValues([currentUid: 1])
        
        // add followed user posts to current user feed
        USER_POSTS_REF.child(self.uid).observe(.childAdded, with: { snapshot in
            let postId = snapshot.key
            USER_FEED_REF.child(currentUid).updateChildValues([postId: 1])
        })
    }
    
    func unfollow(){
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        guard let uid = uid else { return }
        
        isFollowed = false
     
        // remove followed user to current user-following structure
        USER_FOLLOWING_REF.child(currentUid).child(uid).removeValue()
     
        // remove current user to followed user-follower structure
        USER_FOLLOWER_REF.child(self.uid).child(currentUid).removeValue()
        
        // reomve followed user posts to current user feed
        USER_POSTS_REF.child(self.uid).observe(.childAdded, with: { snapshot in
            let postId = snapshot.key
            USER_FEED_REF.child(currentUid).child(postId).removeValue()
        })
    }
    
    func checkIfUserIsFollowed(completion: @escaping(Bool) -> ()) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        USER_FOLLOWING_REF.child(currentUid).observeSingleEvent(of: .value) { snapshot in
            if snapshot.hasChild(self.uid) {
                
                self.isFollowed = true
                completion(true)
            } else {
                self.isFollowed = false
                completion(false)
            }
        }
    }
}
