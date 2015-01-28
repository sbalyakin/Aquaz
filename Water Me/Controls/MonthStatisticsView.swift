//
//  MonthStatisticsView.swift
//  Water Me
//
//  Created by Sergey Balyakin on 26.11.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

protocol MonthStatisticsViewDataSource {
  func monthStatisticsGetConsumptionFractionForDate(date: NSDate, dayOfCurrentMonth: Int) -> Double
}

@IBDesignable class MonthStatisticsView: CalendarView {
  
  @IBInspectable var dayConsumptionColor: UIColor = UIColor.orangeColor()
  @IBInspectable var dayConsumptionFullColor: UIColor = UIColor(red: 80/255, green: 184/255, blue: 187/255, alpha: 1.0)
  @IBInspectable var dayConsumptionBackgroundColor: UIColor = UIColor(red: 80/255, green: 184/255, blue: 187/255, alpha: 0.1)
  @IBInspectable var dayConsumptionLineWidth: CGFloat = 4
  
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
    button.consumptionFraction = requestConsumptionFractionForDate(dayInfo)
    return button
  }
  
  private func requestConsumptionFractionForDate(dayInfo: CalendarViewDayInfo) -> Double {
    #if TARGET_INTERFACE_BUILDER
      return 0.5
    #else
      return dataSource?.monthStatisticsGetConsumptionFractionForDate(dayInfo.date, dayOfCurrentMonth: dayInfo.dayOfCurrentMonth) ?? 0
    #endif
  }

}