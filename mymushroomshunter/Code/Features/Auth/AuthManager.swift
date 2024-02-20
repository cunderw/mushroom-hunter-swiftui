//
//  UserAuthManager.swift
//  mymushroomshunter
//
//  Created by Carson Underwood on 2/13/24.
//

import Combine
import FirebaseAuth

protocol UserProtocol {
    var uid: String { get }
    var email: String? { get }
}

extension User: UserProtocol {}

protocol AuthenticationService {
    var currentUser: UserProtocol? { get }
    func signIn(withEmail email: String, password: String, completion: @escaping (Bool, Error?) -> Void)
    func signUp(withEmail email: String, password: String, completion: @escaping (Bool, Error?) -> Void)
    func signOut() throws
    var objectWillChange: ObservableObjectPublisher { get }
}

class AuthManager: ObservableObject {
    @Published var isUserAuthenticated: Bool = false
    @Published var user: UserProtocol?

    private var authService: AuthenticationService
    private var cancellables: Set<AnyCancellable> = []

    init(authService: AuthenticationService) {
        self.authService = authService

        self.isUserAuthenticated = authService.currentUser != nil
        self.user = authService.currentUser

        authService.objectWillChange.sink { [weak self] in
            self?.user = self?.authService.currentUser
            self?.isUserAuthenticated = (self?.authService.currentUser != nil)
        }.store(in: &cancellables)
    }

    func signIn(email: String, password: String, completion: @escaping () -> Void = {}) {
        authService.signIn(withEmail: email, password: password) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.isUserAuthenticated = true
                    self?.user = self?.authService.currentUser
                } else {
                    print("Error signing in: \(error?.localizedDescription ?? "Unknown error")")
                }
                completion()
            }
        }
    }

    func signUp(email: String, password: String, completion: @escaping () -> Void = {}) {
        authService.signUp(withEmail: email, password: password) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.isUserAuthenticated = true
                    self?.user = self?.authService.currentUser
                } else {
                    print("Error signing up: \(error?.localizedDescription ?? "Unknown error")")
                }
                completion()
            }
        }
    }

    func signOut() {
        do {
            try authService.signOut()
            isUserAuthenticated = false
            user = nil
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

class MockUser: UserProtocol {
    var uid: String
    var email: String?

    init(uid: String, email: String?) {
        self.uid = uid
        self.email = email
    }
}

class FirebaseAuthenticationService: AuthenticationService {
    var objectWillChange = ObservableObjectPublisher()

    var currentUser: UserProtocol? {
        Auth.auth().currentUser
    }

    func signIn(withEmail email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let _ = authResult?.user {
                self.objectWillChange.send()
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }

    func signUp(withEmail email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let _ = authResult?.user {
                self.objectWillChange.send()
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }

    func signOut() throws {
        try Auth.auth().signOut()
        objectWillChange.send()
    }
}

class MockAuthenticationService: AuthenticationService {
    var objectWillChange = ObservableObjectPublisher()

    var currentUser: UserProtocol? {
        willSet {
            objectWillChange.send()
        }
    }

    var signInShouldSucceed: Bool = true
    var signUpShouldSucceed: Bool = true
    var signOutShouldSucceed: Bool = true
    var signInError: Error?
    var signUpError: Error?
    var signOutError: Error?

    init(currentUser: UserProtocol? = nil, signInShouldSucceed: Bool = true, signUpShouldSucceed: Bool = true, signOutShouldSucceed: Bool = true, signInError: Error? = nil, signUpError: Error? = nil, signOutError: Error? = nil) {
        self.currentUser = currentUser
        self.signInShouldSucceed = signInShouldSucceed
        self.signUpShouldSucceed = signUpShouldSucceed
        self.signOutShouldSucceed = signOutShouldSucceed
        self.signInError = signInError
        self.signUpError = signUpError
        self.signOutError = signOutError
    }

    func signIn(withEmail email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        if signInShouldSucceed {
            currentUser = MockUser(uid: "mockUid", email: email)
            completion(true, nil)
        } else {
            completion(false, signInError)
        }
    }

    func signUp(withEmail email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        if signUpShouldSucceed {
            currentUser = MockUser(uid: "mockUid", email: email)
            completion(true, nil)
        } else {
            completion(false, signUpError)
        }
    }

    func signOut() throws {
        if !signOutShouldSucceed {
            if let error = signOutError {
                throw error
            } else {
                throw NSError(domain: "MockAuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock sign out failure"])
            }
        }
        currentUser = nil
    }
}
