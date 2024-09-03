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
    @State private var selectedUserEmail: String = ""
    @State private var selectedUserId: String = ""
    
    @Binding var presentSideMenu: Bool
    
    var body: some View {
        VStack{
            HStack{
                Button{
                    presentSideMenu.toggle()
                } label: {
                    Image(systemName: "line.horizontal.3")
                        .resizable()
                        .frame(width: 15, height: 15)
                }
                Spacer()
            }
            
            Spacer()
            Text("Add people")
            TextField("Email", text: selectedUserEmail.isEmpty ? $email: $selectedUserEmail)
                .modifier(InputField())
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            Button("Send Invitation") {
                guard let currentUserId = Auth.auth().currentUser?.uid else {
                    print("Error: Current user ID is missing")
                    return
                }
                FirebaseManager.shared.sendFriendRequest(senderId: currentUserId, receiverId: selectedUserId) {result in
                    switch result {
                    case .success():
                        print("Friend request sent successfully")
                    case .failure(let error):
                        print("Error sending friend request: \(error.localizedDescription)")
                    }
                }
            }
            .disabled(selectedUserEmail.isEmpty && email.isEmpty ? true : false)
            .buttonStyle(ActionButton(backgroundColor: selectedUserEmail.isEmpty && email.isEmpty ? Color.gray : Color.green, textColor: Color.white, borderColor: selectedUserEmail.isEmpty && email.isEmpty ? Color.gray : Color.green))
            .padding(.bottom, 10)
            Spacer()
            List(viewModel.users) { user in
                VStack(alignment: .leading) {
                    Text(user.email)
                        .font(.subheadline)
                    
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
                .contentShape(Rectangle())
                .onTapGesture {
                    // Update the text field when a user is tapped
                    selectedUserEmail = user.email
                    selectedUserId = user.id!
                }
            }
            .onAppear {
                        viewModel.startListeningForRequestStatuses() // Start listening for real-time updates
                    }
            .onDisappear {
                viewModel.listenerRegistration?.remove() // Clean up the listener when the view disappears
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

