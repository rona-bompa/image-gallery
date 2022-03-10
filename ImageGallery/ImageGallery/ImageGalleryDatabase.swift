//
//  ImageGalleryDAO.swift
//  ImageGallery
//
//  Created by Rona Bompa on 10.03.2022.
//

import Foundation

class ImageGalleryDatabase {

    static var imageGalleries: [ImageGallery] = [

        ImageGallery(name: "Dogs", images: []),
        ImageGallery(name: "Stanford", images: []),
        ImageGallery(name: "Vacation", images: [
            ImageGallery.Image(url: URL(string: "http://www.grandoasiscancunresort.com/images/gallery/gallery-1.jpg")!, aspectRatio: ImageGallery.AspectRatio(width: 1, height: 1)),
            ImageGallery.Image(url: URL(string: "https://cdn-image.travelandleisure.com/sites/default/files/styles/1600x1000/public/local-experts-cancun-best-pools.jpg?itok=AnlK-wK5")!, aspectRatio: ImageGallery.AspectRatio(width: 1, height: 1))
        ])
    ]
}
