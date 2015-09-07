//
//  UserDefaults.swift
//  Smashtag
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
    }
    
    func storePreferedBallBounciness(bounciness: Float) {
        userDefaults.setObject(bounciness, forKey: Key.PreferedBallBounciness)
    }
    func fetchPreferedBallBounciness() -> Float? {
        return userDefaults.objectForKey(Key.PreferedBallBounciness) as? Float
    }
    
    func storeNumberOfBalls(numberOfBalls number: Int) {
        userDefaults.setObject(number, forKey: Key.NumberOfBalls)
    }
    
    func fetchNumberOfBalls() -> Int? {
        return userDefaults.objectForKey(Key.NumberOfBalls) as? Int
    }
    
    func storeNumberOfBricks(numberOfBricks number: Int) {
        userDefaults.setObject(number, forKey: Key.NumberOfBricks)
    }
    
    func fetchNumberOfBricks() -> Int? {
        return userDefaults.objectForKey(Key.NumberOfBricks) as? Int
    }
    
}