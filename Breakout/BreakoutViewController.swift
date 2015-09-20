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
    
    private var numberOfBricks: Int {
        return userDefaults.numberOfBricks
    }
    
    private var numberOfBricksForCurrentGame: Int?
    
    private var numberOfBalls: Int  {
        return userDefaults.numberOfBalls
    }
    
    private var brickSize: CGSize {
        let brickWidth = gameView.bounds.width / CGFloat(Constants.BricksPerRow)
        let brickHeight = gameView.bounds.height / 5 / CGFloat(Constants.BricksPerRow)
        return CGSize(width: brickWidth, height: brickHeight)
    }
    
    private var lastGameViewBounds: CGRect?
    
    private var specialBricks: Bool { return userDefaults.specialBricks }
    
    private let breakoutBehavior = BreakoutBehavior()
    private let settings = SettingsTableViewController()
    private let userDefaults = UserDefaults()
    
    private var gameIsActive: Bool = false {
        didSet {
            if oldValue == false && gameIsActive == true {
                bricksRemaining = numberOfBricks
            }
        }
    }
    
    private var ballView: [UIView]? {
        didSet {
            if !gameIsActive && ballView != nil {
                for ball in ballView! {
                    breakoutBehavior.addBall(ball)
                }
            }
        }
    }
    
    @IBOutlet weak var score: UILabel!
    
    private var gameScore: Int = 0 {
        didSet{
            score?.text = "Score: \(gameScore)"
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    //MARK: - Structs
    
    private struct Brick {
        
        var view: UIView
        var type: BrickType
        
        enum BrickType {
            case Normal
            case Special
        }
    }
    
    private struct Constants {
        
        static let BallColor = UIColor.redColor()
        static let BallCornerRadius: CGFloat = 5.0
        static let BallSpecialColor = UIColor.blueColor()
        static let BallSize = CGSize(width: 13, height: 13)
        
        static let BrickBorderColor = UIColor.blackColor()
        static let BrickBorderWidth: CGFloat = 1
        static let BrickColor = UIColor(red:0.11, green:0.81, blue:0.15, alpha:0.5)
        static let BrickFadingColor = UIColor(red:0.00, green:0.85, blue:1.00, alpha:0.5)
        static let BricksPerRow = 5
        static let BrickSpecialColor = UIColor(red:0.00, green:0.00, blue:1.00, alpha:0.5)
        
        static let DefaultOccurenceOfSpecialBricks = 0.15 // percentage of special bricks
        
        static let PaddleColor = UIColor(red: 0.00, green: 0.15, blue: 0.47, alpha: 0.7)
        static let PaddleSensitivity: CGFloat = 20 // the higher, the more sensitive
    }
    
    private struct PathNames {
        static let BrickBarrier = "Brick Barrier"
        static let GameLeftBarrier = "Game Left Barrier"
        static let GameRightBarrier = "Game Right Barrier"
        static let GameTopBarrier = "Game Top Barrier"
        static let PaddleBarrier = "Paddle Barrier"
    }
    
    private struct Score {
        static let PointPerBrickHit = 1
        static let PointForCompletingGame = 50
        static let PointForEachRemainingBall = 10
    }

    
    //MARK: - Lifecyle
    
    @IBAction func pushBall(sender: UITapGestureRecognizer) {
        if ballView != nil {
            for ball in ballView! {
                breakoutBehavior.pushBall(ball)
            }
            gameIsActive = true
        }
    }
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        breakoutBehavior.delegate = self
        animator.addBehavior(breakoutBehavior)
        breakoutBehavior.collider.collisionDelegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        breakoutBehavior.setElasticity(CGFloat(userDefaults.ballBounciness))
        if gameIsActive {
            breakoutBehavior.restartBalls()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        let manager = AppDelegate.Motion.Manager
        
        if manager.accelerometerAvailable {
            manager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue()) { (data, error) -> Void in
                
                var gravity: CGVector?
                
                let orientation = UIApplication.sharedApplication().statusBarOrientation
                
                if let motionData = data {
                    if orientation == UIInterfaceOrientation.Portrait {
                        gravity = CGVector(dx: motionData.gravity.x, dy: -motionData.gravity.y)
                    }
                    if orientation == UIInterfaceOrientation.LandscapeRight {
                        gravity = CGVector(dx: -motionData.gravity.y, dy: -motionData.gravity.x)
                    }
                    if orientation == UIInterfaceOrientation.LandscapeLeft {
                        gravity = CGVector(dx: motionData.gravity.y, dy: motionData.gravity.x)
                    }
                }
                if let gravity = gravity {
                    if self.gameIsActive {
                        let newPaddleOriginX = min(max(self.paddleOrigin!.x + gravity.dx * Constants.PaddleSensitivity, self.gameView.bounds.minX), self.gameView.bounds.maxX - self.paddleSize.width)
                        if newPaddleOriginX != self.paddleOrigin!.x {
                            self.paddleOrigin?.x = newPaddleOriginX // move the paddle according to device real life gravity
                        }
                        self.breakoutBehavior.gravity.gravityDirection = gravity // links real life gravity to in game gravity
                    }
                }
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        lastGameViewBounds = gameView.bounds
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        initGameLayout()
    }
    
    private func initGameLayout() {
        
        placePaddle()
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
    
    private func createGameBounds() {
        
        let bottomLeftCorner = CGPoint(x: gameView.bounds.origin.x, y: gameView.bounds.maxY)
        let topLeftCorner = CGPoint(x: gameView.bounds.origin.x, y: gameView.bounds.origin.y)
        let topRightCorner = CGPoint(x: gameView.bounds.maxX, y: gameView.bounds.origin.y)
        let bottomRightCorner = CGPoint(x: gameView.bounds.maxX, y: gameView.bounds.maxY)
        
        breakoutBehavior.createBoundarySegment(named: PathNames.GameLeftBarrier, fromPoint: bottomLeftCorner, toPoint: topLeftCorner)
        breakoutBehavior.createBoundarySegment(named: PathNames.GameTopBarrier, fromPoint: topLeftCorner, toPoint: topRightCorner)
        breakoutBehavior.createBoundarySegment(named: PathNames.GameRightBarrier, fromPoint: topRightCorner, toPoint: bottomRightCorner)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        AppDelegate.Motion.Manager.stopDeviceMotionUpdates()
        if gameIsActive {
            breakoutBehavior.stopBalls()
        }
    }
    
    //MARK: - BreakoutBehaviorDelegate
    func didRemoveBall(ball: UIView, sender: BreakoutBehavior) {
        if let index = (ballView!).indexOf(ball) {
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
    
    //MARK: - UICollisionBehaviorDelegate
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, atPoint p: CGPoint) {
        
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
                    let ball = createBall(atOrigin: ballOrigin, ofColor: Constants.BallSpecialColor) // On collision, for special brick, create a new ball
                    ballView! += [ball]
                    breakoutBehavior.addBall(ball)
                    breakoutBehavior.pushBall(ball)
                }
            }
        }
    }
    
    //MARK: - Ball
    
    private func createAndPlaceBallAtInitialPosition() -> [UIView]? {
        
        //Add the ball as a UIView, position it on the paddle , in the middle
        if let paddleOrigin = paddleOrigin {
            var balls = [UIView]()
            for _ in 0..<numberOfBalls {
                let ballOrigin = CGPoint(x: (paddleOrigin.x + paddleSize.width / 2 - Constants.BallSize.width / 2) , y: (paddleOrigin.y - Constants.BallSize.height))
                let ball = createBall(atOrigin: ballOrigin, ofColor: Constants.BallColor)
                balls.append(ball)
            }
            return balls
        } else {
            return nil
        }
    }
    
    private func createBall (atOrigin origin: CGPoint, ofColor color: UIColor) -> UIView {
        let ballFrame = CGRect(origin: origin, size: Constants.BallSize)
        let ballViewFrame = UIView(frame: ballFrame)
        ballViewFrame.layer.cornerRadius = Constants.BallCornerRadius
        ballViewFrame.backgroundColor = color
        return ballViewFrame
    }
    
    
    //MARK: - Paddle
    
    private func setAndDrawPaddle() {
        if paddleOrigin != nil {
            let paddle = CGRect(origin: paddleOrigin!, size: paddleSize)
            let paddleBezierPath = UIBezierPath(roundedRect: paddle, cornerRadius: 5)
            gameView.fillColor = Constants.PaddleColor
            gameView.setBezierPath(paddleBezierPath, named: PathNames.PaddleBarrier)
            breakoutBehavior.addBezierPath(paddleBezierPath, named: PathNames.PaddleBarrier)
        }
    }
    
    private func placePaddle() {
        
        let centerPosition = CGPoint(x: gameView.bounds.midX  - paddleSize.width / 2, y: gameView.bounds.maxY - paddleSize.height * 3) // Bottom of screen in the middle
            
        if let origin = paddleOrigin {
            if lastGameViewBounds != nil {
                let relativePositionX = origin.x / lastGameViewBounds!.width
                let relativePositionY = origin.y / lastGameViewBounds!.height
                paddleOrigin = CGPoint(x: gameView.bounds.width * relativePositionX, y: gameView.bounds.height * relativePositionY)
            } else {
                paddleOrigin = centerPosition
            }
        } else {
            paddleOrigin = centerPosition
        }
    }
    
    //MARK: - Brick
    
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
        
        repeat {
            brickFrame.origin.y += brickFrame.size.height
            brickFrame.origin.x = 0
            
            for _ in 0 ..< Constants.BricksPerRow {
                if bricksToAdd.count < numberOfBricksTemp {
                    bricksToAdd.append(brickFrame)
                    brickFrame.origin.x += brickFrame.size.width
                }
            }
            
        } while bricksToAdd.count < numberOfBricksTemp
        
        for (index,frame) in bricksToAdd.enumerate() {
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
                
                if bricksToReplace.contains(name) {
                    
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
    
    private func clearBricks() {
        for (name,brick) in bricks {
            brick.view.removeFromSuperview()
            bricks.removeValueForKey(name)
            breakoutBehavior.removeBezierPath(named: name)
        }
    }
    
    private func randomBrick (brickView: UIView, brickIndex: Int) -> Brick {
        if specialBricks {
            if brickIndex %  Int(1 / Constants.DefaultOccurenceOfSpecialBricks) == 0 {
                brickView.backgroundColor = Constants.BrickSpecialColor
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
    
    //MARK: - View Animations and Alerts
    
    private func gameOverAlert() {
        let alert = UIAlertController (title: "Game Over", message: "Score : \(gameScore)", preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Replay", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.clearBricks()
            self.initGameLayout()
        }
        
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    

    private func animateBrickDisappearance(view:UIView) {
        UIView.transitionWithView(view,
            duration: 0.3,
            options: UIViewAnimationOptions.TransitionFlipFromBottom,
            animations: {
                view.backgroundColor = Constants.BrickFadingColor
                view.layer.borderWidth = 0},
            completion: {if $0 {self.fadeAnimation(view)}})
    }
    
    private func fadeAnimation(view:UIView) {
        if view.alpha == 1.0 {
            UIView.animateWithDuration(0.2,
                delay: 0.0,
                options: UIViewAnimationOptions.CurveEaseInOut,
                animations: {view.alpha = 0.0},
                completion: {
                    if $0 {
                        self.breakoutBehavior.removeBrick(view) }})
        }
    }
}
