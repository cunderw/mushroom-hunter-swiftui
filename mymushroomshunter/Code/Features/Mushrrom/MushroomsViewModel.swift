//
//  MushroomsViewModel.swift
//  mymushroomshunter
//
//  Created by Carson Underwood on 2/13/24.
//

import FirebaseFirestore
import FirebaseAuth

class MushroomViewModel: ObservableObject {
    @Published var mushrooms: [Mushroom] = []

    func fetchMushrooms() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }

        print("Fetching Mushrooms for user: %@", userID)
        let db = Firestore.firestore()
        db.collection("mushrooms").whereField("userID", isEqualTo: userID).getDocuments { [weak self] (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                self?.mushrooms = querySnapshot.documents.compactMap { documentSnapshot -> Mushroom? in
                    return Mushroom(document: documentSnapshot)
                }
            } else if let error = error {
                print("Error fetching mushrooms: \(error.localizedDescription)")
            }
        }
    }
}
