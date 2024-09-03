//
//  ConnectView.swift
//  Interest-animations
//
//  Created by Usman Tahir Qureshi on 8/12/24.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct ConnectView: View {
    @State private var email: String = ""
    @ObservedObject var viewModel = UsersViewModel()
    @State private var selectedUserId: String = ""
    @State private var isSheetPresented = false
    @State private var searchText: String = ""
    
    @Binding var presentSideMenu: Bool
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    presentSideMenu.toggle()
                } label: {
                    Image(systemName: "line.horizontal.3")
                        .resizable()
                        .frame(width: 15, height: 15)
                }
                Spacer()
            }
            .padding(.bottom, 20)

            // Search Bar
            TextField("Search Users", text: $searchText)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .onChange(of: searchText) { newValue in
                    viewModel.searchUser(query: newValue)
                }
                .padding(.bottom, 40)
            
            Spacer()

            if viewModel.users.isEmpty {
                Text("Loading users...")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.top, 20)
            } else if searchText.isEmpty {
                // Display all users when search text is empty
                List(viewModel.users) { user in
                    userRow(user: user)
                }
                .listStyle(PlainListStyle()) // Removes default list styling
                .background(Color.clear)
            } else if viewModel.filteredUsers.isEmpty {
                // Show "User not found" if no results match the search query
                Text("User not found")
                    .font(.headline)
                    .foregroundColor(.red)
                    .padding(.top, 20)
            } else {
                // Display filtered users
                List(viewModel.filteredUsers) { user in
                    userRow(user: user)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .onAppear {
            viewModel.fetchUsers() // Fetch all users on view appear
            viewModel.startListeningForRequestStatuses() // Start listening for request statuses
        }
        .onDisappear {
            viewModel.listenerRegistration?.remove() // Clean up listener when the view disappears
        }
    }
    
    // Function to build user row UI
    @ViewBuilder
    private func userRow(user: UserData) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(user.email)
                    .font(.subheadline)
                Spacer()
                Button(action: {
                    
                }) {
                    Image(systemName: "paperplane") // Replace with your desired SF Symbol
                        .font(.system(size: 15))
                }
                .onTapGesture {
                    selectedUserId = user.id!
                    
                    guard let currentUserId = Auth.auth().currentUser?.uid else {
                        print("Error: Current user ID is missing")
                        return
                    }
                    FirebaseManager.shared.sendFriendRequest(senderId: currentUserId, receiverId: selectedUserId) { result in
                        switch result {
                        case .success():
                            print("Friend request sent successfully")
                        case .failure(let error):
                            print("Error sending friend request: \(error.localizedDescription)")
                        }
                    }
                }
            }
            
            if let status = viewModel.getFriendRequestStatus(for: user.id!) {
                Text("Request Status: \(status.rawValue)")
                    .font(.caption)
                    .foregroundColor(status == .requested ? .orange : (status == .accepted ? .green : .red))
            } else {
                Text("Request Status: Not Sent")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
                            
            if let status = viewModel.getFriendRequestStatus(for: user.id!), status == .requested {
                Button(action: {
                    if let receiverId = user.id {
                        viewModel.cancelFriendRequest(to: receiverId)
                    }
                }) {
                    Text("Cancel")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle()) // Use PlainButtonStyle to avoid default button styling
            }
        }
        
    }
}
