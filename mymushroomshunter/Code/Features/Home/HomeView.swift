//
//  HomeView.swift
//  mymushroomshunter
//
//  Created by Carson Underwood on 2/13/24.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack {
                MushroomsListView()
            }.navigationTitle("My Mushrooms")
        }
    }
}

#Preview {
    HomeView()
}
