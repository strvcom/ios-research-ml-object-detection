//
//  Router.swift
//  HandDetectionWithTuriCreate
//
//  Created by Matej on 24/04/2019.
//  Copyright © 2019 STRV. All rights reserved.
//

import Foundation
import UIKit.UIViewController

enum Router {

    enum PresentationType {
        case present
        case setRoot
    }

    static func route(to route: Storyboard.Name, presentationType: PresentationType = .setRoot) {
        guard let viewController = UIStoryboard.instantiate(storyboard: route) else {
            return
        }

        guard let window: UIWindow = (UIApplication.shared.delegate as? AppDelegate)?.window else {
            fatalError("Unable to retrieve window")
        }
        switch presentationType {
        case .present:
            window.rootViewController?.present(viewController, animated: true, completion: nil)
        case .setRoot:
            window.rootViewController = viewController
        }
    }
}
