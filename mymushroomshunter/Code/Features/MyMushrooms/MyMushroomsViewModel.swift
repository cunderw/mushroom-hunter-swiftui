//
//  MyMushroomsViewModel.swift
//  mymushroomshunter
//
//  Created by Carson Underwood on 2/13/24.
//

import Combine
import Foundation

class MyMushroomViewModel: ObservableObject {
    @Published var mushrooms: [Mushroom] = []
    var repository: MushroomRepository?

    func fetchUserMushrooms(userID: String) {
        print("Fetching Mushrooms for user: \(userID)")
        repository?.fetchUserMushrooms(userID: userID) { [weak self] mushrooms, error in
            DispatchQueue.main.async {
                if let mushrooms = mushrooms {
                    self?.mushrooms = mushrooms
                } else if let error = error {
                    print("Error fetching mushrooms: \(error.localizedDescription)")
                }
            }
        }
    }
}
