//
//  SettingsTableViewController.swift
//  Breakout
//
//  Created by Raphael Neuenschwander on 07.09.15.
//  Copyright (c) 2015 Raphael Neuenschwander. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var switcher: UISwitch! {
        didSet {
            switcher.on = userDefaults.fetchSpecialBrickPreference()
        }
    }
    @IBOutlet weak var gravitySwitcher: UISwitch!
    @IBOutlet weak var stepper: UIStepper! {
        didSet {
            if let bricks = userDefaults.fetchNumberOfBricks() {
                stepper.value = Double(bricks)
            } else {
                stepper.value = stepper.minimumValue
            }
            numberOfBricksLabel.text = "\(Int(stepper.value))"
        }
    }
    @IBOutlet weak var numberOfBricksLabel: UILabel!
    @IBOutlet weak var numberOfBallSegmentedControl: UISegmentedControl! {
        didSet {
            numberOfBallSegmentedControl.selectedSegmentIndex = (userDefaults.fetchNumberOfBalls() ?? 1) - 1
            numberOfBallSegmentedControl.addTarget(self, action: "storeNumberOfBalls:", forControlEvents: UIControlEvents.ValueChanged)
        }
    }

    private let userDefaults = UserDefaults()
    @IBOutlet weak var bouncinessSlider: UISlider! {
        didSet {
            bouncinessSlider.value = userDefaults.fetchPreferedBallBounciness() ?? 1.0
        }
    }
    
    func storeNumberOfBalls(segmentController: UISegmentedControl) {
        userDefaults.storeNumberOfBalls(numberOfBalls: segmentController.selectedSegmentIndex + 1)
    }
    
    @IBAction func changedNumberOfBricks(sender: UIStepper) {
        numberOfBricksLabel.text = "\(Int(sender.value))"
    }
    
    @IBAction func changeNumberOfBricksTouchUpInside(sender: UIStepper) {
        userDefaults.storeNumberOfBricks(numberOfBricks: Int(sender.value))
    }
    
    @IBAction func switchSpecialBricksPreference(sender: UISwitch) {
            userDefaults.storeSpecialBrickPreference(sender.on)
    }
    
    @IBAction func changeBounciness(slider: UISlider) {
        userDefaults.storePreferedBallBounciness(slider.value)
    }
}
