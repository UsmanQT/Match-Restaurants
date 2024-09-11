//
//  FriendsView.swift
//  Interest-animations
//
//  Created by Usman Tahir Qureshi on 9/3/24.
//

import Foundation
import SwiftUI

struct FriendsView: View {
    
    @ObservedObject var viewModel = UsersViewModel()
    
    @Binding var presentSideMenu: Bool
    
    var body: some View {
        VStack {
            if viewModel.friendsList.isEmpty {
                Text("No friends found.")
            } else {
                List(viewModel.friendsList, id: \.self) { friendId in
                    Text(friendId) // You can customize this to display a user's name instead of the ID
                }
            }
        }
        .onAppear {
            viewModel.fetchFriends()
        }
    }
}

