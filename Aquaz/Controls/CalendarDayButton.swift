//
//  CalendarDayButton.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 26.11.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class CalendarDayButton: UIButton {
  
  var dayInfo: CalendarViewDayInfo! {
    didSet {
      assert(dayInfo != nil)
      dayInfo.changeHandler = dayInfoChanged
      dayInfoChanged()
    }
  }
  
  var backgroundCircleColor: UIColor = UIColor.clearColor() {
    didSet {
      setNeedsDisplay()
    }
  }
  
  override func drawRect(rect: CGRect) {
    drawBackground(rect: rect)
  }
  
  func drawBackground(#rect: CGRect) {
    if backgroundCircleColor.isClearColor() {
      return
    }
    
    backgroundCircleColor.setFill()
    let circlePath = UIBezierPath(ovalInRect: rect)
    circlePath.fill()
  }
  
  private func dayInfoChanged() {
    let colors = dayInfo.computeColors()
    setTitle(dayInfo.title, forState: .Normal)
    setTitleColor(colors.text, forState: .Normal)
    backgroundCircleColor = colors.background
    if dayInfo.isFuture {
      enabled = false
    }
  }
  
}
