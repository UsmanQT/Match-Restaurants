//
//  FirebaseManager.swift
//  Interest-animations
//
//  Created by Usman Tahir Qureshi on 8/8/24.
//

import Foundation
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class FirebaseManager {
    static let shared = FirebaseManager()
    
    internal init() {
        // Initialize Firebase if needed
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }

    
    func login(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error signing in:", error.localizedDescription)
                completion(.failure(error))
            } else if authResult?.user != nil {
                print("Success")
                completion(.success(()))
            }
        }
    }
    
    func signUp(email: String, password: String, username: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error signing up:", error.localizedDescription)
                completion(.failure(error))
            } else if let authResult = authResult {
                let userId = authResult.user.uid
                
                // Create a User model instance
                let user = UserData(id: userId, displayName: username, email: email)
                
                do {
                    // Add the user data to Firestore using the User model
                    try Firestore.firestore().collection("users").document(userId).setData(from: user) { error in
                        if let error = error {
                            print("Error creating user document:", error.localizedDescription)
                            completion(.failure(error))
                        } else {
                            print("User signed up and document created successfully")
                            completion(.success(()))
                        }
                    }
                } catch let error {
                    print("Error encoding user data: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
    }
    
    func sendFriendRequest(senderId: String, receiverId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let friendRequest = FriendRequest(receiverId: receiverId, senderId: senderId, status: .requested)
        
        let db = Firestore.firestore()
        
        // Reference to the sender's document
        let senderRef = db.collection("users").document(senderId)
        
        // Reference to the receiver's document
        let receiverRef = db.collection("users").document(receiverId)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let senderDocument: DocumentSnapshot
            let receiverDocument: DocumentSnapshot
            
            do {
                // Fetch sender's document
                senderDocument = try transaction.getDocument(senderRef)
                // Fetch receiver's document
                receiverDocument = try transaction.getDocument(receiverRef)
            } catch {
                print("Error fetching documents: \(error.localizedDescription)")
                completion(.failure(error))
                return nil
            }
            
            // Add the friend request to the sender's sentFriendRequests
            var senderData = senderDocument.data() ?? [:]
            var sentRequests = (senderData["sentFriendRequests"] as? [[String: Any]]) ?? []
            sentRequests.append([
                "receiverId": receiverId,
                "senderId": senderId,
                "status": FriendRequestStatus.requested.rawValue
            ])
            senderData["sentFriendRequests"] = sentRequests
            
            // Add the friend request to the receiver's receivedFriendRequests
            var receiverData = receiverDocument.data() ?? [:]
            var receivedRequests = (receiverData["receivedFriendRequests"] as? [[String: Any]]) ?? []
            receivedRequests.append([
                "receiverId": receiverId,
                "senderId": senderId,
                "status": FriendRequestStatus.requested.rawValue
            ])
            receiverData["receivedFriendRequests"] = receivedRequests
            
            // Update the documents with the new friend request
            transaction.updateData(["sentFriendRequests": sentRequests], forDocument: senderRef)
            transaction.updateData(["receivedFriendRequests": receivedRequests], forDocument: receiverRef)
            
            return nil
        }) { (result, error) in
            if let error = error {
                print("Error sending friend request: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("Friend request sent successfully")
                completion(.success(()))
            }
        }
    }
    
    func acceptFriendRequest(senderId: String, receiverId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()

        // Reference to the sender's document
        let senderRef = db.collection("users").document(senderId)
        
        // Reference to the receiver's document
        let receiverRef = db.collection("users").document(receiverId)

        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let senderDocument: DocumentSnapshot
            let receiverDocument: DocumentSnapshot
            
            do {
                // Fetch sender's document
                senderDocument = try transaction.getDocument(senderRef)
                // Fetch receiver's document
                receiverDocument = try transaction.getDocument(receiverRef)
            } catch {
                print("Error fetching documents: \(error.localizedDescription)")
                completion(.failure(error))
                return nil
            }
            
            // Update friend request status
            var senderData = senderDocument.data() ?? [:]
            var sentRequests = (senderData["sentFriendRequests"] as? [[String: Any]]) ?? []
            if let index = sentRequests.firstIndex(where: { $0["receiverId"] as? String == receiverId }) {
                sentRequests[index]["status"] = FriendRequestStatus.accepted.rawValue
            }
            senderData["sentFriendRequests"] = sentRequests
            
            var receiverData = receiverDocument.data() ?? [:]
            var receivedRequests = (receiverData["receivedFriendRequests"] as? [[String: Any]]) ?? []
            if let index = receivedRequests.firstIndex(where: { $0["senderId"] as? String == senderId }) {
                receivedRequests[index]["status"] = FriendRequestStatus.accepted.rawValue
            }
            receiverData["receivedFriendRequests"] = receivedRequests
            
            // Remove the friend request from both lists
            senderData["sentFriendRequests"] = sentRequests.filter { $0["receiverId"] as? String != receiverId }
            receiverData["receivedFriendRequests"] = receivedRequests.filter { $0["senderId"] as? String != senderId }
            
            // Add both users to each other's friends list
            var senderFriends = (senderData["friends"] as? [String]) ?? []
            if !senderFriends.contains(receiverId) {
                senderFriends.append(receiverId)
            }
            senderData["friends"] = senderFriends
            
            var receiverFriends = (receiverData["friends"] as? [String]) ?? []
            if !receiverFriends.contains(senderId) {
                receiverFriends.append(senderId)
            }
            receiverData["friends"] = receiverFriends
            
            // Update the documents
            transaction.updateData(["sentFriendRequests": senderData["sentFriendRequests"] as! [[String: Any]]], forDocument: senderRef)
            transaction.updateData(["receivedFriendRequests": receiverData["receivedFriendRequests"] as! [[String: Any]]], forDocument: receiverRef)
            transaction.updateData(["friends": senderFriends], forDocument: senderRef)
            transaction.updateData(["friends": receiverFriends], forDocument: receiverRef)
            
            return nil
        }) { (result, error) in
            if let error = error {
                print("Error accepting friend request: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("Friend request accepted successfully")
                completion(.success(()))
            }
        }
    }





    
}
