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
                        .padding(.bottom, 20)
                    
                    
                    Button("Sign Up") {
                        FirebaseManager.shared.signUp(email: self.email, password: self.password, username: self.username) { result in
                            switch result {
                            case .success:
                                print("User signed up successfully")
                                // You can navigate to the next screen here
                            case .failure(let error):
                                self.toastMessage = error.localizedDescription
                                self.showErrorToast = true
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
    
    

    



}

