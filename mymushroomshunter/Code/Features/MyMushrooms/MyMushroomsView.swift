//
//  MyMushroomsView.swift
//  mymushroomshunter
//
//  Created by Carson Underwood on 2/13/24.
//

import SwiftUI

struct MyMushroomsView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var viewModel: MyMushroomViewModel
    @State private var showingAddMushroomSheet = false

    var body: some View {
        NavigationStack {
            List(viewModel.mushrooms) { mushroom in
                MushroomCardView(mushroom: mushroom, layout: .horizontal)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showingAddMushroomSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddMushroomSheet) {
                AddMushroomView()
            }
            .navigationTitle("My Mushrooms")
            .onAppear {
                if authManager.isUserAuthenticated {
                    viewModel.fetchUserMushrooms(userID: authManager.user!.uid)
                }
            }
        }
    }
}

struct MyMushroomsView_Previews: PreviewProvider {
    static var previews: some View {
        let mockRepository = MockMushroomRepository(mushrooms: [
            Mushroom.sample,
            Mushroom.sample,
            Mushroom.sample,
            Mushroom.sample,
            Mushroom.sample,
            Mushroom.sample,
        ])

        let viewModel = MyMushroomViewModel(repository: mockRepository)
        let authManager = AuthManager(
            authService: MockAuthenticationService(
                currentUser: MockUser(uid: "123", email: "test@example.com")
            )
        )

        MyMushroomsView()
            .environmentObject(authManager)
            .environmentObject(viewModel)
    }
}
