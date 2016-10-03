//
//  CalendarContentViewCell.swift
//  OmegaCalendar
//
//  Created by Sergey Balyakin on 17.03.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class CalendarContentViewCell: UICollectionViewCell {
  
  fileprivate var label: UILabel!
  fileprivate var backgroundLayer: CAShapeLayer!
  fileprivate var dayInfo: CalendarViewDayInfo!
  
  func setDayInfo(_ dayInfo: CalendarViewDayInfo, calendarContentView: CalendarContentView) {
    self.dayInfo = dayInfo

    let colors = computeColors(calendarContentView)

    if !colors.background.isClearColor() {
      if backgroundLayer == nil {
        backgroundLayer = CAShapeLayer()
        contentView.layer.insertSublayer(backgroundLayer, at: 0)
      }

      backgroundLayer.fillColor = colors.background.cgColor
    } else {
      backgroundLayer?.removeFromSuperlayer()
      backgroundLayer = nil
    }

    if label == nil {
      label = UILabel()
      label.backgroundColor = backgroundLayer == nil ? colors.background : UIColor.clear // remove useless blending
      label.isUserInteractionEnabled = false
      label.textAlignment = .center
      contentView.addSubview(label)
    } 

    label.text = dayInfo.title
    label.textColor = colors.text
    if dayInfo.isToday {
      let fontDescriptor = calendarContentView.font.fontDescriptor.withSymbolicTraits(.traitBold)
      let boldFont = UIFont(descriptor: fontDescriptor!, size: calendarContentView.font.pointSize)
      label.font = boldFont
    } else {
      label.font = calendarContentView.font
    }
    
    setNeedsLayout()
  }
  
  func getDayInfo() -> CalendarViewDayInfo {
    return dayInfo
  }
    
  override func layoutSubviews() {
    super.layoutSubviews()
    
    let radius = trunc(min(contentView.bounds.width, contentView.bounds.height) / 2) - 2
    let origin = CGPoint(x: contentView.bounds.midX - radius, y: contentView.bounds.midY - radius)
    let size = CGSize(width: radius * 2, height: radius * 2)
    let rect = CGRect(origin: origin, size: size)
    
    backgroundLayer?.path = UIBezierPath(ovalIn: rect).cgPath
    
    label?.frame = contentView.bounds
  }

  fileprivate func computeColors(_ calendarContentView: CalendarContentView) -> (text: UIColor, background: UIColor) {
    var result = (text: UIColor.black, background: UIColor.clear)
    
    if let selectedDate = calendarContentView.selectedDate , DateHelper.areEqualDays(selectedDate, dayInfo.date) {
      result.text = calendarContentView.selectedDayTextColor
      result.background = calendarContentView.selectedDayBackgroundColor
    } else if dayInfo.isToday {
      result.text = calendarContentView.todayTextColor
      result.background = calendarContentView.todayBackgroundColor
    } else if dayInfo.isWeekend {
      result.text = calendarContentView.weekendTextColor
      result.background = calendarContentView.weekendBackgroundColor
    } else {
      result.text = calendarContentView.workDayTextColor
      result.background = calendarContentView.workDayBackgroundColor
    }
    
    // Make colors more translutent for future days and for days of past month
    if dayInfo.isFuture {
      if !result.text.isClearColor() {
        result.text = result.text.withAlphaComponent(calendarContentView.futureDaysTransparency)
      }
      
      result.background = UIColor.clear
    } else if !dayInfo.isCurrentMonth {
      if !result.text.isClearColor() {
        result.text = result.text.withAlphaComponent(calendarContentView.anotherMonthTransparency)
      }
      
      result.background = UIColor.clear
    }
    
    return result
  }

}
