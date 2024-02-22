//
//  AddMushroomViewModel.swift
//  mymushroomshunter
//
//  Created by Carson Underwood on 2/21/24.
//

import Combine
import CoreLocation
import SwiftUI

enum ViewModelError: Error {
    case formIncompleteOrRepositoryNotSet
}

class AddMushroomViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var geolocation: CLLocationCoordinate2D?
    @Published var dateFound: Date = .init()
    @Published var selectedImage: UIImage?

    var repository: MushroomRepository?

    var formComplete: Bool {
        !name.isEmpty && !description.isEmpty && selectedImage != nil && isGeolocationSet
    }

    private var isGeolocationSet: Bool {
        guard let geolocation = geolocation else { return false }
        return geolocation.latitude != 0 && geolocation.longitude != 0
    }

    func saveMushroom(userID: String, completion: @escaping (Bool, Error?) -> Void) {
        guard formComplete, let repository = repository else {
            completion(false, ViewModelError.formIncompleteOrRepositoryNotSet)
            return
        }

        if let image = selectedImage, let geolocation = geolocation {
            repository.uploadImage(image: image) { [weak self] result in
                switch result {
                case .success(let url):
                    self?.createAndSaveMushroom(with: url, geolocation: geolocation, userID: userID, completion: completion)
                case .failure(let error):
                    completion(false, error)
                }
            }
        } else {
            completion(false, ViewModelError.formIncompleteOrRepositoryNotSet)
        }
    }

    private func createAndSaveMushroom(with photoUrl: URL, geolocation: CLLocationCoordinate2D, userID: String, completion: @escaping (Bool, Error?) -> Void) {
        let mushroom = Mushroom(
            id: nil,
            name: name,
            description: description,
            photoUrl: photoUrl.absoluteString,
            dateFound: dateFound,
            geolocation: geolocation,
            userID: userID
        )

        repository?.saveMushroom(mushroom: mushroom) { result in
            switch result {
            case .success:
                completion(true, nil)
            case .failure(let error):
                completion(false, error)
            }
        }
    }
}
