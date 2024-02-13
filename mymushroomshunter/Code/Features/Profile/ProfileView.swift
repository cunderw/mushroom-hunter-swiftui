//
//  ContentView.swift
//  mymushroomshunter
//
//  Created by Carson Underwood on 2/13/24.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManagerWrapper: AuthManagerWrapper
    var body: some View {
        VStack {
                Text("Welcome, \(authManagerWrapper.authManager.user?.email ?? "User")!")
                Button("Sign Out") {
                    authManagerWrapper.authManager.signOut()
                }
        }
    }
}

