//
//  DateHelper.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 07.11.14.
//  Copyright © 2014 Sergey Balyakin. All rights reserved.
//

import Foundation

class DateHelper {

  class func dateBySettingHour(_ hour: Int, minute: Int, second: Int, ofDate: Date) -> Date {
    let calendar = Calendar.current
    var components = calendar.dateComponents([.year, .month, .day], from: ofDate)
    components.hour = hour
    components.minute = minute
    components.second = second
    
    if let date = calendar.date(from: components) {
      return date
    } else {
      assert(false)
      return ofDate
    }
  }

  class func addToDate(_ date: Date, years: Int, months: Int, days: Int) -> Date {
    let components = DateComponents(calendar: nil, timeZone: nil, era: nil, year: years, month: months, day: days)
    
    if let newDate = Calendar.current.date(byAdding: components, to: date) {
      return newDate
    } else {
      assert(false)
      return date
    }
  }

  class func dateByJoiningDateTime(datePart: Date, timePart: Date) -> Date {
    let components = Calendar.current.dateComponents([.hour, .minute, .second], from: timePart)
    return dateBySettingHour(components.hour!, minute: components.minute!, second: components.second!, ofDate: datePart)
  }
  
  class func startOfDay(_ date: Date) -> Date {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month ,.day], from: date)
    
    if let newDate = calendar.date(from: components) {
      return newDate
    } else {
      assert(false)
      return date
    }
  }
  
  class func startOfMonth(_ date: Date) -> Date {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month], from: date)
    
    if let newDate = calendar.date(from: components) {
      return newDate
    } else {
      assert(false)
      return date
    }
  }

  class func startOfYear(_ date: Date) -> Date {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year], from: date)
    
    if let newDate = calendar.date(from: components) {
      return newDate
    } else {
      assert(false)
      return date
    }
  }
  
  class func nextDayFrom(_ date: Date) -> Date {
    return Calendar.current.date(byAdding: .day, value: 1, to: date)!
  }

  class func previousDayBefore(_ date: Date) -> Date {
    return Calendar.current.date(byAdding: .day, value: -1, to: date)!
  }

  class func nextMonthFrom(_ date: Date) -> Date {
    return Calendar.current.date(byAdding: .month, value: 1, to: date)!
  }
  
  class func previousMonthBefore(_ date: Date) -> Date {
    return Calendar.current.date(byAdding: .month, value: -1, to: date)!
  }
  
  class func nextYearFrom(_ date: Date) -> Date {
    return Calendar.current.date(byAdding: .year, value: 1, to: date)!
  }
  
  class func previousYearBefore(_ date: Date) -> Date {
    return Calendar.current.date(byAdding: .year, value: -1, to: date)!
  }
  
  class func calendarDays(fromDate: Date, toDate: Date) -> Int {
    let calendar = Calendar.current
    let fromComponents = calendar.dateComponents([.year, .month, .day], from: fromDate)
    let toComponents = calendar.dateComponents([.year, .month, .day], from: toDate)
    return calendar.dateComponents([.day], from: fromComponents, to: toComponents).day!
  }
  
  class func calendarMonths(fromDate: Date, toDate: Date) -> Int {
    let calendar = Calendar.current
    let fromComponents = calendar.dateComponents([.year, .month], from: fromDate)
    let toComponents = calendar.dateComponents([.year, .month], from: toDate)
    return calendar.dateComponents([.month], from: fromComponents, to: toComponents).month!
  }
  
  class func calendarYears(fromDate: Date, toDate: Date) -> Int {
    let calendar = Calendar.current
    let fromComponents = calendar.dateComponents([.year], from: fromDate)
    let toComponents = calendar.dateComponents([.year], from: toDate)
    return calendar.dateComponents([.year], from: fromComponents, to: toComponents).year!
  }

  class func days(fromDate: Date, toDate: Date) -> Int {
    return Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day!
  }
  
  class func months(fromDate: Date, toDate: Date) -> Int {
    return Calendar.current.dateComponents([.month], from: fromDate, to: toDate).month!
  }
  
  class func years(fromDate: Date, toDate: Date) -> Int {
    return Calendar.current.dateComponents([.year], from: fromDate, to: toDate).year!
  }
  
  class func areEqualDays(_ date1: Date, _ date2: Date) -> Bool {
    return calendarDays(fromDate: date1, toDate: date2) == 0
  }

  class func areEqualMonths(_ date1: Date, _ date2: Date) -> Bool {
    return calendarMonths(fromDate: date1, toDate: date2) == 0
  }
  
  class func areEqualYears(_ date1: Date, _ date2: Date) -> Bool {
    return calendarYears(fromDate: date1, toDate: date2) == 0
  }

  class func daysPerWeek() -> Int {
    return Calendar.current.maximumRange(of: .weekday)!.count
  }

  class func monthsPerYear() -> Int {
    return Calendar.current.maximumRange(of: .month)!.count
  }

  class func daysInMonth(date: Date) -> Int {
    return Calendar.current.range(of: .day, in: .month, for: date)!.count
  }
  
  /// Generates string for the specified date. If year of a current date is year of today, the function hides it.
  class func stringFromDate(_ date: Date, shortDateStyle: Bool = false) -> String {
    let today = Date()
    let daysTillToday = calendarDays(fromDate: today, toDate: date)
    let dateFormatter = DateFormatter()
    
    if abs(daysTillToday) <= 1 {
      // Use standard date formatting for yesterday, today and tomorrow
      // in order to obtain "Yesterday", "Today" and "Tomorrow" localized date strings
      dateFormatter.dateStyle = shortDateStyle ? .short : .medium
      dateFormatter.timeStyle = .none
      dateFormatter.doesRelativeDateFormatting = true
    } else {
      // Use custom formatting. If year of a current date is year of today, hide it.
      let yearsTillToday = calendarYears(fromDate: today, toDate: date)
      let monthFormat = shortDateStyle ? "MMM" : "MMMM"
      let template = yearsTillToday == 0 ? "d\(monthFormat)" : "d\(monthFormat)yyyy"
      let formatString = DateFormatter.dateFormat(fromTemplate: template, options: 0, locale: Locale.current)
      dateFormatter.dateFormat = formatString
    }
    return dateFormatter.string(from: date)
  }
  
  class func stringFromTime(_ time: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .none
    dateFormatter.timeStyle = .short
    return dateFormatter.string(from: time)
  }
  
  class func stringFromDateTime(_ dateTime: Date, shortDateStyle: Bool = false) -> String {
    let datePart = stringFromDate(dateTime, shortDateStyle: shortDateStyle)
    let timePart = stringFromTime(dateTime)
    return "\(datePart), \(timePart)"
  }
  
}

extension Date {
  func isLaterThan(_ date: Date) -> Bool {
    return date.compare(self) == .orderedAscending
  }
  
  func isEarlierThan(_ date: Date) -> Bool {
    return date.compare(self) == .orderedDescending
  }
}

