//
//  FlickerSeachView.swift
//  FlickerSearch
//
//  Created by Ranjith vanaparthi on 6/28/24.
//

import Foundation
import SwiftUI

struct SearchView: View {
    // StateObject to manage the view model for the search view.
    @StateObject private var viewModel = FlickerSearchViewModel()
    // State to track the current device orientation.
    @State private var orientation: UIDeviceOrientation = UIDevice.current.orientation
    
    var body: some View {
        NavigationStack {
            // Switch based on the state of the ViewModel to determine what to display.
            switch viewModel.uistate {
            case .intial:
                // Display an empty view when the state is initial.
                EmptyView()
            case .loading:
                // Display a progress view when the data is loading.
                ProgressView()
            case .error:
                // Display an error view when an error occurs.
                ErrorView()
            case .loaded:
                // Display a scrollable grid of images when data is loaded.
                ScrollView {
                    LazyVGrid(columns: layoutColumns) {
                        // Iterate through the images in the view model.
                        ForEach(viewModel.images) { image in
                            // Navigation link to navigate to the details view.
                            NavigationLink(destination: FlickrDeatilsView(viewModel: FlickrDetailImageViewModel(imageItem: image))) {
                                // Display the image using the DisplayImage view.
                                DisplayImage(urlString: image.media.m)
                            }
                        }
                    }
                }
            }
        }
        // Add a searchable text field to the view.
        .searchable(text: $viewModel.searchText)
        .onAppear {
            // Observe orientation changes and update the orientation state.
            NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { _ in
                orientation = UIDevice.current.orientation
            }
        }
        .onDisappear {
            // Remove the orientation change observer when the view disappears.
            NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        }
    }
    
    // Compute the layout columns based on the current device orientation.
    private var layoutColumns: [GridItem] {
        var countValue = 5
        switch orientation {
        case .unknown, .portrait, .portraitUpsideDown, .faceDown, .faceUp:
            countValue = 3
        case .landscapeLeft, .landscapeRight:
            countValue = 5
        @unknown default:
            countValue = 3
        }
        return Array(repeating: GridItem(.flexible()), count: countValue)
    }
}

// View to display an image from a URL.
struct DisplayImage: View {
    let urlString: String
    var body: some View {
        // Load the image asynchronously.
        AsyncImage(url: URL(string: urlString)) { phase in
            switch phase {
            case .empty:
                // Display a progress view while the image is loading.
                ProgressView()
            case .success(let image):
                // Display the loaded image.
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                    .transition(.opacity)
                    .animation(.easeInOut)
            case .failure:
                // Display a placeholder image if the loading fails.
                Image(systemName: "photo")
            @unknown default:
                // Display a placeholder image for unknown cases.
                Image(systemName: "photo")
            }
        }
        .frame(width: 100, height: 100)
        .cornerRadius(8)
    }
}

// View representing an error state with an option to retry fetching the data.
struct ErrorView: View {
    var body: some View {
        VStack {
            Text("Something went wrong")
                .foregroundColor(.red)
        }
    }
}

