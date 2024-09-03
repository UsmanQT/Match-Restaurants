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
    @Published var filteredUsers: [UserData] = []
    @Published var receivedRequests: [FriendRequest] = []
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
        
        // References to the current user's document and receiver's document
        let currentUserRef = db.collection("users").document(currentUserId)
        let receiverRef = db.collection("users").document(receiverId)
        
        // Start a transaction to safely remove the request from both users
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            // Fetch current user's document
            let currentUserDocument: DocumentSnapshot
            do {
                try currentUserDocument = transaction.getDocument(currentUserRef)
            } catch let fetchError as NSError {
                print("Error fetching current user document: \(fetchError)")
                errorPointer?.pointee = fetchError
                return nil
            }
            
            // Fetch receiver's document
            let receiverDocument: DocumentSnapshot
            do {
                try receiverDocument = transaction.getDocument(receiverRef)
            } catch let fetchError as NSError {
                print("Error fetching receiver document: \(fetchError)")
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard var sentRequests = currentUserDocument.data()?["sentFriendRequests"] as? [[String: Any]],
                  var receivedRequests = receiverDocument.data()?["receivedFriendRequest"] as? [[String: Any]] else {
                return nil
            }
            
            // Find and remove the request from the current user's sent requests
            if let index = sentRequests.firstIndex(where: { $0["receiverId"] as? String == receiverId }) {
                sentRequests.remove(at: index)
                transaction.updateData(["sentFriendRequests": sentRequests], forDocument: currentUserRef)
            }
            
            // Find and remove the request from the receiver's received requests
            if let index = receivedRequests.firstIndex(where: { $0["senderId"] as? String == currentUserId }) {
                receivedRequests.remove(at: index)
                transaction.updateData(["receivedFriendRequest": receivedRequests], forDocument: receiverRef)
            }
            
            return nil
        }) { (object, error) in
            if let error = error {
                print("Error removing request: \(error)")
            } else {
                print("Request successfully removed from both users")
            }
        }
    }
    
    func fetchReceivedFriendRequests() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let userRef = db.collection("users").document(currentUserId)
        
        userRef.getDocument { [weak self] (document, error) in
            if let document = document, document.exists {
                do {
                    if let data = document.data(),
                       let receivedRequestsData = data["receivedFriendRequest"] as? [[String: Any]] {
                        let decoder = JSONDecoder()
                        self?.receivedRequests = try receivedRequestsData.map {
                            try decoder.decode(FriendRequest.self, from: JSONSerialization.data(withJSONObject: $0))
                        }
                    }
                } catch {
                    print("Error decoding friend requests: \(error)")
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func searchUser(query: String) {
        if query.isEmpty {
            filteredUsers = users
        } else {
            filteredUsers = users.filter { user in
                user.email.lowercased().contains(query.lowercased()) ||
                user.displayName.lowercased().contains(query.lowercased())
            }
        }
    }


    
    deinit {
        listenerRegistration?.remove()
    }
}
