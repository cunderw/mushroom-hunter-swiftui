//
//  AddMushroomViewModelTests.swift
//  mymushroomshunterTests
//
//  Created by Carson Underwood on 2/22/24.
//

import XCTest
@testable import mymushroomshunter
import UIKit
import CoreLocation

class AddMushroomViewModelTests: XCTestCase {
    var viewModel: AddMushroomViewModel!
    var mockRepository: MockMushroomRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockRepository = MockMushroomRepository()
        viewModel = AddMushroomViewModel()
        viewModel.repository = mockRepository
    }

    override func tearDownWithError() throws {
        viewModel = nil
        mockRepository = nil
        try super.tearDownWithError()
    }

    func testSaveMushroomSuccess() {
        viewModel.name = "Test Mushroom"
        viewModel.description = "Test Description"
        viewModel.geolocation = CLLocationCoordinate2D(latitude: 10.0, longitude: 10.0)
        viewModel.selectedImage = UIImage(systemName: "photo")
        mockRepository.mockUploadURL = URL(string: "https://example.com/image.jpg")

        let expectation = self.expectation(description: "Mushroom saved successfully")

        viewModel.saveMushroom(userID: "testUserID") { success, error in
            XCTAssertTrue(success)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testSaveMushroomIncompleteForm() {
        viewModel.name = "Test Mushroom"
        viewModel.description = ""

        let expectation = self.expectation(description: "Mushroom save failed due to incomplete form")

        viewModel.saveMushroom(userID: "testUserID") { success, error in
            XCTAssertFalse(success)
            XCTAssertNotNil(error)
            if let viewModelError = error as? ViewModelError {
                XCTAssertEqual(viewModelError, ViewModelError.formIncompleteOrRepositoryNotSet)
            } else {
                XCTFail("Expected ViewModelError.formIncompleteOrRepositoryNotSet")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testSaveMushroomImageUploadFailure() {
        viewModel.name = "Test Mushroom"
        viewModel.description = "Test Description"
        viewModel.geolocation = CLLocationCoordinate2D(latitude: 10.0, longitude: 10.0)
        viewModel.selectedImage = UIImage(systemName: "photo")
        mockRepository.shouldFailUpload = true
        mockRepository.mockUploadError = UploadImageError.unknownError

        let expectation = self.expectation(description: "Mushroom save failed due to image upload error")

        viewModel.saveMushroom(userID: "testUserID") { success, error in
            XCTAssertFalse(success)
            XCTAssertNotNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }
}

