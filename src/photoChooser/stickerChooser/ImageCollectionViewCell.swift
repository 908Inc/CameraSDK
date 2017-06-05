//
//  ImageCollectionViewCell.swift
//  Stories
//
//  Created by vlad on 3/10/17.
//  Copyright © 2017 908. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet fileprivate weak var imageView: UIImageView!

    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
        }
    }
}


import SDWebImage

extension ImageCollectionViewCell {
    func charge(with imageUrl: URL?, placeholderImage: UIImage?) {
        guard let url = imageUrl else {
            imageView.image = placeholderImage

            printErr("no imageUrl provided")

            return
        }

        imageView.sd_setImage(with: imageUrl, placeholderImage: placeholderImage)
    }
}
