//
//  CameraPreview.swift
//  HandDetectionWithTuriCreate
//
//  Created by Matej on 28/04/2019.
//  Copyright © 2019 STRV. All rights reserved.
//

import UIKit
import AVFoundation

/// UIImageView with support for drawing bounding boxes
class CameraPreview: UIImageView {
    private var maskLayer = [CALayer]()
}

// MARK: - Public
extension CameraPreview {
    // MARK: AV capture properties
    var previewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }

    var session: AVCaptureSession? {
        get {
            return previewLayer.session
        }
        set {
            previewLayer.session = newValue
        }
    }

    func drawLayer(in rect: CGRect, color: UIColor = .yellow, with label: String) {

        let mask = CAShapeLayer()
        let textLayer = CATextLayer()
        
        mask.frame = rect
        textLayer.frame = rect

        mask.backgroundColor = color.cgColor
        mask.opacity = 0.4
        mask.cornerRadius = 12

        mask.borderColor = color.cgColor
        mask.borderWidth = 2.0
        
        textLayer.string = label
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.fontSize = 12

        maskLayer.append(mask)
        maskLayer.append(textLayer)
        layer.insertSublayer(mask, at: 1)
        layer.addSublayer(textLayer)
    }

    func removeMasks() {
        for mask in maskLayer {
            mask.removeFromSuperlayer()
        }
        maskLayer.removeAll()
    }
}
