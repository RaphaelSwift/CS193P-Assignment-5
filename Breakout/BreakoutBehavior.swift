//
//  BreakoutBehavior.swift
//  Breakout
//
//  Created by Raphael Neuenschwander on 31.08.15.
//  Copyright (c) 2015 Raphael Neuenschwander. All rights reserved.
//

import UIKit

class BreakoutBehavior: UIDynamicBehavior, UICollisionBehaviorDelegate
{
    private lazy var collider: UICollisionBehavior =  {
        let collider = UICollisionBehavior()
        //Remove the ball when it leaves the game's bounds
        collider.action = {
            for item in collider.items {
                if let ball = item as? UIView {
                    let ballPosition = ball.center
                    if self.dynamicAnimator?.referenceView?.pointInside(ballPosition, withEvent: nil) == false {
                        self.removeBall(ball)
                    }
                }
            }
        }
        
        return collider
        }()
    
    private lazy var pusher : UIPushBehavior? = { //"Lazy" because we want to configure it
        if let lazilyCreatedPusher = UIPushBehavior(items: nil, mode: UIPushBehaviorMode.Instantaneous) {
            lazilyCreatedPusher.angle = 2
            lazilyCreatedPusher.magnitude = 0.05
            
            // Remove it from its animator once it is done acting on its items
            lazilyCreatedPusher.action = { [unowned lazilyCreatedPusher] in // mark as unowned to avoid memory cycle
                lazilyCreatedPusher.dynamicAnimator?.removeBehavior(lazilyCreatedPusher)
            }
            return lazilyCreatedPusher
        } else {
            return nil
            }
        }()
    
    private lazy var ballBehavior: UIDynamicItemBehavior = {
        let lazilyCreatedBallBehavior = UIDynamicItemBehavior()
        lazilyCreatedBallBehavior.elasticity = 1.0 // 100% energy back on collision
        lazilyCreatedBallBehavior.allowsRotation = false
        lazilyCreatedBallBehavior.resistance = 0.0
        lazilyCreatedBallBehavior.friction = 0.0
        
        return lazilyCreatedBallBehavior
    }()
    
    override init() {
        super.init()
        
        //Add the desired behaviors
        addChildBehavior(collider)
        addChildBehavior(pusher)
        addChildBehavior(ballBehavior)
    }
    
    func removeBezierPath(named name: String) {
        collider.removeBoundaryWithIdentifier(name)
    }
    
    func addBezierPath(path:UIBezierPath,named name: String) {
        removeBezierPath(named: name)
        collider.addBoundaryWithIdentifier(name, forPath: path)
    }
   
    
    func addBall(ball:UIView) {
        
        // add the drop to the reference view (ie. it appears on screen)
        //dynamicAnimator?.referenceView?.addSubview(ball)
        
        // add collider ( collusion rule) to the ball
        collider.addItem(ball)
        
        // add the push behavior to the ball
        pusher?.addItem(ball)
        
        // add dynamics behavior to the ball
        ballBehavior.addItem(ball)
        
    }
    
    func removeBall(ball:UIView) {
        
        //remove the collider
        collider.removeItem(ball)
        
        //remove the push behavior
        pusher?.removeItem(ball)
        
        //remove the dynamic behavior
        ballBehavior.removeItem(ball)
        
        //remove the ball from the its superView
        ball.removeFromSuperview()
    }
}
