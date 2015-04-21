//
//  CalendarViewDataSource.swift
//  OmegaCalendar
//
//  Created by Sergey Balyakin on 17.03.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import Foundation

class CalendarViewDataSource {
  
  class func createCalendarViewDaysInfoForMonth(monthDate: NSDate) -> [CalendarViewDayInfo] {
    let calendar = NSCalendar.currentCalendar()
    let daysPerWeek = calendar.maximumRangeOfUnit(.CalendarUnitWeekday).length

    var daysInfo = [CalendarViewDayInfo]()
    
    let date = monthDate
    
    // Separate the date to components
    let components = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay | .CalendarUnitTimeZone | .CalendarUnitCalendar, fromDate: date)
    
    // Compute the first and the last days of the month
    let daysInMonth = calendar.rangeOfUnit(.CalendarUnitDay, inUnit: .CalendarUnitMonth, forDate: date)
    
    components.day = daysInMonth.location
    let firstMonthDay = calendar.dateFromComponents(components)!
    let weekdayOfFirstMonthDay = calendar.ordinalityOfUnit(.CalendarUnitWeekday, inUnit: .CalendarUnitWeekOfMonth, forDate: firstMonthDay)
    
    components.day = daysInMonth.length
    let lastMonthDay = calendar.dateFromComponents(components)!
    let weekdayOfLastMonthDay = calendar.ordinalityOfUnit(.CalendarUnitWeekday, inUnit: .CalendarUnitWeekOfMonth, forDate: lastMonthDay)
    
    // Fill days and days titles
    daysInfo = []
    let today = DateHelper.dateByClearingTime(ofDate: NSDate())
    let weekdayRange = calendar.maximumRangeOfUnit(.CalendarUnitWeekday)
    var weekdayOfDate = 0
    let checkForToday = DateHelper.areDatesEqualByMonths(date, today)
    let from = 2 - weekdayOfFirstMonthDay
    let to = daysInMonth.length + daysPerWeek - weekdayOfLastMonthDay
    
    for i in from...to {
      components.day = i
      let date = calendar.dateFromComponents(components)!
      
      if i == from {
        let weekDayComponents = calendar.components(.CalendarUnitWeekday, fromDate: date)
        weekdayOfDate = weekDayComponents.weekday
      } else {
        if weekdayOfDate > daysPerWeek {
          weekdayOfDate = 1
        }
      }
      let isWeekend = (weekdayOfDate == weekdayRange.location) || (weekdayOfDate == weekdayRange.length)
      weekdayOfDate++
      
      let isToday = checkForToday ? DateHelper.areDatesEqualByDays(date, today) : false
      let isCurrentMonth = i >= daysInMonth.location && i <= daysInMonth.length
      let dayOrdinalNumber = isCurrentMonth ? i : calendar.ordinalityOfUnit(.CalendarUnitDay, inUnit: .CalendarUnitMonth, forDate: date)
      let title = "\(dayOrdinalNumber)"
      let isFuture = date.compare(today) == .OrderedDescending
      
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