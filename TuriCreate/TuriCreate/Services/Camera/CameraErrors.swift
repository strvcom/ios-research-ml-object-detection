//
//  CameraErrors.swift
//  HandDetectionWithTuriCreate
//
//  Created by Matej on 28/04/2019.
//  Copyright © 2019 STRV. All rights reserved.
//

import Foundation

extension Camera {
    public enum Error: Swift.Error {
        case noCameraDevicesAvailable
        case noCameraSelected
        case captureSessionUndefined
        case invalidCameraInput
        case invalidOutput

        case undefined
    }
}
