//
//  Message.swift
//  Lavender
//
//  Created by Van Muoi on 6/30/22.
//

import Foundation
import Firebase

class Message {
    var messageText: String!
    var fromId: String!
    var toId: String!
    var creatitonDate: Date!
    
    init(dictionary: Dictionary<String, AnyObject>) {
        if let messageText = dictionary["messageText"] as? String {
            self.messageText = messageText
        }
        
        if let fromId = dictionary["fromId"] as? String {
            self.fromId = fromId
        }
        
        if let toId = dictionary["toId"] as? String {
            self.toId = toId
        }
        
        if let creatitonDate = dictionary["creatitonDate"] as? Double {
            self.creatitonDate = Date(timeIntervalSince1970: creatitonDate)
        }
    }
    
    func getChatPartnerId() -> String {
        guard let currentUid = Auth.auth().currentUser?.uid else { return "" }
        
        if fromId == currentUid {
            return toId
        } else {
            return fromId
        }
    }
    
}
