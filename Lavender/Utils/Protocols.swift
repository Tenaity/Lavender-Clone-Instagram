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
    func handleFollowTapped(for cell: FollowCell)
}
