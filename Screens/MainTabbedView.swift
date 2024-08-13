//
//  MainTabbedView.swift
//  Interest-animations
//
//  Created by Usman Tahir Qureshi on 8/9/24.
//

import Foundation
import SwiftUI

struct MainTabbedView: View {
    
    @State var presentSideMenu = false
    @State var selectedSideMenuTab = 0
    
    var body: some View {
        ZStack{
            
            TabView(selection: $selectedSideMenuTab) {
                HomeView(presentSideMenu: $presentSideMenu)
                    .tag(0)
                ExploreView(presentSideMenu: $presentSideMenu)
                    .tag(1)
                ChatView(presentSideMenu: $presentSideMenu)
                    .tag(2)
                ProfileView(presentSideMenu: $presentSideMenu)
                    .tag(3)
                ConnectView(presentSideMenu: $presentSideMenu)
                    .tag(4)
            }
            
            SideMenu(isShowing: $presentSideMenu, content: AnyView(SideMenuView(selectedSideMenuTab: $selectedSideMenuTab, presentSideMenu: $presentSideMenu)))
        }
    }
}
