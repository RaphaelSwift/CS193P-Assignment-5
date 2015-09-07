//
//  SettingsTableViewController.swift
//  Breakout
//
//  Created by Raphael Neuenschwander on 07.09.15.
//  Copyright (c) 2015 Raphael Neuenschwander. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {


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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func changeBounciness(slider: UISlider) {
        userDefaults.storePreferedBallBounciness(slider.value)
    }
    
    @IBAction func changeNumberOfBalls(sender: UISegmentedControl) {
        
    }
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
