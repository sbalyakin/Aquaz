//
//  MonthStatisticsTableViewCell.swift
//  Warter Me
//
//  Created by Sergey Balyakin on 26.11.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

protocol MonthStatisticsTableViewCellDelegate {
  func dayButtonTapped(dayButton: MonthStatisticsDayButton)
}

class MonthStatisticsTableViewCell: UITableViewCell {
  
  var delegate: MonthStatisticsTableViewCellDelegate? = nil
  
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

  override func layoutSubviews() {
    super.layoutSubviews()
    
    let dayButtonRects = computeRectsForDayButtons()
    assert(dayButtonRects.count == dayButtons.count)

    for (index, rect) in enumerate(dayButtonRects) {
      let dayButton = dayButtons[index]
      dayButton.frame = rect
    }
  }
  
  private func computeRectsForDayButtons() -> [CGRect] {
    let width = bounds.width / CGFloat(daysPerWeek)
    var rects: [CGRect] = []
    
    for i in 0..<daysPerWeek {
      let x = bounds.minX + CGFloat(i) * width
      var rect = CGRectMake(trunc(x), bounds.minY, ceil(width), bounds.height)
      let minSize = min(rect.width, rect.height)
      let dx = (rect.width - minSize) / 2
      let dy = (rect.height - minSize) / 2
      
      rect.inset(dx: dx + 4, dy: dy + 4)
      rects.append(rect.integerRect)
    }
    
    return rects
  }
  
  private func initButtons() {
    let dayButtonRects = computeRectsForDayButtons()
    assert(dayButtonRects.count == daysPerWeek)

    for i in 0..<daysPerWeek {
      let rect = dayButtonRects[i]
      let dayButton = MonthStatisticsDayButton(frame: rect)
      dayButton.addTarget(self, action: "dayButtonTapped:", forControlEvents: .TouchUpInside)
      contentView.addSubview(dayButton)
      dayButtons.append(dayButton)
    }
  }
  
  func dayButtonTapped(button: UIButton!) {
    if let delegate = delegate {
      if let dayButton = button as? MonthStatisticsDayButton {
        if let dayInfo = dayButton.dayInfo {
          delegate.dayButtonTapped(dayButton)
        } else {
          assert(false, "dayInfo for MonthStatisticsDayButton is not specified")
        }
      } else {
        assert(false, "Day button class is not MonthStatisticsDayButton")
      }
    }
  }
  
  var dayButtons: [MonthStatisticsDayButton] = []

  private let daysPerWeek = NSCalendar.currentCalendar().maximumRangeOfUnit(.WeekdayCalendarUnit).length
}
