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
  
  override var backgroundColor: UIColor! {
    didSet {
      contentView.backgroundColor = backgroundColor
      backgroundView?.backgroundColor = backgroundColor
      label?.backgroundColor = backgroundColor
    }
  }
    
  func setDayInfo(dayInfo: CalendarViewDayInfo, calendarContentView: CalendarContentView) {
    self.dayInfo = dayInfo

    let colors = computeColors(calendarContentView)

    if !colors.background.isClearColor() {
      if backgroundLayer == nil {
        backgroundLayer = CAShapeLayer()
        contentView.layer.insertSublayer(backgroundLayer, atIndex: 0)
      }

      backgroundLayer.fillColor = colors.background.CGColor
    } else {
      backgroundLayer?.removeFromSuperlayer()
      backgroundLayer = nil
    }

    if label == nil {
      label = UILabel()
      label.backgroundColor = backgroundColor // remove useless blending
      label.userInteractionEnabled = false
      label.textAlignment = .Center
      contentView.addSubview(label)
    } 

    label.text = dayInfo.title
    label.textColor = colors.text
    if dayInfo.isToday {
      let fontDescriptor = calendarContentView.font.fontDescriptor().fontDescriptorWithSymbolicTraits(.TraitBold)!
      let boldFont = UIFont(descriptor: fontDescriptor, size: calendarContentView.font.pointSize)
      label.font = boldFont
    } else {
      label.font = calendarContentView.font
    }
    
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
    var result = (text: UIColor.blackColor(), background: UIColor.clearColor())
    
    if let selectedDate = calendarContentView.selectedDate where DateHelper.areDatesEqualByDays(selectedDate, dayInfo.date) {
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
        result.text = result.text.colorWithAlphaComponent(calendarContentView.futureDaysTransparency)
      }
      
      result.background = UIColor.clearColor()
    } else if !dayInfo.isCurrentMonth {
      if !result.text.isClearColor() {
        result.text = result.text.colorWithAlphaComponent(calendarContentView.anotherMonthTransparency)
      }
      
      result.background = UIColor.clearColor()
    }
    
    return result
  }

}
