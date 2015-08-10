//
//  StringExtensions.swift
//  WeatherFeel
//
//  Created by John Mauro on 7/15/15.
//  Copyright (c) 2015 John Mauro. All rights reserved.
//

import Foundation


extension String {
  func trimAfter(word: String) -> String {
    self.lowercaseString
    let find = self.rangeOfString(word)
    let range = Range(start: find!.startIndex, end: self.endIndex)
    return self.substringWithRange(range)
  }
}