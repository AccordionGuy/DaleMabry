//
// DaleMabry: GameScene.swift
// ==========================
//
// This is the "meat" of the game; the code for the gameplay
// all lives here


import SpriteKit

class GameScene: SKScene {
  
  // MARK: Properties
  // ================
  
  enum PlayerDeathCauses {
    case OutOfTime
    case HitByCar
  }
  
  // Game time trackers
  // ------------------
  var lastUpdateTime: NSTimeInterval = 0        // The last time Sprite Kit called update()
  var timeSinceLastUpdate: NSTimeInterval = 0   // Delta time since last update
  var timeSinceLastClockTick: NSTimeInterval = 0
  
  
  // Screen coordinates
  // ------------------
  let playableRect: CGRect         // Rect definining the playable area of the screen
                                   // (this will vary from device to device)
  var lastTouchLocation: CGPoint?  // Stores the location of the last place
                                   // where the user touched the screen
  
  
  // Player
  // ------
  let player = SKSpriteNode(imageNamed: "player_1")
  let playerMovePointsPerSec: CGFloat = 480.0          // Max distance zombie can move in a second
  let playerRotateRadiansPerSecond: CGFloat = 4.0 * π  // Max angle zombie can rotate in a second
  var playerVelocity = CGPoint.zero                    // Initial player velocity vector

  let PLAYER_ANIMATION_KEY = "player_animation"
  let playerAnimation: SKAction
  
  let playerCollisionSound = SKAction.playSoundFileNamed("splat.mp3", waitForCompletion: false)
  
  var playerIsAlive = true
  var playerLives: Int = 5
  
  var timeRemaining: Int = 30
  
  
  // Cars
  // ----
  enum Direction {
    case GoingRight
    case GoingLeft
  }
  
  
  // On-screen displays
  // ------------------
  let livesLabel = SKLabelNode(fontNamed: "Chalkduster")
  let timeLabel = SKLabelNode(fontNamed: "Chalkduster")
  
  let playerDiedLabel = SKLabelNode(fontNamed: "Chalkduster")


  // MARK: -
  
  // MARK: Initialization
  // ====================
  
  override init(size: CGSize) {
    // Determine the playable onscreen real estate
    // -------------------------------------------
    // This game takes various devices' screen ratios into account.
    // 
    // Some devices, such as iPhones from the 4s era and earlier,
    // as well as iPads, have screens with a 4:3 aspect ratio.
    // Other devices, such as the iPhone 5 and later models,
    // as well as the Apple TV, have a 16:9 aspect ratio.
    //
    // We've opted to show the entire width of the background image,
    // no matter what aspect ratio is. 16:9 screens are a little less
    // tall in relation to their width than 4:3 screen are,
    // so on a 16:9 screen, a small portion of the top and bottom 
    // of the background will not be visible.
    // 
    // We deal with these various devices' aspect ratios by
    // defining playableRect, a rectangle that specifies the area
    // of the screen that is always visible (and therefore, playable)
    // regardless of the device and its aspect ratio.
    
    let maxAspectRatio: CGFloat = 16.0 / 9.0
    
    // With aspect fit, the playable width is the scene's width,
    // regardless of aspect ratio. We need to calculate the playable height.
    let playableHeight = size.width / maxAspectRatio
    
    // We want to center the playable rectangle on the screen,
    // and that's how we determine playable margin.
    let playableMargin = (size.height - playableHeight) / 2.0
    
    playableRect = CGRect(x: 0,
      y: playableMargin,
      width: size.width,
      height: playableHeight)
    
    
    // Initialize the player's sprite animation
    // ----------------------------------------
    var textures: [SKTexture] = []
    for i in 1...4 {
      textures.append(SKTexture(imageNamed: "player_\(i)"))
    }
    textures.append(textures[2])
    textures.append(textures[1])
    playerAnimation = SKAction.animateWithTextures(textures, timePerFrame: 0.1)
    
    super.init(size: size)
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  override func didMoveToView(view: SKView) {
    playBackgroundMusic("backgroundMusic.mp3")
    
    // Set up initial game state
    // -------------------------
    
    playerLives = 5
    timeRemaining = 5
    
    
    // Draw the background
    // -------------------
    
    let background = SKSpriteNode(imageNamed: "background")
    background.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
    background.zPosition = 0
    addChild(background)

    
    // Set up the HUD
    // --------------
    
    livesLabel.text = "Lives: \(playerLives)"
    livesLabel.fontColor = SKColor.whiteColor()
    livesLabel.fontSize = 100
    livesLabel.zPosition = 100
    livesLabel.horizontalAlignmentMode = .Left
    livesLabel.verticalAlignmentMode = .Bottom
    livesLabel.position = CGPoint(x: 60, y: 225)
    addChild(livesLabel)
    
    timeLabel.text = "Time: \(timeRemaining)"
    timeLabel.fontColor = SKColor.whiteColor()
    timeLabel.fontSize = 100
    timeLabel.zPosition = 100
    timeLabel.horizontalAlignmentMode = .Left
    timeLabel.verticalAlignmentMode = .Bottom
    timeLabel.position = CGPoint(x: 1500, y: 225)
    addChild(timeLabel)
    
    playerDiedLabel.text = "Time's up"
    playerDiedLabel.fontColor = SKColor.whiteColor()
    playerDiedLabel.fontSize = 100
    playerDiedLabel.zPosition = 100
    playerDiedLabel.position = CGPoint(x: frame.width / 2,
                                    y: frame.height / 2)
    playerDiedLabel.hidden = true
    addChild(playerDiedLabel)
    
    
    
    // Start the traffic
    // -----------------
    
    createLane(lane: 0, timeToCross: 4, timeBetweenCars: 5, direction: .GoingRight)
    createLane(lane: 1, timeToCross: 8, timeBetweenCars: 3.5 , direction: .GoingLeft)
    createLane(lane: 2, timeToCross: 9, timeBetweenCars: 2, direction: .GoingRight)
    createLane(lane: 3, timeToCross: 5, timeBetweenCars: 3, direction: .GoingRight)
    createLane(lane: 4, timeToCross: 4, timeBetweenCars: 2 , direction: .GoingLeft)
    createLane(lane: 5, timeToCross: 3, timeBetweenCars: 2, direction: .GoingRight)
    
    
    // Set up the player sprite
    // ------------------------
    
    putPlayerAtStartingPosition()
    addChild(player)
  }
  
  func putPlayerAtStartingPosition() {
    player.position = CGPoint(x: frame.width / 2,
                              y: playableRect.minY)
    player.zPosition = 100
    player.zRotation = π / 2
    player.setScale(0.33)
    
    playerVelocity = CGPoint.zero
    
    startPlayerAnimation()
  }
  

  // MARK: -
  
  // MARK: Event loop methods
  // ========================
  
  override func update(currentTime: NSTimeInterval) {
    // This method gets called at the start of each event loop,
    // immediate after Sprite Kit renders the latest frame onscreen.
    //
    // It's a good place to do things like moving sprites and
    // perform any other tasks to update the scene.
    
    if lastUpdateTime > 0 {
      timeSinceLastUpdate = currentTime - lastUpdateTime
      
      
      if playerIsAlive {
        timeSinceLastClockTick += timeSinceLastUpdate
        
        if timeSinceLastClockTick >= 1.0 {
          timeRemaining -= 1
          timeLabel.text = "Time: \(timeRemaining)"
          timeSinceLastClockTick = 0
          
          if timeRemaining <= 0 && playerIsAlive {
            killPlayer(.OutOfTime)
          }
        }
      }
      
    }
    else {
      timeSinceLastUpdate = 0
    }
    lastUpdateTime = currentTime
    
    if playerIsAlive {
      if let destination = lastTouchLocation {
        if (destination - player.position).length() < playerMovePointsPerSec * CGFloat(timeSinceLastUpdate) {
          player.position = destination
          playerVelocity = CGPoint.zero
          stopPlayerAnimation()
        }
        else {
          movePlayerToward(destination)
        }
        boundsCheckPlayer()
      }
    }
    
  }
  
  override func didEvaluateActions() {
    // This method gets called *after* Sprite Kit has evaluated
    // all the actions and the sprites have been updated and
    // put into their new locations. 
    //
    // It's a good place to do things like checking for collisions
    // and evaluating other sprite interactions.
    
    if playerHitCar() && playerIsAlive {
      killPlayer(.HitByCar)
    }
    else if player.position.y >= 1340 {
      backgroundMusicPlayer.stop()
      let gameOverScene = GameOverScene(size: size, won: true)
      gameOverScene.scaleMode = scaleMode
      let horizontalFlip = SKTransition.flipHorizontalWithDuration(0.5)
      view?.presentScene(gameOverScene, transition: horizontalFlip)
    }
  }
  
  func playerHitCar() -> Bool {
    var result = false
    enumerateChildNodesWithName("car") { node, stop in
      let car = node as! SKSpriteNode
      if CGRectIntersectsRect(car.frame, self.player.frame) {
        stop.memory = true
        result = true
      }
    }
    return result
  }
  
  func killPlayer(causeOfDeath: PlayerDeathCauses) {
    print("kill player")
    // Player loses a life
    // -------------------
    // 1. Stop whatever actions the player sprite is currently executing
    // 2. Play the "collision" sound
    // 3. Simultaneously...
    //    - Spin the player sprite 720 degrees, and
    //    - Shrink it down to nothing
    // 4. Reduce the number of player lives by 1
    // 5. Update the onscreen lives counter
    // 6. If the player isn't out of lives, put the player sprite
    //    back at the starting position,
    //    otherwise, stop the music and go to the "Game Over" scene
    
    playerIsAlive = false
    
    runAction(playerCollisionSound)
    
    player.removeAllActions()
    let spinAction = SKAction.rotateByAngle(4 * π, duration: 1.0)
    let shrinkAction = SKAction.scaleBy(0, duration: 1.0)
    let spinAndShrinkAction = SKAction.group([spinAction, shrinkAction])
    let showMessageAction = SKAction.runBlock {
      if causeOfDeath == .OutOfTime {
        self.playerDiedLabel.text = "Out of time!"
      }
      else {
        self.playerDiedLabel.text = "That'll leave a mark."
      }
      self.playerDiedLabel.hidden = false
    }
    let pause = SKAction.waitForDuration(4)
    let hideMessageAction = SKAction.runBlock {
      self.playerDiedLabel.hidden = true
    }
    let removeLifeAndEvaluate = SKAction.runBlock {
      self.playerLives -= 1
      self.livesLabel.text = "Lives: \(self.playerLives)"
      
      if self.playerLives > 0 {
        print("reset player")
        // If the player has at least one life remaining,
        // put the player back at the starting position.
        self.putPlayerAtStartingPosition()
        self.timeRemaining = 30
        self.timeLabel.text = "Time: \(self.timeRemaining)"
        self.timeSinceLastUpdate = 0
        self.timeSinceLastClockTick = 0
        self.playerVelocity.x = 0
        self.playerIsAlive = true
      }
      else {
        // If the player has used up all of his/her lives,
        // go to the "game over" screen and show the "you lose" graphic.
        backgroundMusicPlayer.stop()
        let gameOverScene = GameOverScene(size: self.size, won: false)
        gameOverScene.scaleMode = self.scaleMode
        let horizontalFlip = SKTransition.flipHorizontalWithDuration(0.5)
        self.view?.presentScene(gameOverScene, transition: horizontalFlip)
      }
    }
    player.runAction(SKAction.sequence([spinAndShrinkAction,
                                        showMessageAction,
                                        pause,
                                        hideMessageAction,
                                        removeLifeAndEvaluate]))
  }
  
  
  
  // MARK: -
  
  // MARK: Player animation
  // ======================
  
  func startPlayerAnimation() {
    if player.actionForKey(PLAYER_ANIMATION_KEY) == nil {
      player.runAction(SKAction.repeatActionForever(playerAnimation),
                       withKey: PLAYER_ANIMATION_KEY)
    }
  }
  
  func stopPlayerAnimation() {
    player.removeActionForKey(PLAYER_ANIMATION_KEY)
  }
  

  
  // MARK: -
  
  // MARK: Touch handlers
  // ====================
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard let touch = touches.first else {
      return
    }
    
    lastTouchLocation = touch.locationInNode(self)
    sceneTouched(lastTouchLocation!)
    
  }
  
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard let touch = touches.first else {
      return
    }
    
    lastTouchLocation = touch.locationInNode(self)
    sceneTouched(lastTouchLocation!)
  }
  
  func sceneTouched(touchLocation: CGPoint) {
    movePlayerToward(lastTouchLocation!)
  }
  
  
  // MARK: -
  
  // MARK: Player movement
  // =====================
  
  func moveSprite(sprite: SKSpriteNode,
                  velocity: CGPoint)
  {
    let amountToMove = velocity * CGFloat(timeSinceLastUpdate)
    sprite.position += amountToMove
  }
  
  func rotateSprite(sprite: SKSpriteNode,
                    direction: CGPoint,
                    rotateRadiansPerSec: CGFloat)
  {
    let angle = smallestAngleBetween(sprite.zRotation, and: direction.angle)
    let amtToRotate = min(abs(angle), rotateRadiansPerSec * CGFloat(timeSinceLastUpdate))
    sprite.zRotation += amtToRotate * angle.sign()
  }
  
  func movePlayerToward(destination: CGPoint)
  {
    startPlayerAnimation()
    playerVelocity = (destination - player.position).normalized() * playerMovePointsPerSec
    moveSprite(player,
               velocity: playerVelocity)
    rotateSprite(player,
                 direction: playerVelocity,
                 rotateRadiansPerSec: playerRotateRadiansPerSecond)
  }
  
  func boundsCheckPlayer() {
    let bottomLeft = CGPoint(x: CGRectGetMinX(playableRect),
      y: CGRectGetMinY(playableRect))
    let topRight = CGPoint(x: CGRectGetMaxX(playableRect),
      y: CGRectGetMaxY(playableRect))
    
    if player.position.x <= bottomLeft.x {
      player.position.x = bottomLeft.x
      playerVelocity.x = 0
    }
    if player.position.x >= topRight.x {
      player.position.x = topRight.x
      playerVelocity.x = 0
    }
    if player.position.y <= bottomLeft.y {
      player.position.y = bottomLeft.y
      playerVelocity.y = 0
    }
    if player.position.y >= topRight.y {
      player.position.y = topRight.y
      playerVelocity.y = 0
    }
  }

  
  // MARK: -
  
  // MARK: Non-player element movement
  // =================================
  
  func createLane(lane lane: Int,
    timeToCross: NSTimeInterval,
    timeBetweenCars: NSTimeInterval,
    direction: Direction)
  {
    
    // Helper functions
    // ----------------
    
    func randomCarImageName(direction: Direction) -> String {
      let carImages = ["ambulance",
                       "black_car",
                       "blue_pickup",
                       "minivan",
                       "orange_car",
                       "police",
                       "red_car",
                       "taxi",
                       "truck"]
      return carImages[Int.random(min: 0, max: carImages.count)]
    }
    
    func spawnCar(lane lane: Int,
      timeToCross: NSTimeInterval,
      direction: Direction,
      imageName: String)
    {
      let laneYCoordinates: [CGFloat] = [400, 525, 650, 950, 1075, 1200]
      let carPositionY = laneYCoordinates[lane]
      let car = SKSpriteNode(imageNamed: imageName)
      car.name = "car"
      
      let offLeftEdge = -car.size.width / 2
      let offRightEdge = frame.size.width + car.size.width / 2
      let carStartX: CGFloat
      let carEndX: CGFloat
      if direction == .GoingLeft {
        carStartX = offRightEdge
        carEndX = offLeftEdge
        car.zRotation = π
      }
      else {
        carStartX = offLeftEdge
        carEndX = offRightEdge
      }
      car.position = CGPoint(x: carStartX, y: carPositionY)
      car.zPosition = 1
      
      addChild(car)
      
      let moveAction = SKAction.moveToX(carEndX, duration: timeToCross)
      let cleanUpAction = SKAction.removeFromParent()
      car.runAction(SKAction.sequence([moveAction, cleanUpAction]))
    }
    
    
    // Main method
    // -----------
    
    let laneAction = SKAction.repeatActionForever(
      SKAction.sequence([
        SKAction.runBlock {
          spawnCar(lane: lane,
          timeToCross: timeToCross,
          direction: direction,
          imageName: randomCarImageName(direction))
        },
        SKAction.waitForDuration(timeBetweenCars)
      ])
    )
    runAction(laneAction)

  }
  
}

/*

Portions of this code were adapted from "Zombie Conga", an app whose code
appears in "2D iOS and tvOS Games by Tutorials", copyright © 2015 Razeware LLC.
See: http://www.raywenderlich.com/store/2d-ios-tvos-games-by-tutorials

The remainder is copyright © 2016 Joey deVilla.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/
