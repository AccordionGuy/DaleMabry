 //
//  GameViewController.swift
//  Dale Mabry
//
//  Created by Jose Martin DeVilla on 1/16/16.
//  Copyright (c) 2016 Joey deVilla. All rights reserved.
//

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
    
    scene.scaleMode = .AspectFill
    skView.presentScene(scene)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Release any cached data, images, etc that aren't in use.
  }

  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
}
