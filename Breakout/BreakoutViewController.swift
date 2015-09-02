//
//  BreakoutViewController.swift
//  Breakout
//
//  Created by Raphael Neuenschwander on 31.08.15.
//  Copyright (c) 2015 Raphael Neuenschwander. All rights reserved.
//

import UIKit

class BreakoutViewController: UIViewController, UIDynamicAnimatorDelegate, UICollisionBehaviorDelegate
{

    @IBOutlet weak var gameView: BezierPathsView!
    
    private lazy var animator: UIDynamicAnimator = {
        let lazilyCreatedAnimator = UIDynamicAnimator(referenceView: self.gameView)
        lazilyCreatedAnimator.delegate = self
        return lazilyCreatedAnimator
    }()
    
    private var paddleSize: CGSize {
        let paddleWidth = gameView.frame.width / 4
        return CGSize(width: paddleWidth, height: 20)
    }
    
    private var paddleOrigin: CGPoint? {
        didSet {
            if paddleOrigin != nil {
                setAndDrawPaddle() // setAndRedraw the paddle each time the origin changes
            }
        }
    }
    
    private var bricks = [String:UIView]()
    
    private var bricksPerRow = 5
    private var numberOfBricks = 20
    
    private var brickSize: CGSize {
        let brickWidth = gameView.frame.width / CGFloat(bricksPerRow)
        let brickHeight = brickWidth / 4
        return CGSize(width: brickWidth, height: brickHeight)
    }
    
    private let breakoutBehavior = BreakoutBehavior()
    
    private var ballActivity: Bool = false
    
    private let ballSize = CGSize(width: 10, height: 10)
    
    private var ballView: UIView? {
        didSet {
            if !ballActivity && ballView != nil {
                breakoutBehavior.addBall(ballView!)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animator.addBehavior(breakoutBehavior)
        
        for childBehavior in breakoutBehavior.childBehaviors {
            if let collisionChildBehavior = childBehavior as? UICollisionBehavior {
                    collisionChildBehavior.collisionDelegate = self
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        initGameLayout()
        
    }

    private struct PathNames {
        static let PaddleBarrier = "Paddle Barrier"
        static let GameLeftBarrier = "Game Left Barrier"
        static let GameRightBarrier = "Game Right Barrier"
        static let GameTopBarrier = "Game Top Barrier"
        static let BrickBarrier = "Brick Barrier"
    }
    
    @IBAction func pushBall(sender: UITapGestureRecognizer) {
        if ballView != nil {
            breakoutBehavior.pushBall(ballView!)
            ballActivity = true
        }
    }
    
    
    
    // Move the paddle by panning on the screen
    @IBAction func movePaddle(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Changed:
            let translation = gesture.translationInView(gameView)
            let paddleMove = translation.x
            if paddleMove != 0 {
                // ensure that the paddle remains within the game's bound
                let newPaddleOrigin = min(max(paddleOrigin!.x + paddleMove, gameView.bounds.minX), gameView.bounds.maxX - paddleSize.width)
                paddleOrigin?.x = newPaddleOrigin
                gesture.setTranslation(CGPointZero, inView: gameView) // set to 0 for incremental change
            }
            
        default: break
        }
    }
    

    //UIDynamicAnimatorDelegate 
    func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        
        // When the animators pauses, if there are no longer active items in the reference view and that the game is currently active, reinitalize the game.
        if ballActivity && animator.itemsInRect(animator.referenceView!.frame).isEmpty {
            ballActivity = false
            ballView = nil
            initGameLayout()
        }
    }
    
    func dynamicAnimatorWillResume(animator: UIDynamicAnimator) {
        //TODO: use it when returning from setting tab ?
    }
    
    //UICollisionBehaviorDelegate
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying, atPoint p: CGPoint) {
        
        // Remove brick boundary on collision
        if let identifier = identifier as? String {
            if identifier.hasPrefix(PathNames.BrickBarrier) {
                breakoutBehavior.removeBezierPath(named: identifier)
                
                // Remove the brick with animation, remove it from the superview only if the animation completes
                if let brickToRemove = bricks.removeValueForKey(identifier) {
                    animateBrickDisappearance(brickToRemove)
                }
            }
        }
    }

    // Draw the paddle
    private func setAndDrawPaddle() {
        if paddleOrigin != nil {
            let paddle = CGRect(origin: paddleOrigin!, size: paddleSize)
            let paddleBezierPath = UIBezierPath(roundedRect: paddle, cornerRadius: 5)
            gameView.setBezierPath(paddleBezierPath, named: PathNames.PaddleBarrier)
            breakoutBehavior.addBezierPath(paddleBezierPath, named: PathNames.PaddleBarrier)
        }
    }
    
    // Animates the disappearance of the brick
    private func animateBrickDisappearance(view:UIView) {
        UIView.transitionWithView(view,
            duration: 0.3,
            options: UIViewAnimationOptions.TransitionFlipFromBottom,
            animations: {view.backgroundColor = UIColor.blueColor() },
            completion: {if $0 {self.fadeAnimation(view)}})
    }
    
    // Fades the view and remove it from superview when it completes
    private func fadeAnimation(view:UIView) {
        if view.alpha == 1.0 {
            UIView.animateWithDuration(0.2,
                delay: 0.0,
                options: UIViewAnimationOptions.CurveEaseInOut,
                animations: {view.alpha = 0.0},
                completion: { if $0 { view.removeFromSuperview() }})
        }
    }
    
    // Initiliaze the game layout etc.
    private func initGameLayout() {
        
        // Clear bricks
        for (name,brick) in bricks {
            brick.removeFromSuperview()
            bricks.removeValueForKey(name)
        }

        
        //Set the paddle origin
        paddleOrigin = CGPoint(x: gameView.frame.midX  - paddleSize.width / 2, y: gameView.frame.maxY - paddleSize.height * 2)
        
        //Add the ball as a UIView, position it on the paddle , in the middle
        if let paddleOrigin = paddleOrigin {
            let ballOrigin = CGPoint(x: (paddleOrigin.x + paddleSize.width / 2 - ballSize.width / 2) , y: (paddleOrigin.y - ballSize.height))
            let ballFrame = CGRect(origin: ballOrigin, size: ballSize)
            let ballViewFrame = UIView(frame: ballFrame)
            ballViewFrame.backgroundColor = UIColor.redColor()
            if ballView == nil  {
                ballView = ballViewFrame
            }
        }
        
        // Define the game bounds/barrier
        let gameBoundLeftBezierPath = UIBezierPath()
        gameBoundLeftBezierPath.moveToPoint(CGPoint(x: gameView.frame.origin.x, y: gameView.frame.maxY))
        gameBoundLeftBezierPath.addLineToPoint(CGPoint(x: gameView.frame.origin.x, y: gameView.frame.origin.y))
        breakoutBehavior.addBezierPath(gameBoundLeftBezierPath, named: PathNames.GameLeftBarrier)
        
        let gameBoundTopBezierPath = UIBezierPath()
        gameBoundTopBezierPath.moveToPoint(CGPoint(x: gameView.frame.origin.x, y: gameView.frame.origin.y))
        gameBoundTopBezierPath.addLineToPoint(CGPoint(x: gameView.frame.maxX, y: gameView.frame.origin.y))
        breakoutBehavior.addBezierPath(gameBoundTopBezierPath, named: PathNames.GameTopBarrier)
        
        let gameBoundRightBezierPath = UIBezierPath()
        gameBoundRightBezierPath.moveToPoint(CGPoint(x: gameView.frame.maxX, y: gameView.frame.origin.y))
        gameBoundRightBezierPath.addLineToPoint(CGPoint(x: gameView.frame.maxX, y: gameView.frame.maxY))
        breakoutBehavior.addBezierPath(gameBoundRightBezierPath, named: PathNames.GameRightBarrier)
        
        // Draw the bricks
        var bricksToAdd = [CGRect]()
        var brickFrame = CGRect(x: 0, y: 0, width: brickSize.width, height: brickSize.height)
        
        do {
        brickFrame.origin.y += brickFrame.size.height
        brickFrame.origin.x = 0
        
        for _ in 0 ..< bricksPerRow {
            bricksToAdd.append(brickFrame)
            brickFrame.origin.x += brickFrame.size.width
        }
        
        } while bricksToAdd.count < numberOfBricks

        for (index,frame) in enumerate(bricksToAdd) {
            let brickPath = UIBezierPath(rect: frame)
            let brickView = UIView(frame: frame)
            let name = "\(PathNames.BrickBarrier)\(index)"
            
            // Add the brick as a boundary to the dynamic collision behavior
            breakoutBehavior.addBezierPath(brickPath, named: name)
            
            // Add the brick as a subview to the reference view
            brickView.backgroundColor = UIColor.greenColor()
            gameView.addSubview(brickView)
            bricks["\(PathNames.BrickBarrier)\(index)"]  = brickView
        }
    }
    
    
}
