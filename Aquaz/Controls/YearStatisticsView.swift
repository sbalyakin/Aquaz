//
//  YearStatisticsView.swift
//  YearStatistics
//
//  Created by Sergey Balyakin on 21.11.14.
//  Copyright © 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

protocol YearStatisticsViewDataSource: class {
  
  func yearStatisticsViewGetTitleForHorizontalValue(_ value: CGFloat) -> String
  func yearStatisticsViewGetTitleForVerticalValue(_ value: CGFloat) -> String

}

@IBDesignable class YearStatisticsView: UIView {

  @IBInspectable var backgroundDarkColor: UIColor = UIColor(white: 235/255, alpha: 1.0)
  @IBInspectable var valuesChartLineColor: UIColor = UIColor(red: 80/255, green: 184/255, blue: 187/255, alpha: 1.0)
  @IBInspectable var valuesChartFillColor: UIColor = UIColor(red: 80/255, green: 184/255, blue: 187/255, alpha: 0.1)
  @IBInspectable var valuesChartLineWidth: CGFloat = 3
  @IBInspectable var goalsChartColor: UIColor = UIColor(red: 239/255, green: 64/255, blue: 79/255, alpha: 0.5)
  @IBInspectable var scaleTextColor: UIColor = UIColor(red: 147/255, green: 149/255, blue: 152/255, alpha: 1.0)
  @IBInspectable var gridColor: UIColor = UIColor(red: 230/255, green: 231/255, blue: 232/255, alpha: 1.0)
  @IBInspectable var pinsColor: UIColor = UIColor.white
  @IBInspectable var pinDiameter: CGFloat = 9
  @IBInspectable var chartFillEnabled: Bool = true
  @IBInspectable var verticalMaximumAdjustingEnabled: Bool = true
  @IBInspectable var horizontalScaleMargin: CGFloat = 4
  @IBInspectable var verticalScaleMargin: CGFloat = 6
  @IBInspectable var horizontalMargin: CGFloat = 10
  @IBInspectable var titleFont: UIFont = UIFont.systemFont(ofSize: 12) {
    didSet {
      verticalMaximumLabel.font = titleFont
      horizontalMinimumLabel.font = titleFont
      horizontalMaximumLabel.font = titleFont
      setNeedsLayout()
    }
  }
  
  override var backgroundColor: UIColor? {
    didSet {
      if let backgroundColor = backgroundColor , !backgroundColor.isClearColor() {
        verticalMaximumLabel.backgroundColor = backgroundColor.withAlphaComponent(0.7)
      }
    }
  }
  
  var animationDuration = 0.4
  
  let monthsPerYear = DateHelper.monthsPerYear()
  
  let pinShadowOffsetByX: CGFloat = 0
  let pinShadowOffsetByY: CGFloat = 1
  let pinShadowBlurRadius: CGFloat = 1

  let horizontalGridStep = 2
  var verticalGridStep = 2
  
  typealias ItemType = (value: CGFloat, goal: CGFloat)
  fileprivate typealias UIAreas = (chart: CGRect, verticalScale: CGRect, horizontalScale: CGRect, background: CGRect)

  weak var dataSource: YearStatisticsViewDataSource?
  
  fileprivate var isFirstSettingItems = true

  override init(frame: CGRect) {
    super.init(frame: frame)
    baseInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    baseInit()
  }
  
  fileprivate func baseInit() {
    createLayers()
    createLabels()
  }
  
  fileprivate func createLabels() {
    verticalMaximumLabel?.removeFromSuperview()
    horizontalMinimumLabel?.removeFromSuperview()
    horizontalMaximumLabel?.removeFromSuperview()
    
    verticalMaximumLabel = UILabel()
    verticalMaximumLabel.font = titleFont
    verticalMaximumLabel.textColor = scaleTextColor
    if let backgroundColor = backgroundColor , !backgroundColor.isClearColor() {
      verticalMaximumLabel.backgroundColor = backgroundColor.withAlphaComponent(0.7)
    }
    addSubview(verticalMaximumLabel)
    
    horizontalMinimumLabel = UILabel()
    horizontalMinimumLabel.font = titleFont
    horizontalMinimumLabel.textColor = scaleTextColor
    addSubview(horizontalMinimumLabel)
    
    horizontalMaximumLabel = UILabel()
    horizontalMaximumLabel.font = titleFont
    horizontalMaximumLabel.textColor = scaleTextColor
    addSubview(horizontalMaximumLabel)
    
    updateLabels(initial: true)
  }
  
  fileprivate func updateLabels(initial: Bool) {
    let verticalMaximumTitle = getVerticalTitleForValue(verticalMaximum)
    if initial {
      verticalMaximumLabel.text = verticalMaximumTitle
    } else {
      verticalMaximumLabel.setTextWithAnimation(verticalMaximumTitle)
    }
    
    let horizontalMinimumTitle = getHorizontalTitleForValue(0)
    if initial {
      horizontalMinimumLabel.text = horizontalMinimumTitle
    } else {
      horizontalMinimumLabel.setTextWithAnimation(horizontalMinimumTitle)
    }

    let lastItem = items.count > 0 ? items.count - 1 : 0
    let horizontalMaximumTitle = getHorizontalTitleForValue(CGFloat(lastItem))
    if initial {
      horizontalMaximumLabel.text = horizontalMaximumTitle
    } else {
      horizontalMaximumLabel.setTextWithAnimation(horizontalMaximumTitle)
    }
  }
  
  fileprivate func createLayers() {
    createValuesLineLayer()
    createValuesFillLayer()
    createGoalsShapeLayer()
    createPinsLayer()
    createGridLayer()
  }

  fileprivate func createValuesLineLayer() {
    valuesLineLayer?.removeFromSuperlayer()
    
    valuesLineLayer = CAShapeLayer()
    valuesLineLayer.frame = uiAreas.chart
    valuesLineLayer.bounds = uiAreas.chart
    valuesLineLayer.strokeColor = valuesChartLineColor.cgColor
    valuesLineLayer.fillColor = nil
    valuesLineLayer.lineWidth = valuesChartLineWidth
    valuesLineLayer.lineJoin = kCALineJoinRound
    layer.addSublayer(valuesLineLayer)
  }
  
  fileprivate func createValuesFillLayer() {
    valuesFillLayer?.removeFromSuperlayer()

    valuesFillLayer = CAShapeLayer()
    valuesFillLayer.frame = uiAreas.chart
    valuesFillLayer.bounds = uiAreas.chart
    valuesFillLayer.strokeColor = nil
    valuesFillLayer.fillColor = valuesChartFillColor.cgColor
    valuesFillLayer.lineWidth = 0
    valuesFillLayer.lineJoin = kCALineJoinRound
    layer.addSublayer(valuesFillLayer)
  }
  
  fileprivate func createGoalsShapeLayer() {
    goalsLayer?.removeFromSuperlayer()

    goalsLayer = CAShapeLayer()
    goalsLayer.frame = uiAreas.chart
    goalsLayer.bounds = uiAreas.chart
    goalsLayer.strokeColor = goalsChartColor.cgColor
    goalsLayer.fillColor = nil
    goalsLayer.lineWidth = 1
    goalsLayer.lineJoin = kCALineJoinRound
    goalsLayer.lineDashPattern = [3, 3]
    layer.addSublayer(goalsLayer)
  }
  
  fileprivate func createPinsLayer() {
    pinsLayer?.removeFromSuperlayer()
    
    // Create main layer with shadow
    pinsLayer = CALayer()
    pinsLayer.shadowOffset = CGSize(width: pinShadowOffsetByX, height: pinShadowOffsetByY)
    pinsLayer.shadowRadius = pinShadowBlurRadius
    pinsLayer.shadowColor = UIColor.black.cgColor
    pinsLayer.shadowOpacity = 0.2
    pinsLayer.frame = uiAreas.chart
    pinsLayer.bounds = uiAreas.chart
    layer.addSublayer(pinsLayer)
    
    // Create shape layer for each pin
    for _ in 0..<items.count {
      let pinLayer = CAShapeLayer()
      pinLayer.strokeColor = nil
      pinLayer.fillColor = pinsColor.cgColor
      pinsLayer.addSublayer(pinLayer)
    }
  }
  
  fileprivate func createGridLayer() {
    gridLayer?.removeFromSuperlayer()

    gridLayer = CAShapeLayer()
    gridLayer.frame = uiAreas.background
    gridLayer.bounds = uiAreas.background
    gridLayer.strokeColor = gridColor.cgColor
    gridLayer.lineWidth = 1
    gridLayer.lineCap = kCALineCapButt
    layer.addSublayer(gridLayer)
  }
  
  @available(iOS 8.0, *)
  override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()

    var items: [YearStatisticsView.ItemType] = []
    
    for i in 0..<monthsPerYear {
      let value = 1500 + cos(CGFloat(i + 4) / 2) * 700
      items.append((value: CGFloat(value), goal: 2000))
    }
    
    setItems(items)
  }
  
  func setItems(_ items: [ItemType]) {
    let needToRecreatePins = items.count != self.items.count
    
    self.items = items

    verticalMaximum = computeVerticalMaximum()
    
    if needToRecreatePins {
      createPinsLayer()
    }
    
    updateLabels(initial: isFirstSettingItems)
    setNeedsLayout()

    isFirstSettingItems = false
  }
  
  fileprivate func computeVerticalMaximum() -> CGFloat {
    if items.isEmpty {
      return 0
    }
    
    var maximum: CGFloat = 0
    
    for item in items {
      let itemMax = max(item.value, item.goal)
      maximum = max(maximum, itemMax)
    }
    
    if verticalMaximumAdjustingEnabled {
      maximum = adjustValue(maximum)
    }
    
    return maximum
  }
  
  fileprivate func adjustValue(_ value: CGFloat) -> CGFloat {
    if value > 1000 {
      return ceil(value / 100) * 100
    } else if value > 100 {
      return ceil(value / 10) * 10
    } else {
      return ceil(value)
    }
  }
  
  fileprivate func getHorizontalTitleForValue(_ value: CGFloat) -> String {
    return dataSource?.yearStatisticsViewGetTitleForHorizontalValue(value) ?? "\(Int(value))"
  }
  
  fileprivate func getVerticalTitleForValue(_ value: CGFloat) -> String {
    return dataSource?.yearStatisticsViewGetTitleForVerticalValue(value) ?? "\(Int(value))"
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    uiAreas = computeAreasFromRect(bounds)
    layoutLabels()
    layoutLayers()
  }
  
  fileprivate func computeAreasFromRect(_ rect: CGRect) -> UIAreas {
    horizontalMinimumLabel.sizeToFit()
    horizontalMaximumLabel.sizeToFit()

    let bottomRectangleHeight = max(horizontalMinimumLabel.frame.height, horizontalMaximumLabel.frame.height) + horizontalScaleMargin
    let verticalRectangles = rect.divided(atDistance: bottomRectangleHeight, from: .maxYEdge)
    var result: UIAreas
    result.chart = verticalRectangles.remainder.insetBy(dx: horizontalMargin + pinDiameter / 2, dy: pinDiameter / 2).integral
    result.verticalScale = result.chart
    result.horizontalScale = verticalRectangles.slice.insetBy(dx: horizontalMargin, dy: 0).integral
    result.background = verticalRectangles.remainder.integral
    return result
  }

  fileprivate func layoutLabels() {
    verticalMaximumLabel.sizeToFit()
    horizontalMinimumLabel.sizeToFit()
    horizontalMaximumLabel.sizeToFit()

    verticalMaximumLabel.frame.origin = CGPoint(x: uiAreas.verticalScale.minX, y: uiAreas.verticalScale.minY + verticalScaleMargin)
    
    horizontalMinimumLabel.frame.origin = CGPoint(x: uiAreas.horizontalScale.minX, y: uiAreas.horizontalScale.maxY - horizontalMinimumLabel.frame.height)

    horizontalMaximumLabel.frame.origin = CGPoint(x: uiAreas.horizontalScale.maxX - horizontalMaximumLabel.frame.width, y: uiAreas.horizontalScale.maxY - horizontalMaximumLabel.frame.height)
  }
  
  fileprivate func layoutLayers() {
    layoutItemsLayers()
    layoutGridLayer()
  }
  
  fileprivate func layoutItemsLayers() {
    if isFirstSettingItems {
      let zeroRect = CGRect(x: uiAreas.chart.minX, y: uiAreas.chart.maxY, width: uiAreas.chart.width, height: 0)
      let zeroPaths = computePathsForRect(zeroRect)
      layoutValuesLine(zeroPaths.valuesStroke, useAnimation: false)
      layoutValuesFill(zeroPaths.valuesFill, useAnimation: false)
      layoutGoalsLine(zeroPaths.goals, useAnimation: false)
      layoutPins(zeroPaths.pinsPoints, useAnimation: false)
    }
    
    let paths = computePathsForRect(uiAreas.chart)
    layoutValuesLine(paths.valuesStroke, useAnimation: true)
    layoutValuesFill(paths.valuesFill, useAnimation: true)
    layoutGoalsLine(paths.goals, useAnimation: true)
    layoutPins(paths.pinsPoints, useAnimation: true)
  }
  
  fileprivate func computePathsForRect(_ rect: CGRect) -> (valuesStroke: CGPath, valuesFill: CGPath, goals: CGPath, pinsPoints: [CGPoint]) {
    if items.isEmpty {
      return (valuesStroke: UIBezierPath().cgPath, valuesFill: UIBezierPath().cgPath, goals: UIBezierPath().cgPath, pinsPoints: [])
    }
    
    let maxIndex = CGFloat(items.count) - 1
    
    // Fill goals path
    let halfSectionWidth = round(rect.width / maxIndex / 2)
    let goalsPath = UIBezierPath()
    var previousGoal: CGPoint = CGPoint.zero

    for (index, item) in items.enumerated() {
      let x = rect.minX + CGFloat(index) / maxIndex * rect.width
      let y = verticalMaximum > 0 ? rect.maxY - item.goal / verticalMaximum * rect.height : 0
      let point = CGPoint(x: round(x), y: round(y))

      if index == 0 {
        goalsPath.move(to: point)
        goalsPath.addLine(to: CGPoint(x: point.x + halfSectionWidth, y: point.y))
      } else {
        goalsPath.addLine(to: CGPoint(x: previousGoal.x + halfSectionWidth, y: point.y))
        let nextGoalX = min(point.x + halfSectionWidth, rect.maxX)
        goalsPath.addLine(to: CGPoint(x: nextGoalX, y: point.y))
      }
      
      previousGoal = point
    }

    // Fill values paths and compute values coordinates
    let valuesStrokePath = UIBezierPath()
    let valuesFillPath = UIBezierPath()
    var valuesPoints: [CGPoint] = []
    
    for (index, item) in items.enumerated() {
      let x = rect.minX + CGFloat(index) / maxIndex * rect.width
      let y = verticalMaximum > 0 ? rect.maxY - item.value / verticalMaximum * rect.height : 0
      let point = CGPoint(x: round(x), y: round(y))
      valuesPoints.append(point)
      if index == 0 {
        valuesStrokePath.move(to: point)
        valuesFillPath.move(to: point)
      } else {
        valuesStrokePath.addLine(to: point)
        valuesFillPath.addLine(to: point)
      }
    }

    // Close fill path
    valuesFillPath.addLine(to: CGPoint(x: valuesPoints.last!.x, y: rect.maxY))
    valuesFillPath.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
    valuesFillPath.addLine(to: CGPoint(x: rect.minX, y: valuesPoints.first!.y))
    
    return (valuesStroke: valuesStrokePath.cgPath, valuesFill: valuesFillPath.cgPath, goals: goalsPath.cgPath, pinsPoints: valuesPoints)
  }
  
  fileprivate func layoutValuesLine(_ path: CGPath, useAnimation: Bool) {
    transformShape(valuesLineLayer, path: path, useAnimation: useAnimation)
  }
  
  fileprivate func layoutValuesFill(_ path: CGPath, useAnimation: Bool) {
    if chartFillEnabled {
      transformShape(valuesFillLayer, path: path, useAnimation: useAnimation)
    }
  }

  fileprivate func layoutGoalsLine(_ path: CGPath, useAnimation: Bool) {
    transformShape(goalsLayer, path: path, useAnimation: useAnimation)
  }
  
  fileprivate func layoutPins(_ coords: [CGPoint], useAnimation: Bool) {
    for (index, coord) in coords.enumerated() {
      if pinsLayer.sublayers == nil || index >= pinsLayer.sublayers!.count {
        break
      }
      
      let pinLayer = pinsLayer.sublayers![index] as! CAShapeLayer
      
      let rect = CGRect(x: coord.x - pinDiameter / 2, y: coord.y - pinDiameter / 2, width: pinDiameter, height: pinDiameter)
      let path = UIBezierPath(ovalIn: rect).cgPath
      transformShape(pinLayer, path: path, useAnimation: useAnimation)
    }
  }
  
  fileprivate func transformShape(_ shape: CAShapeLayer, path: CGPath, useAnimation: Bool) {
    if useAnimation {
      CATransaction.begin()
      
      let startPath: CGPath
      
      if let presentation = shape.presentation() {
        startPath = presentation.path ?? path
      } else {
        startPath = shape.path ?? path
      }

      let animation = CABasicAnimation(keyPath: "path")
      animation.duration = animationDuration
      animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
      animation.fromValue = startPath
      shape.path = path
      animation.toValue = shape.path
      shape.add(animation, forKey: "path")
      
      CATransaction.commit()
    } else {
      shape.path = path
    }
  }

  fileprivate func transformShapeFrame(_ shape: CAShapeLayer, frame: CGRect, useAnimation: Bool) {
    if useAnimation {
      CATransaction.begin()
      
      let startRect: CGRect
      
      if let presentation = shape.presentation() {
        startRect = presentation.frame
      } else {
        startRect = shape.frame
      }
      
      let animation = CABasicAnimation(keyPath: "position")
      animation.duration = animationDuration
      animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
      animation.fromValue = NSValue(cgPoint: startRect.origin)
      shape.position = frame.origin
      animation.fromValue = NSValue(cgPoint: frame.origin)
      shape.add(animation, forKey: "position")
      
      CATransaction.commit()
    } else {
      shape.position = frame.origin
    }
  }

  fileprivate func layoutGridLayer() {
    let rect = uiAreas.chart
    let maxIndex = CGFloat(items.count) - 1
    
    let gridPath = UIBezierPath()
    
    for i in 0..<items.count {
      let x = round(rect.minX + CGFloat(i) / maxIndex * rect.width)
      gridPath.move(to: CGPoint(x: x, y: rect.minY))
      gridPath.addLine(to: CGPoint(x: x, y: rect.maxY))
    }
    
    gridLayer.path = gridPath.cgPath
  }

  fileprivate var items: [ItemType] = []
  
  fileprivate var verticalMaximumLabel: UILabel!
  fileprivate var horizontalMinimumLabel: UILabel!
  fileprivate var horizontalMaximumLabel: UILabel!
  fileprivate var valuesLineLayer: CAShapeLayer!
  fileprivate var valuesFillLayer: CAShapeLayer!
  fileprivate var goalsLayer: CAShapeLayer!
  fileprivate var gridLayer: CAShapeLayer!
  fileprivate var pinsLayer: CALayer!

  fileprivate var uiAreas: UIAreas = (chart: CGRect.zero, verticalScale: CGRect.zero, horizontalScale: CGRect.zero, background: CGRect.zero)
  
  fileprivate var verticalMaximum: CGFloat = 0
  
}
