//
//  MyMushroomViewModelTests.swift
//  mymushroomshunterTests
//
//  Created by Carson Underwood on 2/21/24.
//

import CoreLocation
@testable import mymushroomshunter
import XCTest

class MyMushroomViewModelTests: XCTestCase {
    var viewModel: MyMushroomViewModel!
    var mockRepository: MockMushroomRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockMushroomRepository()
        viewModel = MyMushroomViewModel()
        viewModel.repository = mockRepository
    }

    override func tearDown() {
        viewModel = nil
        mockRepository = nil
        super.tearDown()
    }

    func testFetchUserMushroomsSuccess() {
        // Given
        let expectedMushrooms = [
            Mushroom(
                id: "1",
                name: "Chanterelle",
                description: "Chanterelles have a distinctive bright yellow color and a funnel shape. They are known for their unique peppery, fruity flavor.",
                photoUrl: "https://images.unsplash.com/photo-1630921121767-81e86d066a5d?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTl8fG11c2hyb29tfGVufDB8fDB8fHww",
                dateFound: Date(),
                geolocation: CLLocationCoordinate2D(latitude: 51.509865, longitude: -0.118092),
                userID: "user123"
            ),
            Mushroom(
                id: "2",
                name: "Morrell",
                description: "Morells have a distinctive bright yellow color and a funnel shape. They are known for their unique peppery, fruity flavor.",
                photoUrl: "https://images.unsplash.com/photo-1630921121767-81e86d066a5d?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTl8fG11c2hyb29tfGVufDB8fDB8fHww",
                dateFound: Date(),
                geolocation: CLLocationCoordinate2D(latitude: 51.509865, longitude: -0.118092),
                userID: "user123"
            )
        ]
        mockRepository.mockMushrooms = expectedMushrooms

        let expectation = XCTestExpectation(description: "Successfully fetched user mushrooms")

        // When
        viewModel.startListeningForUserMushrooms(userID: "testUserID")

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // Wait for async call
            XCTAssertEqual(self.viewModel.mushrooms, expectedMushrooms)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testFetchUserMushroomsFailure() {
        // Given
        mockRepository.mockFetchError = NSError(domain: "TestError", code: -1, userInfo: nil)

        let expectation = XCTestExpectation(description: "Failed to fetch user mushrooms")

        // When
        viewModel.startListeningForUserMushrooms(userID: "testUserID")

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // Wait for async call
            XCTAssertTrue(self.viewModel.mushrooms.isEmpty)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }
}
