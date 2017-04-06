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

    enum CapturePhotoHelperError: String, Error {
        case cantAccessCaptureConnection = "captureConnection is nil. Do you try to get photo in simulator?"
    }


    weak var delegate: CapturePhotoHelperDelegate?
    let captureSession = AVCaptureSession()

    public override init() {
        super.init()

        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        captureSession.addOutput(stillImageOutput)

        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: sampleQueue)

        let metaOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }

        if captureSession.canAddOutput(metaOutput) {
            captureSession.addOutput(metaOutput)
        }

        setCaptureDeviceForPosition(.front)

        if (metaOutput.availableMetadataObjectTypes.contains { $0 as? String == AVMetadataObjectTypeFace }) {
            metaOutput.metadataObjectTypes = [AVMetadataObjectTypeFace]
        }
    }

    func capturePhotoAsynchronously(_ handler: ((UIImage?, Error?) -> Swift.Void)!) {
        guard let captureConnection = captureConnection else {
            handler(nil, CapturePhotoHelperError.cantAccessCaptureConnection)

            return
        }

        stillImageOutput.captureStillImageAsynchronously(from: captureConnection) { sampleBuffer, error in
            var resultImage: UIImage? = nil
            var error: Error? = error

            defer { handler(resultImage, error) }

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
        guard let devices = AVCaptureDevice.devices() else {
            printErr("no devices found")

            return
        }

        guard let newCaptureDevice = devices.first(where: { device in
            guard let captureDevice = device as? AVCaptureDevice else { return false }

            return captureDevice.hasMediaType(AVMediaTypeVideo) && captureDevice.position == position
        }) as? AVCaptureDevice else {
            printErr("no sufficient devices found")

            return
        }

        do {
            let newDeviceInput = try AVCaptureDeviceInput(device: newCaptureDevice)

            captureSession.beginConfiguration()
            captureSession.removeInput(deviceInput)
            captureSession.addInput(newDeviceInput)

            if let connection = (stillImageOutput.connections.first { $0 is AVCaptureConnection }) as? AVCaptureConnection {
                connection.videoOrientation = .portrait
                captureConnection = connection
            }

            captureSession.commitConfiguration()

            captureSession.startRunning() //??

            captureDevice = newCaptureDevice
            deviceInput = newDeviceInput
        } catch {
            printErr("can't start session", error: error)
        }
    }

    private var deviceInput: AVCaptureDeviceInput?
    private var captureConnection: AVCaptureConnection?
    private (set) var captureDevice: AVCaptureDevice?
    private let stillImageOutput = AVCaptureStillImageOutput()
    private let sampleQueue = DispatchQueue(label: "com.zweigraf.DisplayLiveSamples.sampleQueue", attributes: [])
}


extension CapturePhotoHelper: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
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
    }
}
