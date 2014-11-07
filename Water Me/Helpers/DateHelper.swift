//
//  DateHelper.swift
//  Water Me
//
//  Created by Sergey Balyakin on 07.11.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation

class DateHelper {

  class func dateBySettingHour(hour: Int, minute: Int, second: Int, ofDate: NSDate) -> NSDate {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay, fromDate: ofDate)
    components.hour = hour
    components.minute = minute
    components.second = second
    return calendar.dateFromComponents(components)!
  }

  class func dateByClearingTime(#ofDate: NSDate) -> NSDate {
    return dateBySettingHour(0, minute: 0, second: 0, ofDate: ofDate)
  }
  
  class func dateByJoiningDateTime(#datePart: NSDate, timePart: NSDate) -> NSDate {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond, fromDate: timePart)
    return dateBySettingHour(components.hour, minute: components.minute, second: components.second, ofDate: datePart)
  }
  
  class func computeUnitsFrom(date: NSDate, toDate: NSDate, unit: NSCalendarUnit) -> Int {
    let calendar = NSCalendar.currentCalendar()
    let valueFrom = calendar.ordinalityOfUnit(unit, inUnit: .CalendarUnitEra, forDate: date)
    let valueTo = calendar.ordinalityOfUnit(unit, inUnit: .CalendarUnitEra, forDate: toDate)
    return valueTo - valueFrom
  }
  
}