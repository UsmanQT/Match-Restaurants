//
//  ConnectView.swift
//  Interest-animations
//
//  Created by Usman Tahir Qureshi on 8/12/24.
//

import Foundation
import SwiftUI

struct ConnectView: View {
    @State private var email: String = ""
    @ObservedObject var viewModel = UsersViewModel()
    @State private var selectedUserEmail: String = ""
    
    @Binding var presentSideMenu: Bool
    
    var body: some View {
        VStack{
            HStack{
                Button{
                    presentSideMenu.toggle()
                } label: {
                    Image(systemName: "line.horizontal.3")
                        .resizable()
                        .frame(width: 15, height: 15)
                }
                Spacer()
            }
            
            Spacer()
            Text("Add people")
            TextField("Email", text: selectedUserEmail.isEmpty ? $email: $selectedUserEmail)
                .modifier(InputField())
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            Button("Send Invitation") {
                print("anything?")
            }
            .disabled(selectedUserEmail.isEmpty && email.isEmpty ? true : false)
            .buttonStyle(ActionButton(backgroundColor: selectedUserEmail.isEmpty && email.isEmpty ? Color.gray : Color.green, textColor: Color.white, borderColor: selectedUserEmail.isEmpty && email.isEmpty ? Color.gray : Color.green))
            .padding(.bottom, 10)
            Spacer()
            List(viewModel.users) { user in
                VStack(alignment: .leading) {
                    Text(user.email)
                        .font(.subheadline)
                }
                .onTapGesture {
                    // Update the text field when a user is tapped
                    selectedUserEmail = user.email
                }
            }
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

