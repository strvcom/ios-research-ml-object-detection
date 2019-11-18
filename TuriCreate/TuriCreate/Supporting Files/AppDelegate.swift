//
//  AppDelegate.swift
//  TuriCreate
//
//  Created by Nikita Beresnev on 25/06/2019.
//  Copyright © 2019 Nikita Beresnev. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow()
        Router.route(to: .objectDetection)
        window?.makeKeyAndVisible()

        return true
    }

}

