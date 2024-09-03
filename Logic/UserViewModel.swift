//
//  UserViewModel.swift
//  Interest-animations
//
//  Created by Usman Tahir Qureshi on 9/3/24.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

class UsersViewModel: ObservableObject {
    @Published var users: [UserData] = []
    private var db = Firestore.firestore()
    var listenerRegistration: ListenerRegistration?
    @Published var requestStatuses: [String: FriendRequestStatus] = [:] // User ID to status map
    
    init() {
        fetchUsers()
    }
    
    func fetchUsers() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("No user is currently logged in.")
            return
        }

        listenerRegistration = db.collection("users")
            .addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching users: \(error)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No documents found")
                    return
                }
                
                self.users = documents.compactMap { document -> UserData? in
                    let userData = try? document.data(as: UserData.self)
                    // Exclude the current logged-in user
                    return userData?.id != currentUserId ? userData : nil
                }
            }
    }
    
    func startListeningForRequestStatuses() {
            guard let currentUserId = Auth.auth().currentUser?.uid else { return }

            // Remove any existing listener
            listenerRegistration?.remove()

            // Listen for real-time updates to the current user document
            listenerRegistration = db.collection("users").document(currentUserId).addSnapshotListener { [weak self] documentSnapshot, error in
                if let error = error {
                    print("Error listening for document updates: \(error)")
                    return
                }
                
                guard let data = documentSnapshot?.data(),
                      let sentRequests = data["sentFriendRequests"] as? [[String: Any]] else {
                    return
                }
                
                // Create a dictionary for fast lookup
                var statuses: [String: FriendRequestStatus] = [:]
                for request in sentRequests {
                    if let receiverId = request["receiverId"] as? String,
                       let statusString = request["status"] as? String,
                       let status = FriendRequestStatus(rawValue: statusString) {
                        statuses[receiverId] = status
                    }
                }
                
                // Update the published property
                DispatchQueue.main.async {
                    self?.requestStatuses = statuses
                }
            }
        }
    
    func getFriendRequestStatus(for userId: String) -> FriendRequestStatus? {
        return requestStatuses[userId]
    }
    
    func cancelFriendRequest(to receiverId: String) {
            guard let currentUserId = Auth.auth().currentUser?.uid else { return }
            
            // Reference to the current user's document
            let userRef = db.collection("users").document(currentUserId)
            
            // Start a transaction to safely remove the request
            db.runTransaction({ (transaction, errorPointer) -> Any? in
                let userDocument: DocumentSnapshot
                do {
                    try userDocument = transaction.getDocument(userRef)
                } catch let fetchError as NSError {
                    print("Error fetching user document: \(fetchError)")
                    errorPointer?.pointee = fetchError
                    return nil
                }
                
                guard var sentRequests = userDocument.data()?["sentFriendRequests"] as? [[String: Any]] else {
                    return nil
                }
                
                // Find and remove the request
                if let index = sentRequests.firstIndex(where: { $0["receiverId"] as? String == receiverId }) {
                    sentRequests.remove(at: index)
                    transaction.updateData(["sentFriendRequests": sentRequests], forDocument: userRef)
                }
                
                return nil
            }) { (object, error) in
                if let error = error {
                    print("Error removing request: \(error)")
                } else {
                    print("Request successfully removed")
                }
            }
        }

    
    deinit {
        listenerRegistration?.remove()
    }
}
