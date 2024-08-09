//
//  Interest_animationsApp.swift
//  Interest-animations
//
//  Created by Usman Tahir Qureshi on 8/8/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct Interest_animationsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
       
    @StateObject var authenticationState = UserAuthenticationState()
    
    var body: some Scene {
        WindowGroup {
            NavigationView{
                AuthenticationSwitcher()
            }
            .environmentObject(authenticationState)
        }
    }
}

struct AuthenticationSwitcher: View {
    @EnvironmentObject var authenticationState: UserAuthenticationState
    
    var body: some View {
        if (authenticationState.isSignedIn) {
            MainTabbedView()
        } else {
            SignInView()
        }
    }
}
