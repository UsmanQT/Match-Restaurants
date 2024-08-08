//
//  SignUp.swift
//  Interest-animations
//
//  Created by Usman Tahir Qureshi on 8/8/24.
//

import Foundation
import SwiftUI

struct SignUpView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
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
                
                Button("Sign Up") {
                    // Login action here
                }
                .buttonStyle(ActionButton(backgroundColor: Color.black, textColor: Color.white, borderColor: Color.black))
                
                Button("Login With Google") {
                    // Google login action here
                }
                .buttonStyle(ActionButton(backgroundColor: Color.blue, textColor: Color.white, borderColor: Color.blue))
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
    }

}

