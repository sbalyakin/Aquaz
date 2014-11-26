//
//  CalendarDayButton.swift
//  Water Me
//
//  Created by Sergey Balyakin on 07.11.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class CalendarDayButton: UIButton {
  
  var dayInfo: CalendarView.DayInfo? {
    didSet {
      dayInfoChanged()
    }
  }
  
  func dayInfoChanged() {
    if let info = dayInfo {
      let colors = info.computeColors()
      setTitle(info.title, forState: .Normal)
      setTitleColor(colors.text, forState: .Normal)
      backgroundColor = colors.background
      if info.isFuture {
        enabled = false
      }
    } else {
      setTitle("", forState: .Normal)
      setTitleColor(UIColor.blackColor(), forState: .Normal)
      backgroundColor = UIColor.clearColor()
      layer.cornerRadius = 0.0
      enabled = false
    }
    adjustLayerCornerRadius()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    adjustLayerCornerRadius()
  }
  
  private func adjustLayerCornerRadius() {
    if backgroundColor == UIColor.clearColor() {
      layer.cornerRadius = 0.0
    } else {
      let minSide = min(bounds.width, bounds.height)
      layer.cornerRadius = minSide / 2
    }
  }
  
  override init() {
    super.init()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
}
