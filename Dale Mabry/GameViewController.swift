//
// DaleMabry: GameViewController.swift
// ===================================
// The launch point for the app.


import UIKit
import SpriteKit

class GameViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // We're not using the scene editor for this game;
    // we're creating the sprites programatically instead.
    let scene = GameScene(size: CGSize(width: 2048, height: 1536))
    let skView = self.view as! SKView
    skView.showsFPS = true
    skView.showsNodeCount  = true
    
    // If ignoresSiblingOrder is:
    // - true:  Sprite Kit makes no guarantees as to the order in which
    //          it draws each node's children with the same zPosition.
    //          In general, it's best to set ignoreSiblingOrder to true,
    //          so that Sprite Kit do its own optimizations.
    // - false: Sprite Kit draws each node's children with the zPosition
    //          determined by the order in which they were added to
    //          their parent.
    skView.ignoresSiblingOrder = true
    
    scene.scaleMode = .aspectFill
    skView.presentScene(scene)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Release any cached data, images, etc that aren't in use.
  }

  func prefersStatusBarHidden() -> Bool {
    return true
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
