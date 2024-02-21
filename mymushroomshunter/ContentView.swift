//
//  ContentView.swift
//  mymushroomshunter
//
//  Created by Carson Underwood on 2/13/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var mushroomRepositoryWrapper: MushroomRepositoryWrapper
    var body: some View {
        VStack {
            if authManager.isUserAuthenticated {
                TabView {
                    MyMushroomsView()
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
                }
            } else {
                LoginView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let mockRepository = MockMushroomRepository(mushrooms: [
            Mushroom.sample,
            Mushroom.sample,
            Mushroom.sample,
            Mushroom.sample,
            Mushroom.sample,
            Mushroom.sample,
        ])

        let mockRepositoryWrapper = MushroomRepositoryWrapper(repository: mockRepository)

        ContentView()
            .environmentObject(
                AuthManager(
                    authService: MockAuthenticationService(currentUser: MockUser(uid: "123", email: "test@test.com"))
                )
            )
            .environmentObject(mockRepositoryWrapper)
            .previewDisplayName("User Authenticated")

        ContentView()
            .environmentObject(
                AuthManager(
                    authService: MockAuthenticationService()
                )
            )
            .environmentObject(mockRepositoryWrapper)
            .previewDisplayName("User Not Authenticated")
    }
}
