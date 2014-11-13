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
    let components = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay | .CalendarUnitTimeZone | .CalendarUnitCalendar, fromDate: ofDate)
    components.hour = hour
    components.minute = minute
    components.second = second
    return calendar.dateFromComponents(components)!
  }

  class func addToDate(date: NSDate, years: Int, months: Int, days: Int) -> NSDate {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay | .CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond, fromDate: date)
    components.year += years
    components.month += months
    components.day += days
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
    let valueFrom = calendar.ordinalityOfUnit(unit, inUnit: .CalendarUnitEra, forDate: dateByClearingTime(ofDate: date))
    let valueTo = calendar.ordinalityOfUnit(unit, inUnit: .CalendarUnitEra, forDate: dateByClearingTime(ofDate: toDate))
    return valueTo - valueFrom
  }
  
  class func areDatesEqualByDays(#date1: NSDate, date2: NSDate) -> Bool {
    let calendar = NSCalendar.currentCalendar()
    let components1 = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay, fromDate: date1)
    let components2 = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay, fromDate: date2)
    
    return components1.year == components2.year &&
      components1.month == components2.month &&
      components1.day == components2.day
  }
  
  class func areDatesEqualByMonths(#date1: NSDate, date2: NSDate) -> Bool {
    let calendar = NSCalendar.currentCalendar()
    let components1 = calendar.components(.CalendarUnitYear | .CalendarUnitMonth, fromDate: date1)
    let components2 = calendar.components(.CalendarUnitYear | .CalendarUnitMonth, fromDate: date2)
    
    return components1.year == components2.year &&
      components1.month == components2.month
  }
  
  /// Generates string for the specified date. If year of a current date is year of today, the function hides it.
  class func stringFromDate(date: NSDate) -> String {
    let today = NSDate()
    let daysTillToday = computeUnitsFrom(today, toDate: date, unit: .CalendarUnitDay)
    let dateFormatter = NSDateFormatter()
    
    if abs(daysTillToday) <= 1 {
      // Use standard date formatting for yesterday, today and tomorrow
      // in order to obtain "Yesterday", "Today" and "Tomorrow" localized date strings
      dateFormatter.dateStyle = .MediumStyle
      dateFormatter.timeStyle = .NoStyle
      dateFormatter.doesRelativeDateFormatting = true
    } else {
      // Use custom formatting. If year of a current date is year of today, hide it.
      let yearsTillToday = computeUnitsFrom(today, toDate: date, unit: .CalendarUnitYear)
      let template = yearsTillToday == 0 ? "dMMMM" : "dMMMMyyyy"
      let formatString = NSDateFormatter.dateFormatFromTemplate(template, options: 0, locale: NSLocale.currentLocale())
      dateFormatter.dateFormat = formatString
    }
    return dateFormatter.stringFromDate(date)
  }
  
  class func stringFromTime(time: NSDate) -> String {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateStyle = .NoStyle
    dateFormatter.timeStyle = .ShortStyle
    return dateFormatter.stringFromDate(time)
  }
  
  class func stringFromDateTime(dateTime: NSDate) -> String {
    let datePart = stringFromDate(dateTime)
    let timePart = stringFromTime(dateTime)
    return "\(datePart), \(timePart)"
  }

}