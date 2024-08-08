//
//  SignIn.swift
//  Interest-animations
//
//  Created by Usman Tahir Qureshi on 8/8/24.
//

import Foundation
import SwiftUI
import FirebaseCore


struct SignInView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showErrorToast = false
    @State private var toastMessage = String()
    
    var body: some View {
        NavigationView {
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
                    
                    SecureField("Password", text: $password)
                        .modifier(InputField())
                        .padding(.vertical, 20)
                    
                    Button("Login") {
                        login(email: email, password: password) {
                            success, error in
                                if !success  {
                                    self.showErrorToast.toggle()
                                    self.toastMessage = error?.localizedDescription ?? "Unknown error"
                                }
                                                
                        }
                    }
                    .buttonStyle(ActionButton(backgroundColor: Color.black, textColor: Color.white, borderColor: Color.black))
                    .padding(.bottom, 10)
                    Button("Login With Google") {
                        // Google login action here
                    }
                    .buttonStyle(ActionButton(backgroundColor: Color.blue, textColor: Color.white, borderColor: Color.blue))
                    .padding(.bottom, 10)
                    
                    
                    NavigationLink(destination: SignUpView()) {
                        Text("Create Account")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 2)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                
                }
                .padding(.horizontal, 30)
                
                Spacer()
            }
        }
        
    }
    
    private func login(email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
            let firebaseManager = FirebaseManager.shared
            
        firebaseManager.login(email: email, password: password) { result in
            switch result {
            case .success:
                print("User logged In successfully")
                completion(true, nil)
            case .failure(let error):
                print("Error signing in: \(error.localizedDescription)")
                completion(false, error)
            }
        }
    }
}
