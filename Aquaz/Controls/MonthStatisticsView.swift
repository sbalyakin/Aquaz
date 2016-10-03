//
//  MonthStatisticsView.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 17.03.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

protocol MonthStatisticsViewDataSource: class {
  func monthStatisticsGetValuesForDateInterval(beginDate: Date, endDate: Date, calendarContentView: CalendarContentView) -> [Double]
}

@IBDesignable class MonthStatisticsView: CalendarView {
  
  @IBInspectable var dayIntakeColor: UIColor = UIColor.orange
  @IBInspectable var dayIntakeFullColor: UIColor = UIColor(red: 80/255, green: 184/255, blue: 187/255, alpha: 1.0)
  @IBInspectable var dayIntakeBackgroundColor: UIColor = UIColor(red: 80/255, green: 184/255, blue: 187/255, alpha: 0.1)
  @IBInspectable var dayIntakeLineWidth: CGFloat = 4
  
  weak var dataSource: MonthStatisticsViewDataSource?
  
  override func createCalendarViewContent() -> CalendarContentView {
    let contentView = MonthStatisticsContentView(frame: bounds)
    
    contentView.dayIntakeColor = dayIntakeColor
    contentView.dayIntakeFullColor = dayIntakeFullColor
    contentView.dayIntakeBackgroundColor = dayIntakeBackgroundColor
    contentView.dayIntakeLineWidth = dayIntakeLineWidth
    
    return contentView
  }
  
  override func createCalendarViewDaysInfoForMonth(calendarContentView: CalendarContentView, monthDate: Date) -> [CalendarViewDayInfo] {
    let daysInfo = CalendarViewDataSource.createCalendarViewDaysInfoForMonth(monthDate)
    
    #if TARGET_INTERFACE_BUILDER
      for dayInfo in daysInfo {
        if dayInfo.isCurrentMonth {
          dayInfo.userData = CGFloat(sin(Double(dayInfo.dayOfCurrentMonth % 20) / 20 * M_PI))
        }
      }
    #else
      let startOfMonth = DateHelper.startOfMonth(monthDate)
      let startOfNextMonth = DateHelper.nextMonthFrom(startOfMonth)
      
      if let values = dataSource?.monthStatisticsGetValuesForDateInterval(beginDate: startOfMonth, endDate: startOfNextMonth, calendarContentView: calendarContentView) , !values.isEmpty {
        for dayInfo in daysInfo {
          if dayInfo.isCurrentMonth {
            let dayIndex = dayInfo.dayOfCurrentMonth - 1
            if dayIndex < values.count {
              dayInfo.userData = values[dayIndex]
            } else {
              assert(false)
            }
          }
        }
      }
    #endif
    
    return daysInfo
  }

}
