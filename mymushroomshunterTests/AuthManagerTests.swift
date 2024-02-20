//
//  AuthManagerTests.swift
//  mymushroomshunterTests
//
//  Created by Carson Underwood on 2/20/24.
//

@testable import mymushroomshunter
import XCTest

class AuthManagerTests: XCTestCase {
    var authManager: AuthManager!
    var mockAuthService: MockAuthenticationService!

    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthenticationService()
        authManager = AuthManager(authService: mockAuthService)
    }

    override func tearDown() {
        authManager = nil
        mockAuthService = nil
        super.tearDown()
    }

    func testSignInSuccess() {
        // Given
        mockAuthService.signInShouldSucceed = true
        let expectation = XCTestExpectation(description: "SignIn succeeds")

        // When
        authManager.signIn(email: "test@example.com", password: "password") {
            // Then
            XCTAssertTrue(self.authManager.isUserAuthenticated)
            XCTAssertNotNil(self.authManager.user)
            XCTAssertEqual(self.authManager.user?.email, "test@example.com")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testSignInFailure() {
        // Given
        mockAuthService.signInShouldSucceed = false
        mockAuthService.signInError = NSError(domain: "AuthError", code: -1, userInfo: nil)
        let expectation = XCTestExpectation(description: "SignIn fails")

        // When
        authManager.signIn(email: "test@example.com", password: "wrongpassword") {
            // Then
            XCTAssertFalse(self.authManager.isUserAuthenticated)
            XCTAssertNil(self.authManager.user)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testSignUpSuccess() {
        // Given
        mockAuthService.signUpShouldSucceed = true
        let expectation = XCTestExpectation(description: "SignUp succeeds")

        // When
        authManager.signUp(email: "new@example.com", password: "newpassword") {
            // Then
            XCTAssertTrue(self.authManager.isUserAuthenticated)
            XCTAssertNotNil(self.authManager.user)
            XCTAssertEqual(self.authManager.user?.email, "new@example.com")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testSignUpFailure() {
        // Given
        mockAuthService.signUpShouldSucceed = false
        mockAuthService.signUpError = NSError(domain: "AuthError", code: -1, userInfo: nil)
        let expectation = XCTestExpectation(description: "SignUp fails")

        // When
        authManager.signUp(email: "new@example.com", password: "short") {
            // Then
            XCTAssertFalse(self.authManager.isUserAuthenticated)
            XCTAssertNil(self.authManager.user)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testSignOut() {
        // Given
        mockAuthService.currentUser = MockUser(uid: "mockUid", email: "user@example.com")
        mockAuthService.signOutShouldSucceed = true
        authManager.user = mockAuthService.currentUser
        authManager.isUserAuthenticated = true

        // When
        authManager.signOut()

        // Then
        XCTAssertFalse(authManager.isUserAuthenticated)
        XCTAssertNil(authManager.user)
    }
}
