//
//  Post.swift
//  Lavender
//
//  Created by Van Muoi on 6/13/22.
//

import Foundation
import Firebase
import simd

class Post {
    var caption: String!
    var likes: Int!
    var imageUrl: String!
    var ownerUid: String!
    var creationDate: Date!
    var postId: String!
    var user: User!
    var didLike = false
    
    init(postId: String, user: User, dictionary: Dictionary<String, AnyObject>) {
        
        self.postId = postId
        
        self.user = user
        
        if let caption = dictionary["caption"] as? String {
            self.caption = caption
        }
        
        if let likes = dictionary["likes"] as? Int {
            self.likes = likes
        }
        
        if let imageUrl = dictionary["imageUrl"] as? String {
            self.imageUrl = imageUrl
        }
        
        if let ownerUid = dictionary["ownerUid"] as? String {
            self.ownerUid = ownerUid
        }
        
        if let creationDate = dictionary["creationDate"] as? Double {
            self.creationDate = Date(timeIntervalSince1970: TimeInterval(creationDate))
        }
    }
    
    func adjustLike(addLike: Bool, completion: @escaping (Int) ->()) {
        
        guard let currentUid = Auth.auth().currentUser?.uid, let postId = postId else { return }
        
        if addLike {
            // update user-likes structures
            USER_LIKES_REF.child(currentUid).updateChildValues([postId: 1])
            
            // update post-likes structures
            POST_LIKES_REF.child(self.postId).updateChildValues([currentUid: 1]) {
                (err, ref) in
                self.likes = self.likes + 1
                self.didLike = true
                completion(self.likes)
                POSTS_REF.child(self.postId).child("likes").setValue(self.likes)
            }
            
            
            
        } else {
            // remove user-likes structures
            USER_LIKES_REF.child(currentUid).child(self.postId).removeValue()
            
            // remove post-likes structures
            POST_LIKES_REF.child(self.postId).child(currentUid).removeValue() {
                (err, ref) in
                guard self.likes > 0 else { return }
                self.likes = self.likes - 1
                self.didLike = false
                completion(self.likes)
                POSTS_REF.child(self.postId).child("likes").setValue(self.likes)
            }
        }
        
    }
}
