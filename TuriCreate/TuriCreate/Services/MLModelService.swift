//
//  MLModelService.swift
//  HandDetectionWithTuriCreate
//
//  Created by Matej on 29/04/2019.
//  Copyright © 2019 STRV. All rights reserved.
//

import Foundation
import CoreML

// Lazily loading models to make sure that there is max
// one instance of any given model and any time

private let fruits_2000_model = model_2000().model
private let fruits_custom_model = custom_model().model

enum MLModelService  {

    enum Model: Int, CaseIterable {
        case fruits_2000, fruits_custom

        var modelDescription: String {
            switch self {
            case .fruits_2000:
                return "Fruits 2000 model"
            case .fruits_custom:
                return "Custom Trained Model"

            }
        }

        var title: String {
            switch self {
            case .fruits_2000:
                return "Fruits 2000 iterations"
            case .fruits_custom:
                return "Fruits custom model"
            }
        }
    }

    // MARK: - Public
    static var currentlySelectedModel: MLModelService.Model = .fruits_2000
    static var modelDidUpdate: ((MLModelService.Model) -> Void)?

    static func getModel() -> MLModel {
        switch currentlySelectedModel {
        case .fruits_2000:
            return fruits_2000_model
        case .fruits_custom:
            return fruits_custom_model
        }
    }

    static func switchModel(to model: MLModelService.Model) {
        currentlySelectedModel = model
        modelDidUpdate?(model)
    }
}
