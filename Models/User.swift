//
//  User.swift
//  Interest-animations
//
//  Created by Usman Tahir Qureshi on 9/3/24.
//

import Foundation
import FirebaseFirestore
struct UserData: Identifiable, Codable {
    @DocumentID var id: String?
    var displayName: String
    var email: String
    // Add other fields as needed
}
