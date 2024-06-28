//
//  FlickerServiceRequest.swift
//  FlickerSearch
//
//  Created by Ranjith vanaparthi on 6/28/24.
//

import Foundation
import Combine

// Protocol defining the interface for the Flickr search service.
protocol FlickerSearchServiceable {
    func searchImage(by text: String) -> AnyPublisher<FlickrResponse, NetworkError>
}

// Class implementing the Flickr search service, making network requests to fetch images.
class FlickerSearchServiceRequest: FlickerSearchServiceable {
    
    // Properties for the network request handler and the environment configuration.
    private var networkRequest: Requestable
    private var environment: Environment = .development
    
    // Initializer to inject dependencies, allowing for testability.
    init(networkRequest: Requestable, environment: Environment) {
        self.networkRequest = networkRequest
        self.environment = environment
    }
    
    // Function to search for images based on the provided text.
    func searchImage(by text: String) -> AnyPublisher<FlickrResponse, NetworkError> {
        // Create the endpoint for the search request.
        let endpoint = FlickerSearchEndpoints.getImagesBy(text: encodeSpaces(in: text))
        // Create the network request using the environment configuration.
        let request = endpoint.createRequest(environment: self.environment)
        // Perform the network request and return the result as a publisher.
        return self.networkRequest.request(request)
    }
    
    // Function to encode spaces in the search text to ensure valid URL encoding.
    func encodeSpaces(in string: String) -> String {
        let allowedCharacterSet = CharacterSet(charactersIn: " ").inverted
        return string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
    }
}

