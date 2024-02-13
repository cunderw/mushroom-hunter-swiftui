//
//  UserAuthManager.swift
//  mymushroomshunter
//
//  Created by Carson Underwood on 2/13/24.
//

import Foundation
import FirebaseAuth

class AuthManager: ObservableObject {
    @Published var isUserAuthenticated: Bool = false
    @Published var user: User? = nil

    static let shared = AuthManager()

    private init() {
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
                print(error.localizedDescription)
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
                print(error!.localizedDescription)
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

