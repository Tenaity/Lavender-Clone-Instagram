//
//  User.swift
//  Lavender
//
//  Created by Van Muoi on 5/20/22.
//

class User {
    // attributes
    var username: String!
    var name: String!
    var profileImage: String!
    var uid: String!
    
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
}
