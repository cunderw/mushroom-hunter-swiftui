//
//  MushroomModel.swift
//  mymushroomshunter
//
//  Created by Carson Underwood on 2/13/24.
//

import CoreLocation
import FirebaseFirestore
import Foundation
import os

protocol DocumentSnapshotProtocol {
    var documentID: String { get }
    func data() -> [String: Any]
}

extension QueryDocumentSnapshot: DocumentSnapshotProtocol {}

struct Mushroom: Identifiable {
    let id: String? // Document ID
    let name: String
    let description: String
    let photoUrl: String
    let dateFound: Date
    let geolocation: CLLocationCoordinate2D
    let userID: String
}

extension Mushroom {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: Mushroom.self)
    )
}

extension Mushroom {
    init?(document: DocumentSnapshotProtocol) {
        let data = document.data()

        guard let name = data["name"] as? String,
              let description = data["description"] as? String,
              let photoUrl = data["photoUrl"] as? String,
              let userID = data["userID"] as? String,
              let dateFoundTimestamp = data["dateFound"] as? Timestamp,
              let geolocationDict = data["geolocation"] as? [String: Any],
              let latitude = geolocationDict["latitude"] as? Double,
              let longitude = geolocationDict["longitude"] as? Double
        else {
            Mushroom.logger.error("[MushroomModel] - Document data is incomplete or incorrectly formatted")
            return nil
        }

        let dateFound = dateFoundTimestamp.dateValue()

        self.id = document.documentID
        self.name = name
        self.description = description
        self.photoUrl = photoUrl
        self.userID = userID
        self.dateFound = dateFound
        self.geolocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension Mushroom: Equatable {
    static func == (lhs: Mushroom, rhs: Mushroom) -> Bool {
        return lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.description == rhs.description &&
            lhs.photoUrl == rhs.photoUrl &&
            lhs.dateFound == rhs.dateFound &&
            lhs.geolocation.latitude == rhs.geolocation.latitude &&
            lhs.geolocation.longitude == rhs.geolocation.longitude &&
            lhs.userID == rhs.userID
    }
}

extension Mushroom {
    static var sample: Mushroom {
        Mushroom(
            id: "1",
            name: "Chanterelle",
            description: "Chanterelles have a distinctive bright yellow color and a funnel shape. They are known for their unique peppery, fruity flavor.",
            photoUrl: "https://images.unsplash.com/photo-1630921121767-81e86d066a5d?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTl8fG11c2hyb29tfGVufDB8fDB8fHww",
            dateFound: Date(),
            geolocation: CLLocationCoordinate2D(latitude: 51.509865, longitude: -0.118092),
            userID: "user123"
        )
    }
}
