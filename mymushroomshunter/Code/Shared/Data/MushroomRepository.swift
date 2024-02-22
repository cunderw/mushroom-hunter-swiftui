//
//  MushroomRepository.swift
//  mymushroomshunter
//
//  Created by Carson Underwood on 2/20/24.
//

import FirebaseFirestore
import FirebaseStorage
import Foundation
import os

enum UploadImageError: Error {
    case failedToCompressImage
    case unknownError
}

protocol MushroomRepository {
    func fetchUserMushrooms(userID: String, completion: @escaping ([Mushroom]?, Error?) -> Void)
    func saveMushroom(mushroom: Mushroom, completion: @escaping (Result<String, Error>) -> Void)
    func uploadImage(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void)
    func removeUserMushroomsListener()
}

class MushroomRepositoryWrapper: ObservableObject {
    var repository: MushroomRepository

    init(repository: MushroomRepository) {
        self.repository = repository
    }
}

class FirebaseMushroomRepository: MushroomRepository, ObservableObject {
    private let db = Firestore.firestore()
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: FirebaseMushroomRepository.self)
    )
    private var userMushroomsListener: ListenerRegistration?
    func fetchUserMushrooms(userID: String, completion: @escaping ([Mushroom]?, Error?) -> Void) {
        Self.logger.trace("[FirebaseRepository] - Fetching user mushrooms")
        userMushroomsListener?.remove()
        userMushroomsListener = db.collection("mushrooms").whereField("userID", isEqualTo: userID)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    Self.logger.error("[FirebaseRepository] - Error fetching mushrooms: \(error.localizedDescription)")
                    completion(nil, error)
                } else if let querySnapshot = querySnapshot {
                    let mushrooms = querySnapshot.documents.compactMap { documentSnapshot -> Mushroom? in
                        Mushroom(document: documentSnapshot)
                    }
                    Self.logger.trace("[FirebaseRepository] - Fetching user mushrooms complete")
                    completion(mushrooms, nil)
                }
            }
    }

    func removeUserMushroomsListener() {
        userMushroomsListener?.remove()
    }

    func saveMushroom(mushroom: Mushroom, completion: @escaping (Result<String, Error>) -> Void) {
        Self.logger.trace("[FirebaseRepository] - Saving Mushroom")

        let dateFoundTimeStamp = Timestamp(date: mushroom.dateFound)

        let data: [String: Any] = [
            "name": mushroom.name,
            "description": mushroom.description,
            "photoUrl": mushroom.photoUrl,
            "dateFound": dateFoundTimeStamp,
            "geolocation": [
                "latitude": mushroom.geolocation.latitude,
                "longitude": mushroom.geolocation.longitude
            ],
            "userID": mushroom.userID
        ]

        if let id = mushroom.id {
            let documentRef = db.collection("mushrooms").document(id)
            documentRef.setData(data) { error in
                if let error = error {
                    Self.logger.error("[FirebaseRepository] - Error updating mushroom: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    Self.logger.trace("[FirebaseRepository] - Mushroom successfully updated")
                    completion(.success(id)) // Return the existing document ID
                }
            }
        } else {
            var documentRef: DocumentReference? = nil
            documentRef = Firestore.firestore().collection("mushrooms").addDocument(data: data) { error in
                if let error = error {
                    Self.logger.error("[FirebaseRepository] - Error saving new mushroom: \(error.localizedDescription)")
                    completion(.failure(error))
                } else if let documentID = documentRef?.documentID {
                    Self.logger.trace("[FirebaseRepository] - Mushroom successfully saved with ID: \(documentID)")
                    completion(.success(documentID)) // Return the new document ID
                } else {
                    // Handle the unexpected case where there's no error and no document reference
                    Self.logger.error("[FirebaseRepository] - Unknown error: No DocumentID found after saving new mushroom")
                    completion(.failure(NSError(domain: "FirebaseRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error: No DocumentID found after saving new mushroom"])))
                }
            }
        }
    }

    func uploadImage(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        Self.logger.trace("[FirebaseRepository] - Uploading Image")
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            print("[FirebaseRepository] - Error uploading image: failed to compress image")
            completion(.failure(UploadImageError.failedToCompressImage))
            return
        }

        let storageRef = Storage.storage().reference().child("images/\(Int(Date().timeIntervalSince1970)).jpg")

        _ = storageRef.putData(imageData, metadata: nil) { metadata, error in
            guard metadata != nil else {
                if let error = error {
                    Self.logger.error("[FirebaseRepository] - Error uploading image: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    Self.logger.error("[FirebaseRepository] - Error uploading image: unkown error")
                    completion(.failure(UploadImageError.unknownError))
                }
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    Self.logger.error("[FirebaseRepository] - Error  uploading image: \(error.localizedDescription)")
                    completion(.failure(error))
                } else if let url = url {
                    Self.logger.trace("[FirebaseRepository] - Image uploaded")
                    completion(.success(url))
                } else {
                    Self.logger.error("[FirebaseRepository] - Error uploading image: no URL")
                    completion(.failure(UploadImageError.unknownError))
                }
            }
        }
    }
}

class MockMushroomRepository: MushroomRepository, ObservableObject {
    var mockMushrooms: [Mushroom]?
    var mockFetchError: Error?
    var mockSaveError: Error?
    var shouldFailUpload: Bool = false
    var mockUploadError: Error?
    var mockUploadURL: URL? = URL(string: "https://example.com/image.jpg")

    init(mushrooms: [Mushroom] = []) {
        self.mockMushrooms = mushrooms
    }

    func fetchUserMushrooms(userID: String, completion: @escaping ([Mushroom]?, Error?) -> Void) {
        print("[MockFirebaseRepository] - Fetching User Mushrooms")
        if let error = mockFetchError {
            completion(nil, error)
        } else {
            completion(mockMushrooms, nil)
        }
    }

    func saveMushroom(mushroom: Mushroom, completion: @escaping (Result<String, Error>) -> Void) {
        print("[MockFirebaseRepository] - Saving Mushroom")
        if let error = mockFetchError {
            completion(.failure(error))
        } else {
            let mockDocumentID = "mockDocumentID"
            print("[FirebaseRepository] - Mushroom successfully saved with ID: \(mockDocumentID)")
            completion(.success(mockDocumentID))
        }
    }

    func uploadImage(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        print("[MockFirebaseRepository] - Uploading Image")
        if shouldFailUpload {
            if let mockError = mockUploadError {
                completion(.failure(mockError))
            } else {
                print("[MockFirebaseRepository] - Error uploading image: unkown error")
                completion(.failure(UploadImageError.unknownError))
            }
        } else {
            if let mockUploadURL = mockUploadURL {
                print("[MockFirebaseRepository] - Image uploaded")
                completion(.success(mockUploadURL))
            } else {
                print("[MockFirebaseRepository] - Error uploading image: unkown error")
                completion(.failure(UploadImageError.unknownError))
            }
        }
    }

    func removeUserMushroomsListener() {}
}
