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
    @State private var selectedUserId: String? = nil
    @State private var isSheetPresented = false
    @State private var searchText: String = ""
    @State private var isOverlayRespondVisible = false
    @State private var userFriendStatus: [String: Bool] = [:]
    
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
            viewModel.fetchReceivedFriendRequests() // Fetch received friend requests
            viewModel.fetchUsers() // Fetch all users on view appear
            viewModel.fetchFriends()
            viewModel.startListeningForRequestStatuses() // Start listening for request statuses
        }
        .onDisappear {
            viewModel.listenerRegistration?.remove() // Clean up listener when the view disappears
        }
    }
    
    @ViewBuilder
    private func userRow(user: UserData) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(user.email)
                    .font(.subheadline)
                Spacer()
                
                if let userId = user.id, viewModel.friendsList.contains(userId) {
                    Text("Friends")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                else if viewModel.receivedRequests.contains(where: { $0.senderId == user.id }) {
                    HStack{
                        Button(action: {
                            // Toggle dropdown for this specific user
                            selectedUserId = (selectedUserId == user.id) ? nil : user.id
                        }) {
                            Text("Respond  ↓")
                                .font(.system(size: 15))
                        }
                        .buttonStyle(PlainButtonStyle()) // Use PlainButtonStyle to avoid default button styling
                        
                    }
                    
                } else {
                    Button(action: {
                        // Handle sending friend request here
                        selectedUserId = user.id!
                        print(user.displayName)
                        guard let currentUserId = Auth.auth().currentUser?.uid else {
                            print("Error: Current user ID is missing")
                            return
                        }
                        FirebaseManager.shared.sendFriendRequest(senderId: currentUserId, receiverId: selectedUserId!) { result in
                            switch result {
                            case .success():
                                print("Friend request sent successfully")
                            case .failure(let error):
                                print("Error sending friend request: \(error.localizedDescription)")
                            }
                        }
                    }) {
                        Image(systemName: "paperplane") // Replace with your desired SF Symbol
                            .font(.system(size: 15))
                    }
                }
            }

            // Displaying friend request status
            if let status = viewModel.getFriendRequestStatus(for: user.id!) {
                Text("Request Status: \(status.rawValue)")
                    .font(.caption)
                    .foregroundColor(status == .requested ? .orange : (status == .accepted ? .green : .red))
            } else {
                Text("Request Status: Not Sent")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            // Optionally add a cancel button for sent friend requests
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
            

            // Show dropdown for the selected user
            if selectedUserId == user.id {
                HStack {
                    Spacer()
                    VStack(spacing: 0) {
                        Button(action: {
                            // Handle accept action
                            guard let currentUserId = Auth.auth().currentUser?.uid else {
                                print("Error: Current user ID is missing")
                                return
                            }
                            FirebaseManager.shared.acceptFriendRequest(senderId: selectedUserId!, receiverId: currentUserId) { result in
                                switch result {
                                case .success():
                                    print("Friend request accepted successfully")
                                    // Perform any additional actions on success, like updating the UI or notifying the user
                                case .failure(let error):
                                    print("Error accepting friend request: \(error.localizedDescription)")
                                    // Handle the error, maybe show an alert to the user or log the error
                                }
                            }

                            selectedUserId = nil // Close dropdown after accepting
                        }) {
                            Text("Accept")
                                .font(.system(size: 14))
                                .frame(maxWidth: .infinity, minHeight: 30) // Set minimum height
                                .padding(.horizontal, 10) // Decrease horizontal padding
                                .background(Color.green)
                                .foregroundColor(.white)
                        }
                        Button(action: {
                            // Handle reject action
                            //viewModel.rejectFriendRequest(from: user.id!)
                            selectedUserId = nil // Close dropdown after rejecting
                        }) {
                            Text("Reject")
                                .font(.system(size: 14))
                                .frame(maxWidth: .infinity, minHeight: 30) // Set minimum height
                                .padding(.horizontal, 10) // Decrease horizontal padding
                                .background(Color.red)
                                .foregroundColor(.white)
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(8)
                    .frame(width: 100) // Adjust width as needed
                    .padding(.top, 5) // Padding to separate from "Respond" button
                    .transition(.opacity)
                    .zIndex(1) // Ensure dropdown appears above other content
                }
                }
                
        }
        .background(Color.clear.contentShape(Rectangle()).onTapGesture {
            // Close dropdown if tapped outside
            if selectedUserId == user.id {
                selectedUserId = nil
            }
        })
    }

}

struct SmallWhiteContainer: View {
    @Binding var isVisible: Bool

    var body: some View {
        VStack {
            HStack{
                Button("Accept") {}
                    .buttonStyle(DefaultButtonStyle())
                Button("Reject") {}
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .frame(width: 200, height: 100) // Adjust the height here
    }
}
