//
//  MonthStatisticsDayButton.swift
//  Water Me
//
//  Created by Sergey Balyakin on 26.11.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class MonthStatisticsDayButton: UIButton {
  
  var dayInfo: MonthStatisticsView.DayInfo! {
    didSet {
      assert(dayInfo != nil)
      dayInfo.changeHandler = dayInfoChanged
      dayInfoChanged()
    }
  }
  
  private var backgroundCircleColor: UIColor = UIColor.clearColor()
  
  private var consumptionColor: UIColor {
    return dayInfo.monthStatisticsView.dayConsumptionColor
  }
  
  private var consumptionBackgroundColor: UIColor {
    return dayInfo.monthStatisticsView.dayConsumptionBackgroundColor
  }
  
  private var consumptionLineWidth: CGFloat {
    return dayInfo.monthStatisticsView.dayConsumptionLineWidth
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

  override func drawRect(rect: CGRect) {
    drawBackground(rect: rect)
    
    if dayInfo.isCurrentMonth && !dayInfo.isFuture {
      drawArc(rect: rect)
    }
  }
  
  private func drawBackground(#rect: CGRect) {
    if backgroundCircleColor == UIColor.clearColor() {
      return
    }

    backgroundCircleColor.setFill()
    // It seems that circles are drawn visually slightly larger than arcs with the same radius, so reduce circle size a little.
    let adjustedRect = rect.rectByInsetting(dx: 0.2, dy: 0.2)
    let circlePath = UIBezierPath(ovalInRect: adjustedRect)
    circlePath.fill()
  }
  
  private func drawArc(#rect: CGRect) {
    let lineWidth: CGFloat = consumptionLineWidth
    
    let centerPoint = CGPointMake(rect.midX, rect.midY)
    let startAngle = CGFloat(-M_PI_2)
    let endAngle = CGFloat(-M_PI_2 + M_PI * 2 * dayInfo!.consumptionFraction)
    let radius = rect.width / 2 - lineWidth / 2
    
    let circlePath = UIBezierPath(ovalInRect: rect.rectByInsetting(dx: lineWidth / 2, dy: lineWidth / 2))
    circlePath.lineWidth = lineWidth
    circlePath.lineCapStyle = kCGLineCapRound
    consumptionBackgroundColor.setStroke()
    circlePath.stroke()
    
    let arcPath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
    arcPath.lineWidth = lineWidth
    arcPath.lineCapStyle = kCGLineCapRound
    consumptionColor.setStroke()
    arcPath.stroke()
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
