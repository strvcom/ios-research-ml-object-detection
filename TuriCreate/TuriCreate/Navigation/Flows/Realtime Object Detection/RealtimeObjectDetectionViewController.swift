//
//  RealtimeObjectDetectionViewController.swift
//  HandDetectionWithTuriCreate
//
//  Created by Matej on 24/04/2019.
//  Copyright © 2019 STRV. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class RealtimeObjectDetectionViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet fileprivate weak var previewView: CameraPreview!
    @IBOutlet fileprivate weak var modelSegmentedControl: UISegmentedControl!


    // MARK: Properties
    private var camera: Camera!
    private var visionService: VisionService!

    var trackedItems: [TrackItemType] {
        var items = [TrackItemType]()
        items.append(.pineapple)
        items.append(.apple)
        items.append(.dragonFruit)
        items.append(.mango)
        return items
    }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCamera()
        configureVision()
        configureSegmentedControl()
    }

    private func configureVision() {
        self.visionService = VisionService(with: previewView, trackedItems: trackedItems)
    }

    private func configureSegmentedControl() {
        modelSegmentedControl.removeAllSegments()

        let models = MLModelService.Model.allCases
        models.forEach { (model) in
            modelSegmentedControl.insertSegment(withTitle: model.title, at: model.rawValue, animated: false)
        }

        modelSegmentedControl.selectedSegmentIndex = MLModelService.currentlySelectedModel.rawValue
    }

    @IBAction func modelSelectionDidChange() {
        guard let selectedModel = MLModelService.Model(rawValue: modelSegmentedControl.selectedSegmentIndex) else {
            return
        }
        MLModelService.switchModel(to: selectedModel)
    }

    @IBAction func switchValueChanged() {
        visionService.updateTrackedItems(trackedItems: trackedItems)
    }
}

// MAKR: - Camera
extension RealtimeObjectDetectionViewController {
    fileprivate func configureCamera() {
        self.camera = Camera(with: self)
        camera.startCameraSession { (error) in
            if let error = error {
                fatalError("Camera start sesssion error: \(error.localizedDescription)")
            }
            DispatchQueue.main.async { [weak self] in
                self?.camera.getPreviewLayer(for: self!.previewView)
            }
        }
    }
}

extension RealtimeObjectDetectionViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        var requestOptions: [VNImageOption: Any] = [:]
        if let cameraIntrensicData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
            requestOptions = [.cameraIntrinsics: cameraIntrensicData]
        }

        let exifOrientation = camera!.exifOrientationFromDeviceOrientation()
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                                        orientation: CGImagePropertyOrientation(rawValue: UInt32(exifOrientation))!,
                                                        options: requestOptions)
        visionService.performRequest(for: imageRequestHandler)
    }
}
