//
//  FlickrSearchViewModelTests.swift
//  FlickerSearchTests
//
//  Created by Ranjith vanaparthi on 6/28/24.
//

import Combine
import XCTest
@testable import FlickerSearch

class FlickerSearchViewModelTests: XCTestCase {
    
    var viewModel: FlickerSearchViewModel!
    var mockService: MockFlickerSearchService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockService = MockFlickerSearchService()
        viewModel = FlickerSearchViewModel(service: mockService)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testInitialization() {
        XCTAssertTrue(viewModel.images.isEmpty)
        XCTAssertEqual(viewModel.uistate, .intial)
    }
    
    func testSearchWithEmptyText() {
        viewModel.searchText = ""
        XCTAssertEqual(viewModel.uistate, .intial)
        XCTAssertTrue(viewModel.images.isEmpty)
    }
    
    func testSearchWithNonEmptyTextSuccess() {
        let response = FlickrResponse(items: [FlickrImage(title: "Test", link: "https://example.com", media: FlickrImage.Media(m: "https://example.com/image.jpg"), description: "Description", author: "Author", published: "2024-06-28T00:00:00Z")])
        
        mockService.result = .success(response)
        
        let expectation = XCTestExpectation(description: "Search images successfully")
        
        viewModel.$uistate
            .dropFirst()
            .sink { state in
                if state == .loaded {
                    XCTAssertEqual(self.viewModel.images.count, 1)
                    XCTAssertEqual(self.viewModel.images.first?.title, "Test")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.searchText = "test"
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSearchWithNonEmptyTextError() {
        mockService.result = .failure(NetworkError.badURL("badURL"))
        
        let expectation = XCTestExpectation(description: "Search images with error")
        
        viewModel.$uistate
            .dropFirst()
            .sink { state in
                if state == .error {
                    XCTAssertTrue(self.viewModel.images.isEmpty)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.searchText = "test"
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDebounceEffect() {
        let response = FlickrResponse(items: [FlickrImage(title: "Test", link: "https://example.com", media: FlickrImage.Media(m: "https://example.com/image.jpg"), description: "Description", author: "Author", published: "2024-06-28T00:00:00Z")])
        
        mockService.result = .success(response)
        
        let expectation = XCTestExpectation(description: "Search images with debounce")
        
        viewModel.$uistate
            .dropFirst(2) // Debounce will trigger two states: loading and loaded
            .sink { state in
                if state == .loaded {
                    XCTAssertEqual(self.viewModel.images.count, 1)
                    XCTAssertEqual(self.viewModel.images.first?.title, "Test")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.searchText = "t"
        viewModel.searchText = "te"
        viewModel.searchText = "tes"
        viewModel.searchText = "test"
        
        wait(for: [expectation], timeout: 1.5)
    }
}



class MockFlickerSearchService: FlickerSearchServiceable {
    var result: Result<FlickrResponse, NetworkError>?
    
    func searchImage(by text: String) -> AnyPublisher<FlickrResponse, NetworkError> {
        if let result = result {
            return result.publisher.eraseToAnyPublisher()
        } else {
            return Fail(error: NetworkError.unknown(code: -1, error: "error")).eraseToAnyPublisher()
        }
    }
}
