//
//  UserAuthenticationState.swift
//  Interest-animations
//
//  Created by Usman Tahir Qureshi on 8/8/24.
//

import Foundation
import Firebase
import FirebaseAuth

enum AuthenticationError: Error {
    case loginError, logoutError
}

@MainActor
class UserAuthenticationState: ObservableObject {
    @Published var isBusy = false
    @Published var isSignedIn: Bool = false
    @Published var user: User? = nil
    
    init() {
        Auth.auth().addStateDidChangeListener { _, user in
            self.isSignedIn = (user != nil)
            self.user = user
        }
    }
    
    func logout() async -> Result<Bool, AuthenticationError> {
            // TODO: Try signing out in backend
            isBusy = true
            
            do {
                try await Task.sleep(nanoseconds: 1_000_000_000)
                self.isSignedIn = false
                isBusy = false
                
                return .success(true)
            }
            
            catch {
                isBusy = false
                
                return .failure(.logoutError)
            }
        }
}
