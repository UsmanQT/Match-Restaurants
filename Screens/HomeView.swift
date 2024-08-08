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
    var body: some View {
        VStack {
            Text("Home")
            Button("log out") {
                do {
                    try Auth.auth().signOut()
                } catch {
                    print("Already logged out")
                }
            }
        }
    }
}
