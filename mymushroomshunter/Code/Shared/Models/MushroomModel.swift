//
//  MushroomModel.swift
//  mymushroomshunter
//
//  Created by Carson Underwood on 2/13/24.
//

import CoreLocation
import FirebaseFirestore
import Foundation

struct Mushroom: Identifiable {
    let id: String // Document ID
    let name: String
    let description: String
    let photoUrl: String
    let dateFound: Date
    let geolocation: CLLocationCoordinate2D
    let userID: String
}

extension DateFormatter {
    static let customDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

extension Mushroom {
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()

        guard let name = data["name"] as? String else {
            print("Error: Expected 'name' to be a String but found \(type(of: data["name"]!))")
            return nil
        }

        guard let description = data["description"] as? String else {
            print("Error: Expected 'description' to be a String but found \(type(of: data["description"]!))")
            return nil
        }

        guard let photoUrl = data["photoUrl"] as? String else {
            print("Error: Expected 'photoUrl' to be a String but found \(type(of: data["photoUrl"]!))")
            return nil
        }

        guard let userID = data["userID"] as? String else {
            print("Error: Expected 'userID' to be a String but found \(type(of: data["userID"]!))")
            return nil
        }

        guard let dateFoundString = data["dateFound"] as? String else {
            print("Error: 'dateFound' is not a String")
            return nil
        }

        guard let dateFound = DateFormatter.customDateFormatter.date(from: dateFoundString) else {
            print("Error: 'dateFound' could not be converted to Date from string: \(dateFoundString)")
            return nil
        }

        guard let geolocationDict = data["geolocation"] as? [String: Any],
              let latitude = geolocationDict["latitude"] as? Double,
              let longitude = geolocationDict["longitude"] as? Double
        else {
            print("Error: Expected 'geolocation' to be a dictionary with Double latitude and longitude but found \(type(of: data["geolocation"]!))")
            return nil
        }

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
