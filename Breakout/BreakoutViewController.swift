//
//  BreakoutViewController.swift
//  Breakout
//
//  Created by Raphael Neuenschwander on 31.08.15.
//  Copyright (c) 2015 Raphael Neuenschwander. All rights reserved.
//

import UIKit

class BreakoutViewController: UIViewController
{

    @IBOutlet weak var gameView: BezierPathsView!
    
    private lazy var animator: UIDynamicAnimator = {
        let lazilyCreatedAnimator = UIDynamicAnimator(referenceView: self.gameView)
        
        return lazilyCreatedAnimator
    }()
    
    private var paddleSize: CGSize {
        let paddleWidth = gameView.frame.width / 4
        return CGSize(width: paddleWidth, height: 20)
    }
    
    private let breakoutBehavior = BreakoutBehavior()
    
    private var bricksPerRow = 5
    private var numberOfBricks = 20
    
    private var brickSize: CGSize {
        let brickWidth = gameView.frame.width / CGFloat(bricksPerRow)
        let brickHeight = brickWidth / 4
        return CGSize(width: brickWidth, height: brickHeight)
    }
    
    
    private let ballSize = CGSize(width: 10, height: 10)
    
    //private var paddleFillColor: UIColor = UIColor.blueColor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animator.addBehavior(breakoutBehavior)
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
    
    private func start() {
        
    }
    
    // Initiliaze the game layout etc.
    private func initGameLayout() {
        

        //Draw the paddle
        let paddleOrigin = CGPoint(x: gameView.frame.midX  - paddleSize.width / 2, y: gameView.frame.maxY - paddleSize.height * 2)
        let paddle = CGRect(origin: paddleOrigin, size: paddleSize)
        let paddleBezierPath = UIBezierPath(roundedRect: paddle, cornerRadius: 5)
        
        gameView.setBezierPaths([paddleBezierPath], named: PathNames.PaddleBarrier)
        breakoutBehavior.addBezierPath(paddleBezierPath, named: PathNames.PaddleBarrier)
        
        //Add the ball as a UIView, position it on the padde , in the middle
        let ballOrigin = CGPoint(x: (paddleOrigin.x + paddleSize.width / 2 - ballSize.width / 2) , y: (paddleOrigin.y - ballSize.height))
        let ballFrame = CGRect(origin: ballOrigin, size: ballSize)
        let ballView = UIView(frame: ballFrame)
        ballView.backgroundColor = UIColor.redColor()
        
        breakoutBehavior.addBall(ballView)
        
        // Draw the game bounds
        let gameBoundLeftBezierPath = UIBezierPath()
        gameBoundLeftBezierPath.moveToPoint(CGPoint(x: gameView.frame.origin.x, y: gameView.frame.maxY))
        gameBoundLeftBezierPath.addLineToPoint(CGPoint(x: gameView.frame.origin.x, y: gameView.frame.origin.y))
        gameView.setBezierPaths([gameBoundLeftBezierPath], named: PathNames.GameLeftBarrier)
        breakoutBehavior.addBezierPath(gameBoundLeftBezierPath, named: PathNames.GameLeftBarrier)
        
        
        let gameBoundTopBezierPath = UIBezierPath()
        gameBoundTopBezierPath.moveToPoint(CGPoint(x: gameView.frame.origin.x, y: gameView.frame.origin.y))
        gameBoundTopBezierPath.addLineToPoint(CGPoint(x: gameView.frame.maxX, y: gameView.frame.origin.y))
        gameView.setBezierPaths([gameBoundTopBezierPath], named: PathNames.GameTopBarrier)
        breakoutBehavior.addBezierPath(gameBoundTopBezierPath, named: PathNames.GameTopBarrier)
        
        let gameBoundRightBezierPath = UIBezierPath()
        gameBoundRightBezierPath.moveToPoint(CGPoint(x: gameView.frame.maxX, y: gameView.frame.origin.y))
        gameBoundRightBezierPath.addLineToPoint(CGPoint(x: gameView.frame.maxX, y: gameView.frame.maxY))
        gameView.setBezierPaths([gameBoundRightBezierPath], named: PathNames.GameRightBarrier)
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
        
        gameView.setBezierPaths(bricksToAdd, named: PathNames.BrickBarrier)
        
    }
}
