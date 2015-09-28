//
//  RadarOverlayView.swift
//  WeatherFeel
//
//  Created by John Mauro on 9/10/15.
//  Copyright (c) 2015 John Mauro. All rights reserved.
//

import UIKit
import MapKit

class RadarOverlayView: MKOverlayRenderer {
  var overlayImage: UIImage
  // var overlayImagesArray = [UIImage]()
  // var i = 0
  // var index = Int()
  
  
  init(overlay: MKOverlay, overlayImage: UIImage) {
    self.overlayImage = overlayImage
    super.init(overlay: overlay)
  }
  
  /*
  init(overlay: MKOverlay, overlayImagesArray: Array<UIImage>) {
    self.overlayImagesArray = overlayImagesArray
    super.init(overlay: overlay)
    
  }
  */
  

  override func drawMapRect(mapRect: MKMapRect, zoomScale: MKZoomScale, inContext context: CGContext) {
    /*
    if i >= overlayImagesArray.count {
      i = 0
    }
    */
    
    // let imageReference = overlayImagesArray[i].CGImage
   
    let imageReference = overlayImage.CGImage
    
    
    let theMapRect = overlay.boundingMapRect
    let theRect = self.rectForMapRect(theMapRect)
    
    CGContextScaleCTM(context, 1.0, -1.0)
    CGContextTranslateCTM(context, 0.0, -theRect.size.height)
    CGContextDrawImage(context, theRect, imageReference)
    
    // i++
  }
}