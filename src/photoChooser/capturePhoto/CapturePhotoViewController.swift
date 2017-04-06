//
//  PhotoChooser.swift
//  Stories
//
//  Created by vlad on 8/9/16.
//  Copyright © 2016 908. All rights reserved.
//

import UIKit
import Messages
import AVFoundation

protocol CapturePhotoViewControllerDelegate: class {
    func photoWasCaptured(_ photo: UIImage)
}

class CapturePhotoViewController: UIViewController {
    @IBOutlet var imagePicker: UIImagePickerController!
    weak var delegate: CapturePhotoViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        capturePhotoHelper.delegate = captureButtonView

        if let previewLayer = AVCaptureVideoPreviewLayer(session: capturePhotoHelper.captureSession) {
            view.layer.insertSublayer(previewLayer, at: 0)

            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            cameraLayer = previewLayer
        }
    }

    override func viewDidLayoutSubviews() {
        cameraLayer?.frame = view.bounds
    }

    @IBAction func showPhotoPickerTapped(_ sender: UIButton) {
        show(imagePicker, sender: nil)
    }

    @IBAction private func capturePhotoTapped() {
        guard let delegate = delegate else {
            printErr("delegate wasn't set")

            return
        }

        capturePhotoHelper.capturePhotoAsynchronously { capturedPhoto, error in
            guard error == nil, let capturedPhoto = capturedPhoto else {
                printErr("can't make photo", error: error)

                UIAlertController.show(from: self, for: UIAlertController.UserAlert.lCantMakePhoto)

                return
            }

            DispatchQueue.main.async {
                delegate.photoWasCaptured(capturedPhoto)
            }
        }
    }

    @IBAction func changeCameraButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected

        capturePhotoHelper.setCaptureDeviceForPosition(sender.isSelected ? .back : .front)
    }


    private let capturePhotoHelper = CapturePhotoHelper()
    private var cameraLayer: AVCaptureVideoPreviewLayer?
    @IBOutlet weak var captureButtonView: CaptureButtonView!
}


extension CapturePhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        guard let delegate = delegate else {
            printErr("delegate isn't set")

            return
        }

        guard let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            UIAlertController.show(from: self, for: UIAlertController.UserAlert.lBrokenImage, logMessage: "unexpected behavior; selected image isn't UIImage")

            return
        }

        guard let resultPhoto = chosenImage.fixOrientation() else {
            UIAlertController.show(from: self, for: UIAlertController.UserAlert.lBrokenImage, logMessage: "can't access photo after fixing orientation")

            return
        }

        picker.dismiss(animated: true)
        delegate.photoWasCaptured(resultPhoto)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
