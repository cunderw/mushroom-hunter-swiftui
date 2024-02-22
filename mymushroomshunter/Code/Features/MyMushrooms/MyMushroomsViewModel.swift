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

    func startListeningForUserMushrooms(userID: String) {
        repository?.fetchUserMushrooms(userID: userID, completion: { [weak self] mushrooms, error in
            if let mushrooms = mushrooms {
                self?.mushrooms = mushrooms
            } else if let error = error {
                print("Error fetching mushrooms: \(error.localizedDescription)")
            }
        })
    }

    func stopListening() {
        repository?.removeUserMushroomsListener()
    }
}
