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
            switcher.on = userDefaults.specialBricks
        }
    }
    @IBOutlet weak var gravitySwitcher: UISwitch!
    @IBOutlet weak var stepper: UIStepper! {
        didSet {
            stepper.value = Double(userDefaults.numberOfBricks)
            numberOfBricksLabel.text = "\(Int(stepper.value))"
        }
    }
    @IBOutlet weak var numberOfBricksLabel: UILabel!
    @IBOutlet weak var numberOfBallSegmentedControl: UISegmentedControl! {
        didSet {
            numberOfBallSegmentedControl.selectedSegmentIndex = (userDefaults.numberOfBalls) - 1
            numberOfBallSegmentedControl.addTarget(self, action: "storeNumberOfBalls:", forControlEvents: UIControlEvents.ValueChanged)
        }
    }

    private let userDefaults = UserDefaults()
    @IBOutlet weak var bouncinessSlider: UISlider! {
        didSet {
            bouncinessSlider.value = userDefaults.ballBounciness
        }
    }
    
    func storeNumberOfBalls(segmentController: UISegmentedControl) {
        userDefaults.numberOfBalls = segmentController.selectedSegmentIndex + 1
    }
    
    @IBAction func changedNumberOfBricks(sender: UIStepper) {
        numberOfBricksLabel.text = "\(Int(sender.value))"
    }
    
    @IBAction func changeNumberOfBricksTouchUpInside(sender: UIStepper) {
        userDefaults.numberOfBricks = Int(sender.value)
    }
    
    @IBAction func switchSpecialBricksPreference(sender: UISwitch) {
            userDefaults.specialBricks = sender.on
    }
    
    @IBAction func changeBounciness(slider: UISlider) {
        userDefaults.ballBounciness = slider.value
    }
}
