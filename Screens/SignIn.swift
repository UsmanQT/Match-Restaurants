//
//  SignIn.swift
//  Interest-animations
//
//  Created by Usman Tahir Qureshi on 8/8/24.
//

import Foundation
import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

struct SignInView: View {
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
                
                Button("Login") {
                    // Login action here
                }
                .buttonStyle(ActionButton(backgroundColor: Color.black))
                
                Button("Login With Google") {
                    // Google login action here
                }
                .buttonStyle(ActionButton(backgroundColor: Color.blue))
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
    }
}
