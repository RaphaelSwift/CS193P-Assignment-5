//
//  UserDefaults.swift
//  Breakout
//
//  Created by Raphael Neuenschwander on 20.08.15.
//  Copyright (c) 2015 Raphael Neuenschwander. All rights reserved.
//

import Foundation
import UIKit

class UserDefaults {
    
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    
    private struct Key {
        static let PreferedBallBounciness = "UserDefaults.Key.PreferedBallBounciness"
        static let NumberOfBalls = "UserDefaults.Key.NumberOfBalls"
        static let NumberOfBricks = "UserDefaults.Key.NumberOfBricks"
        static let SpecialBricksPreference = "UserDefaults.Key.SpecialBricksPreference"
    }
    
    private struct DefaultGameSettings {
        static let BallBounciness: Float = 1.0
        static let NumberOfBalls: Int = 1
        static let NumberOfBricks: Int = 5
        static let SpecialBricks: Bool = true
    }
    
    var ballBounciness: Float {
        get { return userDefaults.objectForKey(Key.PreferedBallBounciness) as? Float ?? DefaultGameSettings.BallBounciness }
        set { userDefaults.setObject(newValue, forKey: Key.PreferedBallBounciness) }
    }
    
    var numberOfBalls: Int {
        get { return userDefaults.objectForKey(Key.NumberOfBalls) as? Int ?? DefaultGameSettings.NumberOfBalls }
        set { userDefaults.setObject(newValue, forKey: Key.NumberOfBalls)}
    }
    
    var numberOfBricks: Int {
        get { return userDefaults.objectForKey(Key.NumberOfBricks) as? Int ?? DefaultGameSettings.NumberOfBricks }
        set { userDefaults.setObject(newValue, forKey: Key.NumberOfBricks)}
    }
    
    var specialBricks: Bool {
        get { return userDefaults.objectForKey(Key.SpecialBricksPreference) as? Bool ?? DefaultGameSettings.SpecialBricks }
        set { userDefaults.setObject(newValue, forKey: Key.SpecialBricksPreference) }
    }
}