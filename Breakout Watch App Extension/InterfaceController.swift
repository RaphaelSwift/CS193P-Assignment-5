//
//  InterfaceController.swift
//  Breakout Watch App Extension
//
//  Created by Raphael Neuenschwander on 25.09.15.
//  Copyright © 2015 Raphael Neuenschwander. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController{


    @IBAction func pushBalls() {
        // Push balls in a random direction
        let session = WCSession.defaultSession()
        if session.reachable {
            let message = ["action":"push ball"]
            session.sendMessage(message, replyHandler: { (replyMessage) -> Void in
                print(replyMessage["Reply"] as? String ?? "no message recieved")
                }, errorHandler: nil)
            session.sendMessage(message, replyHandler: nil, errorHandler: nil)
        }
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
