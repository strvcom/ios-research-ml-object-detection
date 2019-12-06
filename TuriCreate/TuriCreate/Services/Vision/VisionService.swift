//
//  VisionService.swift
//  HandDetectionWithTuriCreate
//
//  Created by Matej on 29/04/2019.
//  Copyright © 2019 STRV. All rights reserved.
//

import Foundation
import UIKit.UIColor
import Vision

protocol VisionServiceIputs {
    func performRequest(for imageRequestHandler: VNImageRequestHandler)
    func updateTrackedItems(trackedItems: [TrackItemType])
}

class VisionService: VisionServiceIputs {

    // MARK: Private
    fileprivate var requests = [VNRequest]()

    /// Preview used to draw bounding boxes with detected items
    fileprivate var previewView: CameraPreview!
    fileprivate var trackedItems: [TrackItemType] = []

    enum Config {
        /// Confidence in % expressed from 0 - 1 which will be used
        /// to draw bounding boxes on the images in the preview
        static let confidence: VNConfidence = 0.5
    }

    // MARK: Public
    init(with preview: CameraPreview, trackedItems: [TrackItemType] = []) {
        self.previewView = preview
        self.trackedItems = trackedItems
        setupVision()
    }

    // MARK: Inputs

    func performRequest(for imageRequestHandler: VNImageRequestHandler) {
        do {
            try imageRequestHandler.perform(requests)
        } catch {
            fatalError("Vision Service: perform request error: \(error.localizedDescription)")
        }
    }

    func updateTrackedItems(trackedItems: [TrackItemType]) {
        self.trackedItems = trackedItems
    }
}

// MARK: - Vision
extension VisionService {
    func setupVision() {

        MLModelService.modelDidUpdate = {[weak self] _ in
            self?.setupVision()
        }
        setupVisionModel()
    }

    private func setupVisionModel() {
        guard let model = try? VNCoreMLModel(for: MLModelService.getModel()) else {
            fatalError("Can't load Vision ML model")
        }

        let request = VNCoreMLRequest(model: model, completionHandler: completionRequestHandler)
        request.imageCropAndScaleOption = .scaleFill
        self.requests = [request]
    }

    func completionRequestHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNRecognizedObjectObservation], !observations.isEmpty else {
            return
        }

        DispatchQueue.main.async {
            self.drawVisionRequestResults(results: observations)
        }
    }

    func drawVisionRequestResults(results: [VNRecognizedObjectObservation]) {
        // remove all previously added masks
        previewView.removeMasks()

        let filteredResults = results.filter({ $0.confidence >= Config.confidence })

        // CoreGraphics => transforming origin from top left corner to bottom left corner
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -self.previewView.frame.height)
        let translate = CGAffineTransform.identity.scaledBy(x: self.previewView.frame.width, y: self.previewView.frame.height)

        filteredResults.forEach { (result) in
            guard let label = result.labels.first?.identifier else {
                assertionFailure("Unable to retrieve identifier for result: \(result)")
                return
            }
            guard TrackItemType.shouldTrack(items: trackedItems, for: label) else {
                print("Cannot track item: \(label) with trackedItems: \(trackedItems)")
                return
            }
            let rectangleBounds = result.boundingBox.applying(translate).applying(transform)

            let color = UIColor.yellow
            previewView.drawLayer(in: rectangleBounds, color: color, with: result.formattedConfidenceLabel)
        }
    }
}

extension VNRecognizedObjectObservation {
    var formattedConfidenceLabel: String {
        guard let identifier = self.labels.first?.identifier else { return "" }

        let percentageFormatter = NumberFormatter()
        percentageFormatter.numberStyle = .percent

        guard
            let value = percentageFormatter.string(from: NSNumber(value: confidence))
        else {
            return ""
        }

        return "\(identifier): \(value)"
    }
}
