//
//  MonthStatisticsContentViewCell.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 17.03.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import Foundation
import UIKit

class MonthStatisticsContentViewCell: CalendarContentViewCell {

  var value: Double? {
    return getDayInfo().userData as? Double
  }
  
  fileprivate var circleLayer: CAShapeLayer!
  fileprivate var arcLayer: CAShapeLayer!
  
  override func setDayInfo(_ dayInfo: CalendarViewDayInfo, calendarContentView: CalendarContentView) {
    super.setDayInfo(dayInfo, calendarContentView: calendarContentView)

    if let monthStatisticsContentView = calendarContentView as? MonthStatisticsContentView {
      circleLayer?.removeFromSuperlayer()
      circleLayer = nil
      arcLayer?.removeFromSuperlayer()
      arcLayer = nil
      
      if getDayInfo().isCurrentMonth && !getDayInfo().isFuture {
        circleLayer = CAShapeLayer()
        circleLayer.lineWidth = monthStatisticsContentView.dayIntakeLineWidth
        circleLayer.lineCap = CAShapeLayerLineCap.round
        circleLayer.fillColor = nil
        circleLayer.strokeColor = monthStatisticsContentView.dayIntakeBackgroundColor.cgColor
        contentView.layer.addSublayer(circleLayer)

        if let value = value {
          arcLayer = CAShapeLayer()
          arcLayer.lineWidth = monthStatisticsContentView.dayIntakeLineWidth
          arcLayer.lineCap = CAShapeLayerLineCap.round
          arcLayer.fillColor = nil
          arcLayer.strokeStart = 0
          if value < 1 {
            arcLayer.strokeColor = monthStatisticsContentView.dayIntakeColor.cgColor
          } else {
            arcLayer.strokeColor = monthStatisticsContentView.dayIntakeFullColor.cgColor
          }

          contentView.layer.addSublayer(arcLayer)

          let centerOnScreenPoint = convert(bounds.origin, to: nil)
          let isVisible = UIScreen.main.bounds.contains(centerOnScreenPoint)
          
          if isVisible {
            arcLayer.strokeEnd = 0

            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.duration = 0.4
            animation.fromValue = 0
            animation.toValue = value
            animation.fillMode = CAMediaTimingFillMode.forwards
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            animation.isRemovedOnCompletion = false
            arcLayer.strokeEnd = CGFloat(value)
            arcLayer.add(animation, forKey: "animateStrokeEnd")
          } else {
            // If cell is invisible we skip animation
            arcLayer.strokeEnd = CGFloat(value)
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

  fileprivate func layoutCircleLayer(_ rect: CGRect) {
    if let circleLayer = circleLayer {
      let circlePath = UIBezierPath(ovalIn: rect.insetBy(dx: circleLayer.lineWidth / 2, dy: circleLayer.lineWidth / 2))
      
      circleLayer.path = circlePath.cgPath
    }
  }
  
  fileprivate func layoutArcLayer(_ rect: CGRect) {
    if let arcLayer = arcLayer {
      let centerPoint = CGPoint(x: rect.midX, y: rect.midY)
      let startAngle = -CGFloat.pi * 0.5
      let endAngle = CGFloat.pi * 1.5
      let radius = rect.width / 2 - arcLayer.lineWidth / 2
      
      let arcPath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
      
      arcLayer.path = arcPath.cgPath
    }
  }

}
