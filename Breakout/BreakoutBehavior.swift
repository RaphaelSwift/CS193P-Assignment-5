//
//  BreakoutBehavior.swift
//  Breakout
//
//  Created by Raphael Neuenschwander on 31.08.15.
//  Copyright (c) 2015 Raphael Neuenschwander. All rights reserved.
//

import UIKit

class BreakoutBehavior: UIDynamicBehavior
{
    private let collider = UICollisionBehavior()
    
    private var pusher : UIPushBehavior = {
        var lazilyCreatedPusher = UIPushBehavior(items: nil, mode: UIPushBehaviorMode.Instantaneous)
        lazilyCreatedPusher.setAngle(2, magnitude: 0.05)
        return lazilyCreatedPusher
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
    
    func addBezierPath(path:UIBezierPath,named name: String) {
        collider.removeBoundaryWithIdentifier(name)
        collider.addBoundaryWithIdentifier(name, forPath: path)
    }
   
    
    func addBall(ball:UIView) {
        
        // add the drop to the reference view (ie. it appears on screen)
        dynamicAnimator?.referenceView?.addSubview(ball)
        
        // add collider ( collusion rule) to the ball
        collider.addItem(ball)
        
        // add the push behavior to the ball
        pusher.addItem(ball)
        
        // add dynamics behavior to the ball
        ballBehavior.addItem(ball)
        
    }
    
}
