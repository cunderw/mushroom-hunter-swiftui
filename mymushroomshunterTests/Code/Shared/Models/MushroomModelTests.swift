//
//  MushroomModelTests.swift
//  mymushroomshunterTests
//
//  Created by Carson Underwood on 2/22/24.
//

import CoreLocation
import FirebaseFirestore
@testable import mymushroomshunter
import XCTest

class MushroomTests: XCTestCase {
    class MockDocumentSnapshot: DocumentSnapshotProtocol {
        var documentID: String
        var dataStub: [String: Any]

        init(documentID: String, data: [String: Any]) {
            self.documentID = documentID
            self.dataStub = data
        }

        func data() -> [String: Any] {
            return dataStub
        }
    }

    func testMushroomInitialization() {
        let timestamp = Timestamp(date: Date())
        let data: [String: Any] = [
            "name": "Chanterelle",
            "description": "A description",
            "photoUrl": "https://example.com/photo.jpg",
            "userID": "user123",
            "dateFound": timestamp,
            "geolocation": ["latitude": 51.509865, "longitude": -0.118092]
        ]

        let mockDocument = MockDocumentSnapshot(documentID: "1", data: data)

        guard let mushroom = Mushroom(document: mockDocument) else {
            XCTFail("Mushroom initialization failed")
            return
        }

        XCTAssertEqual(mushroom.id, "1")
        XCTAssertEqual(mushroom.name, "Chanterelle")
        XCTAssertEqual(mushroom.description, "A description")
        XCTAssertEqual(mushroom.photoUrl, "https://example.com/photo.jpg")
        XCTAssertEqual(mushroom.userID, "user123")
        XCTAssertEqual(mushroom.geolocation.latitude, 51.509865)
        XCTAssertEqual(mushroom.geolocation.longitude, -0.118092)
    }

    func testInitializationFailsWithoutName() {
        let data: [String: Any] = [
            "description": "A description",
            "photoUrl": "https://example.com/photo.jpg",
            "userID": "user123",
            "dateFound": Timestamp(date: Date()),
            "geolocation": ["latitude": 51.509865, "longitude": -0.118092]
        ]
        let mockDocument = MockDocumentSnapshot(documentID: "1", data: data)
        XCTAssertNil(Mushroom(document: mockDocument), "Mushroom initialized successfully without a name.")
    }

    func testInitializationFailsWithoutDescription() {
        let data: [String: Any] = [
            "name": "Chanterelle",
            "photoUrl": "https://example.com/photo.jpg",
            "userID": "user123",
            "dateFound": Timestamp(date: Date()),
            "geolocation": ["latitude": 51.509865, "longitude": -0.118092]
        ]
        let mockDocument = MockDocumentSnapshot(documentID: "1", data: data)
        XCTAssertNil(Mushroom(document: mockDocument), "Mushroom initialized successfully without a description.")
    }

    func testInitializationFailsWithoutPhotoUrl() {
        let data: [String: Any] = [
            "name": "Chanterelle",
            "description": "A description",
            "userID": "user123",
            "dateFound": Timestamp(date: Date()),
            "geolocation": ["latitude": 51.509865, "longitude": -0.118092]
        ]
        let mockDocument = MockDocumentSnapshot(documentID: "1", data: data)
        XCTAssertNil(Mushroom(document: mockDocument), "Mushroom initialized successfully without a photoUrl.")
    }

    func testInitializationFailsWithoutUserID() {
        let data: [String: Any] = [
            "name": "Chanterelle",
            "description": "A description",
            "photoUrl": "https://example.com/photo.jpg",
            "dateFound": Timestamp(date: Date()),
            "geolocation": ["latitude": 51.509865, "longitude": -0.118092]
        ]
        let mockDocument = MockDocumentSnapshot(documentID: "1", data: data)
        XCTAssertNil(Mushroom(document: mockDocument), "Mushroom initialized successfully without a userID.")
    }

    func testInitializationFailsWithoutDateFound() {
        let data: [String: Any] = [
            "name": "Chanterelle",
            "description": "A description",
            "photoUrl": "https://example.com/photo.jpg",
            "userID": "user123",
            "geolocation": ["latitude": 51.509865, "longitude": -0.118092]
        ]
        let mockDocument = MockDocumentSnapshot(documentID: "1", data: data)
        XCTAssertNil(Mushroom(document: mockDocument), "Mushroom initialized successfully without a dateFound.")
    }

    func testInitializationFailsWithoutGeolocation() {
        let data: [String: Any] = [
            "name": "Chanterelle",
            "description": "A description",
            "photoUrl": "https://example.com/photo.jpg",
            "userID": "user123",
            "dateFound": Timestamp(date: Date())
        ]
        let mockDocument = MockDocumentSnapshot(documentID: "1", data: data)
        XCTAssertNil(Mushroom(document: mockDocument), "Mushroom initialized successfully without geolocation.")
    }

    func testInitializationFailsWithIncompleteGeolocation() {
        let data: [String: Any] = [
            "name": "Chanterelle",
            "description": "A description",
            "photoUrl": "https://example.com/photo.jpg",
            "userID": "user123",
            "dateFound": Timestamp(date: Date()),
            "geolocation": ["latitude": 51.509865]
        ]
        let mockDocument = MockDocumentSnapshot(documentID: "1", data: data)
        XCTAssertNil(Mushroom(document: mockDocument), "Mushroom initialized successfully with incomplete geolocation.")
    }
}
