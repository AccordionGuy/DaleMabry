//
// DaleMabry: MyUtils.swift
// ========================
// A collection of handy utility functions and extensions
// for game development.


import Foundation
import CoreGraphics


// MARK: -

// MARK: Math for 32-bit platforms
// ===============================
// Implementations of the atan2() and sqrt functions for 32-bit platforms
// (the iPhone 5 and earlier and iPad 4th gen are 32-bit, while
// the iPhone 5S and later and iPad Air and later are 64-bit).

#if !(arch(x86_64) || arch(arm64))
  func atan2(y: CGFloat, x: CGFloat) -> CGFloat {
    return CGFloat(atan2f(Float(y), Float(x)))
  }
  
  func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
  }
#endif


// MARK: -

// MARK: CGPoint arithmetic
// ========================
// These overloads of the +, -, *, and / operators to work on CGPoints
// are handy when you use CGPoints to represent both points *and* vectors.
// The + and - operators support CGPoint-CGPoint addition and subtraction,
// while the * and / operations support both:
//
//   - CGPoint-scalar multiplication/division
//   - CGPoint-CGPoint multiplication/division,
//     where CGPoint1 * CGPoint2 = (x1 * x2, y1 * y2) and
//           CGPoint1 / CGPoint2 = (x1 / x2, y1 / y2)

func + (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func += (inout left: CGPoint, right: CGPoint) {
  left = left + right
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func -= (inout left: CGPoint, right: CGPoint) {
  left = left - right
}

func * (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x * right.x, y: left.y * right.y)
}

func *= (inout left: CGPoint, right: CGPoint) {
  left = left * right
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func *= (inout point: CGPoint, scalar: CGFloat) {
  point = point * scalar
}

func / (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x / right.x, y: left.y / right.y)
}

func /= (inout left: CGPoint, right: CGPoint) {
  left = left / right
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

func /= (inout point: CGPoint, scalar: CGFloat) {
  point = point / scalar
}


// MARK: -

// MARK: CGPoint vector extensions
// ===============================

extension CGPoint {
  
  // Returns the length of the vector represented by the CGPoint.
  func length() -> CGFloat {
    return sqrt(x * x + y * y)
  }
  
  // Given the vector represented by the CGPoint,
  // returns a CGPoint representing a vector pointing in the same direction,
  // but having a length of 1.
  func normalized() -> CGPoint {
    return self / length()
  }
  
  // Returns the angle (in radians, of course) between
  // the vector represented by the CGPoint and the x-axis,
  // where the angle increases in the counterclockwise direction.
  var angle: CGFloat {
    return atan2(y, x)
  }
  
}


// MARK: -

// MARK: Angle utilities
// =====================

// π (option-p) is so much nicer than M_PI, don't you think?
let π = CGFloat(M_PI)

// Between any two angles on the same plane, there is a smaller angle
// and a larger one. Given two angles, this returns the smaller of the two.
func smallestAngleBetween(angle1: CGFloat, and angle2: CGFloat) -> CGFloat {
  let twoπ = π * 2.0
  var angle = (angle2 - angle1) % twoπ
  
  if (angle >= π) {
    angle = angle - twoπ
  }
  
  if (angle <= -π) {
    angle = angle + twoπ
  }
  
  return angle
}


// MARK: -

// MARK: CGFloat extensions
// ========================

extension CGFloat {
  
  // Return 1.0 if the value is positive and -1.0 if it's negative.
  func sign() -> CGFloat {
    return (self >= 0.0) ? 1.0 : -1.0
  }
  
  // Return a random CGFloat between 0 and 1.
  // Uses arc4random_uniform to avoid modulo bias (simply put,
  // just use this random function. It works better.)
  static func random() -> CGFloat {
    return (CGFloat(arc4random_uniform(UInt32.max)) / CGFloat(UInt32.max))
  }
  
  // Return a random CGFloat between min and max inclusive.
  static func random(min min: CGFloat, max: CGFloat) -> CGFloat {
    assert(min < max)
    return CGFloat.random() * (max - min) + min
  }
  
}


// MARK: -

// MARK: Double extensions
// =======================

extension Double {
  
  // Return a random Double between 0 and 1.
  // Uses arc4random_uniform to avoid modulo bias (simply put,
  // just use this random function. It works better.)
  static func random() -> Double {
    return (Double(arc4random_uniform(UInt32.max)) / Double(UInt32.max))
  }
  
  // Return a random Double between min and max inclusive.
  static func random(min min: Double, max: Double) -> Double {
    assert(min < max)
    return Double.random() * (max - min) + min
  }
  
}

extension Int {
  
  // Return a random Int between min and max inclusive.
  static func random(min min: Int, max: Int) -> Int {
    return Int(arc4random_uniform(UInt32(max - min) + UInt32(min)))
  }
  
}


// MARK: -

// MARK: Background music player
// =============================

import AVFoundation

var backgroundMusicPlayer: AVAudioPlayer!

func playBackgroundMusic(filename: String) {
  let resourceUrl = NSBundle.mainBundle().URLForResource(filename,
    withExtension: nil)
  guard let url = resourceUrl else {
    print("Couldn't find file \"\(filename)\".")
    return
  }
  
  do {
    try backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: url)
    backgroundMusicPlayer.numberOfLoops = -1
    backgroundMusicPlayer.prepareToPlay()
    backgroundMusicPlayer.play()
  }
  catch {
    print("Couldn't create audio player!")
    return
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