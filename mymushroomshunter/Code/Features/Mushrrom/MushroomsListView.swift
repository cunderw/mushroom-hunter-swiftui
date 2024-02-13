//
//  MushroomsView.swift
//  mymushroomshunter
//
//  Created by Carson Underwood on 2/13/24.
//

import SwiftUI

struct MushroomsListView: View {
    @ObservedObject var viewModel = MushroomViewModel()

    var body: some View {
        List(viewModel.mushrooms) { mushroom in
            VStack(alignment: .leading) {
                MushroomCardView(mushroom: mushroom, layout: .horizontal)
            }
        }
        .onAppear {
            viewModel.fetchMushrooms()
        }
    }
}

struct MushroomsView_Previews: PreviewProvider {
    static var previews: some View {
        MushroomsListView(viewModel: MockMushroomViewModel())
    }
}
