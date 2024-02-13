//
//  mymushroomshunterApp.swift
//  mymushroomshunter
//
//  Created by Carson Underwood on 2/13/24.
//

import SwiftUI
import Firebase

extension MyMushroomsHunterApp {
  private func setupAuthentication() {
    FirebaseApp.configure()
  }
}

@main
struct MyMushroomsHunterApp: App {
    @StateObject private var authManager = AuthManager.shared
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
