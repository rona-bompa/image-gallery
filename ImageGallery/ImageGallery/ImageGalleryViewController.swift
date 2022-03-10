//
//  ImageGalleryViewController.swift
//  ImageGallery
//
//  Created by Rona Bompa on 10.03.2022.
//

import UIKit

class ImageGalleryViewController: UIViewController {

    /// setting the title to the ImageGallery name
//   // var imageGallery = ImageGallery() {
//        didSet {
//            title = imageGallery.name
//        }
//    }
    var imageGallery  = ImageGalleryDatabase.imageGalleries[2]


    /// setUp collectionView' delegates & gestures
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.dropDelegate = self
            collectionView.dragDelegate = self

            // later - to add pinch gesture
        }
    }

    /// width of each collectionViewCell
    private(set) lazy var cellWidth: CGFloat = collectionView.bounds.width / 2 // gap bewteen 2 columns

    // MARK: - Navigation
    /// perform segue that shows the selected gallery image
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "showImage" {
            if let vc = segue.destination as? ImageViewController {

                if let cell = sender as? ImageGalleryCollectionViewCell {
                    // Make sure we can retriee an indexPath for the given cell
                    guard let indexPath = collectionView.indexPath(for: cell) else {
                        print("Couldn't find indexPath for selected cell")
                        return
                    }
                    // setUp destionation model
                    vc.galleryImage = imageGallery.images[indexPath.item]
                }
            }
        }
    }
}

    // MARK: - Extension - DataSource
extension ImageGalleryViewController: UICollectionViewDataSource {

    /// number of images in the image gallery
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageGallery.images.count
    }

    /// cell for item at indexPath
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // dequeue reusable cell for an image's cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageGalleryCollectionViewCell", for: indexPath) as! ImageGalleryCollectionViewCell

        // setup the cell
        cell.imageURL = imageGallery.images[indexPath.item].url
        return cell
    }
}

    // MARK: - Extension - FlowLayout
extension ImageGalleryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let aspectRatio = imageGallery.images[indexPath.item].aspectRatio
        // calculating height based on width and aspect ratio
        let height: CGFloat = (cellWidth * CGFloat(aspectRatio.height)) / CGFloat(aspectRatio.width)
        // the cell's size
        return CGSize(width: cellWidth, height: height)
    }
}

    // MARK: - Extension - Drop
extension ImageGalleryViewController: UICollectionViewDropDelegate {

    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        // for external drops, we require URL & the Image
        if session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self) {
            return true
        }
        return false
    }


    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        // determine if the drag session is local or not
            let isSelf = (session.localDragSession?.localContext as? UICollectionView) ==  collectionView
        // move local, copy others
            return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
    }

    /// called when the use initiates the drop
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        // Get the destionation index path. Just insert at the begining if there is none set
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)

        // process al items being dragged
        for item in coordinator.items {
            // local drop
            if let sourceIndexPath = item.sourceIndexPath {
                guard let galleryImage = item.dragItem.localObject as? ImageGallery.Image else { break }


                // perform local drop
                collectionView.performBatchUpdates({
                    // update model
                    imageGallery.images.remove(at: sourceIndexPath.item)
                    imageGallery.images.insert(galleryImage, at: destinationIndexPath.item)

                    // update view
                    collectionView.deleteItems(at: [sourceIndexPath])
                    collectionView.insertItems(at: [destinationIndexPath])
                })
                coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
            } else {
                var url: URL?
                var aspectRatio: ImageGallery.AspectRatio?

                // get the aspect ratio of the UIImage
                item.dragItem.itemProvider.loadObject(ofClass: UIImage.self) { (provider, error) in
                    // valid UIImage?
                    if let image = provider as? UIImage {
                        // get the aspect ratio
                        aspectRatio = ImageGallery.AspectRatio(width: Int(image.size.width), height: Int(image.size.height))
                    }
                }

                // get the URL
                item.dragItem.itemProvider.loadObject(ofClass: NSURL.self) { [weak self] (provider, error) in
                    // valid URL?
                    url = provider as? URL

                    // if both are provided, perform the drop
                    if url != nil && aspectRatio != nil {
                        DispatchQueue.main.async {
                            collectionView.performBatchUpdates({
                                // update model
                                self?.imageGallery.images.insert(ImageGallery.Image(url: url!, aspectRatio: aspectRatio!), at: destinationIndexPath.item)
                                // update view
                                collectionView.insertItems(at: [destinationIndexPath])

                                // animates the item to the specific index path in the collection view
                                coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)

                            })
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Extension - Drag
extension ImageGalleryViewController: UICollectionViewDragDelegate {

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        // Set local context to Collection View
        session.localContext = collectionView

        // The image being dragged
        let draggedImage = imageGallery.images[indexPath.item]

        // For drags outside our app, the URL of the image will be provided
        let url = UIDragItem(itemProvider: NSItemProvider(object: draggedImage.url.imageURL as NSURL))

        // for local drags, the full "ImageGallery.image" will be provided
        url.localObject = draggedImage

        return [url]
    }
}



