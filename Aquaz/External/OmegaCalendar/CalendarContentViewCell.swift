//
//  CalendarContentViewCell.swift
//  OmegaCalendar
//
//  Created by Sergey Balyakin on 17.03.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class CalendarContentViewCell: UICollectionViewCell {
  
  private var label: UILabel!
  private var backgroundLayer: CAShapeLayer!
  private var dayInfo: CalendarViewDayInfo!
    
  func setDayInfo(dayInfo: CalendarViewDayInfo, calendarContentView: CalendarContentView) {
    self.dayInfo = dayInfo

    label?.removeFromSuperview()
    label = nil
    backgroundLayer?.removeFromSuperlayer()
    backgroundLayer = nil
    
    let colors = computeColors(calendarContentView)
    
    if !colors.background.isClearColor() {
      backgroundLayer = CAShapeLayer()
      backgroundLayer.fillColor = colors.background.CGColor
      contentView.layer.addSublayer(backgroundLayer)
    }
    
    label = UILabel()
    label.text = dayInfo.title
    label.textColor = colors.text
    label.textAlignment = .Center
    label.font = calendarContentView.font
    label.userInteractionEnabled = false
    
    contentView.addSubview(label)
    
    setNeedsLayout()
  }
  
  func getDayInfo() -> CalendarViewDayInfo! {
    return dayInfo
  }
    
  override func layoutSubviews() {
    super.layoutSubviews()
    
    let radius = trunc(min(contentView.bounds.width, contentView.bounds.height) / 2) - 2
    let origin = CGPoint(x: contentView.bounds.midX - radius, y: contentView.bounds.midY - radius)
    let size = CGSize(width: radius * 2, height: radius * 2)
    let rect = CGRect(origin: origin, size: size)
    
    backgroundLayer?.path = UIBezierPath(ovalInRect: rect).CGPath
    
    label?.frame = contentView.bounds
  }

  private func computeColors(calendarContentView: CalendarContentView) -> (text: UIColor, background: UIColor) {
    var result = (text: UIColor.clearColor(), background: UIColor.clearColor())
    
    if dayInfo.isToday {
      result.text = calendarContentView.todayTextColor
      result.background = calendarContentView.todayBackgroundColor
    }
    
    if let selectedDate = calendarContentView.selectedDate {
      if DateHelper.areDatesEqualByDays(date1: selectedDate, date2: dayInfo.date) {
        result.text = result.text.realColorFromColor(calendarContentView.selectedDayTextColor)
        result.background = result.background.realColorFromColor(calendarContentView.selectedDayBackgroundColor)
      }
    }
    
    if dayInfo.isWeekend {
      result.text = result.text.realColorFromColor(calendarContentView.weekendTextColor)
      result.background = result.background.realColorFromColor(calendarContentView.weekendBackgroundColor)
    }
    
    if result.text.isClearColor() {
      result.text = calendarContentView.workDayTextColor
    }
    
    if result.background.isClearColor() {
      result.background = calendarContentView.workDayBackgroundColor
    }
    
    // Make colors more translutent for future days and for days of past month
    if dayInfo.isFuture {
      if !result.text.isClearColor() {
        result.text = result.text.colorWithAlphaComponent(calendarContentView.futureDaysTransparency)
      }
      
      if !result.background.isClearColor() {
        result.background = result.background.colorWithAlphaComponent(calendarContentView.futureDaysTransparency)
      }
    } else if !dayInfo.isCurrentMonth {
      if !result.text.isClearColor() {
        result.text = result.text.colorWithAlphaComponent(calendarContentView.anotherMonthTransparency)
      }
      
      if !result.background.isClearColor() {
        result.background = result.background.colorWithAlphaComponent(calendarContentView.anotherMonthTransparency)
      }
    }
    
    return result
  }

}

private extension UIColor {
  func realColorFromColor(color: UIColor) -> UIColor {
    if isClearColor() && !color.isClearColor() {
      return color
    }
    
    return self
  }
}

