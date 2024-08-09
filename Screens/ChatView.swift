//
//  ChatView.swift
//  Interest-animations
//
//  Created by Usman Tahir Qureshi on 8/9/24.
//

import Foundation
import SwiftUI

struct ChatView: View {
    
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
            Text("Chat View")
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}
