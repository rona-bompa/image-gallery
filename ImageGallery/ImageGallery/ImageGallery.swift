//
//  ImageGallery.swift
//  ImageGallery
//
//  Created by Rona Bompa on 10.03.2022.
//

import Foundation

struct ImageGallery {

    struct AspectRatio {
        let width: Int
        let height: Int
    }

    struct Image {
        let url: URL
        let aspectRatio: AspectRatio
    }

    var name:  String = "Untitled"
    var images: [Image] = [Image]()

}
