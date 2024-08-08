//
//  SignUp.swift
//  Interest-animations
//
//  Created by Usman Tahir Qureshi on 8/8/24.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @State private var email: String = ""
    @State private var username = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showErrorToast = false
    @State private var toastMessage = String()

    
    var body: some View {
        NavigationStack{
            VStack {
                Text("Let's match restaurants")
                    .font(.headline)
                    .padding(.top, 100)
                
                Spacer()
                
                VStack {
                    TextField("Email", text: $email)
                        .modifier(InputField())
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    TextField("User Name", text: $username)
                        .modifier(InputField())
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    SecureField("Password", text: $password)
                        .modifier(InputField())
                        .padding(.vertical, 20)
                    
                    Button("Sign Up") {
                        createAccount(email: email, password: password) {
                            success, error in
                                if !success  {
                                    self.showErrorToast.toggle()
                                    self.toastMessage = error?.localizedDescription ?? "Unknown error"
                                }
                                                
                        }
                    }
                    .buttonStyle(ActionButton(backgroundColor: Color.black, textColor: Color.white, borderColor: Color.black))
                    
                }
                .padding(.horizontal, 30)
                
                Spacer()
            }
            
        }
    }
    
    private func createAccount(email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
            let firebaseManager = FirebaseManager.shared
            
        firebaseManager.createAccount(email: email, password: password) { result in
            switch result {
            case .success:
                print("User registered successfully")
                completion(true, nil)
            case .failure(let error):
                print("Error signing up: \(error.localizedDescription)")
                completion(false, error)
            }
        }
    }

}

