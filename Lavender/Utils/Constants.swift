//
//  Constants.swift
//  Lavender
//
//  Created by Van Muoi on 5/28/22.
//

import Firebase

let DB_REF = Database.database().reference()
 
let USER_REF = DB_REF.child("users")
 
let USER_FOLLOWER_REF = DB_REF.child("user-followers")
let USER_FOLLOWING_REF = DB_REF.child("user-following")
