//
//  AnimatedRadar.swift
//  WeatherFeel
//
//  Created by John Mauro on 9/14/15.
//  Copyright (c) 2015 John Mauro. All rights reserved.
//

import UIKit
import MapKit


class AnimatedRadar: UIImageView {
  
  var images = [UIImage]()
  
  init(frame: CGRect, images: Array<UIImage>) {
    self.images = images
    super.init(frame: frame)
  }

  // TODO: what is the purpose of this
  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  func startAnimatingRadar() {
    
    var rect: CGRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)
    // print(" startedAnimatingRadar with rect: \(rect) and images count: \(images.count) ")
    
    /*
    UIGraphicsBeginImageContext(rect.size)
    var context: CGContextRef  = UIGraphicsGetCurrentContext()
    CGContextClipToMask(context, rect, self.images[0].CGImage)
    CGContextFillRect(context, rect)
    var img = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    */
    
    // not sure if i need all the stuff before this
    self.alpha = 0.5
    self.animationImages = images
    self.animationDuration = 3.0
    self.animationRepeatCount = 0

    
    self.startAnimating()
    
  }
  
  
}


