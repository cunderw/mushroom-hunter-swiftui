//
//  ContentView.swift
//  mymushroomshunter
//
//  Created by Carson Underwood on 2/13/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManagerWrapper: AuthManagerWrapper
    var body: some View {
        VStack {
            if authManagerWrapper.authManager.isUserAuthenticated {
                TabView {
                    HomeView()
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }
                    NearMeView()
                        .tabItem {
                            Label("Near Me", systemImage: "location")
                        }
                    ProfileView()
                        .tabItem {
                            Label("Profile", systemImage: "person")
                        }
                        .environmentObject(authManagerWrapper)
                }
            } else {
                LoginView()
                    .environmentObject(authManagerWrapper)
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthManagerWrapper(authManager: MockAuthManager(isUserAuthenticated: true)))
            .previewDisplayName("User Authenticated")

        ContentView()
            .environmentObject(AuthManagerWrapper(authManager: MockAuthManager(isUserAuthenticated: false)))
            .previewDisplayName("User Not Authenticated")
    }
}
