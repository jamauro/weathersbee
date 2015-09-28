//
//  RadarTileOverlay.swift
//  WeatherFeel
//
//  Created by John Mauro on 9/14/15.
//  Copyright (c) 2015 John Mauro. All rights reserved.
//

import UIKit
import MapKit


class RadarTileOverlay: MKTileOverlay {
  
  
  // var cache: NSCache = NSCache()
  var tileCache = [NSURL: NSData]()
  var alpha = 1.0
  
  /*
  override func URLForTilePath(path: MKTileOverlayPath) -> NSURL! {
    return NSURL(string: URLTemplate)
      // [NSURL URLWithString:[NSString stringWithFormat:@"http://tile.example.com/%d/%d/%d", path.z, path.x, path.y]];
  }
  */
  
  override func loadTileAtPath(path: MKTileOverlayPath,
    result: ((NSData?, NSError?) -> Void)) {
      
      // print(" cache is \(cache) ")
      // print(" URL \(URLForTilePath(path)) ", terminator: "")
      
      /*
      if (result == nil) {
        return
      }
      */
      
      if let tileData = tileCache[URLForTilePath(path)] {
        print(" using cache ", terminator: "")
        result(tileData, nil)
      } else {
        print(" requesting tile ", terminator: "")
        var request: NSURLRequest = NSURLRequest(URL: URLForTilePath(path))
        let mainQueue = NSOperationQueue.mainQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
          if error == nil {
            self.tileCache[self.URLForTilePath(path)] = data
            result(data, error)
          }
          
          
        })
      }
      
      // print(" result of loading tile: \(result)")
      super.loadTileAtPath(path, result: result)
      
    
      
  }
}

