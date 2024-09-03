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
    private var listenerRegistration: ListenerRegistration?
    
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
    
    deinit {
        listenerRegistration?.remove()
    }
}
