//
//  WeekStatisticsView.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 18.11.14.
//  Copyright © 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

protocol WeekStatisticsViewDataSource: class {
  
  func weekStatisticsViewIsFutureDay(_ dayIndex: Int) -> Bool
  func weekStatisticsViewIsToday(_ dayIndex: Int) -> Bool
  func weekStatisticsViewGetTitleForValue(_ value: CGFloat) -> String
  
}

protocol WeekStatisticsViewDelegate: class {
  
  func weekStatisticsViewDaySelected(_ dayIndex: Int)
  
}

@IBDesignable class WeekStatisticsView: UIView {
  
  @IBInspectable var backgroundDarkColor: UIColor = UIColor(white: 235/255, alpha: 1.0)
  @IBInspectable var barsColor: UIColor = UIColor(red: 80/255, green: 184/255, blue: 187/255, alpha: 1.0)
  @IBInspectable var goalLineColor: UIColor = UIColor(red: 239/255, green: 64/255, blue: 79/255, alpha: 0.5)
  @IBInspectable var scaleColor: UIColor = UIColor(red: 147/255, green: 149/255, blue: 152/255, alpha: 1.0)
  @IBInspectable var daysColor: UIColor = UIColor.darkGray
  @IBInspectable var daysBackground: UIColor = UIColor.white
  @IBInspectable var daysFont: UIFont = UIFont.systemFont(ofSize: 12) {
    didSet {
      createButtons()
      setNeedsLayout()
    }
  }
  @IBInspectable var todayColor: UIColor = UIColor.darkGray
  @IBInspectable var todayBackground: UIColor = UIColor.white
  @IBInspectable var futureDaysColor: UIColor = UIColor.darkGray.withAlphaComponent(0.7)
  @IBInspectable var futureDaysBackground: UIColor = UIColor.clear
  @IBInspectable var barCornerRadius: CGFloat = 2
  @IBInspectable var barWidthFraction: CGFloat = 0.4
  @IBInspectable var scaleLabelsCount: Int = 2
  @IBInspectable var scaleMargin: CGFloat = 6
  @IBInspectable var dayButtonsTopMargin: CGFloat = 10
  @IBInspectable var horizontalMargin: CGFloat = 0
  @IBInspectable var titleFont: UIFont = UIFont.systemFont(ofSize: 12) {
    didSet {
      titleLabel?.font = titleFont
      setNeedsLayout()
    }
  }
  @IBInspectable var disableFutureDayButtons: Bool = true
  
  override var backgroundColor: UIColor? {
    didSet {
      if let backgroundColor = backgroundColor , !backgroundColor.isClearColor() {
        titleLabel?.backgroundColor = backgroundColor.withAlphaComponent(0.7)
      }
    }
  }

  var animationDuration = 0.4
  let daysPerWeek: Int = DateHelper.daysPerWeek()
  
  weak var delegate: WeekStatisticsViewDelegate?
  weak var dataSource: WeekStatisticsViewDataSource?

  typealias ItemType = (value: CGFloat, goal: CGFloat)
  typealias TitleForStepFunction = (CGFloat) -> String
  fileprivate typealias UIAreas = (scale: CGRect, bars: CGRect, days: CGRect, background: CGRect)

  fileprivate var items: [ItemType] = []
  fileprivate var dayButtons: [UIButton] = []

  fileprivate var uiAreas: UIAreas = (scale: CGRect.zero, bars: CGRect.zero, days: CGRect.zero, background: CGRect.zero)
  
  fileprivate var goalsLayer: CAShapeLayer!
  fileprivate var barsLayer: CALayer!
  fileprivate var backgroundLayer: CAGradientLayer!
  fileprivate var titleLabel: UILabel!
  
  fileprivate var maximumValue: CGFloat = 0
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    baseInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    baseInit()
  }

  override var intrinsicContentSize : CGSize {
    return CGSize(width: 300, height: 300)
  }
  
  @available(iOS 8.0, *)
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

  fileprivate func baseInit() {
    createButtons()
    createLayers()
    createTitleLabel()
    initItems()
  }

  fileprivate func initItems() {
    var items = [ItemType]()
    for _ in 0..<daysPerWeek {
      let item: ItemType = (value: 0, goal: 0)
      items.append(item)
    }

    setItems(items, animate: false)
  }
  
  fileprivate func createButtons() {
    deleteButtons()
    
    let calendar = Calendar.current
    
    for dayIndex in 0..<daysPerWeek {
      let weekDayIndex = (dayIndex + calendar.firstWeekday - 1) % daysPerWeek
      
      let title = calendar.veryShortWeekdaySymbols[weekDayIndex]

      let dayButton = UIButton()
      dayButton.tag = dayIndex
      dayButton.titleLabel?.font = daysFont
      dayButton.setTitle(title, for: UIControlState())
      dayButton.addTarget(self, action: #selector(self.dayButtonTapped(_:)), for: .touchUpInside)
      dayButton.backgroundColor = UIColor.clear
      dayButton.isUserInteractionEnabled = false // will be enabled later

      addSubview(dayButton)
      dayButtons.append(dayButton)
    }
    
    updateButtons()
  }
  
  fileprivate func deleteButtons() {
    for dayButton in dayButtons {
      dayButton.removeFromSuperview()
    }
    dayButtons.removeAll(keepingCapacity: true)
  }

  fileprivate func updateButtons() {
    for dayButton in dayButtons {
      let titleColor: UIColor
      let backgroundColor: UIColor
      let font: UIFont
      let isFutureDay = dataSource?.weekStatisticsViewIsFutureDay(dayButton.tag) ?? false

      if dataSource?.weekStatisticsViewIsToday(dayButton.tag) ?? false {
        titleColor = todayColor
        backgroundColor = todayBackground
        let fontDescriptor = daysFont.fontDescriptor.withSymbolicTraits(.traitBold)
        font = UIFont(descriptor: fontDescriptor!, size: daysFont.pointSize)
      } else {
        titleColor = isFutureDay ? futureDaysColor : daysColor
        backgroundColor = isFutureDay ? UIColor.clear : daysBackground
        font = daysFont
      }
      
      UIView.animate(withDuration: 0.4, animations: {
        dayButton.setTitleColor(titleColor, for: UIControlState())
        dayButton.backgroundColor = backgroundColor
        dayButton.titleLabel?.font = font
      }) 
      dayButton.isUserInteractionEnabled = !isFutureDay
    }
  }
  
  func getDayButtonWithIndex(_ index: Int) -> UIButton {
    return dayButtons[index]
  }
  
  fileprivate func createLayers() {
    createBackgroundLayer()
    createBarsLayer()
    createGoalsLayer()
  }
  
  fileprivate func createBackgroundLayer() {
    if backgroundColor?.isClearColor() ?? true {
      return
    }
    
    if backgroundDarkColor.isClearColor() {
      return
    }
    
    backgroundLayer = CAGradientLayer()
    backgroundLayer.colors = [backgroundDarkColor.cgColor, backgroundColor!.cgColor]
    layer.insertSublayer(backgroundLayer, at: 0)
  }

  fileprivate func createBarsLayer() {
    // Create layer containing bar shape sub-layers
    barsLayer = CALayer()
    barsLayer.frame = uiAreas.bars
    barsLayer.bounds = uiAreas.bars
    barsLayer.masksToBounds = true
    layer.addSublayer(barsLayer)
    
    // Create shape layer for each bar
    for _ in 0..<daysPerWeek {
      let barLayer = CAShapeLayer()
      barLayer.strokeColor = nil
      barLayer.fillColor = barsColor.cgColor
      barsLayer.addSublayer(barLayer)
    }
  }
  
  fileprivate func createGoalsLayer() {
    goalsLayer = CAShapeLayer()
    goalsLayer.frame = uiAreas.bars
    goalsLayer.bounds = uiAreas.bars
    goalsLayer.strokeColor = goalLineColor.cgColor
    goalsLayer.fillColor = nil
    goalsLayer.lineWidth = 1
    goalsLayer.lineJoin = kCALineJoinRound
    goalsLayer.lineDashPattern = [3, 3]
    layer.addSublayer(goalsLayer)
  }
  
  fileprivate func createTitleLabel() {
    titleLabel?.removeFromSuperview()
    
    titleLabel = UILabel()
    titleLabel.font = titleFont
    titleLabel.textColor = scaleColor
    if let backgroundColor = backgroundColor , !backgroundColor.isClearColor() {
      titleLabel.backgroundColor = backgroundColor.withAlphaComponent(0.7)
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
  }

  fileprivate func calcUIAreasFromRect(_ rect: CGRect) {
    let barWidth = round(rect.width / CGFloat(daysPerWeek))
    let verticalRectangles = rect.divided(atDistance: barWidth, from: .maxYEdge)
    
    uiAreas.scale = verticalRectangles.remainder.insetBy(dx: horizontalMargin, dy: 0).integral
    uiAreas.bars = uiAreas.scale
    uiAreas.days = verticalRectangles.slice.insetBy(dx: horizontalMargin, dy: 0).integral
    uiAreas.background = verticalRectangles.remainder.integral
  }

  fileprivate func layoutBackground() {
    if backgroundLayer != nil {
      var rect = uiAreas.background
      rect = rect.divided(atDistance: rect.height / 2, from: .minYEdge).slice
      backgroundLayer.frame = rect
    }
  }
  
  fileprivate func layoutBars() {
    barsLayer.frame = uiAreas.bars
    updateBars(animate: false)
  }
  
  fileprivate func layoutGoals() {
    goalsLayer.frame = uiAreas.bars
    updateGoals(animate: false)
  }

  fileprivate func updateBars(animate: Bool) {
    barsLayer.frame = uiAreas.bars
    
    let paths = calcBarsPathsForRect(barsLayer.bounds)
    updateBarsPaths(paths, useAnimation: animate)
  }
  
  fileprivate func updateBarsPaths(_ paths: [(rect: CGRect, path: CGPath)], useAnimation: Bool) {
    for (index, path) in paths.enumerated() {
      if barsLayer.sublayers == nil || index >= barsLayer.sublayers!.count {
        assert(false, "Cannot find necessary shape sub-layers for bars")
        break
      }
      
      let barLayer = barsLayer.sublayers?[index] as! CAShapeLayer
      barLayer.frame = path.rect
      transformShape(barLayer, path: path.path, useAnimation: useAnimation)
    }
  }

  fileprivate func updateGoals(animate: Bool) {
    goalsLayer.frame = uiAreas.bars
    
    let path = calcGoalsPathForRect(goalsLayer.bounds)
    transformShape(goalsLayer, path: path, useAnimation: animate)
  }

  fileprivate func layoutButtons() {
    for (index, dayButton) in dayButtons.enumerated() {
      let dayButtonRect = calcRectangleForDayButtonWithIndex(index, containerRect: uiAreas.days)
      dayButton.frame = dayButtonRect
      dayButton.layer.cornerRadius = round(dayButtonRect.width / 2)
    }
  }
  
  fileprivate func layoutTitleLabel() {
    titleLabel.sizeToFit()
    titleLabel.frame.origin = CGPoint(x: uiAreas.scale.minX, y: uiAreas.scale.minY + scaleMargin)
  }
  
  fileprivate func calcSizeForText(_ text: String, font: UIFont) -> CGSize {
    let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
    let fontAttributes = [NSAttributedStringKey.font: font, NSAttributedStringKey.paragraphStyle: textStyle]
    let infiniteSize = CGSize(width: CGFloat.infinity, height: CGFloat.infinity)
    let rect = text.boundingRect(with: infiniteSize, options: .usesLineFragmentOrigin, attributes: fontAttributes, context: nil)
    return rect.size
  }
  
  fileprivate func calcGoalsPathForRect(_ rect: CGRect) -> CGPath {
    let goalsCount = items.count
    let barWidth = rect.width / CGFloat(goalsCount)
    var xFrom = rect.minX
    
    let path = UIBezierPath()
    
    for (index, item) in items.enumerated() {
      let goalHeight = maximumValue > 0 ? CGFloat(item.goal) / maximumValue * rect.height : 0
      let y = round(rect.maxY - goalHeight)
      let xTo = xFrom + barWidth
      
      let fromPoint = CGPoint(x: round(xFrom), y: y)
      
      if index == 0 {
        path.move(to: fromPoint)
      } else {
        path.addLine(to: fromPoint)
      }
      
      let toPoint = CGPoint(x: round(xTo), y: y)
      path.addLine(to: toPoint)
      
      xFrom = xTo
    }
    
    return path.cgPath
  }
  
  fileprivate func calcBarsPathsForRect(_ rect: CGRect) -> [(rect: CGRect, path: CGPath)] {
    let valuesCount = items.count
    let fullBarWidth = rect.width / CGFloat(valuesCount)
    let barWidthInset = (fullBarWidth * (1 - barWidthFraction)) / 2
    let visibleBarWidth = round(fullBarWidth * barWidthFraction)
    
    var paths: [(rect: CGRect, path: CGPath)] = []
    
    for (index, item) in items.enumerated() {
      let barHeight = maximumValue > 0 ? (CGFloat(item.value) / maximumValue * rect.height) : 0
      let x = rect.minX + CGFloat(index) * fullBarWidth
      
      var barRect = CGRect(x: x, y: rect.maxY - barHeight, width: fullBarWidth, height: barHeight)
      barRect = barRect.insetBy(dx: barWidthInset, dy: 0).integral
      barRect.size.width = visibleBarWidth // to ensure for same width for all bars
      
      // If height of a bar is less than double corner radius there will be issues during its animation, so fix the height
      if barRect.size.height < barCornerRadius * 2 {
        barRect.size.height = barCornerRadius * 2
      }
      
      var fullBarRect = barRect
      fullBarRect.origin.y = 0
      fullBarRect.size.height = rect.height
      
      barRect.origin.x = 0
      
      let path = UIBezierPath(roundedRect: barRect, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: barCornerRadius, height: barCornerRadius))
      let pathItem = (rect: fullBarRect, path: path.cgPath)
      paths.append(pathItem)
    }
    
    return paths
  }
  
  fileprivate func transformShape(_ shape: CAShapeLayer, path: CGPath, useAnimation: Bool) {
    if useAnimation {
      let startPath: CGPath
      
      if let presentation = shape.presentation() {
        startPath = presentation.path!
      } else {
        startPath = shape.path!
      }

      let animation = CABasicAnimation(keyPath: "path")
      animation.duration = animationDuration
      animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
      animation.fromValue = startPath
      shape.path = path
      animation.toValue = path
      shape.add(animation, forKey: "path")

    } else {
      shape.path = path
    }
  }
  
  fileprivate func calcRectangleForDayButtonWithIndex(_ index: Int, containerRect: CGRect) -> CGRect {
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
    buttonRect = buttonRect.insetBy(dx: dx, dy: dy)
    return CGRect(x: trunc(buttonRect.minX), y: trunc(buttonRect.minY), width: ceil(buttonRect.width), height: trunc(buttonRect.height))
  }

  // MARK: Other -
  
  func setItems(_ items: [ItemType], animate: Bool = true) {
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
      titleLabel.sizeToFit()
    }

    updateGoals(animate: animate)
    updateBars(animate: animate)
  }
  
  @objc func dayButtonTapped(_ sender: UIButton) {
    delegate?.weekStatisticsViewDaySelected(sender.tag)
  }

  fileprivate func getTitleForScaleValue(_ value: CGFloat) -> String {
    return dataSource?.weekStatisticsViewGetTitleForValue(value) ?? "\(Int(value))"
  }
  
  fileprivate func calcMaximumValue() -> CGFloat {
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
