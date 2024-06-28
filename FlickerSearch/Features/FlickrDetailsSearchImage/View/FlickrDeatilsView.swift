//
//  FlickrDeatilsView.swift
//  FlickerSearch
//
//  Created by Ranjith vanaparthi on 6/28/24.
//

import Foundation
import SwiftUI

struct FlickrDeatilsView: View {
    // ObservedObject to manage the view model for the details view.
    @ObservedObject private var viewModel: FlickrDetailImageViewModel

    // Initializer to inject the view model.
    init(viewModel: FlickrDetailImageViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            // Load and display the image asynchronously.
            AsyncImage(url: URL(string: viewModel.imageItem.media.m)) { phase in
                switch phase {
                case .empty:
                    // Show a progress view while the image is loading.
                    ProgressView()
                case .success(let image):
                    // Display the image when loading is successful.
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                case .failure:
                    // Show a placeholder image if loading fails.
                    Image(systemName: "photo")
                @unknown default:
                    // Show a placeholder image for unknown cases.
                    Image(systemName: "photo")
                }
            }
            // Display the title of the image.
            Text(viewModel.imageItem.title)
                .font(.headline)
                .padding(.top)
            // Display the description of the image.
            Text(viewModel.imageItem.description)
                .font(.subheadline)
                .padding(.top)
            // Display the author of the image.
            Text("Author: \(viewModel.imageItem.author)")
                .font(.subheadline)
                .padding(.top)
            // Display the published date of the image.
            Text("Published: \(formatDate(viewModel.imageItem.published))")
                .font(.subheadline)
                .padding(.top)
            // Display the size of the image if available.
            if let size = extractImageSize(from: viewModel.imageItem.description) {
                Text("Size: \(size.width) x \(size.height)")
                    .font(.subheadline)
                    .padding(.top)
            }
            // Button to share the image.
            Button(action: shareImage) {
                Text("Share")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.top)
            Spacer()
        }
        .padding()
    }
    
    // Function to format the date string.
    func formatDate(_ dateString: String) -> String {
        let dateFormatter = ISO8601DateFormatter()
        if let date = dateFormatter.date(from: dateString) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .medium
            return formatter.string(from: date)
        }
        return dateString
    }
    
    // Function to extract the image size from the description.
    func extractImageSize(from description: String) -> (width: Int, height: Int)? {
        let pattern = "\\s(\\d+)\\sx\\s(\\d+)\\s"
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: description, range: NSRange(description.startIndex..., in: description)) {
            if let widthRange = Range(match.range(at: 1), in: description),
               let heightRange = Range(match.range(at: 2), in: description) {
                let width = Int(description[widthRange])
                let height = Int(description[heightRange])
                if let width = width, let height = height {
                    return (width, height)
                }
            }
        }
        return nil
    }
    
    // Function to share the image using a share sheet.
    func shareImage() {
        let url = URL(string: viewModel.imageItem.media.m)!
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        // Present the share sheet.
        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
}

