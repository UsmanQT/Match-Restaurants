//
//  UserViewModel.swift
//  Interest-animations
//
//  Created by Usman Tahir Qureshi on 9/3/24.
//

import Foundation
import Combine
import FirebaseFirestore

class UsersViewModel: ObservableObject {
    @Published var users: [UserData] = []
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    init() {
        fetchUsers()
    }
    
    func fetchUsers() {
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
                    try? document.data(as: UserData.self)
                }
            }
    }
    
    deinit {
        listenerRegistration?.remove()
    }
}
