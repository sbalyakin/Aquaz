//
//  YearStatisticsView.swift
//  YearStatistics
//
//  Created by Sergey Balyakin on 21.11.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

@IBDesignable class YearStatisticsView: UIView {

  @IBInspectable var valuesChartLineColor: UIColor = UIColor(red: 80/255, green: 184/255, blue: 187/255, alpha: 1.0)
  @IBInspectable var valuesChartFillColor: UIColor = UIColor(red: 80/255, green: 184/255, blue: 187/255, alpha: 0.1)
  @IBInspectable var goalsChartColor: UIColor = UIColor(red: 239/255, green: 64/255, blue: 79/255, alpha: 0.5)
  @IBInspectable var scaleTitleColor: UIColor = UIColor(red: 147/255, green: 149/255, blue: 152/255, alpha: 1.0)
  @IBInspectable var gridColor: UIColor = UIColor(red: 230/255, green: 231/255, blue: 232/255, alpha: 1.0)
  @IBInspectable var pinsColor: UIColor = UIColor.whiteColor()
  @IBInspectable var pinDiameter: CGFloat = 6
  @IBInspectable var chartFillEnabled: Bool = true
  @IBInspectable var verticalMaximumAdjustingEnabled: Bool = true
  @IBInspectable var horizontalScaleMargin: CGFloat = 4
  @IBInspectable var verticalScaleMargin: CGFloat = 10
  
  var animationDuration = 0.4
  var scaleTitleFont: UIFont = UIFont.systemFontOfSize(12)

  let pinShadowOffsetByX: CGFloat = 0
  let pinShadowOffsetByY: CGFloat = 1
  let pinShadowBlurRadius: CGFloat = 1

  let horizontalGridStep = 2
  var verticalGridStep = 2
  
  typealias TitleForStepFunction = (CGFloat) -> String
  typealias ItemType = (value: CGFloat, goal: CGFloat)
  private typealias UIAreas = (chart: CGRect, verticalScale: CGRect, horizontalScale: CGRect)

  var titleForVerticalStep: TitleForStepFunction?
  var titleForHorizontalStep: TitleForStepFunction?
  
  override init() {
    super.init()
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  override func prepareForInterfaceBuilder() {
    initWithFakeValues()
  }
  
  override func layoutSubviews() {
    uiAreas = computeAreasFromRect(bounds)
  }

  func setItems(items: [ItemType]) {
    _verticalMaximum = nil
    _horizontalTitles = nil
    _verticalTitles = nil
    _horizontalTitlesSizes = nil
    _verticalTitlesSizes = nil
    _horizontalTitlesMaxHeight = nil
    _verticalTitlesMaxWidth = nil
    
    if items.count != self.items.count {
      _valuesStrokeShapeLayer = nil
      _valuesFillShapeLayer = nil
      _goalsShapeLayer = nil
      _pinsLayer = nil
      layer.sublayers = nil
    }
    
    self.items = items
    
    setNeedsDisplay()
  }
  
  private func initWithFakeValues() {
    var items: [YearStatisticsView.ItemType] = []
    
    for i in 0..<12 {
      let value = 1500 + cos(CGFloat(i + 4) / 2) * 700
      items.append((value: CGFloat(value), goal: 2000))
    }
    
    setItems(items)
  }
  
  private func computeAreasFromRect(rect: CGRect) -> UIAreas {
    // Year statistics control contains three areas: vertical scale, horizontal scale and chart.
    // Scheme of their placements:
    // +---+-------------------+
    // |   |                   |
    // | V |                   |
    // | e |                   |
    // | r |                   |
    // | t |                   |
    // | i |      Chart        |
    // | c |                   |
    // | a |                   |
    // | l |                   |
    // |   |                   |
    // +---+-------------------+
    // |   |    Horizontal     |
    // +---+-------------------+
    
    let leftRectangleWidth = round(verticalTitlesMaxWidth + verticalScaleMargin)
    let bottomRectangleHeight = horizontalTitlesMaxHeight + horizontalScaleMargin
    let lastVerticalTitleHeight = verticalTitlesSizes.last != nil ? verticalTitlesSizes.last!.height : 0
    
    var innerRect = CGRectMake(rect.minX, rect.minY + ceil(lastVerticalTitleHeight / 2), rect.width, rect.height - ceil(lastVerticalTitleHeight / 2))
    let dx = max(pinDiameter / 2 + pinShadowBlurRadius + pinShadowOffsetByX, 1)
    let dy = max(pinDiameter / 2 + pinShadowBlurRadius + pinShadowOffsetByY, 1)
    innerRect.inset(dx: dx, dy: dy)
    
    let horizontalRectangles = innerRect.rectsByDividing(leftRectangleWidth, fromEdge: .MinXEdge)
    let leftRectangle = horizontalRectangles.slice
    let rightRectangle = horizontalRectangles.remainder
    
    let leftVerticalRectangles = leftRectangle.rectsByDividing(bottomRectangleHeight, fromEdge: .MaxYEdge)
    let rightVerticalRectangles = rightRectangle.rectsByDividing(bottomRectangleHeight, fromEdge: .MaxYEdge)
    
    var result: UIAreas
    result.chart = rightVerticalRectangles.remainder
    result.verticalScale = leftVerticalRectangles.remainder
    result.horizontalScale = rightVerticalRectangles.slice
    return result
  }

  private func computeVerticalMaximum() {
    if items.isEmpty {
      _verticalMaximum = 0
      return
    }
    
    _verticalMaximum = 0
    
    for item in items {
      let itemMax = max(item.value, item.goal)
      _verticalMaximum = max(_verticalMaximum, itemMax)
    }

    if verticalMaximumAdjustingEnabled {
      _verticalMaximum = adjustValue(_verticalMaximum)
    }
  }
  
  private func adjustValue(value: CGFloat) -> CGFloat {
    if value > 1000 {
      return ceil(value / 100) * 100
    } else if value > 100 {
      return ceil(value / 10) * 10
    } else {
      return ceil(value)
    }
  }
  
  private func fillVerticalTitles() {
    let verticalGap = verticalMaximum / CGFloat(verticalGridStep - 1)
    _verticalTitles = []
    for i in 0..<verticalGridStep {
      let value = CGFloat(i) * verticalGap
      var title: String
      if let titleFunc = titleForVerticalStep {
        title = titleFunc(value)
      } else {
        title = "\(Int(value))"
      }
      _verticalTitles.append(title)
    }
  }
  
  private func fillHorizontalTitles() {
    let horizontalGap = (CGFloat(items.count) - 1) / CGFloat(horizontalGridStep - 1)
    _horizontalTitles = []
    for i in 0..<horizontalGridStep {
      let value = CGFloat(i) * horizontalGap
      var title: String
      if let titleFunc = titleForHorizontalStep {
        title = titleFunc(value)
      } else {
        title = "\(Int(value))"
      }
      _horizontalTitles.append(title)
    }
  }

  private func computeTitlesSizes() {
    computeVerticalTitlesSizes()
    computeHorizontalTitlesSizes()
  }
  
  private func computeHorizontalTitlesSizes() {
    _horizontalTitlesMaxHeight = 0
    _horizontalTitlesSizes = []
    
    for title in horizontalTitles {
      let size = computeSizeForText(title, font: scaleTitleFont)
      _horizontalTitlesSizes.append(size)
      if size.height > _horizontalTitlesMaxHeight {
        _horizontalTitlesMaxHeight = size.height
      }
    }
  }
  
  private func computeVerticalTitlesSizes() {
    _verticalTitlesMaxWidth = 0
    _verticalTitlesSizes = []
    
    for title in verticalTitles {
      let size = computeSizeForText(title, font: scaleTitleFont)
      _verticalTitlesSizes.append(size)
      if size.width > _verticalTitlesMaxWidth {
        _verticalTitlesMaxWidth = size.width
      }
    }
  }
  
  private func computeSizeForText(text: String, font: UIFont) -> CGSize {
    let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as NSMutableParagraphStyle
    let fontAttributes = [NSFontAttributeName: font, NSParagraphStyleAttributeName: textStyle]
    let size = text.boundingRectWithSize(CGSizeMake(CGFloat.infinity, CGFloat.infinity), options: .UsesLineFragmentOrigin, attributes: fontAttributes, context: nil).size
    return CGSizeMake(round(size.width), round(size.height))
  }
  
  override func drawRect(rect: CGRect) {
    drawVerticalScale()
    drawHorizontalScale()
    drawChart()
  }
  
  private func drawVerticalScale() {
    if verticalTitles.isEmpty || verticalTitlesSizes.isEmpty || verticalTitles.count != verticalTitlesSizes.count {
      return
    }
    
    let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as NSMutableParagraphStyle
    textStyle.alignment = NSTextAlignment.Right
    
    let fontAttributes = [NSFontAttributeName: scaleTitleFont, NSForegroundColorAttributeName: scaleTitleColor, NSParagraphStyleAttributeName: textStyle]
    
    let rect = uiAreas.verticalScale
    let segmentHeight = rect.height / CGFloat(verticalGridStep - 1)
    
    for (index, title) in enumerate(verticalTitles) {
      let textHeight = verticalTitlesSizes[index].height
      let midY = rect.maxY - CGFloat(index) * segmentHeight
      let minY = midY - textHeight / 2
      let labelRect = CGRectMake(rect.minX, minY, rect.width - verticalScaleMargin, textHeight).integerRect
      title.drawInRect(labelRect, withAttributes: fontAttributes)
    }
  }

  private func drawHorizontalScale() {
    if horizontalTitles.isEmpty || horizontalTitlesSizes.isEmpty || horizontalTitles.count != horizontalTitlesSizes.count {
      return
    }
    
    let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as NSMutableParagraphStyle
    let fontAttributes = [NSFontAttributeName: scaleTitleFont, NSForegroundColorAttributeName: scaleTitleColor, NSParagraphStyleAttributeName: textStyle]
    let rect = uiAreas.horizontalScale.rectByOffsetting(dx: 0, dy: horizontalScaleMargin)
    
    // First title
    let firstTitle = horizontalTitles.first!
    textStyle.alignment = .Left
    firstTitle.drawInRect(rect, withAttributes: fontAttributes)
    
    // Last title
    let lastTitle = horizontalTitles.last!
    textStyle.alignment = .Right
    lastTitle.drawInRect(rect, withAttributes: fontAttributes)
  }
  
  private func drawChart() {
    drawGrid()
    drawItems()
  }
  
  private func isFirstDraw() -> Bool {
    return _valuesStrokeShapeLayer == nil
  }
  
  private func drawItems() {
    if isFirstDraw() {
      let zeroRect = CGRectMake(uiAreas.chart.minX, uiAreas.chart.maxY, uiAreas.chart.width, 0)
      let zeroPaths = computePathsForRect(zeroRect)
      drawValuesLine(zeroPaths.valuesStroke, useAnimation: false)
      drawValuesFill(zeroPaths.valuesFill, useAnimation: false)
      drawGoalsLine(zeroPaths.goals, useAnimation: false)
      drawPins(zeroPaths.pinsPoints, useAnimation: false)
    }
    
    let paths = computePathsForRect(uiAreas.chart)
    drawValuesLine(paths.valuesStroke, useAnimation: true)
    drawValuesFill(paths.valuesFill, useAnimation: true)
    drawGoalsLine(paths.goals, useAnimation: true)
    drawPins(paths.pinsPoints, useAnimation: true)
  }
  
  private func computePathsForRect(rect: CGRect) -> (valuesStroke: CGPath, valuesFill: CGPath, goals: CGPath, pinsPoints: [CGPoint]) {
    if items.isEmpty {
      return (valuesStroke: UIBezierPath().CGPath, valuesFill: UIBezierPath().CGPath, goals: UIBezierPath().CGPath, pinsPoints: [])
    }
    
    let maxIndex = CGFloat(items.count) - 1
    
    // Fill goals path
    let halfSectionWidth = round(rect.width / maxIndex / 2)
    let goalsPath = UIBezierPath()
    var previousGoal: CGPoint = CGPointZero

    for (index, item) in enumerate(items) {
      let x = rect.minX + CGFloat(index) / maxIndex * rect.width
      let y = rect.maxY - item.goal / verticalMaximum * rect.height
      let point = CGPointMake(round(x), round(y))

      if index == 0 {
        goalsPath.moveToPoint(point)
        goalsPath.addLineToPoint(CGPointMake(point.x + halfSectionWidth, point.y))
      } else {
        goalsPath.addLineToPoint(CGPointMake(previousGoal.x + halfSectionWidth, point.y))
        let nextGoalX = min(point.x + halfSectionWidth, rect.maxX)
        goalsPath.addLineToPoint(CGPointMake(nextGoalX, point.y))
      }
      
      previousGoal = point
    }

    // Fill values paths and compute values coordinates
    let valuesStrokePath = UIBezierPath()
    let valuesFillPath = UIBezierPath()
    var valuesPoints: [CGPoint] = []
    
    for (index, item) in enumerate(items) {
      let x = rect.minX + CGFloat(index) / maxIndex * rect.width
      let y = rect.maxY - item.value / verticalMaximum * rect.height
      let point = CGPointMake(round(x), round(y))
      valuesPoints.append(point)
      if index == 0 {
        valuesStrokePath.moveToPoint(point)
        valuesFillPath.moveToPoint(point)
      } else {
        valuesStrokePath.addLineToPoint(point)
        valuesFillPath.addLineToPoint(point)
      }
    }

    // Close fill path
    valuesFillPath.addLineToPoint(CGPointMake(valuesPoints.last!.x, rect.maxY))
    valuesFillPath.addLineToPoint(CGPointMake(rect.minX, rect.maxY))
    valuesFillPath.addLineToPoint(CGPointMake(rect.minX, valuesPoints.first!.y))
    
    return (valuesStroke: valuesStrokePath.CGPath, valuesFill: valuesFillPath.CGPath, goals: goalsPath.CGPath, pinsPoints: valuesPoints)
  }
  
  private func drawValuesLine(path: CGPath, useAnimation: Bool) {
    transformShape(valuesStrokeShapeLayer, path: path, useAnimation: useAnimation)
  }
  
  private func drawValuesFill(path: CGPath, useAnimation: Bool) {
    if chartFillEnabled {
      transformShape(valuesFillShapeLayer, path: path, useAnimation: useAnimation)
    }
  }

  private func drawGoalsLine(path: CGPath, useAnimation: Bool) {
    transformShape(goalsShapeLayer, path: path, useAnimation: useAnimation)
  }
  
  private func drawPins(coords: [CGPoint], useAnimation: Bool) {
    for (index, coord) in enumerate(coords) {
      if pinsLayer.sublayers == nil || index >= pinsLayer.sublayers.count {
        break
      }
      
      let pinLayer = pinsLayer.sublayers[index] as CAShapeLayer
      let rect = CGRectMake(coord.x - pinDiameter / 2, coord.y - pinDiameter / 2, pinDiameter, pinDiameter)
      var path = UIBezierPath(ovalInRect: rect).CGPath
      transformShape(pinLayer, path: path, useAnimation: useAnimation)
    }
  }
  
  private func transformShape(shape: CAShapeLayer, path: CGPath, useAnimation: Bool) {
    if useAnimation {
      let animation = CABasicAnimation(keyPath: "path")
      animation.duration = animationDuration
      animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
      animation.fromValue = shape.path
      shape.path = path
      animation.toValue = shape.path
      shape.addAnimation(animation, forKey: nil)
    } else {
      shape.path = path
    }
  }

  private func drawGrid() {
    let rect = uiAreas.chart
    let maxIndex = CGFloat(items.count) - 1
    let bezier = UIBezierPath()
    gridColor.setStroke()
    
    for i in 0..<items.count {
      let x = round(rect.minX + CGFloat(i) / maxIndex * rect.width)
      let pointFrom = CGPointMake(x, rect.minY)
      let pointTo = CGPointMake(x, rect.maxY)
      bezier.moveToPoint(pointFrom)
      bezier.addLineToPoint(pointTo)
      bezier.stroke()
    }
  }

  private func createValuesStrokeShapeLayer() {
    _valuesStrokeShapeLayer = CAShapeLayer(layer: layer)
    _valuesStrokeShapeLayer.frame = uiAreas.chart
    _valuesStrokeShapeLayer.bounds = uiAreas.chart
    _valuesStrokeShapeLayer.strokeColor = valuesChartLineColor.CGColor
    _valuesStrokeShapeLayer.fillColor = nil
    _valuesStrokeShapeLayer.lineWidth = 2
    _valuesStrokeShapeLayer.lineJoin = kCALineJoinRound
    layer.addSublayer(_valuesStrokeShapeLayer)
  }
  
  private func createValuesFillShapeLayer() {
    _valuesFillShapeLayer = CAShapeLayer(layer: layer)
    _valuesFillShapeLayer.frame = uiAreas.chart
    _valuesFillShapeLayer.bounds = uiAreas.chart
    _valuesFillShapeLayer.strokeColor = nil
    _valuesFillShapeLayer.fillColor = valuesChartFillColor.CGColor
    _valuesFillShapeLayer.lineWidth = 0
    _valuesFillShapeLayer.lineJoin = kCALineJoinRound
    layer.addSublayer(_valuesFillShapeLayer)
  }
  
  private func createGoalsShapeLayer() {
    _goalsShapeLayer = CAShapeLayer(layer: layer)
    _goalsShapeLayer.frame = uiAreas.chart
    _goalsShapeLayer.bounds = uiAreas.chart
    _goalsShapeLayer.strokeColor = goalsChartColor.CGColor
    _goalsShapeLayer.fillColor = nil
    _goalsShapeLayer.lineWidth = 1
    _goalsShapeLayer.lineJoin = kCALineJoinRound
    _goalsShapeLayer.lineDashPattern = [3, 3]
    layer.addSublayer(_goalsShapeLayer)
  }
  
  private func createPinsLayer() {
    // Create main layer with shadow
    _pinsLayer = CALayer(layer: layer)
    _pinsLayer.shadowOffset = CGSizeMake(pinShadowOffsetByX, pinShadowOffsetByY)
    _pinsLayer.shadowRadius = pinShadowBlurRadius
    _pinsLayer.shadowColor = UIColor.blackColor().CGColor
    _pinsLayer.shadowOpacity = 0.2
    _pinsLayer.frame = uiAreas.chart
    _pinsLayer.bounds = uiAreas.chart
    layer.addSublayer(_pinsLayer)
    
    // Create shape layer for each pin
    for i in 0..<items.count {
      let pinLayer = CAShapeLayer(layer: _pinsLayer)
      pinLayer.strokeColor = nil
      pinLayer.fillColor = UIColor.whiteColor().CGColor
      _pinsLayer.addSublayer(pinLayer)
    }
  }

  private var items: [ItemType] = []
  
  private var _valuesStrokeShapeLayer: CAShapeLayer!
  private var valuesStrokeShapeLayer: CAShapeLayer {
    if _valuesStrokeShapeLayer == nil {
      createValuesStrokeShapeLayer()
    }
    return _valuesStrokeShapeLayer
  }
  
  private var _valuesFillShapeLayer: CAShapeLayer!
  private var valuesFillShapeLayer: CAShapeLayer {
    if _valuesFillShapeLayer == nil {
      createValuesFillShapeLayer()
    }
    return _valuesFillShapeLayer
  }
  
  private var _goalsShapeLayer: CAShapeLayer!
  private var goalsShapeLayer: CAShapeLayer {
    if _goalsShapeLayer == nil {
      createGoalsShapeLayer()
    }
    return _goalsShapeLayer
  }
  
  private var _pinsLayer: CALayer!
  private var pinsLayer: CALayer {
    if _pinsLayer == nil {
      createPinsLayer()
    }
    return _pinsLayer
  }
  
  private var uiAreas: UIAreas = (chart: CGRectZero, verticalScale: CGRectZero, horizontalScale: CGRectZero)
  
  private var _verticalMaximum: CGFloat!
  private var verticalMaximum: CGFloat {
    if _verticalMaximum == nil {
      computeVerticalMaximum()
    }
    return _verticalMaximum
  }
  
  private var _horizontalTitles: [String]!
  private var horizontalTitles: [String] {
    if _horizontalTitles == nil {
      fillHorizontalTitles()
    }
    return _horizontalTitles
  }
  
  private var _verticalTitles: [String]!
  private var verticalTitles: [String] {
    if _verticalTitles == nil {
      fillVerticalTitles()
    }
    return _verticalTitles
  }
  
  private var _horizontalTitlesSizes: [CGSize]!
  private var horizontalTitlesSizes: [CGSize] {
    if _horizontalTitlesSizes == nil {
      computeTitlesSizes()
    }
    return _horizontalTitlesSizes
  }
  
  private var _verticalTitlesSizes: [CGSize]!
  private var verticalTitlesSizes: [CGSize] {
    if _verticalTitlesSizes == nil {
      computeTitlesSizes()
    }
    return _verticalTitlesSizes
  }
  
  private var _horizontalTitlesMaxHeight: CGFloat!
  private var horizontalTitlesMaxHeight: CGFloat {
    if _horizontalTitlesMaxHeight == nil {
      computeTitlesSizes()
    }
    return _horizontalTitlesMaxHeight
  }
  
  private var _verticalTitlesMaxWidth: CGFloat!
  private var verticalTitlesMaxWidth: CGFloat {
    if _verticalTitlesMaxWidth == nil {
      computeTitlesSizes()
    }
    return _verticalTitlesMaxWidth
  }
  
}
