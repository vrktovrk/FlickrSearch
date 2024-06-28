//
//  FlickrDetailImageViewModel.swift
//  FlickerSearch
//
//  Created by Ranjith vanaparthi on 6/28/24.
//

import SwiftUI

final class FlickrDetailImageViewModel: ObservableObject {
    var imageItem: FlickrImage

    init(imageItem: FlickrImage) {
        self.imageItem = imageItem
    }
}
