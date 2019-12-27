//
//  Storyboard+.swift
//  FruitDetector
//
//  Created by Matej on 24/04/2019.
//  Copyright © 2019 STRV. All rights reserved.
//

import UIKit

extension UIStoryboard {
    static func instantiate(storyboard: Storyboard.Name) -> UIViewController? {
        let storyboard = UIStoryboard(name: storyboard.rawValue, bundle: nil)
        let initialViewController = storyboard.instantiateInitialViewController()
        return initialViewController
    }
}

enum Storyboard {
    enum Name: String {
        case objectDetection = "RealtimeObjectDetection"
    }
}
