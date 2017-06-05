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
    @IBOutlet private weak var substrateView: UIView! {
        didSet {
            substrateView.layer.cornerRadius = substrateView.width / 2
        }
    }

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

        imageView.sd_setImage(with: url, placeholderImage: placeholderImage)
    }

    func charge(withImage image: UIImage?) {
        imageView.sd_cancelCurrentImageLoad()
        
        imageView.image = image
    }
}
