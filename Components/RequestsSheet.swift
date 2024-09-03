//
//  RequestsSheet.swift
//  Interest-animations
//
//  Created by Usman Tahir Qureshi on 9/3/24.
//

import Foundation
import SwiftUI

struct RequestsSheet: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: UsersViewModel

    var body: some View {
        NavigationView {
            List(viewModel.receivedRequests) { request in
                VStack(alignment: .leading) {
                    Text("Sender ID: \(request.senderId)")
                    Text("Status: \(request.status.rawValue)")
                }
            }
            .navigationTitle("Received Requests")
            .navigationBarItems(trailing: Button("Close") {
                isPresented = false
            })
        }
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 20)
        .onAppear {
            viewModel.fetchReceivedFriendRequests()
        }
    }
}
