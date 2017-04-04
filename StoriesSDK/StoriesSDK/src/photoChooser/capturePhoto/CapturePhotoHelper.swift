//
//  CapturePhotoHelper.swift
//  Stories
//
//  Created by vlad on 3/21/17.
//  Copyright © 2017 908. All rights reserved.
//

import UIKit
import AVFoundation

protocol CapturePhotoHelperDelegate: class {
    func faceObjectsAppeared(_ emotion: ImageDetector.Emotion?)
}

class CapturePhotoHelper: NSObject {
    weak var delegate: CapturePhotoHelperDelegate?
    let captureSession = AVCaptureSession()

    public override init() {
        super.init()

        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        captureSession.addOutput(stillImageOutput)

        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: sampleQueue)

        let metaOutput = AVCaptureMetadataOutput()
        metaOutput.setMetadataObjectsDelegate(self, queue: faceQueue)

        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }

        if captureSession.canAddOutput(metaOutput) {
            captureSession.addOutput(metaOutput)
        }

        setCaptureDeviceForPosition(.front)

        metaOutput.metadataObjectTypes = [AVMetadataObjectTypeFace]
    }

    func capturePhotoAsynchronously(_ handler: ((UIImage?, Error?) -> Swift.Void)!) {
        stillImageOutput.captureStillImageAsynchronously(from: captureConnection) { sampleBuffer, error in
            var resultImage: UIImage? = nil
            var error: Error? = error

            defer {
                handler(resultImage, error)
            }

            guard let buffer = sampleBuffer else {
                printErr("sampleBuffer is nil", error: error)

                return
            }

            var imageData: CFData?

            if #available(iOS 10.0, *) {
                if let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: buffer, previewPhotoSampleBuffer: nil) {
                    imageData = data as CFData
                } else {
                    imageData = nil
                }
            } else {
                imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer) as CFData
            }

            guard let data = imageData, let dataProvider = CGDataProvider(data: data) else {
                printErr("can't create data provider")

                return
            }

            guard let cgImageRef = CGImage(jpegDataProviderSource: dataProvider, decode: nil, shouldInterpolate: true, intent: .defaultIntent) else {
                printErr("can't create CGImage from data")

                return
            }

            guard let captureDevice = self.captureDevice else {
                printErr("captureDevice is nil")

                return
            }

            let orientation: UIImageOrientation = captureDevice.position == .front ? .rightMirrored : .right

            let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: orientation)

            guard let capturedPhoto = image.fixOrientation() else {
                printErr("can't access photo after fixing orientation")

                return
            }

            resultImage = capturedPhoto
        }
    }

    func setCaptureDeviceForPosition(_ position: AVCaptureDevicePosition) {
        captureSession.beginConfiguration()

        // Loop through all the capture devices on this phone
        if let devices = AVCaptureDevice.devices() {
            for device in devices {
                if let captureDevice = device as? AVCaptureDevice {
                    // Make sure this particular device supports video
                    if (captureDevice.hasMediaType(AVMediaTypeVideo)) {
                        // Finally check the position and confirm we've got the back camera
                        if (captureDevice.position == position) {
                            self.captureDevice = captureDevice

                            break
                        }
                    }
                }
            }
        }

        captureSession.removeInput(deviceInput)
        captureSession.commitConfiguration()
        beginSession()
    }

    private func beginSession() {
        do {
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(deviceInput)

            for connection in stillImageOutput.connections {
                if let connection = connection as? AVCaptureConnection {
                    connection.videoOrientation = .portrait

                    captureConnection = connection
                }
            }

            captureSession.startRunning()
            self.deviceInput = deviceInput
        } catch {
            printErr("can't start session", error: error)
        }
    }

    fileprivate var currentMetadata = [Any]()

    private var deviceInput: AVCaptureDeviceInput?
    private var captureConnection: AVCaptureConnection?
    private (set) var captureDevice: AVCaptureDevice?
    private let stillImageOutput = AVCaptureStillImageOutput()
    private let faceQueue = DispatchQueue(label: "com.zweigraf.DisplayLiveSamples.faceQueue", attributes: [])
    private let sampleQueue = DispatchQueue(label: "com.zweigraf.DisplayLiveSamples.sampleQueue", attributes: [])
}


extension CapturePhotoHelper: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        if !currentMetadata.isEmpty {
            guard let cvImage = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                printErr("can't get imageBuffer")

                return
            }

            if #available(iOS 9.0, *) {
                let ciImage = CIImage(cvImageBuffer: cvImage)

                let emotion = ImageDetector.getEmotion(from: ciImage)

                delegate?.faceObjectsAppeared(emotion)
            } else {
                // TODO: add iOS8
            }
        } else {
            delegate?.faceObjectsAppeared(nil)
        }
    }
}


extension CapturePhotoHelper: AVCaptureMetadataOutputObjectsDelegate {
    public func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        currentMetadata = metadataObjects
    }
}
