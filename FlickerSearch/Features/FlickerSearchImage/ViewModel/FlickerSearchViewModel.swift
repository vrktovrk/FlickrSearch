//
//  FlickerSearchViewModel.swift
//  FlickerSearch
//
//  Created by Ranjith vanaparthi on 6/28/24.
//

import Foundation
import Combine

class FlickerSearchViewModel: ObservableObject {
    @Published var searchText = "" // The text entered by the user in the search bar.
    @Published var images = [FlickrImage]() // Array to hold the fetched images.
    @Published var uistate: UIState = .intial // Tracks the current UI state to control view rendering.
    
    private var searchCancellable: AnyCancellable? // Cancellable to manage the ongoing search request.
    
    // Enum to define possible UI states, making state management clear and explicit.
    enum UIState {
        case intial  // Initial View
        case loading // Indicates data is currently being fetched.
        case error   // Indicates an error occurred during data fetching.
        case loaded  // Indicates data has been successfully loaded and is ready to display.
    }
    
    // Constructor initializes the ViewModel with a service that conforms to FlickerSearchServiceable.
    private let service: FlickerSearchServiceable
    // Set to hold any cancellables, used for managing memory and lifecycle of network requests.
    var subscriptions = Set<AnyCancellable>()
    
    init(service: FlickerSearchServiceable = FlickerSearchServiceRequest(networkRequest: RequestableManager(), environment: .development)) {
        self.service = service
        // Observe changes to searchText, debounce the input to prevent excessive API calls,
        // and call seachImages(by:) to fetch the images.
        $searchText
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                self?.seachImages(by: searchText)
            }
            .store(in: &subscriptions)
    }
    
    // Function to search images based on the provided text.
    func seachImages(by text: String) {
        // If the search text is empty, update the state to loaded and clear the images array.
        guard !text.isEmpty else {
            self.uistate = .loaded
            self.images = []
            return
        }
        // Cancel any ongoing search request.
        searchCancellable?.cancel()
        self.uistate = .loading
        // Perform the search using the service.
        searchCancellable = service.searchImage(by: text)
            .receive(on: RunLoop.main)
            .sink { completion in
                // Handle the completion state of the request.
                switch completion {
                case .failure(_):
                    self.uistate = .error
                case .finished:
                    self.uistate = .loaded
                }
            } receiveValue: { response in
                // Handle the received images.
                self.images = response.items
            }
    }
}

