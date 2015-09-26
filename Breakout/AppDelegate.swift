//
//  AppDelegate.swift
//  Breakout
//
//  Created by Raphael Neuenschwander on 31.08.15.
//  Copyright (c) 2015 Raphael Neuenschwander. All rights reserved.
//

import UIKit
import CoreMotion

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    struct Motion{
        static let Manager = CMMotionManager()
    }

}

