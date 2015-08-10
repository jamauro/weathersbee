//
//  ApiKeys.swift
//  WeatherFeel
//
//  Created by John Mauro on 7/14/15.
//  Copyright (c) 2015 John Mauro. All rights reserved.
//

import Foundation

func valueForAPIKey(#keyname: String) -> String {
  let filePath = NSBundle.mainBundle().pathForResource("ApiKeys", ofType:"plist")
  let plist = NSDictionary(contentsOfFile:filePath!)
  
  let value: String = plist?.objectForKey(keyname) as! String
  return value
}