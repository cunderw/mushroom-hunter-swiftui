//
//  MyMushroomsView.swift
//  mymushroomshunter
//
//  Created by Carson Underwood on 2/13/24.
//

import SwiftUI

struct MyMushroomsView: View {
    @EnvironmentObject var authManager: AuthManager
    @ObservedObject var viewModel = MushroomViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                List(viewModel.mushrooms) { mushroom in
                    VStack(alignment: .leading) {
                        MushroomCardView(mushroom: mushroom, layout: .horizontal)
                    }
                }
                .onAppear {
                    viewModel.fetchUserMushrooms(userID: authManager.user!.uid)
                }
            }.navigationTitle("My Mushrooms")
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

        let viewModel = MushroomViewModel(repository: mockRepository)

        MyMushroomsView(viewModel: viewModel)
            .environmentObject(
                AuthManager(
                    authService: MockAuthenticationService(
                        currentUser: MockUser(uid: "123", email: "test@example.com")
                    )
                )
            )
    }
}
