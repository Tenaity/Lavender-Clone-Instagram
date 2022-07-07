//
//  Protocols.swift
//  Lavender
//
//  Created by Van Muoi on 6/3/22.
//

import Foundation

protocol UserProfileHeaderDelegate {
    
    func handleEditFollowTapped(for header: UserProfileHeaderCell)
    func setUserStats(for header: UserProfileHeaderCell)
    func handleFollowersTapped(for header: UserProfileHeaderCell)
    func handleFollowingTapped(for header: UserProfileHeaderCell)
}

protocol FollowCellDelegate {
    func handleFollowTapped(for cell: FollowLikeCell)
}

protocol FeedCellDelegate {
    func handleUserNameTapped(for cell: FeedCell)
    func handleOptionsTapped(for cell: FeedCell)
    func handleLikeTapped(for cell: FeedCell, isDoubleTap: Bool)
    func handleCommentTapped(for cell: FeedCell)
    func handleConfigureLikeButton(for cell: FeedCell)
    func handleShowLikes(for cell: FeedCell)
}

protocol NotificationCellDelegate {
    func handleFollowTapped(for cell: NotificationCell)
    func handlePostTapped(for cell: NotificationCell)
}

protocol Printable {
    var description: String { get }
}

protocol CommentInputAccessoryViewDelegate {
    func didSubmit(forComment comment: String)
}
