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

    
}
