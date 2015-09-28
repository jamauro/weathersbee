//
//  DateExtensions.swift
//  WeatherFeel
//
//  Created by John Mauro on 8/21/15.
//  Copyright (c) 2015 John Mauro. All rights reserved.
//

import Foundation

extension NSDate {
  func hour() -> Int {
    //Get Hour
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components(.Hour, fromDate: self)
    let hour = components.hour
    
    //Return Hour
    return hour
  }
  
  // e.g. if 10 min intervals will give 12:00 for 12:01 to 12:09
  func nearestMinuteFloor(minutes: Int) -> NSDate! {
    
    let referenceTimeInterval = Int(self.timeIntervalSinceReferenceDate)
    let remainingSeconds = referenceTimeInterval % (minutes*60)
    let timeRounded = referenceTimeInterval - remainingSeconds
    
    // if it's above the 9 min mark of each interval then round up to the next 10 min interval
    /*
    if remainingSeconds > 540
    {
    timeRounded = referenceTimeInterval + (minutes*60 - remainingSeconds)
    }
    */
    let roundedDate = NSDate(timeIntervalSinceReferenceDate: NSTimeInterval(timeRounded))
    print(roundedDate, terminator: "")
    return roundedDate
    
  }
}