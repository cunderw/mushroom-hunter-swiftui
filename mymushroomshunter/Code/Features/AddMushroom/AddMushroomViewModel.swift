//
//  AddMushroomViewModel.swift
//  mymushroomshunter
//
//  Created by Carson Underwood on 2/21/24.
//

import Combine
import CoreLocation
import MapKit
import os
import SwiftUI

enum ViewModelError: Error {
    case formIncompleteOrRepositoryNotSet
}

class AddMushroomViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var mushroomName: String = ""
    @Published var mushroomDescription: String = ""
    @Published var dateFound: Date = .init()
    @Published var selectedImage: UIImage?
    @Published var selectedLocation: CLLocationCoordinate2D?
    @Published var mapRegion: MKCoordinateRegion = .init()
    @Published var isLocationServicesDisabled: Bool = false

    var repository: MushroomRepository?

    var formComplete: Bool {
        !mushroomName.isEmpty && !mushroomDescription.isEmpty && selectedImage != nil && isGeolocationSet
    }

    private var isGeolocationSet: Bool {
        guard let geolocation = selectedLocation else { return false }
        return geolocation.latitude != 0 && geolocation.longitude != 0
    }

    private var locationManager = CLLocationManager()

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: FirebaseMushroomRepository.self)
    )

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Self.logger.trace("[AddMushroomViewModel] - LocationManager autorization changed")
        switch manager.authorizationStatus {
        case .notDetermined:
            break
        case .restricted, .denied:
            // Permission was denied or restricted, update the UI to show an alert
            Self.logger.warning("[AddMushroomViewModel] - No location authorization")
            DispatchQueue.main.async {
                self.isLocationServicesDisabled = true
            }
        case .authorizedWhenInUse, .authorizedAlways:
            Self.logger.trace("[AddMushroomViewModel] - Location authorized, starting updating location")
            DispatchQueue.main.async {
                self.isLocationServicesDisabled = false
                self.locationManager.startUpdatingLocation() // Optional: Start location updates
            }
        @unknown default:
            Self.logger.error("[AddMushroomViewModel] - Unknown location status")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.first else { return }
        Self.logger.trace("[AddMushroomViewModel] - Location Changed:  \(currentLocation.coordinate.latitude) - \(currentLocation.coordinate.longitude)")
        mapRegion = MKCoordinateRegion(center: currentLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        manager.stopUpdatingLocation()
    }

    func saveMushroom(userID: String, completion: @escaping (Bool, Error?) -> Void) {
        guard formComplete, let repository = repository else {
            completion(false, ViewModelError.formIncompleteOrRepositoryNotSet)
            return
        }

        if let image = selectedImage, let geolocation = selectedLocation {
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
            name: mushroomName,
            description: mushroomDescription,
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
