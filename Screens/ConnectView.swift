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
            TextField("Email", text: $email)
                .modifier(InputField())
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            Button("Send Invitation") {
                
            }
            .buttonStyle(ActionButton(backgroundColor: Color.green, textColor: Color.white, borderColor: Color.green))
            .padding(.bottom, 10)
            Spacer()
            List(viewModel.users) { user in
                VStack(alignment: .leading) {
                    Text(user.email)
                        .font(.subheadline)
                }
            }
        }
        .padding(.horizontal, 24)
    }
}

