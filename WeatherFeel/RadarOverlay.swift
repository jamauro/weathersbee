//
//  RadarOverlay.swift
//  WeatherFeel
//
//  Created by John Mauro on 9/10/15.
//  Copyright (c) 2015 John Mauro. All rights reserved.
//

import UIKit
import MapKit

class RadarOverlay: NSObject, MKOverlay {
  var coordinate: CLLocationCoordinate2D
  var boundingMapRect: MKMapRect
  
  init(lowerLeftCoordinate: CLLocationCoordinate2D, upperRightCoordinate: CLLocationCoordinate2D) {
    
    let topRight = MKMapPointForCoordinate(upperRightCoordinate)
    let bottomLeft = MKMapPointForCoordinate(lowerLeftCoordinate)
    
    boundingMapRect = MKMapRectMake(bottomLeft.x, topRight.y, fabs(topRight.x - bottomLeft.x), fabs(bottomLeft.y - topRight.y))
   
    
    coordinate = MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMidX(boundingMapRect), MKMapRectGetMidY(boundingMapRect)))
  }
  
}