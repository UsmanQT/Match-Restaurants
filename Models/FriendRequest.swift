//
//  FriendRequest.swift
//  Interest-animations
//
//  Created by Usman Tahir Qureshi on 9/3/24.
//

import Foundation
struct FriendRequest: Codable {
    var receiverId: String
    var senderId: String
    var status: FriendRequestStatus
}
