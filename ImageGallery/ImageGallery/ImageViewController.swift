//
//  ImageViewController.swift
//  ImageGallery
//
//  Created by Rona Bompa on 10.03.2022.
//

import UIKit

class ImageViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
        }
    }

    /// the image to display
    var galleryImage: ImageGallery.Image? {
        didSet {
            if galleryImage != nil {
                fetchImage(galleryImage!.url)
            }
        }
    }

    /// fetch image
    private func fetchImage(_ url: URL) {

        DispatchQueue.global(qos: .userInitiated).async {
            if let data = try? Data(contentsOf: url.imageURL) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.imageView = UIImageView(image: image)
                    }
                }
            }
        }
    }

    /// the imageView to display
    private var imageView: UIImageView? {
        didSet {
            if imageView != nil {
                // adapt view to fit image
                imageView!.sizeToFit()

                // add imageView to scrollView
                scrollView.addSubview(imageView!)

                // update scrollView accordingly
                updateScrollView()
            } else {
                scrollView.subviews.forEach { $0.removeFromSuperview() }
            }
        }
    }

    private func updateScrollView() {
        if imageView != nil {
            let imageSize = imageView?.image?.size ?? CGSize.zero
            let displaySize = scrollView.bounds.size
            // scrollview content-size must fit the image
            scrollView.contentSize = imageSize

            // a scale that will fit the image on the screen
            let zoommScaleToFitsWholeImage = min(displaySize.width/imageSize.width,displaySize.height/imageSize.height)

            scrollView.minimumZoomScale = zoommScaleToFitsWholeImage
            scrollView.maximumZoomScale = zoommScaleToFitsWholeImage
            scrollView.maximumZoomScale = 3.0
        }
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateScrollView()
    }

}


extension ImageViewController: UICollectionViewDelegate {

    /// the view for zooming in the scrollView
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews.first as? UIImageView
    }

}
