//
//  Camera.swift
//  HandDetectionWithTuriCreate
//
//  Created by Matej on 28/04/2019.
//  Copyright © 2019 STRV. All rights reserved.
//

import Foundation
import UIKit.UIView
import AVFoundation

public protocol CameraProtocol {
    func startCameraSession(completion: @escaping ((Camera.Error?) -> Void))
    func getPreviewLayer(for view: UIView)
    func toggleInputs()
}

public class Camera {
    // MARK: Properties
    private let cameraQueue = DispatchQueue(label: "cameraFramework.camera.session.queue")
    private var captureSession: AVCaptureSession?
    private weak var sampleBufferDelegate: AVCaptureVideoDataOutputSampleBufferDelegate?

    // Camera
    private var frontCamera: AVCaptureDevice?
    private var backCamera: AVCaptureDevice?
    private var captureDeviceOutput: AVCapturePhotoOutput?

    // TODO: - is it able to use only this one instead of front and rear at the same time
    private var currentlySelectedCamera: AVCaptureDevice? {
        switch currentCameraSelection {
        case .front: return frontCamera
        case .back: return backCamera
        default: return nil
        }
    }

    public init(with delegate: AVCaptureVideoDataOutputSampleBufferDelegate) {
        self.sampleBufferDelegate = delegate
    }

    var currentCameraSelection: AVCaptureDevice.Position = .back
}

// MARK: - Public
extension Camera: CameraProtocol {
    public func startCameraSession(completion: @escaping ((Camera.Error?) -> Void)) {
        cameraQueue.async {[weak self] in
            self?.createCaptureSession()

            do {
                try self?.configureCaptureDevices()
                try self?.configureCaptureDeviceInput()
                try self?.configureCaptureDeviceOutput()
            } catch {
                completion((error as? Camera.Error) ?? Camera.Error.undefined)
                return
            }
            self?.captureSession?.startRunning()
            completion(nil)
        }
    }

    public func toggleInputs() {
        guard let captureSession = captureSession else {
            return
        }
        currentCameraSelection = currentCameraSelection == .back ? .front : .back
        guard
            let camera = currentlySelectedCamera,
            let captureInput = try? AVCaptureDeviceInput(device: camera) else {
                return
        }
        captureSession.removeInput(captureSession.inputs.first!)
        if captureSession.canAddInput(captureInput) {
            captureSession.addInput(captureInput)
        }
    }

    public func getPreviewLayer(for view: UIView) {
        guard let captureSession = captureSession, captureSession.isRunning else {
            return
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.connection?.videoOrientation = .portrait

        view.layer.insertSublayer(previewLayer, at: 0)
        previewLayer.frame = view.frame
    }

    func exifOrientationFromDeviceOrientation() -> Int32 {
        enum DeviceOrientation: Int32 {
            case top0ColLeft = 1
            case top0ColRight = 2
            case bottom0ColRight = 3
            case bottom0ColLeft = 4
            case left0ColTop = 5
            case right0ColTop = 6
            case right0ColBottom = 7
            case left0ColBottom = 8
        }
        var exifOrientation: DeviceOrientation

        switch UIDevice.current.orientation {
        case .portraitUpsideDown:
            exifOrientation = .left0ColBottom
        case .landscapeLeft:
            exifOrientation = self.currentCameraSelection == .front ? .bottom0ColRight : .top0ColLeft
        case .landscapeRight:
            exifOrientation = self.currentCameraSelection == .front ? .top0ColLeft : .bottom0ColRight
        default:
            exifOrientation = .right0ColTop
        }
        return exifOrientation.rawValue
    }
}

// MARK: - Private
private extension Camera {

    private func createCaptureSession() {
        let captureSession = AVCaptureSession()
        self.captureSession = captureSession
    }

    private func configureCaptureDevices() throws {
        // Find available devices
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                mediaType: .video,
                                                                position: .unspecified)
        let discoveredDevices = discoverySession.devices
        guard !discoveredDevices.isEmpty else {
            throw(Camera.Error.noCameraDevicesAvailable)
        }
        discoveredDevices.forEach { (camera) in
            switch camera.position {
            case .front:
                self.frontCamera = camera
            case .back:
                self.backCamera = camera

                do {
                    try camera.lockForConfiguration()
                    camera.focusMode = .continuousAutoFocus
                    camera.unlockForConfiguration()
                } catch {
                    print("Camera was not locked, focus mode not set to .continuousAutoFocus, but stayed in: \(camera.focusMode)")
                }
            case .unspecified:
                print("Unspecified camera: \(camera)")
            default:
                print("Added unhandled camera case: \(camera)")
            }
        }
    }

    private func configureCaptureDeviceInput() throws {
        guard let captureSession = captureSession else {
            throw(Camera.Error.captureSessionUndefined)
        }
        guard let camera = currentlySelectedCamera else {
            throw(Camera.Error.noCameraSelected)
        }

        let cameraInput: AVCaptureDeviceInput
        do {
            cameraInput = try AVCaptureDeviceInput(device: camera)
        } catch {
            throw(Camera.Error.invalidCameraInput)
        }

        if captureSession.canAddInput(cameraInput) {
            captureSession.addInput(cameraInput)
        }
    }

    private func configureCaptureDeviceOutput() throws {
        guard let captureSession = captureSession else {
            throw(Camera.Error.captureSessionUndefined)
        }

        let captureDeviceOutput = AVCaptureVideoDataOutput()
        captureDeviceOutput.videoSettings = [
            ((kCVPixelBufferPixelFormatTypeKey as NSString) as String): NSNumber(value:kCVPixelFormatType_32BGRA)]

        captureDeviceOutput.setSampleBufferDelegate(sampleBufferDelegate!, queue: cameraQueue)
        captureDeviceOutput.alwaysDiscardsLateVideoFrames = true

        if captureSession.canAddOutput(captureDeviceOutput) {
            captureSession.addOutput(captureDeviceOutput)
        } else {
            throw(Camera.Error.invalidOutput)
        }
    }
}
