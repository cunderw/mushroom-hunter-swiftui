//
//  UserAuthManager.swift
//  mymushroomshunter
//
//  Created by Carson Underwood on 2/13/24.
//

import Foundation
import FirebaseAuth
import Combine

protocol AuthManagerProtocol {
    var isUserAuthenticated: Bool { get set }
    var user: User? { get set }
    func signIn(email: String, password: String)
    func signUp(email: String, password: String)
    func signOut()
    
    var objectWillChange: ObservableObjectPublisher { get }
}


class AuthManager: ObservableObject, AuthManagerProtocol {
    @Published var isUserAuthenticated: Bool = false
    @Published var user: User? = nil

    static let shared = AuthManager()

     init() {
        self.isUserAuthenticated = Auth.auth().currentUser != nil
        self.user = Auth.auth().currentUser

        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            self?.isUserAuthenticated = user != nil
            self?.user = user
        }
    }

    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                print("Error signing in: %@", error.localizedDescription)
            } else {
                self?.isUserAuthenticated = true
                self?.user = Auth.auth().currentUser
            }
        }
    }
    
    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if error != nil {
                // TODO - add alert
                print("Error signing up: %@", error!.localizedDescription)
            } else {
                self?.isUserAuthenticated = true
                self?.user = Auth.auth().currentUser
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.isUserAuthenticated = false
            self.user = nil
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

class AuthManagerWrapper: ObservableObject {
    var authManager: AuthManagerProtocol {
        willSet {
            cancellable?.cancel()
        }
        didSet {
            cancellable = authManager.objectWillChange.sink { [weak self] in
                self?.objectWillChange.send()
            }
        }
    }

    private var cancellable: AnyCancellable?

    init(authManager: AuthManagerProtocol) {
        self.authManager = authManager
        cancellable = authManager.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }
    }
}

class MockAuthManager: AuthManagerProtocol {
    var isUserAuthenticated: Bool
    var user: User?
    var objectWillChange = ObservableObjectPublisher()

    init(isUserAuthenticated: Bool = false, user: User? = nil) {
        self.isUserAuthenticated = isUserAuthenticated
        self.user = user
    }

    func signIn(email: String, password: String) {
        // Simulate sign-in
        self.isUserAuthenticated = true
        objectWillChange.send()
    }
    
    func signUp(email: String, password: String) {
        // Simulate sign-up
        self.isUserAuthenticated = true
        objectWillChange.send()
    }

    func signOut() {
        // Simulate sign-out
        self.isUserAuthenticated = false
        objectWillChange.send()
    }
}

