//
// DaleMabry: GameOverScene.swift
// ==============================
// Displays the appropriate message when either the player:
// - Wins by successfully crossing the highway, or
// - Loses by losing all his/her lives.


import Foundation
import SpriteKit


class GameOverScene: SKScene {
  
  let won: Bool
  
  
  // MARK: -
  
  // MARK: Methods
  // =============
  
  // MARK: -
  
  
  // MARK: Initializers
  // ==================
  
  init(size: CGSize, won: Bool) {
    self.won = won
    super.init(size: size)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented.")
  }
  
  override func didMoveToView(view: SKView) {
    var background: SKSpriteNode
    
    if won {
      background = SKSpriteNode(imageNamed: "you_win_screen")
      runAction(SKAction.sequence([
        SKAction.waitForDuration(0.1),
        SKAction.playSoundFileNamed("win.wav", waitForCompletion: false)
        ]))
    }
    else {
      background = SKSpriteNode(imageNamed: "you_lose_screen")
      runAction(SKAction.sequence([
        SKAction.waitForDuration(0.1),
        SKAction.playSoundFileNamed("lose.wav", waitForCompletion: false)
        ]))
    }
    
    background.position = CGPoint(x: self.size.width / 2,
                                  y: self.size.height / 2)
    self.addChild(background)
    
    let wait = SKAction.waitForDuration(3.0)
    let block = SKAction.runBlock {
      let myScene = GameScene(size: self.size)
      myScene.scaleMode = self.scaleMode
      let reveal = SKTransition.flipHorizontalWithDuration(0.5)
      self.view?.presentScene(myScene, transition: reveal)
    }
    self.runAction(SKAction.sequence([wait, block]))
  }
  
}
