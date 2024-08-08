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
    
    func createAccount(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                // Pass the error back to the completion handler
                completion(.failure(error))
                print("Error creating account: \(error.localizedDescription)")
            } else if authResult != nil {
                // Account created successfully
                completion(.success(()))
            }
        }
    }

    
//    private func addUserToFirestore(uid: String, user: UserProfile, completion: @escaping (Result<UserProfile, Error>) -> Void) {
//        let userRef = Firestore.firestore().collection("users").document(uid)
//        
//        userRef.setData([
//            "displayName": user.displayName,
//            "bio": user.bio,
//            "email": user.email
//        ]) { error in
//            if let error = error {
//                completion(.failure(error))
//                print(error.localizedDescription)
//            } else {
//                completion(.success(user))
//                print("User added to Firestore successfully")
//            }
//        }
//    }
    
}
