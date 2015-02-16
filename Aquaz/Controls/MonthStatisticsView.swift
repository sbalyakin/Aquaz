//
//  MonthStatisticsView.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 26.11.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

protocol MonthStatisticsViewDataSource {
  func monthStatisticsGetValueForDate(date: NSDate, dayOfCurrentMonth: Int) -> Double
}

@IBDesignable class MonthStatisticsView: CalendarView {
  
  @IBInspectable var dayIntakeColor: UIColor = UIColor.orangeColor()
  @IBInspectable var dayIntakeFullColor: UIColor = UIColor(red: 80/255, green: 184/255, blue: 187/255, alpha: 1.0)
  @IBInspectable var dayIntakeBackgroundColor: UIColor = UIColor(red: 80/255, green: 184/255, blue: 187/255, alpha: 0.1)
  @IBInspectable var dayIntakeLineWidth: CGFloat = 4
  
  var dataSource: MonthStatisticsViewDataSource?
  
  override init() {
    super.init()
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  override func createDayButton(#frame: CGRect, dayInfo: CalendarViewDayInfo) -> CalendarDayButton {
    let button = MonthStatisticsDayButton(frame: frame)
    button.dayInfo = dayInfo
    button.monthStatisticsView = self
    button.value = requestValueForDate(dayInfo)
    return button
  }
  
  private func requestValueForDate(dayInfo: CalendarViewDayInfo) -> Double {
    #if TARGET_INTERFACE_BUILDER
      return 0.5
    #else
      return dataSource?.monthStatisticsGetValueForDate(dayInfo.date, dayOfCurrentMonth: dayInfo.dayOfCurrentMonth) ?? 0
    #endif
  }

}