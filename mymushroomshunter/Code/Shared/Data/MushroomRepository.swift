//
//  MushroomRepository.swift
//  mymushroomshunter
//
//  Created by Carson Underwood on 2/20/24.
//

import FirebaseFirestore
import Foundation

protocol MushroomRepository {
    func fetchUserMushrooms(userID: String, completion: @escaping ([Mushroom]?, Error?) -> Void)
}

class FirebaseMushroomRepository: MushroomRepository {
    func fetchUserMushrooms(userID: String, completion: @escaping ([Mushroom]?, Error?) -> Void) {
        let db = Firestore.firestore()
        db.collection("mushrooms").whereField("userID", isEqualTo: userID).getDocuments { querySnapshot, error in
            if let querySnapshot = querySnapshot {
                let mushrooms = querySnapshot.documents.compactMap { documentSnapshot -> Mushroom? in
                    Mushroom(document: documentSnapshot)
                }
                completion(mushrooms, nil)
            } else if let error = error {
                completion(nil, error)
            }
        }
    }
}

class MockMushroomRepository: MushroomRepository {
    var mockMushrooms: [Mushroom]?
    var mockError: Error?

    init(mushrooms: [Mushroom] = []) {
        self.mockMushrooms = mushrooms
    }

    func fetchUserMushrooms(userID: String, completion: @escaping ([Mushroom]?, Error?) -> Void) {
        if let error = mockError {
            completion(nil, error)
        } else {
            completion(mockMushrooms, nil)
        }
    }
}
