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
    let components = calendar.components(.CalendarUnitHour, fromDate: self)
    let hour = components.hour
    
    //Return Hour
    return hour
  }
}