//
//  ImageViewController.swift
//  ImageGallery
//
//  Created by Rona Bompa on 10.03.2022.
//

import UIKit

class ImageViewController: UIViewController {

    var galleryImage: ImageGallery.Image? {
        didSet {
//            if galleryItem != nil {
//                fetchImagE(galleryImage!.imageURL)
//            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
