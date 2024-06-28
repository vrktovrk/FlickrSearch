//
//  FlickerSeachedImageModel.swift
//  FlickerSearch
//
//  Created by Ranjith vanaparthi on 6/28/24.
//

import Foundation

struct FlickrImage: Identifiable, Codable, Hashable {
    static func == (lhs: FlickrImage, rhs: FlickrImage) -> Bool {
        lhs.id == rhs.id
    }
    var id: String {
        return link
    }
    let title: String
    let link: String
    let media: Media
    let description: String
    let author: String
    let published: String
    
    struct Media: Codable, Hashable {
        let m: String
    }
}

struct FlickrResponse: Codable {
    let items: [FlickrImage]
}
