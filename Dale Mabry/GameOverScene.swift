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
  
  override func didMove(to view: SKView) {
    var background: SKSpriteNode
    
    if won {
      background = SKSpriteNode(imageNamed: "you_win_screen")
      run(SKAction.sequence([
        SKAction.wait(forDuration: 0.1),
        SKAction.playSoundFileNamed("win.wav", waitForCompletion: false)
        ]))
    }
    else {
      background = SKSpriteNode(imageNamed: "you_lose_screen")
      run(SKAction.sequence([
        SKAction.wait(forDuration: 0.1),
        SKAction.playSoundFileNamed("lose.wav", waitForCompletion: false)
        ]))
    }
    
    background.position = CGPoint(x: self.size.width / 2,
                                  y: self.size.height / 2)
    self.addChild(background)
    
    let wait = SKAction.wait(forDuration: 3.0)
    let block = SKAction.run {
      let myScene = GameScene(size: self.size)
      myScene.scaleMode = self.scaleMode
      let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
      self.view?.presentScene(myScene, transition: reveal)
    }
    self.run(SKAction.sequence([wait, block]))
  }
  
}

/*

Portions of this code were adapted from "Zombie Conga", an app whose code
appears in "2D iOS and tvOS Games by Tutorials", copyright © 2015 Razeware LLC.
See: http://www.raywenderlich.com/store/2d-ios-tvos-games-by-tutorials

The remainder is copyright © 2020 Joey deVilla.

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
