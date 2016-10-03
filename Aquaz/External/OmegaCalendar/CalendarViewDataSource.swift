//
//  CalendarViewDataSource.swift
//  OmegaCalendar
//
//  Created by Sergey Balyakin on 17.03.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import Foundation

class CalendarViewDataSource {
  
  class func createCalendarViewDaysInfoForMonth(_ monthDate: Date) -> [CalendarViewDayInfo] {
    let calendar = Calendar.current
    let daysPerWeek = DateHelper.daysPerWeek()

    var daysInfo = [CalendarViewDayInfo]()
    
    let date = monthDate
    
    // Separate the date to components
    var components = calendar.dateComponents([.year, .month, .day, .timeZone, .calendar], from: date)
    
    // Compute the first and the last days of the month
    let daysInMonth = calendar.range(of: .day, in: .month, for: date)!
    
    components.day = daysInMonth.lowerBound
    let firstMonthDay = calendar.date(from: components)!
    let weekdayOfFirstMonthDay = calendar.ordinality(of: .weekday, in: .weekOfMonth, for: firstMonthDay)!
    
    components.day = daysInMonth.upperBound - 1
    let lastMonthDay = calendar.date(from: components)!
    let weekdayOfLastMonthDay = calendar.ordinality(of: .weekday, in: .weekOfMonth, for: lastMonthDay)!
    
    // Fill days and days titles
    daysInfo = []
    let today = DateHelper.startOfDay(Date())
    let weekdayRange = calendar.maximumRange(of: .weekday)!
    var weekdayOfDate = 0
    let checkForToday = DateHelper.areEqualMonths(date, today)
    let from = 2 - weekdayOfFirstMonthDay
    let to = daysInMonth.count + daysPerWeek - weekdayOfLastMonthDay
    
    for i in from...to {
      components.day = i
      let date = calendar.date(from: components)!
      
      if i == from {
        let weekDayComponents = calendar.dateComponents([.weekday], from: date)
        weekdayOfDate = weekDayComponents.weekday!
      } else {
        if weekdayOfDate > daysPerWeek {
          weekdayOfDate = 1
        }
      }
      
      let isWeekend = (weekdayOfDate == weekdayRange.lowerBound) || (weekdayOfDate == weekdayRange.upperBound - 1)
      weekdayOfDate += 1
      
      let isToday = checkForToday ? DateHelper.areEqualDays(date, today) : false
      let isCurrentMonth = i >= daysInMonth.lowerBound && i <= daysInMonth.upperBound - 1
      let dayOrdinalNumber = isCurrentMonth ? i : calendar.ordinality(of: .day, in: .month, for: date)!
      let title = "\(dayOrdinalNumber)"
      let isFuture = date.compare(today) == .orderedDescending
      
      let dayInfo = CalendarViewDayInfo(
        date: date,
        dayOfCurrentMonth: i,
        title: title,
        isWeekend: isWeekend,
        isToday: isToday,
        isCurrentMonth: isCurrentMonth,
        isFuture: isFuture)
      
      daysInfo.append(dayInfo)
    }
    
    return daysInfo
  }

}
