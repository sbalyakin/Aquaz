//
//  MonthStatisticsDayButton.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 26.11.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class MonthStatisticsDayButton: CalendarDayButton {

  var value: Double = 0
  var monthStatisticsView: MonthStatisticsView!
  
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
    super.drawRect(rect)
    
    if dayInfo.isCurrentMonth && !dayInfo.isFuture {
      drawIntake(rect: rect)
    }
  }
  
  override func drawBackground(#rect: CGRect) {
    // Slightly reduce background circle size in order to prevent noticeable hard edges,
    // produced by multiplying semi-translucent edges of background circle and intake arcs.
    let adjustedRect = rect.rectByInsetting(dx: 0.2, dy: 0.2)
    super.drawBackground(rect: adjustedRect)
  }
  
  private func drawIntake(#rect: CGRect) {
    if value < 1 {
      drawCircleInRect(rect, strokeColor: monthStatisticsView.dayIntakeBackgroundColor)
      drawArcInRect(rect)
    } else {
      drawCircleInRect(rect, strokeColor: monthStatisticsView.dayIntakeFullColor)
    }
  }
  
  private func drawCircleInRect(rect: CGRect, strokeColor: UIColor) {
    let lineWidth = monthStatisticsView.dayIntakeLineWidth
    let circlePath = UIBezierPath(ovalInRect: rect.rectByInsetting(dx: lineWidth / 2, dy: lineWidth / 2))
    circlePath.lineWidth = lineWidth
    circlePath.lineCapStyle = kCGLineCapRound
    strokeColor.setStroke()
    circlePath.stroke()
  }
  
  private func drawArcInRect(rect: CGRect) {
    let lineWidth: CGFloat = monthStatisticsView.dayIntakeLineWidth
    let centerPoint = CGPoint(x: rect.midX, y: rect.midY)
    let startAngle = CGFloat(-M_PI_2)
    let endAngle = CGFloat(-M_PI_2 + M_PI * 2 * value)
    let radius = rect.width / 2 - lineWidth / 2
    
    let arcPath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
    arcPath.lineWidth = lineWidth
    arcPath.lineCapStyle = kCGLineCapRound
    monthStatisticsView.dayIntakeColor.setStroke()
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
