//
//  MonthStatisticsContentViewCell.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 17.03.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import Foundation
import UIKit

class MonthStatisticsContentViewCell: CalendarContentViewCell {

  var value: CGFloat? {
    return getDayInfo().userData as? CGFloat
  }
  
  private var circleLayer: CAShapeLayer!
  private var arcLayer: CAShapeLayer!
  
  override func setDayInfo(dayInfo: CalendarViewDayInfo, calendarContentView: CalendarContentView) {
    super.setDayInfo(dayInfo, calendarContentView: calendarContentView)

    if let monthStatisticsContentView = calendarContentView as? MonthStatisticsContentView {
      circleLayer?.removeFromSuperlayer()
      circleLayer = nil
      arcLayer?.removeFromSuperlayer()
      arcLayer = nil
      
      if getDayInfo().isCurrentMonth && !getDayInfo().isFuture {
        circleLayer = CAShapeLayer()
        circleLayer.lineWidth = monthStatisticsContentView.dayIntakeLineWidth
        circleLayer.lineCap = kCALineCapRound
        circleLayer.fillColor = nil
        circleLayer.strokeColor = monthStatisticsContentView.dayIntakeBackgroundColor.CGColor
        contentView.layer.addSublayer(circleLayer)

        if let value = value {
          arcLayer = CAShapeLayer()
          arcLayer.lineWidth = monthStatisticsContentView.dayIntakeLineWidth
          arcLayer.lineCap = kCALineCapRound
          arcLayer.fillColor = nil
          arcLayer.strokeStart = 0
          if value < 1 {
            arcLayer.strokeColor = monthStatisticsContentView.dayIntakeColor.CGColor
          } else {
            arcLayer.strokeColor = monthStatisticsContentView.dayIntakeFullColor.CGColor
          }

          contentView.layer.addSublayer(arcLayer)

          let centerOnScreenPoint = convertPoint(bounds.origin, toView: nil)
          let isVisible = UIScreen.mainScreen().bounds.contains(centerOnScreenPoint)
          
          if isVisible {
            arcLayer.strokeEnd = 0

            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.duration = 0.4
            animation.fromValue = 0
            animation.toValue = value
            animation.fillMode = kCAFillModeForwards
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            animation.removedOnCompletion = false
            arcLayer.strokeEnd = value
            arcLayer.addAnimation(animation, forKey: "animateStrokeEnd")
          } else {
            // If cell is invisible we skip animation
            arcLayer.strokeEnd = value
          }
        }
        
        setNeedsLayout()
      }
    } else {
      assert(false)
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    let radius = trunc(min(contentView.bounds.width, contentView.bounds.height) / 2) - 2
    let origin = CGPoint(x: contentView.bounds.midX - radius, y: contentView.bounds.midY - radius)
    let size = CGSize(width: radius * 2, height: radius * 2)
    let rect = CGRect(origin: origin, size: size)
    
    layoutCircleLayer(rect)
    layoutArcLayer(rect)
  }

  private func layoutCircleLayer(rect: CGRect) {
    if let circleLayer = circleLayer {
      let circlePath = UIBezierPath(ovalInRect: rect.rectByInsetting(dx: circleLayer.lineWidth / 2, dy: circleLayer.lineWidth / 2))
      
      circleLayer.path = circlePath.CGPath
    }
  }
  
  private func layoutArcLayer(rect: CGRect) {
    if let arcLayer = arcLayer {
      let centerPoint = CGPoint(x: rect.midX, y: rect.midY)
      let startAngle = CGFloat(-M_PI_2)
      let endAngle = CGFloat(M_PI * 2 - M_PI_2)
      let radius = rect.width / 2 - arcLayer.lineWidth / 2
      
      let arcPath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
      
      arcLayer.path = arcPath.CGPath
    }
  }

}