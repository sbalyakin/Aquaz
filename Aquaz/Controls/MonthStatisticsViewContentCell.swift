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
      
      if let value = value {
        circleLayer = CAShapeLayer()
        circleLayer.lineWidth = monthStatisticsContentView.dayIntakeLineWidth
        circleLayer.lineCap = kCALineCapRound
        circleLayer.fillColor = nil
        circleLayer.strokeColor = value < 1 ? monthStatisticsContentView.dayIntakeBackgroundColor.CGColor : monthStatisticsContentView.dayIntakeFullColor.CGColor
        contentView.layer.addSublayer(circleLayer)
        
        if value < 1 {
          arcLayer = CAShapeLayer()
          arcLayer.lineWidth = monthStatisticsContentView.dayIntakeLineWidth
          arcLayer.lineCap = kCALineCapRound
          arcLayer.fillColor = nil
          arcLayer.strokeColor = monthStatisticsContentView.dayIntakeColor.CGColor
          contentView.layer.addSublayer(arcLayer)
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
      let endAngle = CGFloat(-M_PI_2 + M_PI * 2 * Double(value ?? 0))
      let radius = rect.width / 2 - arcLayer.lineWidth / 2
      
      let arcPath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
      
      arcLayer.path = arcPath.CGPath
    }
  }

}