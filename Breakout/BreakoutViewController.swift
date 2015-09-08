//
//  BreakoutViewController.swift
//  Breakout
//
//  Created by Raphael Neuenschwander on 31.08.15.
//  Copyright (c) 2015 Raphael Neuenschwander. All rights reserved.
//

import UIKit

class BreakoutViewController: UIViewController, UIDynamicAnimatorDelegate, UICollisionBehaviorDelegate, BreakoutBehaviorDelegate
{

    @IBOutlet weak var gameView: BezierPathsView!
    
    private let userDefaults = UserDefaults()
    
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
    
    private var bricks = [String:Brick]()
    
    private var bricksRemaining: Int? {
        didSet {
            if bricksRemaining == 0 { // Corresponds to the state where all the bricks have been eliminated
                gameScore += Score.PointForCompletingGame
                for ball in ballView! {
                    gameScore += Score.PointForEachRemainingBall
                    breakoutBehavior.removeBall(ball)
                }
            }
        }
    }
    
    private var bricksPerRow = 5
    
    private var numberOfBricks: Int {
        return userDefaults.fetchNumberOfBricks() ?? 5
    }
    
    private var numberOfBricksForCurrentGame: Int?
    
    private var numberOfBalls: Int  {
        return userDefaults.fetchNumberOfBalls() ?? 1
    }
    
    private var brickSize: CGSize {
        let brickWidth = gameView.frame.width / CGFloat(bricksPerRow)
        let brickHeight = brickWidth / 4
        return CGSize(width: brickWidth, height: brickHeight)
    }
    
    private var specialBricks: Bool {
        return userDefaults.fetchSpecialBrickPreference()
    }
    
    private let breakoutBehavior = BreakoutBehavior()
    private let settings = SettingsTableViewController()
    
    private var gameIsActive: Bool = false {
        didSet {
            if oldValue == false && gameIsActive == true {
                bricksRemaining = numberOfBricks
            }
        }
    }
    
    private let ballSize = CGSize(width: 12, height: 12)
    
    private var ballView: [UIView]? {
        didSet {
            if !gameIsActive && ballView != nil {
                for ball in ballView! {
                    breakoutBehavior.addBall(ball)
                }
            }
        }
    }
    
    private var gameScore: Int = 0 
    private struct Score {
        static let PointPerBrickHit = 1
        static let PointForCompletingGame = 50
        static let PointForEachRemainingBall = 10
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        //setBackgroundImage()
        
        breakoutBehavior.setElasticity(CGFloat(userDefaults.fetchPreferedBallBounciness() ?? 1.0))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        breakoutBehavior.delegate = self
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
    
    private struct Constants {
        static let BallColor = UIColor.redColor()
        static let BallCornerRadius: CGFloat = 5.0
        static let BrickColor = UIColor.greenColor()
        static let SpecialBrickColor = UIColor.cyanColor()
        static let SpecialBallColor = UIColor.blueColor()
        static let BrickFadingColor = UIColor.darkGrayColor()
        static let BrickBorderColor = UIColor.darkGrayColor()
        static let BrickBorderWidth: CGFloat = 1
        static let DefaultOccurenceOfSpecialBricks = 0.15
        static let BackgroundImage = "NebulaBackground"
    }

    private struct PathNames {
        static let PaddleBarrier = "Paddle Barrier"
        static let GameLeftBarrier = "Game Left Barrier"
        static let GameRightBarrier = "Game Right Barrier"
        static let GameTopBarrier = "Game Top Barrier"
        static let BrickBarrier = "Brick Barrier"
    }
    private struct Brick {
        var view: UIView
        var type: BrickType
        
        enum BrickType {
            case Normal
            case Special
        }
    }
    
    @IBAction func pushBall(sender: UITapGestureRecognizer) {
        if ballView != nil {
            for ball in ballView! {
                breakoutBehavior.pushBall(ball)
            }
            gameIsActive = true
        }
    }
    
    private func setBackgroundImage() {
        
        if let image = UIImage(named: Constants.BackgroundImage) {
            gameView.backgroundColor = UIColor(patternImage: image)
        }
    }
    
    // Move the paddle by panning on the screen
    @IBAction func movePaddle(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Changed:
            if gameIsActive { // can only move the the paddle if the game is active (ie. ball is active)
                let translation = gesture.translationInView(gameView)
                let paddleMove = translation.x
                if paddleMove != 0 {
                    // ensure that the paddle remains within the game's bound
                    let newPaddleOrigin = min(max(paddleOrigin!.x + paddleMove, gameView.bounds.minX), gameView.bounds.maxX - paddleSize.width)
                    paddleOrigin?.x = newPaddleOrigin
                    gesture.setTranslation(CGPointZero, inView: gameView) // set to 0 for incremental change
                }
            }
        default: break
        }
    }
    
    //MARK: - BreakoutBehaviorDelegate
    func didRemoveBall(ball: UIView, sender: BreakoutBehavior) {
        if let index = find(ballView!, ball) {
            ballView?.removeAtIndex(index)
        }
    }

    //MARK: - UIDynamicAnimatorDelegate
    func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        
        // When the animators pauses, if there are no longer active items in the reference view and that the game is currently active, reinitalize the game.
        if gameIsActive && animator.itemsInRect(animator.referenceView!.bounds).isEmpty {
            gameIsActive = false
            ballView = nil
            gameOverAlert()
        }
    }
    
    func dynamicAnimatorWillResume(animator: UIDynamicAnimator) {
        //TODO: use it when returning from setting tab ?
    }
    
    //MARK: - UICollisionBehaviorDelegate
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying, atPoint p: CGPoint) {
        
        // Remove brick on collision
        if let identifier = identifier as? String {
            if identifier.hasPrefix(PathNames.BrickBarrier) {
                let brick = bricks.removeValueForKey(identifier)!
                breakoutBehavior.removeBezierPath(named: identifier)
                breakoutBehavior.addBrick(brick.view)
                animateBrickDisappearance(brick.view)
                gameScore += Score.PointPerBrickHit
                bricksRemaining!--
                
                if bricksRemaining != 0 && brick.type == .Special {
                    let ballOrigin = (item as! UIView).center
                    let ball = createBall(atOrigin: ballOrigin, ofColor: Constants.SpecialBallColor) // On collision, for special brick, create a new ball
                    ballView! += [ball]
                    breakoutBehavior.addBall(ball)
                    breakoutBehavior.pushBall(ball)
                }
            }
        }
    }

    private func createBall (atOrigin origin: CGPoint, ofColor color: UIColor) -> UIView {
        let ballFrame = CGRect(origin: origin, size: ballSize)
        let ballViewFrame = UIView(frame: ballFrame)
        ballViewFrame.layer.cornerRadius = Constants.BallCornerRadius
        ballViewFrame.backgroundColor = color
        return ballViewFrame
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
            animations: {view.backgroundColor = Constants.BrickFadingColor },
            completion: {if $0 {self.fadeAnimation(view)}})
    }
    
    // Fades the view and remove it from superview when it completes
    private func fadeAnimation(view:UIView) {
        if view.alpha == 1.0 {
            UIView.animateWithDuration(0.2,
                delay: 0.0,
                options: UIViewAnimationOptions.CurveEaseInOut,
                animations: {view.alpha = 0.0},
                completion: { if $0 {
                    self.breakoutBehavior.removeBrick(view)
                    view.removeFromSuperview() }})
        }
    }
    
    private func gameOverAlert() {
        let alert = UIAlertController (title: "Game Over", message: "Score : \(gameScore)", preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Replay", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.clearBricks()
            self.initGameLayout()
        }
        
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // Initiliaze the game layout etc.
    private func initGameLayout() {

        
        placePaddleAtInitialPosition()
        
        if !gameIsActive {
            if ballView != nil {
                for ball in ballView! {
                    breakoutBehavior.removeBall(ball)
                }
            }
            ballView = nil
            ballView = createAndPlaceBallAtInitialPosition()
            clearBricks()
            gameScore = 0

        }
        
        if gameIsActive {
            if ballView != nil {
                for ball in ballView! {
                    if !CGRectIntersectsRect(ball.frame, gameView.bounds) {
                        ball.center = CGPoint(x: gameView.bounds.midX, y: gameView.bounds.midY)
                        animator.updateItemUsingCurrentState(ball)
                    }
                }
            }
        }
        
        createBricks()
        createGameBounds()
    }
    
    private func createAndPlaceBallAtInitialPosition() -> [UIView]? {
        
        //Add the ball as a UIView, position it on the paddle , in the middle
        if let paddleOrigin = paddleOrigin {
            
            var balls = [UIView]()
            
            for _ in 0..<numberOfBalls {
                let ballOrigin = CGPoint(x: (paddleOrigin.x + paddleSize.width / 2 - ballSize.width / 2) , y: (paddleOrigin.y - ballSize.height))
                let ball = createBall(atOrigin: ballOrigin, ofColor: Constants.BallColor)
                balls.append(ball)
                
            }
            return balls

        } else {
            return nil
        }
    }
    
    
    // Place the paddle at bottom of screen in the middle
    private func placePaddleAtInitialPosition() {
        paddleOrigin = CGPoint(x: gameView.bounds.midX  - paddleSize.width / 2, y: gameView.bounds.maxY - paddleSize.height * 3)
    }
    
    private func clearBricks() {
        for (name,brick) in bricks {
            brick.view.removeFromSuperview()
            bricks.removeValueForKey(name)
            breakoutBehavior.removeBezierPath(named: name)
        }
    }
    
    private func createBricks() {
        
        var numberOfBricksTemp: Int?
        if !gameIsActive {
            numberOfBricksTemp = numberOfBricks
            numberOfBricksForCurrentGame = numberOfBricks
        } else {
            numberOfBricksTemp = numberOfBricksForCurrentGame
        }

        var bricksToReplace = [String]()
        
        for (name,brick) in bricks {
            brick.view.removeFromSuperview()
            bricks.removeValueForKey(name)
            bricksToReplace.append(name)
        }
        
        // Set the bricks
        var bricksToAdd = [CGRect]()
        var brickFrame = CGRect(x: 0, y: 0, width: brickSize.width, height: brickSize.height)
        
        do {
            brickFrame.origin.y += brickFrame.size.height
            brickFrame.origin.x = 0
            
            for _ in 0 ..< bricksPerRow {
                if bricksToAdd.count < numberOfBricksTemp {
                    bricksToAdd.append(brickFrame)
                    brickFrame.origin.x += brickFrame.size.width
                }
            }
            
        } while bricksToAdd.count < numberOfBricksTemp
        
        for (index,frame) in enumerate(bricksToAdd) {
            let brickPath = UIBezierPath(rect: frame)
            let brickView = UIView(frame: frame)
            let name = "\(PathNames.BrickBarrier)\(index)"
            
            if bricksToReplace.count == 0 { // if there are no bricks to replace, initialize a new set of bricks
                // Add the brick as a boundary to the dynamic collision behavior
                breakoutBehavior.addBezierPath(brickPath, named: name)
                
                // Add the brick as a subview to the reference view
                brickView.backgroundColor = Constants.BrickColor
                gameView.addSubview(brickView)
                bricks[name] = randomBrick(brickView, brickIndex: index)
                
            } else {
                
                if contains(bricksToReplace, name) {

                    // Add the brick as a boundary to the dynamic collision behavior
                    breakoutBehavior.addBezierPath(brickPath, named: name)
                    
                    // Add the brick as a subview to the reference view
                    brickView.backgroundColor = Constants.BrickColor
                    gameView.addSubview(brickView)
                    bricks[name] = randomBrick(brickView, brickIndex: index)
                }
            }
        }
    }
    
    private func randomBrick (brickView: UIView, brickIndex: Int) -> Brick {
        if specialBricks {
            if brickIndex %  Int(1 / Constants.DefaultOccurenceOfSpecialBricks) == 0 {
                brickView.backgroundColor = Constants.SpecialBrickColor
                brickView.layer.borderColor = Constants.BrickBorderColor.CGColor
                brickView.layer.borderWidth = Constants.BrickBorderWidth
                return Brick(view: brickView, type: .Special)
            } else {
                return createNormalBrick(brickView)
            }
        } else {
            return createNormalBrick(brickView)
        }
    }
    
    private func createNormalBrick (brickView: UIView) -> Brick {
        brickView.backgroundColor = Constants.BrickColor
        brickView.layer.borderColor = Constants.BrickBorderColor.CGColor
        brickView.layer.borderWidth = Constants.BrickBorderWidth
        return Brick(view: brickView, type: .Normal)
    }
    
    private func createGameBounds() {
        
        let gameBoundLeftBezierPath = UIBezierPath()
        gameBoundLeftBezierPath.moveToPoint(CGPoint(x: gameView.bounds.origin.x, y: gameView.bounds.maxY))
        gameBoundLeftBezierPath.addLineToPoint(CGPoint(x: gameView.bounds.origin.x, y: gameView.bounds.origin.y))
        breakoutBehavior.addBezierPath(gameBoundLeftBezierPath, named: PathNames.GameLeftBarrier)
        
        let gameBoundTopBezierPath = UIBezierPath()
        gameBoundTopBezierPath.moveToPoint(CGPoint(x: gameView.bounds.origin.x, y: gameView.bounds.origin.y))
        gameBoundTopBezierPath.addLineToPoint(CGPoint(x: gameView.bounds.maxX, y: gameView.bounds.origin.y))
        breakoutBehavior.addBezierPath(gameBoundTopBezierPath, named: PathNames.GameTopBarrier)
        
        let gameBoundRightBezierPath = UIBezierPath()
        gameBoundRightBezierPath.moveToPoint(CGPoint(x: gameView.bounds.maxX, y: gameView.bounds.origin.y))
        gameBoundRightBezierPath.addLineToPoint(CGPoint(x: gameView.bounds.maxX, y: gameView.bounds.maxY))
        breakoutBehavior.addBezierPath(gameBoundRightBezierPath, named: PathNames.GameRightBarrier)
    }
}
