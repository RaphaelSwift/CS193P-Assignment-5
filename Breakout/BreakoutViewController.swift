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
    
    private var bricksPerRow = 5
    private var numberOfBricks = 20
    
    private var brickSize: CGSize {
        let brickWidth = gameView.frame.width / CGFloat(bricksPerRow)
        let brickHeight = brickWidth / 4
        return CGSize(width: brickWidth, height: brickHeight)
    }
    
    private let breakoutBehavior = BreakoutBehavior()
    
    private var activeBallView: Bool = false
    
    private let ballSize = CGSize(width: 10, height: 10)
    
    private var ballView: UIView? {
        didSet {
            if !activeBallView && ballView != nil {
                gameView.addSubview(ballView!)
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
    
    @IBAction func start(sender: UITapGestureRecognizer) {
        start()
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
    
    private func start() {
        if !activeBallView {
            if let existingBallView = ballView {
                breakoutBehavior.addBall(ballView!)
                activeBallView = true
            }
        }
    }
    

    //UIDynamicAnimatorDelegate 
    func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        // The dynamicAnimator pauses when all the balls are off the screen
        ballView = nil
        activeBallView = false
        initGameLayout()
    }
    
    func dynamicAnimatorWillResume(animator: UIDynamicAnimator) {
        
    }
    
    //UICollisionBehaviorDelegate
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying, atPoint p: CGPoint) {
        
        // Remove brick boundary on collision
        if let identifier = identifier as? String {
            if identifier.hasPrefix(PathNames.BrickBarrier) {
                breakoutBehavior.removeBezierPath(named: identifier)
                gameView.setBezierPath(nil, named: identifier)
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
    
    // Initiliaze the game layout etc.
    private func initGameLayout() {
        
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
        var bricksToAdd = [UIBezierPath]()
        var brickFrame = CGRect(x: 0, y: 0, width: brickSize.width, height: brickSize.height)
        
        do {
        brickFrame.origin.y += brickFrame.size.height
        brickFrame.origin.x = 0
        
        for _ in 0 ..< bricksPerRow {
            let bezierPath = UIBezierPath(rect: brickFrame)
            bricksToAdd.append(bezierPath)
            brickFrame.origin.x += brickFrame.size.width
        }
        
        } while bricksToAdd.count < numberOfBricks

        for (index,path) in enumerate(bricksToAdd) {
            gameView.setBezierPath(path, named: "\(PathNames.BrickBarrier)\(index)")
            breakoutBehavior.addBezierPath(path, named: "\(PathNames.BrickBarrier)\(index)")
        }
        
    }
}
