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

    var isSquareMode = false

    override func viewDidLoad() {
        super.viewDidLoad()

        capturePhotoHelper.delegate = captureButtonView

        if let previewLayer = AVCaptureVideoPreviewLayer(session: capturePhotoHelper.captureSession) {
            view.layer.insertSublayer(previewLayer, at: 0)

            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            cameraLayer = previewLayer
        }

        imagePicker.allowsEditing = isSquareMode
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        capturePhotoHelper.captureSession.startRunning()
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        capturePhotoHelper.captureSession.stopRunning()
    }

    override func viewDidLayoutSubviews() {
        if isSquareMode {
            cameraLayer?.frame = CGRect(x: 0, y: view.centerY - view.width / 2, width: view.width, height: view.width)
        } else {
            cameraLayer?.frame = view.bounds
        }
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
            guard error == nil, var capturedPhoto = capturedPhoto else {
                printErr("can't make photo", error: error)

                UIAlertController.show(from: self, for: UIAlertController.UserAlert.lCantMakePhoto)

                return
            }

            if self.isSquareMode {
                let rect = CGRect(x: (capturedPhoto.size.height - capturedPhoto.size.width) / 2, y: 0, width: capturedPhoto.size.width, height: capturedPhoto.size.width)

                guard let cgImage = capturedPhoto.cgImage,
                      let croppedCgImage = cgImage.cropping(to: rect)
                        else {
                    UIAlertController.show(from: self, for: UIAlertController.UserAlert.lCantMakePhoto)

                    return
                }

                capturedPhoto = UIImage(cgImage: croppedCgImage, scale: capturedPhoto.scale, orientation: capturedPhoto.imageOrientation)
            }

            DispatchQueue.main.async {
                delegate.photoWasCaptured(capturedPhoto)
            }
        }
    }

    @IBAction func changeCameraButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected

        capturePhotoHelper.changeCaptureDevicePosition(to: sender.isSelected ? .back : .front)
    }


    let capturePhotoHelper = CapturePhotoHelper()
    var cameraLayer: AVCaptureVideoPreviewLayer?
    @IBOutlet weak var captureButtonView: CaptureButtonView!
}


extension CapturePhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        guard let delegate = delegate else {
            printErr("delegate isn't set")

            return
        }

        guard let chosenImage = info[UIImagePickerControllerEditedImage] as? UIImage else {
            UIAlertController.show(from: picker, for: UIAlertController.UserAlert.lBrokenImage, logMessage: "unexpected behavior; selected image isn't UIImage")

            return
        }

        guard let resultPhoto = chosenImage.fixOrientation() else {
            UIAlertController.show(from: picker, for: UIAlertController.UserAlert.lBrokenImage, logMessage: "can't access photo after fixing orientation")

            return
        }

        picker.dismiss(animated: true)
        delegate.photoWasCaptured(resultPhoto)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
