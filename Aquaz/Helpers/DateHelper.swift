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
    let components = calendar.components([.Year, .Month, .Day, .TimeZone, .Calendar], fromDate: ofDate)
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
    let components = NSDateComponents()
    components.year = years
    components.month = months
    components.day = days
    
    let calendar = NSCalendar.currentCalendar()
    if let newDate = calendar.dateByAddingComponents(components, toDate: date, options: NSCalendarOptions.MatchStrictly) {
      return newDate
    } else {
      assert(false)
      return date
    }
  }

  class func dateByClearingTime(ofDate date: NSDate) -> NSDate {
    return dateBySettingHour(0, minute: 0, second: 0, ofDate: date)
  }
  
  class func dateByJoiningDateTime(datePart datePart: NSDate, timePart: NSDate) -> NSDate {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Hour, .Minute, .Second], fromDate: timePart)
    return dateBySettingHour(components.hour, minute: components.minute, second: components.second, ofDate: datePart)
  }
  
  class func startDateFromDate(date: NSDate, calendarUnit: NSCalendarUnit) -> NSDate {
    var startDate: NSDate?
    NSCalendar.currentCalendar().rangeOfUnit(calendarUnit, startDate: &startDate, interval: nil, forDate: date)
    if let startDate = startDate {
      return startDate
    }
    
    assert(false)
    return date
  }

  class func computeUnitsFrom(date: NSDate, toDate: NSDate, unit: NSCalendarUnit) -> Int {
    let calendar = NSCalendar.currentCalendar()
    let valueFrom = calendar.ordinalityOfUnit(unit, inUnit: .Era, forDate: dateByClearingTime(ofDate: date))
    let valueTo = calendar.ordinalityOfUnit(unit, inUnit: .Era, forDate: dateByClearingTime(ofDate: toDate))
    return valueTo - valueFrom
  }
  
  class func calcDistanceBetweenCalendarDates(fromDate fromDate: NSDate, toDate: NSDate, calendarUnit: NSCalendarUnit) -> Int {
    let calendar = NSCalendar.currentCalendar()
    
    var fromDay: NSDate?
    var toDay: NSDate?
    calendar.rangeOfUnit(calendarUnit, startDate: &fromDay, interval: nil, forDate: fromDate)
    calendar.rangeOfUnit(calendarUnit, startDate: &toDay, interval: nil, forDate: toDate)
    
    let difference = calendar.components(calendarUnit, fromDate: fromDay!, toDate: toDay!, options: .MatchStrictly)
    
    switch calendarUnit {
    case NSCalendarUnit.Day:   return difference.day
    case NSCalendarUnit.Month: return difference.month
    case NSCalendarUnit.Year:  return difference.year
    default: return 0
    }
  }

  class func calcDistanceBetweenDates(fromDate fromDate: NSDate, toDate: NSDate, calendarUnit: NSCalendarUnit) -> Int {
    let calendar = NSCalendar.currentCalendar()
    
    let difference = calendar.components(calendarUnit, fromDate: fromDate, toDate: toDate, options: .MatchStrictly)
    
    switch calendarUnit {
    case NSCalendarUnit.Day:   return difference.day
    case NSCalendarUnit.Month: return difference.month
    case NSCalendarUnit.Year:  return difference.year
    default: return 0
    }
  }
  
  class func areDatesEqualByDays(date1: NSDate, _ date2: NSDate) -> Bool {
    return calcDistanceBetweenCalendarDates(fromDate: date1, toDate: date2, calendarUnit: .Day) == 0
  }
  
  class func areDatesEqualByMonths(date1: NSDate, _ date2: NSDate) -> Bool {
    return calcDistanceBetweenCalendarDates(fromDate: date1, toDate: date2, calendarUnit: .Month) == 0
  }
  
  class func areDatesEqualByYears(date1: NSDate, _ date2: NSDate) -> Bool {
    return calcDistanceBetweenCalendarDates(fromDate: date1, toDate: date2, calendarUnit: .Year) == 0
  }
  
  /// Generates string for the specified date. If year of a current date is year of today, the function hides it.
  class func stringFromDate(date: NSDate, shortDateStyle: Bool = false) -> String {
    let today = NSDate()
    let daysTillToday = calcDistanceBetweenDates(fromDate: today, toDate: date, calendarUnit: .Day)
    let dateFormatter = NSDateFormatter()
    
    if abs(daysTillToday) <= 1 {
      // Use standard date formatting for yesterday, today and tomorrow
      // in order to obtain "Yesterday", "Today" and "Tomorrow" localized date strings
      dateFormatter.dateStyle = shortDateStyle ? .ShortStyle : .MediumStyle
      dateFormatter.timeStyle = .NoStyle
      dateFormatter.doesRelativeDateFormatting = true
    } else {
      // Use custom formatting. If year of a current date is year of today, hide it.
      let yearsTillToday = calcDistanceBetweenDates(fromDate: today, toDate: date, calendarUnit: .Year)
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

