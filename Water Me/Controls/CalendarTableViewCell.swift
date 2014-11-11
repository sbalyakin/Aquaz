//
//  CalendarTableViewCell.swift
//  Warter Me
//
//  Created by Sergey Balyakin on 07.11.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

protocol DaySelectionDelegate {
  func dayDidSelected(date: NSDate)
}

class CalendarTableViewCell: UITableViewCell {
  
  var daySelectionDelegate: DaySelectionDelegate? = nil
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    initButtons()
  }
  
  override init() {
    super.init()
    initButtons()
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initButtons()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    initButtons()
  }

  func dayButtonTapped(button: UIButton!) {
    if let delegate = daySelectionDelegate {
      if let dayButton = button as? CalendarDayButton {
        if let dayInfo = dayButton.dayInfo {
          delegate.dayDidSelected(dayInfo.date)
        } else {
          assert(false, "dayInfo for CalendarDayButton is not specified")
        }
      } else {
        assert(false, "Calendar button class is not CalendarDayButton")
      }
    }
  }
  
  private func initButtons() {
    let width = frame.width / CGFloat(daysPerWeek)
    var x = frame.minX
    
    for i in 0..<daysPerWeek {
      var rect = CGRectMake(trunc(x), frame.minY, ceil(width), frame.height)
      let minSize = min(rect.width, rect.height)
      let dx = (rect.width - minSize) / 2
      let dy = (rect.height - minSize) / 2
      
      rect.inset(dx: dx + 4, dy: dy + 4)
      x += width
      
      let dayButton = CalendarDayButton(frame: rect)
      dayButton.addTarget(self, action: "dayButtonTapped:", forControlEvents: .TouchUpInside)
      
      contentView.addSubview(dayButton)
      dayButtons.append(dayButton)
    }
  }
  
  var dayButtons: [CalendarDayButton] = []

  private let daysPerWeek = NSCalendar.currentCalendar().maximumRangeOfUnit(.WeekdayCalendarUnit).length
}
