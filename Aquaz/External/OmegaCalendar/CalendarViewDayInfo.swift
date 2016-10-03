//
//  CalendarDayInfo.swift
//  OmegaCalendar
//
//  Created by Sergey Balyakin on 17.03.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import Foundation
import UIKit

class CalendarViewDayInfo {
  let date: Date
  let dayOfCurrentMonth: Int
  let title: String
  let isWeekend: Bool
  let isToday: Bool
  let isCurrentMonth: Bool
  let isFuture: Bool
  var userData: Any?
  
  init(date: Date, dayOfCurrentMonth: Int, title: String, isWeekend: Bool, isToday: Bool, isCurrentMonth: Bool, isFuture: Bool) {
    self.date = date
    self.dayOfCurrentMonth = dayOfCurrentMonth
    self.title = title
    self.isWeekend = isWeekend
    self.isToday = isToday
    self.isCurrentMonth = isCurrentMonth
    self.isFuture = isFuture
  }
  
}
