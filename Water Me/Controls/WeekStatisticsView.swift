//
//  WeekStatisticsView.swift
//  Water Me
//
//  Created by Sergey Balyakin on 18.11.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

protocol WeekStatisticsViewDelegate {
  func weekStatisticsViewDaySelected(dayIndex: Int)
}

@IBDesignable class WeekStatisticsView: UIView {
  
  typealias ItemType = (value: CGFloat, goal: CGFloat)
  typealias TitleForStepFunction = (CGFloat) -> String
  private typealias UIAreas = (scale: CGRect, bars: CGRect, days: CGRect)
  
  @IBInspectable var barsColor: UIColor = UIColor(red: 80/255, green: 184/255, blue: 187/255, alpha: 1.0)
  @IBInspectable var goalLineColor: UIColor = UIColor(red: 239/255, green: 64/255, blue: 79/255, alpha: 0.5)
  @IBInspectable var scaleColor: UIColor = UIColor(red: 147/255, green: 149/255, blue: 152/255, alpha: 1.0)
  @IBInspectable var daysColor: UIColor = UIColor(red: 147/255, green: 149/255, blue: 152/255, alpha: 1.0)
  @IBInspectable var daysBackground: UIColor = UIColor.whiteColor()
  @IBInspectable var barCornerRadius: CGFloat = 2
  @IBInspectable var barWidthFraction: CGFloat = 0.4
  @IBInspectable var scaleLabelsCount: Int = 2
  @IBInspectable var scaleRightMargin: CGFloat = 6
  @IBInspectable var dayButtonsTopMargin: CGFloat = 6
  
  var titleFont: UIFont = UIFont.systemFontOfSize(12)
  
  private var items: [ItemType] = []
  private var dayButtons: [UIButton] = []
  
  let daysPerWeek: Int = NSCalendar.currentCalendar().maximumRangeOfUnit(.WeekdayCalendarUnit).length
  
  var animationDuration = 0.4
  
  var delegate: WeekStatisticsViewDelegate?
  var titleForScaleFunction: TitleForStepFunction?
  
  enum VerticalAlign {
    case Top, Center, Bottom
  }
  
  override init() {
    super.init()
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  override func awakeFromNib() {
    initValues()
    createControls(rect: bounds)
  }
  
  override func prepareForInterfaceBuilder() {
    // Initialize values with some predefined values in order to show in Interface Builder
    for i in 0..<daysPerWeek {
      let item: ItemType = (value: CGFloat(200 + i * 300), goal: 1800)
      items.append(item)
    }
    createControls(rect: bounds)
  }
  
  override func layoutSubviews() {
    computeUIAreasFromRect(bounds)
    
    for i in 0..<daysPerWeek {
      let dayButton = dayButtons[i]
      let dayButtonRect = computeRectangleForDayButtonWithIndex(i, containerRect: uiAreas.days)
      dayButton.frame = dayButtonRect
      dayButton.layer.cornerRadius = round(dayButtonRect.width / 2)
    }
  }
  
  func setItems(items: [ItemType]) {
    if items.count != daysPerWeek {
      assert(false, "Count of specified items should equal to days per week")
      return
    }
    
    _maximumValue = nil
    self.items = items
    setNeedsDisplay()
  }
  
  func dayButtonTapped(sender: UIButton) {
    if let delegate = delegate {
      delegate.weekStatisticsViewDaySelected(sender.tag)
    }
  }
  
  private func createControls(#rect: CGRect) {
    computeUIAreasFromRect(rect)
    createDayButtons(rect: uiAreas.days)
  }
  
  private func initValues() {
    for i in 0..<daysPerWeek {
      let item: ItemType = (value: 0, goal: 0)
      items.append(item)
    }
  }
  
  private func computeUIAreasFromRect(rect: CGRect) {
    let maximumValueTitle = getTitleForScaleValue(maximumValue)
    let labelSize = computeSizeForText(maximumValueTitle, font: titleFont)
    let maximumValueTitleHalfHeight = ceil(computeSizeForText(maximumValueTitle, font: titleFont).height / 2)
    
    var innerRect = CGRectMake(rect.minX, rect.minY + maximumValueTitleHalfHeight, rect.width, rect.height - maximumValueTitleHalfHeight)
    innerRect.inset(dx: 1, dy: 1)
    let horizontalRectangles = innerRect.rectsByDividing(labelSize.width + scaleRightMargin, fromEdge: .MinXEdge)
    let rightRectangle = horizontalRectangles.remainder
    let leftRectangle = horizontalRectangles.slice
    let barWidth = round(rightRectangle.width / CGFloat(daysPerWeek))
    let rightVerticalRectangles = rightRectangle.rectsByDividing(barWidth, fromEdge: .MaxYEdge)
    let leftVerticalRectangles = leftRectangle.rectsByDividing(barWidth, fromEdge: .MaxYEdge)
    
    uiAreas.scale = leftVerticalRectangles.remainder.integerRect
    uiAreas.bars = rightVerticalRectangles.remainder.integerRect
    uiAreas.days = rightVerticalRectangles.slice.integerRect
  }
  
  private func createDayButtons(#rect: CGRect) {
    let calendar = NSCalendar.currentCalendar()
    
    for i in 0..<daysPerWeek {
      let title = calendar.veryShortWeekdaySymbols[i] as String
      let dayButtonRect = computeRectangleForDayButtonWithIndex(i, containerRect: rect)
      let dayButton = UIButton(frame: dayButtonRect)
      dayButton.tag = i
      dayButton.setTitle(title, forState: .Normal)
      dayButton.setTitleColor(daysColor, forState: .Normal)
      dayButton.titleLabel?.font = titleFont
      dayButton.backgroundColor = daysBackground
      dayButton.layer.cornerRadius = round(dayButtonRect.width / 2)
      dayButton.addTarget(self, action: "dayButtonTapped:", forControlEvents: .TouchUpInside)
      addSubview(dayButton)
      dayButtons.append(dayButton)
    }
  }
  
  private func computeRectangleForDayButtonWithIndex(index: Int, containerRect: CGRect) -> CGRect {
    assert(index >= 0 && index < daysPerWeek, "Day index is out of bounds")
    
    let rect = CGRectMake(containerRect.minX, containerRect.minY + dayButtonsTopMargin, containerRect.width, containerRect.height - dayButtonsTopMargin)
    let buttonWidth = rect.width / CGFloat(daysPerWeek)
    let buttonHeight = rect.height
    let x = rect.minX + CGFloat(index) * buttonWidth
    let y = rect.minY
    
    var buttonRect = CGRectMake(x, y, buttonWidth, buttonHeight)
    let minSize = min(buttonWidth, buttonHeight)
    let dx = (buttonWidth - minSize) / 2
    let dy = (buttonHeight - minSize) / 2
    buttonRect.inset(dx: dx, dy: dy)
    return CGRectMake(trunc(buttonRect.minX), trunc(buttonRect.minY), ceil(buttonRect.width), trunc(buttonRect.height))
  }
  
  override func drawRect(rect: CGRect) {
    drawScale()
    drawBars()
    drawGoals()
  }
  
  private func drawScale() {
    let rect = uiAreas.scale
    let fontAttributes = [NSFontAttributeName: titleFont, NSForegroundColorAttributeName: scaleColor]
    let segmentHeight = rect.height / CGFloat(scaleLabelsCount - 1)
    
    for i in 0..<scaleLabelsCount {
      let scaleValue = maximumValue / CGFloat(scaleLabelsCount - 1) * CGFloat(i)
      let title = getTitleForScaleValue(scaleValue)

      let size = computeSizeForText(title, font: titleFont)
      let minY = rect.maxY - CGFloat(i) * segmentHeight - size.height / 2
      let minX = rect.maxX - size.width - scaleRightMargin
      let point = CGPointMake(minX, minY)
      title.drawAtPoint(point, withAttributes: fontAttributes)
    }
  }
  
  private func getTitleForScaleValue(value: CGFloat) -> String {
    if let titleFunction = titleForScaleFunction {
      return titleFunction(value)
    }
    
    return "\(Int(value))"
  }
  
  private func computeSizeForText(text: String, font: UIFont) -> CGSize {
    let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as NSMutableParagraphStyle
    let fontAttributes = [NSFontAttributeName: font, NSParagraphStyleAttributeName: textStyle]
    return text.boundingRectWithSize(CGSizeMake(CGFloat.infinity, CGFloat.infinity), options: .UsesLineFragmentOrigin, attributes: fontAttributes, context: nil).size
  }
  
  private func computeMaximumValue() -> CGFloat {
    var maximum: CGFloat = 0
    
    for (value, goal) in items {
      let itemMaximum = max(value, goal)
      if itemMaximum > maximum {
        maximum = itemMaximum
      }
    }
    
    if maximum > 1000 {
      maximum = ceil(maximum / 100) * 100
    } else if maximum > 100 {
      maximum = ceil(maximum / 10) * 10
    }
    
    return maximum
  }
  
  private func drawBars() {
    if _barsLayer == nil {
      let zeroRect = CGRectMake(uiAreas.bars.minX, uiAreas.bars.maxY, uiAreas.bars.width, 0)
      let zeroPaths = computeBarsPathsForRect(zeroRect)
      drawBarsPaths(zeroPaths, useAnimation: false)
    }
    
    let paths = computeBarsPathsForRect(uiAreas.bars)
    drawBarsPaths(paths, useAnimation: true)
  }
  
  private func drawBarsPaths(paths: [CGPath], useAnimation: Bool) {
    for (index, path) in enumerate(paths) {
      if barsLayer.sublayers == nil || index >= barsLayer.sublayers.count {
        assert(false, "Cannot find necessary shape sub-layers for bars")
        break
      }
      
      let barLayer = barsLayer.sublayers[index] as CAShapeLayer
      transformShape(barLayer, path: path, useAnimation: useAnimation)
    }
  }
  
  private func drawGoals() {
    if _goalsShapeLayer == nil {
      let zeroRect = CGRectMake(uiAreas.bars.minX, uiAreas.bars.maxY, uiAreas.bars.width, 0)
      let zeroPath = computeGoalsPathForRect(zeroRect)
      transformShape(goalsShapeLayer, path: zeroPath, useAnimation: false)
    }
    
    let path = computeGoalsPathForRect(uiAreas.bars)
    transformShape(goalsShapeLayer, path: path, useAnimation: true)
  }
  
  private func computeGoalsPathForRect(rect: CGRect) -> CGPath {
    let goalsCount = items.count
    let barWidth = rect.width / CGFloat(goalsCount)
    var xFrom = rect.minX
    
    let path = UIBezierPath()
    
    for (index, item) in enumerate(items) {
      let goalHeight = maximumValue > 0 ? CGFloat(item.goal) / maximumValue * rect.height : 0
      let y = round(rect.maxY - goalHeight)
      let xTo = xFrom + barWidth
      
      let fromPoint = CGPointMake(round(xFrom), y)
      
      if index == 0 {
        path.moveToPoint(fromPoint)
      } else {
        path.addLineToPoint(fromPoint)
      }
      
      let toPoint = CGPointMake(round(xTo), y)
      path.addLineToPoint(toPoint)
      
      xFrom = xTo
    }
    
    return path.CGPath
  }
  
  private func computeBarsPathsForRect(rect: CGRect) -> [CGPath] {
    let valuesCount = items.count
    let fullBarWidth = rect.width / CGFloat(valuesCount)
    let barWidthInset = (fullBarWidth * (1 - barWidthFraction)) / 2
    let visibleBarWidth = round(fullBarWidth * barWidthFraction)
    var x = rect.minX
    
    var paths: [CGPath] = []
    
    for (index, item) in enumerate(items) {
      let barHeight = maximumValue > 0 ? (CGFloat(item.value) / maximumValue * rect.height) : 0
      let x = rect.minX + CGFloat(index) * fullBarWidth
      
      var rect = CGRectMake(x, rect.maxY - barHeight, fullBarWidth, barHeight)
      rect.inset(dx: barWidthInset, dy: 0)
      rect.integerize()
      rect.size.width = visibleBarWidth // to ensure for same width for all bars
      
      // If height of a bar is less than double corner radius there will be issues during its animation, so fix the height
      if rect.size.height < barCornerRadius * 2 {
        rect.size.height = barCornerRadius * 2
      }
      
      let path = UIBezierPath(roundedRect: rect, byRoundingCorners: .TopLeft | .TopRight, cornerRadii: CGSizeMake(barCornerRadius, barCornerRadius))
      paths.append(path.CGPath)
    }
    
    return paths
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
  
  private func createValuesLayer() {
    // Create layer containing bar shape sub-layers
    _barsLayer = CALayer(layer: layer)
    _barsLayer.frame = uiAreas.bars
    _barsLayer.bounds = uiAreas.bars
    _barsLayer.masksToBounds = true
    layer.addSublayer(_barsLayer)
    
    // Create shape layer for each bar
    for i in 0..<items.count {
      let barLayer = CAShapeLayer(layer: _barsLayer)
      barLayer.strokeColor = nil
      barLayer.fillColor = barsColor.CGColor
      _barsLayer.addSublayer(barLayer)
    }
  }
  
  private func createGoalsShapeLayer() {
    _goalsShapeLayer = CAShapeLayer(layer: layer)
    _goalsShapeLayer.frame = uiAreas.bars
    _goalsShapeLayer.bounds = uiAreas.bars
    _goalsShapeLayer.strokeColor = goalLineColor.CGColor
    _goalsShapeLayer.fillColor = nil
    _goalsShapeLayer.lineWidth = 1
    _goalsShapeLayer.lineJoin = kCALineJoinRound
    _goalsShapeLayer.lineDashPattern = [3, 3]
    layer.addSublayer(_goalsShapeLayer)
  }
  
  private var uiAreas: UIAreas = (scale: CGRectZero, bars: CGRectZero, days: CGRectZero)
  
  private var _goalsShapeLayer: CAShapeLayer!
  private var goalsShapeLayer: CAShapeLayer {
    if _goalsShapeLayer == nil {
      createGoalsShapeLayer()
    }
    return _goalsShapeLayer
  }
  
  private var _barsLayer: CALayer!
  private var barsLayer: CALayer {
    if _barsLayer == nil {
      createValuesLayer()
    }
    return _barsLayer
  }
  
  private var _maximumValue: CGFloat!
  private var maximumValue: CGFloat {
    if _maximumValue == nil {
      _maximumValue = computeMaximumValue()
    }
    return _maximumValue
  }
  
}