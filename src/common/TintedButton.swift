//
//  TintedButton.swift
//  AudikoRingtones
//
//  Created by vlad on 2/14/17.
//  Copyright © 2017 Cloudiko. All rights reserved.
//

import UIKit

class TintedButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()

        guard let imageView = imageView, let image = imageView.image else {
            printErr("no imageView generated for button, or no image set")

            return
        }

        setImage(image.withRenderingMode(.alwaysTemplate), for: .selected)
    }
}
