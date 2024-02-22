//
//  MushroomRepository.swift
//  mymushroomshunter
//
//  Created by Carson Underwood on 2/20/24.
//

import FirebaseFirestore
import FirebaseStorage
import Foundation

enum UploadImageError: Error {
    case failedToCompressImage
    case unknownError
}

protocol MushroomRepository {
    func fetchUserMushrooms(userID: String, completion: @escaping ([Mushroom]?, Error?) -> Void)
    func saveMushroom(mushroom: Mushroom, completion: @escaping (Result<String, Error>) -> Void)
    func uploadImage(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void)
}

class MushroomRepositoryWrapper: ObservableObject {
    var repository: MushroomRepository

    init(repository: MushroomRepository) {
        self.repository = repository
    }
}

class FirebaseMushroomRepository: MushroomRepository, ObservableObject {
    func fetchUserMushrooms(userID: String, completion: @escaping ([Mushroom]?, Error?) -> Void) {
        print("[FirebaseRepository] - Fetching User Mushrooms")
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

    func saveMushroom(mushroom: Mushroom, completion: @escaping (Result<String, Error>) -> Void) {
        print("[FirebaseRepository] - Saving Mushroom")

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        let dateFoundString = dateFormatter.string(from: mushroom.dateFound)

        let data: [String: Any] = [
            "name": mushroom.name,
            "description": mushroom.description,
            "photoUrl": mushroom.photoUrl,
            "dateFound": dateFoundString,
            "geolocation": [
                "latitude": mushroom.geolocation.latitude,
                "longitude": mushroom.geolocation.longitude
            ],
            "userID": mushroom.userID
        ]

        if let id = mushroom.id {
            let documentRef = Firestore.firestore().collection("mushrooms").document(id)
            documentRef.setData(data) { error in
                if let error = error {
                    print("[FirebaseRepository] - Error updating mushroom: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    print("[FirebaseRepository] - Mushroom successfully updated")
                    completion(.success(id)) // Return the existing document ID
                }
            }
        } else {
            var documentRef: DocumentReference? = nil
            documentRef = Firestore.firestore().collection("mushrooms").addDocument(data: data) { error in
                if let error = error {
                    print("[FirebaseRepository] - Error saving new mushroom: \(error.localizedDescription)")
                    completion(.failure(error))
                } else if let documentID = documentRef?.documentID {
                    print("[FirebaseRepository] - Mushroom successfully saved with ID: \(documentID)")
                    completion(.success(documentID)) // Return the new document ID
                } else {
                    // Handle the unexpected case where there's no error and no document reference
                    print("[FirebaseRepository] - Unknown error: No DocumentID found after saving new mushroom")
                    completion(.failure(NSError(domain: "FirebaseRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error: No DocumentID found after saving new mushroom"])))
                }
            }
        }
    }

    func uploadImage(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        print("[FirebaseRepository] - Uploading Image")
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            print("[FirebaseRepository] - Error uploading image: failed to compress image")
            completion(.failure(UploadImageError.failedToCompressImage))
            return
        }

        let storageRef = Storage.storage().reference().child("images/\(Int(Date().timeIntervalSince1970)).jpg")

        _ = storageRef.putData(imageData, metadata: nil) { metadata, error in
            guard metadata != nil else {
                if let error = error {
                    print("[FirebaseRepository] - Error uploading image: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    print("[FirebaseRepository] - Error uploading image: unkown error")
                    completion(.failure(UploadImageError.unknownError))
                }
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    print("[FirebaseRepository] - Error  uploading image: \(error.localizedDescription)")
                    completion(.failure(error))
                } else if let url = url {
                    print("[FirebaseRepository] - Image uploaded")
                    completion(.success(url))
                } else {
                    print("[FirebaseRepository] - Error uploading image: no URL")
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
}
