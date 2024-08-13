//
//  HomeView.swift
//  Interest-animations
//
//  Created by Usman Tahir Qureshi on 8/8/24.
//

import Foundation
import SwiftUI
import FirebaseAuth


struct HomeView: View {
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
                    Button("log out") {
                        do {
                            try Auth.auth().signOut()
                        } catch {
                            print("Already logged out")
                        }
                    }
                    
                }
                
                Spacer()
                Text("Home View")
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
}
