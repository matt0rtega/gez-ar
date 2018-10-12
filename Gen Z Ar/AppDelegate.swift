//
//  AppDelegate.swift
//  Gen Z Ar
//
//  Created by Matthew Ortega on 10/12/18.
//  Copyright © 2018 Matthew Ortega. All rights reserved.
//

import UIKit
import ARKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        guard ARImageTrackingConfiguration.isSupported,
            ARWorldTrackingConfiguration.isSupported else {
                fatalError("ARKit is not available on this device.")
        }
        
        return true
    }
}

