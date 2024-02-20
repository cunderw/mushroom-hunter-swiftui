//
//  MyMushroomsHunterApp.swift
//  mymushroomshunter
//
//  Created by Carson Underwood on 2/13/24.
//

import Firebase
import SwiftUI

extension MyMushroomsHunterApp {
    private func setupAuthentication() {
        FirebaseApp.configure()
    }
}

@main
struct MyMushroomsHunterApp: App {
    @StateObject private var authManager = AuthManager(authService: FirebaseAuthenticationService())
    init() {
        setupAuthentication()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
        }
    }
}
