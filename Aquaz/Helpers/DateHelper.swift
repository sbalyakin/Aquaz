//
//  DateHelper.swift
//  Aquaz
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

    if let date = calendar.dateFromComponents(components) {
      return date
    } else {
      assert(false)
      return ofDate
    }
  }

  class func addToDate(date: NSDate, years: Int, months: Int, days: Int) -> NSDate {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay | .CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond, fromDate: date)
    components.year += years
    components.month += months
    components.day += days
    
    if let date = calendar.dateFromComponents(components) {
      return date
    } else {
      assert(false)
      return date
    }
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
  
  class func areDatesEqualByYears(#date1: NSDate, date2: NSDate) -> Bool {
    let calendar = NSCalendar.currentCalendar()
    let components1 = calendar.components(.CalendarUnitYear, fromDate: date1)
    let components2 = calendar.components(.CalendarUnitYear, fromDate: date2)
    
    return components1.year == components2.year
  }
  
  /// Generates string for the specified date. If year of a current date is year of today, the function hides it.
  class func stringFromDate(date: NSDate, shortDateStyle: Bool = false) -> String {
    let today = NSDate()
    let daysTillToday = computeUnitsFrom(today, toDate: date, unit: .CalendarUnitDay)
    let dateFormatter = NSDateFormatter()
    
    if abs(daysTillToday) <= 1 {
      // Use standard date formatting for yesterday, today and tomorrow
      // in order to obtain "Yesterday", "Today" and "Tomorrow" localized date strings
      dateFormatter.dateStyle = shortDateStyle ? .ShortStyle : .MediumStyle
      dateFormatter.timeStyle = .NoStyle
      dateFormatter.doesRelativeDateFormatting = true
    } else {
      // Use custom formatting. If year of a current date is year of today, hide it.
      let yearsTillToday = computeUnitsFrom(today, toDate: date, unit: .CalendarUnitYear)
      let monthFormat = shortDateStyle ? "MMM" : "MMMM"
      let template = yearsTillToday == 0 ? "d\(monthFormat)" : "d\(monthFormat)yyyy"
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
  
  class func stringFromDateTime(dateTime: NSDate, shortDateStyle: Bool = false) -> String {
    let datePart = stringFromDate(dateTime, shortDateStyle: shortDateStyle)
    let timePart = stringFromTime(dateTime)
    return "\(datePart), \(timePart)"
  }
  
}

extension NSDate {
  func isLaterThan(date: NSDate) -> Bool {
    return date.compare(self) == .OrderedAscending
  }
  
  func isEarlierThan(date: NSDate) -> Bool {
    return date.compare(self) == .OrderedDescending
  }
  
  func getNextDay() -> NSDate {
    return DateHelper.addToDate(self, years: 0, months: 0, days: 1)
  }
}

