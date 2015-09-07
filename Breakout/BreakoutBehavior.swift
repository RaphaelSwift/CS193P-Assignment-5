//
//  BreakoutBehavior.swift
//  Breakout
//
//  Created by Raphael Neuenschwander on 31.08.15.
//  Copyright (c) 2015 Raphael Neuenschwander. All rights reserved.
//

import UIKit

@objc protocol BreakoutBehaviorDelegate {
    optional func didRemoveBall(ball: UIView, sender: BreakoutBehavior)
}

class BreakoutBehavior: UIDynamicBehavior, UICollisionBehaviorDelegate
{
    private lazy var collider: UICollisionBehavior =  {
        let collider = UICollisionBehavior()
        //Remove the ball when it leaves the game's bounds
        collider.action = {
            for item in collider.items {
                if let ball = item as? UIView {
                    if !CGRectIntersectsRect(ball.frame, self.dynamicAnimator!.referenceView!.bounds) { // Remove each ball that isn't within the reference view
                        self.removeBall(ball)
                    }
                }
            }
        }
        return collider
    }()
    
    private lazy var ballBehavior: UIDynamicItemBehavior = {
        let lazilyCreatedBallBehavior = UIDynamicItemBehavior()
        lazilyCreatedBallBehavior.elasticity = 1.0 // 100% energy back on collision
        lazilyCreatedBallBehavior.allowsRotation = false
        lazilyCreatedBallBehavior.resistance = 0.0
        lazilyCreatedBallBehavior.friction = 0.0
        
        return lazilyCreatedBallBehavior
    }()
    
    var delegate: BreakoutBehaviorDelegate?
    
    override init() {
        super.init()
        //Add the desired behaviors
        addChildBehavior(collider)
        addChildBehavior(ballBehavior)
    }
    
    func removeBezierPath(named name: String) {
        collider.removeBoundaryWithIdentifier(name)
    }
    
    func addBezierPath(path:UIBezierPath,named name: String) {
        removeBezierPath(named: name)
        collider.addBoundaryWithIdentifier(name, forPath: path)
    }
    
    //Push the ball in a random direction
    func pushBall(ball:UIView) {
        if let pusher = UIPushBehavior(items: [ball], mode: UIPushBehaviorMode.Instantaneous) {
            pusher.angle = CGFloat.randomRadian()
            pusher.magnitude = 0.01
            
            // Remove it from its animator once it is done acting on its items
            pusher.action = { [unowned pusher] in // mark as unowned to avoid memory cycle
                pusher.removeItem(ball)
                pusher.dynamicAnimator!.removeBehavior(pusher)
            }
            
            addChildBehavior(pusher)
        }
    }
   
    
    func addBall(ball:UIView) {
        
        // add the ball to the reference view (ie. it appears on screen)
        dynamicAnimator?.referenceView?.addSubview(ball)
        
        // add collider ( collusion rule) to the ball
        collider.addItem(ball)
        
        // add dynamics behavior to the ball
        ballBehavior.addItem(ball)
        
    }
    
    func removeBall(ball:UIView) {
        
        //remove the collider
        collider.removeItem(ball)
        
        //remove the dynamic behavior
        ballBehavior.removeItem(ball)
        
        //remove the ball from the its superView
        ball.removeFromSuperview()
        
        delegate?.didRemoveBall!(ball, sender: self)
    }
}

private extension CGFloat {
    static func randomRadian() -> CGFloat {
        let randomRadian = CGFloat(arc4random() % 361)
        let pi = CGFloat(M_PI)
        return CGFloat(randomRadian * pi / 180)
    }
}
