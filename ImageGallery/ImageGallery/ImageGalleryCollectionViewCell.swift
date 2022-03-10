//
//  ImageGalleryCollectionViewCell.swift
//  ImageGallery
//
//  Created by Rona Bompa on 10.03.2022.
//

import UIKit

class ImageGalleryCollectionViewCell: UICollectionViewCell {

    // MARK: - Outlets
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    // MARK: - Cell State
    /// States of the cell
    enum State {
        case empty
        case fetching  // currently fetching something asynchronously
        case successfulFetch(UIImage)
        case failedFetch(String)
    }

    /// The state in which the cell is in at the begining:
    private(set) var state: State = .empty {
        didSet {
            updateUIforGivenState(for: state)
        }
    }

    /// update UI if Cell State changes
    private func updateUIforGivenState(for state: State) {
        switch state {
        case .empty: subviews.forEach { $0.removeFromSuperview() }
        case .fetching:
            fetchingState()
        case .successfulFetch(let image):
            successfulFetchState(image)
        case .failedFetch(let error):
            failedFetchState(error)
        }
    }

    /// Fetching
    func fetchingState() {
        subviews.forEach { $0.removeFromSuperview() }
        spinner.startAnimating()
    }

    /// Successful Fetch
    func successfulFetchState(_ image: UIImage) {
        subviews.forEach { $0.removeFromSuperview() }
        spinner.stopAnimating()
        let imageView = UIImageView(frame: self.bounds)
        imageView.image = image
        addSubview(imageView)
    }

    /// Failed Fetch
    func failedFetchState(_ errorMessage: String) {
        print("failed to fetch the image, errorMessage: \(errorMessage)")
        subviews.forEach { $0.removeFromSuperview() }
        spinner.stopAnimating()
        let errorLabel = UILabel()
        errorLabel.text = "🚫"
        errorLabel.sizeToFit()
        errorLabel.center = CGPoint(x: bounds.midX, y: bounds.midY)
        addSubview(errorLabel)
    }


    // MARK: - Fetch URL
    /// This URL should point to a valid image
    var imageURL: URL? {
        didSet {
            updateUIforGivenURL(for: imageURL)
        }
    }

    /// fetching the URL asynchronously in order not the block the main queue
    private func fetchImageAsynchronously(using url: URL) {
        // off main queue
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in

            // fetch data from given URL
            guard let data = try? Data(contentsOf: url.imageURL) else {
                // if failed, update UI in the main queue
                DispatchQueue.main.async {
                        self?.state = .failedFetch("Failed getting data form url: \(url)")
                }
                return
            }

            // create image from fetched data
            guard let image = UIImage(data: data) else {
                // if failed, update UI in the main queue
                DispatchQueue.main.async {
                    self?.state = .failedFetch("Failed creating image with data from url: \(url)")
                }
                return
            }

            // if all went well, update state and indicate successful fetch
            if self?.imageURL == url {
                DispatchQueue.main.async {
                    self?.state = .successfulFetch(image)
                }
            }
        }
    }

    /// update UI for given URL
    private func updateUIforGivenURL(for url: URL?) {
        if url == nil {
            state = .empty
        } else {
            state = .fetching
            fetchImageAsynchronously(using: url!)
        }
    }


    // MARK: - Overrides
    override func layoutSubviews() {
        super.layoutSubviews()

        // update UI layout when the state changes
        updateUIforGivenState(for: state)
    }
}
