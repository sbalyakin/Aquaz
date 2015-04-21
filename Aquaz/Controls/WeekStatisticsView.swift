//
//  WeekStatisticsView.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 18.11.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

protocol WeekStatisticsViewDataSource: class {
  
  func weekStatisticsViewIsFutureDay(dayIndex: Int) -> Bool
  func weekStatisticsViewIsToday(dayIndex: Int) -> Bool
  func weekStatisticsViewGetTitleForValue(value: CGFloat) -> String
  
}

protocol WeekStatisticsViewDelegate: class {
  
  func weekStatisticsViewDaySelected(dayIndex: Int)
  
}

@IBDesignable class WeekStatisticsView: UIView {
  
  @IBInspectable var backgroundDarkColor: UIColor = UIColor(white: 235/255, alpha: 1.0)
  @IBInspectable var barsColor: UIColor = UIColor(red: 80/255, green: 184/255, blue: 187/255, alpha: 1.0)
  @IBInspectable var goalLineColor: UIColor = UIColor(red: 239/255, green: 64/255, blue: 79/255, alpha: 0.5)
  @IBInspectable var scaleColor: UIColor = UIColor(red: 147/255, green: 149/255, blue: 152/255, alpha: 1.0)
  @IBInspectable var daysColor: UIColor = UIColor.darkGrayColor()
  @IBInspectable var daysBackground: UIColor = UIColor.whiteColor()
  @IBInspectable var daysFont: UIFont = UIFont.systemFontOfSize(12) {
    didSet {
      createButtons()
      setNeedsLayout()
    }
  }
  @IBInspectable var todayColor: UIColor = UIColor.darkGrayColor()
  @IBInspectable var todayBackground: UIColor = UIColor.whiteColor()
  @IBInspectable var futureDaysColor: UIColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.7)
  @IBInspectable var futureDaysBackground: UIColor = UIColor.clearColor()
  @IBInspectable var barCornerRadius: CGFloat = 2
  @IBInspectable var barWidthFraction: CGFloat = 0.4
  @IBInspectable var scaleLabelsCount: Int = 2
  @IBInspectable var scaleMargin: CGFloat = 6
  @IBInspectable var dayButtonsTopMargin: CGFloat = 10
  @IBInspectable var horizontalMargin: CGFloat = 0
  @IBInspectable var titleFont: UIFont = UIFont.systemFontOfSize(12) {
    didSet {
      titleLabel?.font = titleFont
      setNeedsLayout()
    }
  }
  @IBInspectable var disableFutureDayButtons: Bool = true
  
  override var backgroundColor: UIColor? {
    didSet {
      if let backgroundColor = backgroundColor where !backgroundColor.isClearColor() {
        titleLabel.backgroundColor = backgroundColor.colorWithAlphaComponent(0.7)
      }
    }
  }

  var animationDuration = 0.4
  let daysPerWeek: Int = NSCalendar.currentCalendar().maximumRangeOfUnit(.CalendarUnitWeekday).length
  
  weak var delegate: WeekStatisticsViewDelegate?
  weak var dataSource: WeekStatisticsViewDataSource?

  typealias ItemType = (value: CGFloat, goal: CGFloat)
  typealias TitleForStepFunction = (CGFloat) -> String
  private typealias UIAreas = (scale: CGRect, bars: CGRect, days: CGRect, background: CGRect)

  private var items: [ItemType] = []
  private var dayButtons: [UIButton] = []

  private var uiAreas: UIAreas = (scale: CGRectZero, bars: CGRectZero, days: CGRectZero, background: CGRectZero)
  
  private var goalsLayer: CAShapeLayer!
  private var barsLayer: CALayer!
  private var backgroundLayer: CAGradientLayer!
  private var titleLabel: UILabel!
  
  private var maximumValue: CGFloat = 0
  
  private var itemsInitializing = false
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    baseInit()
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    baseInit()
  }

  override func intrinsicContentSize() -> CGSize {
    return CGSizeMake(300, 300)
  }
  
  override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
    
    // Initialize values with some predefined values in order to show in Interface Builder
    var items = [ItemType]()
    for index in 0..<daysPerWeek {
      let item: ItemType = (value: CGFloat(200 + index * 300), goal: 1800)
      items.append(item)
    }
    setItems(items, animate: false)
  }

  // MARK: Creation -

  private func baseInit() {
    createButtons()
    createLayers()
    createTitleLabel()
    initItems()
  }

  private func initItems() {
    itemsInitializing = true
    
    var items = [ItemType]()
    for i in 0..<daysPerWeek {
      let item: ItemType = (value: 0, goal: 0)
      items.append(item)
    }
    setItems(items, animate: false)
  }
  
  private func createButtons() {
    deleteButtons()
    
    let calendar = NSCalendar.currentCalendar()
    
    for dayIndex in 0..<daysPerWeek {
      let title = calendar.veryShortWeekdaySymbols[dayIndex] as! String

      let dayButton = UIButton()
      dayButton.tag = dayIndex
      dayButton.titleLabel?.font = daysFont
      dayButton.setTitle(title, forState: .Normal)
      dayButton.addTarget(self, action: "dayButtonTapped:", forControlEvents: .TouchUpInside)
      addSubview(dayButton)
      dayButtons.append(dayButton)
    }
    
    updateButtons()
  }
  
  private func deleteButtons() {
    for dayButton in dayButtons {
      dayButton.removeFromSuperview()
    }
    dayButtons.removeAll(keepCapacity: true)
  }

  private func updateButtons() {
    for dayButton in dayButtons {
      let titleColor: UIColor
      let backgroundColor: UIColor
      let font: UIFont
      let isFutureDay = dataSource?.weekStatisticsViewIsFutureDay(dayButton.tag) ?? false

      if dataSource?.weekStatisticsViewIsToday(dayButton.tag) ?? false {
        titleColor = todayColor
        backgroundColor = todayBackground
        let fontDescriptor = daysFont.fontDescriptor().fontDescriptorWithSymbolicTraits(.TraitBold)!
        font = UIFont(descriptor: fontDescriptor, size: daysFont.pointSize)
      } else {
        titleColor = isFutureDay ? futureDaysColor : daysColor
        backgroundColor = isFutureDay ? UIColor.clearColor() : daysBackground
        font = daysFont
      }
      
      UIView.animateWithDuration(0.4) {
        dayButton.setTitleColor(titleColor, forState: .Normal)
        dayButton.backgroundColor = backgroundColor
        dayButton.titleLabel?.font = font
      }
      dayButton.userInteractionEnabled = !isFutureDay
    }
  }
  
  private func createLayers() {
    createBackgroundLayer()
    createBarsLayer()
    createGoalsLayer()
  }
  
  private func createBackgroundLayer() {
    if backgroundColor?.isClearColor() ?? true {
      return
    }
    
    if backgroundDarkColor.isClearColor() {
      return
    }
    
    backgroundLayer = CAGradientLayer()
    backgroundLayer.colors = [backgroundDarkColor.CGColor, backgroundColor!.CGColor]
    layer.insertSublayer(backgroundLayer, atIndex: 0)
  }

  private func createBarsLayer() {
    // Create layer containing bar shape sub-layers
    barsLayer = CALayer()
    barsLayer.frame = uiAreas.bars
    barsLayer.bounds = uiAreas.bars
    barsLayer.masksToBounds = true
    layer.addSublayer(barsLayer)
    
    // Create shape layer for each bar
    for i in 0..<daysPerWeek {
      let barLayer = CAShapeLayer()
      barLayer.strokeColor = nil
      barLayer.fillColor = barsColor.CGColor
      barsLayer.addSublayer(barLayer)
    }
  }
  
  private func createGoalsLayer() {
    goalsLayer = CAShapeLayer()
    goalsLayer.frame = uiAreas.bars
    goalsLayer.bounds = uiAreas.bars
    goalsLayer.strokeColor = goalLineColor.CGColor
    goalsLayer.fillColor = nil
    goalsLayer.lineWidth = 1
    goalsLayer.lineJoin = kCALineJoinRound
    goalsLayer.lineDashPattern = [3, 3]
    layer.addSublayer(goalsLayer)
  }
  
  private func createTitleLabel() {
    titleLabel?.removeFromSuperview()
    
    titleLabel = UILabel()
    titleLabel.font = titleFont
    titleLabel.textColor = scaleColor
    if let backgroundColor = backgroundColor where !backgroundColor.isClearColor() {
      titleLabel.backgroundColor = backgroundColor.colorWithAlphaComponent(0.7)
    }
    addSubview(titleLabel)
  }

  // MARK: Layout -
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    calcUIAreasFromRect(bounds)
    
    layoutBackground()
    layoutBars()
    layoutGoals()
    
    layoutTitleLabel()

    layoutButtons()
    
    itemsInitializing = false
  }

  private func calcUIAreasFromRect(rect: CGRect) {
    let barWidth = round(rect.width / CGFloat(daysPerWeek))
    let verticalRectangles = rect.rectsByDividing(barWidth, fromEdge: .MaxYEdge)
    let scaleRect = verticalRectangles.remainder.integerRect
    
    uiAreas.scale = verticalRectangles.remainder.rectByInsetting(dx: horizontalMargin, dy: 0).integerRect
    uiAreas.bars = uiAreas.scale
    uiAreas.days = verticalRectangles.slice.rectByInsetting(dx: horizontalMargin, dy: 0).integerRect
    uiAreas.background = verticalRectangles.remainder.integerRect
  }

  private func layoutBackground() {
    if backgroundLayer != nil {
      var rect = uiAreas.background
      rect = rect.rectsByDividing(rect.height / 2, fromEdge: .MinYEdge).slice
      backgroundLayer.frame = rect
    }
  }
  
  private func layoutBars() {
    barsLayer.frame = uiAreas.bars
    
    if itemsInitializing {
      let zeroRect = CGRect(x: barsLayer.bounds.minX, y: barsLayer.bounds.maxY, width: barsLayer.bounds.width, height: 0)
      let zeroPaths = calcBarsPathsForRect(zeroRect)
      layoutBarsPaths(zeroPaths, useAnimation: false)
    }
    
    let paths = calcBarsPathsForRect(barsLayer.bounds)
    layoutBarsPaths(paths, useAnimation: true)
  }
  
  private func layoutBarsPaths(paths: [CGPath], useAnimation: Bool) {
    for (index, path) in enumerate(paths) {
      if barsLayer.sublayers == nil || index >= barsLayer.sublayers.count {
        assert(false, "Cannot find necessary shape sub-layers for bars")
        break
      }
      
      let barLayer = barsLayer.sublayers[index] as! CAShapeLayer
      transformShape(barLayer, path: path, useAnimation: useAnimation)
    }
  }
  
  private func layoutGoals() {
    goalsLayer.frame = uiAreas.bars
    
    if itemsInitializing {
      let zeroRect = CGRect(x: goalsLayer.bounds.minX, y: goalsLayer.bounds.maxY, width: goalsLayer.bounds.width, height: 0)
      let zeroPath = calcGoalsPathForRect(zeroRect)
      transformShape(goalsLayer, path: zeroPath, useAnimation: false)
    }
    
    let path = calcGoalsPathForRect(goalsLayer.bounds)
    transformShape(goalsLayer, path: path, useAnimation: true)
  }

  private func layoutButtons() {
    for (index, dayButton) in enumerate(dayButtons) {
      let dayButtonRect = calcRectangleForDayButtonWithIndex(index, containerRect: uiAreas.days)
      dayButton.frame = dayButtonRect
      dayButton.layer.cornerRadius = round(dayButtonRect.width / 2)
    }
  }
  
  private func layoutTitleLabel() {
    titleLabel.sizeToFit()
    titleLabel.frame.origin = CGPoint(x: uiAreas.scale.minX, y: uiAreas.scale.minY + scaleMargin)
  }
  
  private func calcSizeForText(text: String, font: UIFont) -> CGSize {
    let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
    let fontAttributes = [NSFontAttributeName: font, NSParagraphStyleAttributeName: textStyle]
    let infiniteSize = CGSize(width: CGFloat.infinity, height: CGFloat.infinity)
    let rect = text.boundingRectWithSize(infiniteSize, options: .UsesLineFragmentOrigin, attributes: fontAttributes, context: nil)
    return rect.size
  }
  
  private func calcGoalsPathForRect(rect: CGRect) -> CGPath {
    let goalsCount = items.count
    let barWidth = rect.width / CGFloat(goalsCount)
    var xFrom = rect.minX
    
    let path = UIBezierPath()
    
    for (index, item) in enumerate(items) {
      let goalHeight = maximumValue > 0 ? CGFloat(item.goal) / maximumValue * rect.height : 0
      let y = round(rect.maxY - goalHeight)
      let xTo = xFrom + barWidth
      
      let fromPoint = CGPoint(x: round(xFrom), y: y)
      
      if index == 0 {
        path.moveToPoint(fromPoint)
      } else {
        path.addLineToPoint(fromPoint)
      }
      
      let toPoint = CGPoint(x: round(xTo), y: y)
      path.addLineToPoint(toPoint)
      
      xFrom = xTo
    }
    
    return path.CGPath
  }
  
  private func calcBarsPathsForRect(rect: CGRect) -> [CGPath] {
    let valuesCount = items.count
    let fullBarWidth = rect.width / CGFloat(valuesCount)
    let barWidthInset = (fullBarWidth * (1 - barWidthFraction)) / 2
    let visibleBarWidth = round(fullBarWidth * barWidthFraction)
    var x = rect.minX
    
    var paths: [CGPath] = []
    
    for (index, item) in enumerate(items) {
      let barHeight = maximumValue > 0 ? (CGFloat(item.value) / maximumValue * rect.height) : 0
      let x = rect.minX + CGFloat(index) * fullBarWidth
      
      var rect = CGRect(x: x, y: rect.maxY - barHeight, width: fullBarWidth, height: barHeight)
      rect.inset(dx: barWidthInset, dy: 0)
      rect.integerize()
      rect.size.width = visibleBarWidth // to ensure for same width for all bars
      
      // If height of a bar is less than double corner radius there will be issues during its animation, so fix the height
      if rect.size.height < barCornerRadius * 2 {
        rect.size.height = barCornerRadius * 2
      }
      
      let path = UIBezierPath(roundedRect: rect, byRoundingCorners: .TopLeft | .TopRight, cornerRadii: CGSize(width: barCornerRadius, height: barCornerRadius))
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
  
  private func calcRectangleForDayButtonWithIndex(index: Int, containerRect: CGRect) -> CGRect {
    assert(index >= 0 && index < daysPerWeek, "Day index is out of bounds")
    
    let rect = CGRect(x: containerRect.minX, y: containerRect.minY + dayButtonsTopMargin, width: containerRect.width, height: containerRect.height - dayButtonsTopMargin)
    let buttonWidth = rect.width / CGFloat(daysPerWeek)
    let buttonHeight = rect.height
    let x = rect.minX + CGFloat(index) * buttonWidth
    let y = rect.minY
    
    var buttonRect = CGRect(x: x, y: y, width: buttonWidth, height: buttonHeight)
    let minSize = min(buttonWidth, buttonHeight)
    let dx = (buttonWidth - minSize) / 2
    let dy = (buttonHeight - minSize) / 2
    buttonRect.inset(dx: dx, dy: dy)
    return CGRect(x: trunc(buttonRect.minX), y: trunc(buttonRect.minY), width: ceil(buttonRect.width), height: trunc(buttonRect.height))
  }

  // MARK: Other -
  
  func setItems(items: [ItemType], animate: Bool = true) {
    if items.count != daysPerWeek {
      assert(false, "Count of specified items should equal to days per week")
      return
    }

    self.items = items
    maximumValue = calcMaximumValue()

    updateButtons()
    
    if animate {
      titleLabel.setTextWithAnimation(getTitleForScaleValue(maximumValue)) {
        self.titleLabel.sizeToFit()
      }
    } else {
      titleLabel.text = getTitleForScaleValue(maximumValue)
    }

    setNeedsLayout()
  }
  
  func dayButtonTapped(sender: UIButton) {
    delegate?.weekStatisticsViewDaySelected(sender.tag)
  }

  private func getTitleForScaleValue(value: CGFloat) -> String {
    return dataSource?.weekStatisticsViewGetTitleForValue(value) ?? "\(Int(value))"
  }
  
  private func calcMaximumValue() -> CGFloat {
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
  
}