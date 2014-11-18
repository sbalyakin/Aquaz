//
//  WeekStatisticsView.swift
//  Water Me
//
//  Created by Sergey Balyakin on 18.11.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

// TODO: Resizing should be correctly processed
@IBDesignable class WeekStatisticsView: UIView {

  typealias ItemType = (value: Double, goal: Double)

  @IBInspectable var barsColor: UIColor = UIColor.orangeColor()
  @IBInspectable var goalLineColor: UIColor = UIColor.redColor()
  @IBInspectable var scaleColor: UIColor = UIColor.grayColor()
  @IBInspectable var daysColor: UIColor = UIColor.grayColor()
  @IBInspectable var daysBackground: UIColor = UIColor.whiteColor()
  @IBInspectable var barCornerRadius: CGFloat = 2.0
  @IBInspectable var barWidthFraction: CGFloat = 0.4
  @IBInspectable var scaleLabelsCount: Int = 10
  @IBInspectable var titleFont: UIFont = UIFont.systemFontOfSize(12)
  
  var items: [ItemType] = []

  let daysPerWeek: Int = NSCalendar.currentCalendar().maximumRangeOfUnit(.WeekdayCalendarUnit).length
  let gapFromScaleToBars: CGFloat = 5

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
    for i in 0..<daysPerWeek {
      let item: ItemType = (value: Double(200 + i * 300), goal: 1800)
      items.append(item)
    }
    createControls(rect: bounds)
  }
  
  private func createControls(#rect: CGRect) {
    let rects = computeRectanglesFromRect(rect)
    createDayButtons(rect: rects.days)
  }
  
  private func initValues() {
    for i in 0..<daysPerWeek {
      let item: ItemType = (value: 0, goal: 0)
      items.append(item)
    }
  }
  
  private func computeRectanglesFromRect(rect: CGRect) -> (scale: CGRect, bars: CGRect, days: CGRect) {
    let maximumScaleValue = Int(max(computeMaximumValue(), 9999)) // scale part should be adjusted minimum to 4 symbols
    let labelSize = computeSizeForText("\(maximumScaleValue)", font: titleFont)
    
    let innerRect = rect.rectByInsetting(dx: 4, dy: 4)
    let horizontalRectangles = innerRect.rectsByDividing(labelSize.width + gapFromScaleToBars, fromEdge: .MinXEdge)
    let rightRectangle = horizontalRectangles.remainder
    let leftRectangle = horizontalRectangles.slice
    let barWidth = trunc(rightRectangle.width / CGFloat(daysPerWeek))
    let rightVerticalRectangles = rightRectangle.rectsByDividing(barWidth, fromEdge: .MaxYEdge)
    let leftVerticalRectangles = leftRectangle.rectsByDividing(barWidth, fromEdge: .MaxYEdge)
    
    var result: (scale: CGRect, bars: CGRect, days: CGRect)
    result.scale = leftVerticalRectangles.remainder
    result.bars = rightVerticalRectangles.remainder
    result.days = rightVerticalRectangles.slice
    return result
  }
  
  private func createDayButtons(#rect: CGRect) {
    let buttonWidth = rect.width / CGFloat(daysPerWeek)
    var x = rect.minX
    let calendar = NSCalendar.currentCalendar()
    
    for i in 0..<daysPerWeek {
      var buttonRect = CGRectMake(trunc(x), rect.minY, ceil(buttonWidth), rect.height)
      let minSize = min(buttonRect.width, buttonRect.height)
      let dx = (buttonRect.width - minSize) / 2
      let dy = (buttonRect.height - minSize) / 2
      
      buttonRect.inset(dx: dx + 4, dy: dy + 4)
      x += buttonWidth
      
      let dayButton = UIButton(frame: buttonRect)
      let title = calendar.veryShortWeekdaySymbols[i] as String
      dayButton.tag = i
      dayButton.setTitle(title, forState: .Normal)
      dayButton.setTitleColor(daysColor, forState: .Normal)
      dayButton.titleLabel?.font = titleFont
      dayButton.backgroundColor = daysBackground
      dayButton.layer.cornerRadius = buttonRect.width / 2
      dayButton.addTarget(self, action: "dayButtonTapped:", forControlEvents: .TouchUpInside)
      addSubview(dayButton)
    }

  }
  
  override func drawRect(rect: CGRect) {
    let rects = computeRectanglesFromRect(rect)
    drawScale(rect: rects.scale)
    drawBars(rect: rects.bars)
    drawGoals(rect: rects.bars)
  }
  
  private func drawScale(#rect: CGRect) {
    let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as NSMutableParagraphStyle
    textStyle.alignment = NSTextAlignment.Right
    
    let fontAttributes = [NSFontAttributeName: titleFont, NSForegroundColorAttributeName: scaleColor, NSParagraphStyleAttributeName: textStyle]

    let textHeight: CGFloat = computeSizeForText("0123456789", font: titleFont).height

    let innerRect = rect.rectByInsetting(dx: 0, dy: textHeight / 2)
    let segmentHeight = innerRect.height / CGFloat(scaleLabelsCount)
    
    let maximum = CGFloat(computeMaximumValue())
    
    for i in 0...scaleLabelsCount {
      let minY = round(innerRect.maxY - CGFloat(i) * segmentHeight - textHeight / 2)
      let labelRect = CGRectMake(innerRect.minX, minY, innerRect.width - gapFromScaleToBars, textHeight)
      
      let scaleValue = Int(maximum / CGFloat(scaleLabelsCount) * CGFloat(i))
      "\(scaleValue)".drawInRect(labelRect, withAttributes: fontAttributes)
    }
  }
  
  private func computeSizeForText(text: String, font: UIFont) -> CGSize {
    let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as NSMutableParagraphStyle
    let fontAttributes = [NSFontAttributeName: font, NSParagraphStyleAttributeName: textStyle]
    return text.boundingRectWithSize(CGSizeMake(CGFloat.infinity, CGFloat.infinity), options: .UsesLineFragmentOrigin, attributes: fontAttributes, context: nil).size
  }
  
  private func computeMaximumValue() -> Double {
    var maximum: Double = 0
    
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
  
  private func drawBars(#rect: CGRect) {
    let maximumValue = CGFloat(computeMaximumValue())
    let valuesCount = items.count
    let fullBarWidth = rect.width / CGFloat(valuesCount)
    let barWidthInset = round((fullBarWidth * (1 - barWidthFraction)) / 2)
    var x = rect.minX
    
    for (index, item) in enumerate(items) {
      let barHeight = maximumValue > 0 ? round(CGFloat(item.value) / maximumValue * rect.height) : 0
      
      var rect = CGRectMake(trunc(x), rect.maxY - barHeight, ceil(fullBarWidth), barHeight)
      rect.inset(dx: barWidthInset, dy: 0)
      x += fullBarWidth
      
      drawBar(rect: rect)
    }
  }
  
  private func drawBar(#rect: CGRect) {
    let rectanglePath = UIBezierPath(roundedRect: rect, cornerRadius: barCornerRadius)
    barsColor.setFill()
    rectanglePath.fill()
  }
  
  private func drawGoals(#rect: CGRect) {
    let maximumValue = CGFloat(computeMaximumValue())
    let goalsCount = items.count
    let barWidth = rect.width / CGFloat(goalsCount)
    var xFrom = rect.minX
    
    var bezierPath = UIBezierPath()
    var dashPattern: [CGFloat] = [5, 3]
    bezierPath.setLineDash(&dashPattern, count: dashPattern.count, phase: 0)
    
    for (index, item) in enumerate(items) {
      let goalHeight = maximumValue > 0 ? CGFloat(item.goal) / maximumValue * rect.height : 0
      let y = round(rect.maxY - goalHeight)
      let xTo = xFrom + barWidth
      
      let fromPoint = CGPointMake(round(xFrom), y)

      if index == 0 {
        bezierPath.moveToPoint(fromPoint)
      } else {
        bezierPath.addLineToPoint(fromPoint)
      }
      
      let toPoint = CGPointMake(round(xTo), y)
      bezierPath.addLineToPoint(toPoint)
      
      xFrom = xTo
    }
    
    goalLineColor.setStroke()
    bezierPath.lineWidth = 1
    bezierPath.lineJoinStyle = kCGLineJoinRound
    bezierPath.lineCapStyle = kCGLineCapRound
    bezierPath.stroke()
  }
  
  func dayButtonTapped(sender: UIButton) {
    
  }
  
}
