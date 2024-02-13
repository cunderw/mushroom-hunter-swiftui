//
//  ContentView.swift
//  mymushroomshunter
//
//  Created by Carson Underwood on 2/13/24.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    var body: some View {
        VStack {
                Text("Welcome, \(authManager.user?.email ?? "User")!")
                Button("Sign Out") {
                    authManager.signOut()
                }
        }
    }
}

