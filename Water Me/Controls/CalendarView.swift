//
//  CalendarView.swift
//  Water Me
//
//  Created by Sergey Balyakin on 26.11.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

protocol CalendarViewDelegate {
  func calendarViewDaySelected(date: NSDate)
}

@IBDesignable class CalendarView: UIView {
  @IBInspectable var weekDayTitleTextColor: UIColor = UIColor.blackColor()
  @IBInspectable var workDayTextColor: UIColor = UIColor.blackColor()
  @IBInspectable var workDayBackgroundColor: UIColor = UIColor.clearColor()
  @IBInspectable var weekendTextColor: UIColor = UIColor.redColor()
  @IBInspectable var weekendBackgroundColor: UIColor = UIColor.clearColor()
  @IBInspectable var todayTextColor: UIColor = UIColor.whiteColor()
  @IBInspectable var todayBackgroundColor: UIColor = UIColor.redColor()
  @IBInspectable var selectedDayTextColor: UIColor = UIColor.blueColor()
  @IBInspectable var selectedDayBackgroundColor: UIColor = UIColor.clearColor()
  @IBInspectable var anotherMonthTransparency: CGFloat = 0.4
  @IBInspectable var futureDaysTransparency: CGFloat = 0.1
  @IBInspectable var futureDaysEnabled: Bool = false
  @IBInspectable var dayRowHeightScale: CGFloat = 1.5
  @IBInspectable var linesEnabled: Bool = true
  @IBInspectable var linesColor: UIColor = UIColor(white: 0.8, alpha: 1)
  
  /// Date of month displayed in the calendar
  private var displayedMonthDate: NSDate = NSDate() {
    didSet {
      // Clean specified date and adjust it to the first day
      let components = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay, fromDate: displayedMonthDate)
      components.day = 1
      displayedMonthDate = calendar.dateFromComponents(components)!
      
      updateCalendar()
    }
  }
  
  let daysPerWeek: Int = NSCalendar.currentCalendar().maximumRangeOfUnit(.WeekdayCalendarUnit).length

  var selectedDate: NSDate = NSDate()
  
  var delegate: CalendarViewDelegate?
  
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
    createDaysInfo()
    createControls()
  }
  
  func switchToMonth(date: NSDate) {
    displayedMonthDate = date
  }
  
  func switchToNextMonth() {
    displayedMonthDate = DateHelper.addToDate(displayedMonthDate, years:0, months: 1, days: 0)
  }
  
  func switchToPreviousMonth() {
    displayedMonthDate = DateHelper.addToDate(displayedMonthDate, years:0, months: -1, days: 0)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    if dayButtons.isEmpty {
      createDaysInfo()
      createControls()
    } else {
      layoutControls()
    }
  }
  
  private func createControls() {
    let areas = computeUIAreas()
    createDayButtonsInRect(areas.table)
    createWeekDaysTitlesInRect(areas.weekdays)
  }
  
  private func createDaysInfo() {
    let date = displayedMonthDate
    
    // Separate the date to components
    let components = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay | .CalendarUnitTimeZone | .CalendarUnitCalendar, fromDate: date)
    
    // Compute the first and the last days of the month
    let daysInMonth = calendar.rangeOfUnit(.CalendarUnitDay, inUnit: .CalendarUnitMonth, forDate: date)
    
    components.day = daysInMonth.location
    let firstMonthDay = calendar.dateFromComponents(components)!
    let weekdayOfFirstMonthDay = calendar.ordinalityOfUnit(.CalendarUnitWeekday, inUnit: .WeekCalendarUnit, forDate: firstMonthDay)
    
    components.day = daysInMonth.length
    let lastMonthDay = calendar.dateFromComponents(components)!
    let weekdayOfLastMonthDay = calendar.ordinalityOfUnit(.CalendarUnitWeekday, inUnit: .WeekCalendarUnit, forDate: lastMonthDay)
    
    // Fill days and days titles
    daysInfo = []
    let today = DateHelper.dateByClearingTime(ofDate: NSDate())
    let weekdayRange = calendar.maximumRangeOfUnit(.WeekdayCalendarUnit)
    var weekdayOfDate = 0
    let checkForInitial = DateHelper.areDatesEqualByMonths(date1: date, date2: selectedDate)
    let checkForToday = DateHelper.areDatesEqualByMonths(date1: date, date2: today)
    let from = 2 - weekdayOfFirstMonthDay
    let to = daysInMonth.length + daysPerWeek - weekdayOfLastMonthDay
    
    for i in from...to {
      components.day = i
      let date = calendar.dateFromComponents(components)!
      
      if i == from {
        let weekDayComponents = calendar.components(.WeekdayCalendarUnit, fromDate: date)
        weekdayOfDate = weekDayComponents.weekday
      } else {
        if weekdayOfDate > daysPerWeek {
          weekdayOfDate = 1
        }
      }
      let isWeekend = (weekdayOfDate == weekdayRange.location) || (weekdayOfDate == weekdayRange.length)
      weekdayOfDate++
      
      let isInitial = checkForInitial ? DateHelper.areDatesEqualByDays(date1: date, date2: selectedDate) : false
      let isToday = checkForToday ? DateHelper.areDatesEqualByDays(date1: date, date2: today) : false
      let isCurrentMonth = i >= daysInMonth.location && i <= daysInMonth.length
      let dayOrdinalNumber = isCurrentMonth ? i : calendar.ordinalityOfUnit(.CalendarUnitDay, inUnit: .CalendarUnitMonth, forDate: date)
      let title = "\(dayOrdinalNumber)"
      let isFuture = futureDaysEnabled ? false : date.compare(today) == .OrderedDescending
      
      let dayInfo = CalendarViewDayInfo(
        calendarView: self,
        date: date,
        dayOfCurrentMonth: i,
        title: title,
        isWeekend: isWeekend,
        isInitial: isInitial,
        isToday: isToday,
        isCurrentMonth: isCurrentMonth,
        isFuture: isFuture)
      
      daysInfo.append(dayInfo)
    }
  }
  
  private func computeUIAreas() -> (weekdays: CGRect, table: CGRect) {
    let rects = bounds.rectsByDividing(40, fromEdge: .MinYEdge)
    return (weekdays: rects.slice, table: rects.remainder)
  }
  
  private func createDayButtonsInRect(rect: CGRect) {
    let dayButtonRects = computeDayButtonsRects(containerRect: rect)
    assert(dayButtonRects.count == daysInfo.count)
    
    for (index, dayInfo) in enumerate(daysInfo) {
      let dayButtonRect = dayButtonRects[index]
      addDayButton(frame: dayButtonRect, dayInfo: dayInfo)
    }
  }
  
  private func computeDayButtonsRects(#containerRect: CGRect) -> [CGRect] {
    let sizes = computeDayButtonsSizes(rect: containerRect)
    var buttonRects: [CGRect] = []
    
    for rowIndex in 0..<sizes.rowsCount {
      let minY = round(containerRect.origin.y + CGFloat(rowIndex) * sizes.cellSize.height + sizes.padding.dy)
      
      for columnIndex in 0..<sizes.columnsCount {
        let minX = round(containerRect.origin.x + CGFloat(columnIndex) * sizes.cellSize.width + sizes.padding.dx)
        let origin = CGPoint(x: minX, y: minY)
        let buttonRect = CGRect(origin: origin, size: sizes.buttonSize)
        buttonRects.append(buttonRect)
      }
    }
    
    return buttonRects
  }
  
  private func addDayButton(#frame: CGRect, dayInfo: CalendarViewDayInfo) {
    let button = createDayButton(frame: frame, dayInfo: dayInfo)
    button.addTarget(self, action: "dayButtonTapped:", forControlEvents: .TouchUpInside)
    addSubview(button)
    dayButtons.append(button)
    
    if dayInfo.isSelected {
      selectedDayButton = button
    }
  }
  
  func createDayButton(#frame: CGRect, dayInfo: CalendarViewDayInfo) -> CalendarDayButton {
    let button = CalendarDayButton(frame: frame)
    button.dayInfo = dayInfo
    return button
  }
  
  private func createWeekDaysTitlesInRect(rect: CGRect) {
    let weekDaySymbols = calendar.veryShortWeekdaySymbols
    let weekDayRects = computeWeekDayRects(containerRect: rect)
    assert(weekDaySymbols.count == weekDayRects.count)
    weekDayLabels = []
    
    for (index, title) in enumerate(weekDaySymbols) {
      let rect = weekDayRects[index]
      let weekDayLabel = UILabel(frame: rect)
      weekDayLabel.textColor = weekDayTitleTextColor
      weekDayLabel.backgroundColor = UIColor.clearColor()
      weekDayLabel.textAlignment = .Center
      weekDayLabel.text = title as? String
      
      addSubview(weekDayLabel)
      weekDayLabels.append(weekDayLabel)
    }
  }
  
  private func computeWeekDayRects(#containerRect: CGRect) -> [CGRect] {
    var rects: [CGRect] = []
    let labelWidth = containerRect.width / CGFloat(daysPerWeek)
    
    for i in 0..<daysPerWeek {
      let x = containerRect.minX + CGFloat(i) * labelWidth
      var rect = CGRect(x: round(x), y: containerRect.minY, width: ceil(labelWidth), height: containerRect.height)
      rects.append(rect)
    }
    
    return rects
  }
  
  private func layoutControls() {
    let areas = computeUIAreas()
    layoutWeekDayLabels(rect: areas.weekdays)
    layoutDayButtons(rect: areas.table)
  }
  
  private func layoutWeekDayLabels(#rect: CGRect) {
    let weekDayRects = computeWeekDayRects(containerRect: rect)
    assert(weekDayRects.count == weekDayLabels.count)
    
    for (index, label) in enumerate(weekDayLabels) {
      let rect = weekDayRects[index]
      label.frame = rect
    }
  }
  
  private func layoutDayButtons(#rect: CGRect) {
    let dayButtonRects = computeDayButtonsRects(containerRect: rect)
    assert(dayButtonRects.count == dayButtons.count)
    
    for (index, dayButton) in enumerate(dayButtons) {
      let dayButtonRect = dayButtonRects[index]
      dayButton.frame = dayButtonRect
    }
  }
  
  override func drawRect(rect: CGRect) {
    if linesEnabled {
      let areas = computeUIAreas()
      drawLines(rect: areas.table)
    }
  }
  
  private func computeDayButtonsSizes(#rect: CGRect) -> (columnsCount: Int, rowsCount: Int, cellSize: CGSize, buttonSize: CGSize, padding: CGVector) {
    let columnsCount = daysPerWeek
    let rowsCount = daysInfo.count / columnsCount
    
    let columnWidth = rect.width / CGFloat(columnsCount)
    let rowHeight = columnWidth * dayRowHeightScale
    let dy = (rowHeight - columnWidth) / 2 + 4
    let dx = CGFloat(4)
    let buttonWidth = round(columnWidth - dx * 2)
    let buttonHeight = buttonWidth // make strong circle buttons
    
    let cell = CGSize(width: columnWidth, height: rowHeight)
    let button = CGSize(width: buttonWidth, height: buttonHeight)
    let padding = CGVector(dx: dx, dy: dy)
    
    return (columnsCount: columnsCount, rowsCount: rowsCount, cellSize: cell, buttonSize: button, padding: padding)
  }
  
  private func drawLines(#rect: CGRect) {
    let sizes = computeDayButtonsSizes(rect: rect)
    let linePath = UIBezierPath()
    // Take into account scale factor of retina display
    let scaleOffset = (contentScaleFactor > 1) ? 1 / (2 * contentScaleFactor) : 0
    
    for rowIndex in 1..<sizes.rowsCount {
      let y = round(rect.origin.y + CGFloat(rowIndex) * sizes.cellSize.height) + scaleOffset
      let startPoint = CGPoint(x: rect.minX, y: y)
      let endPoint = CGPoint(x: rect.maxX, y: y)
      
      linePath.moveToPoint(startPoint)
      linePath.addLineToPoint(endPoint)
    }
    
    linePath.lineWidth = 1 / contentScaleFactor
    linesColor.setStroke()
    linePath.stroke()
  }
  
  func dayButtonTapped(dayButton: CalendarDayButton) {
    if let date = dayButton.dayInfo?.date {
      if !DateHelper.areDatesEqualByDays(date1: selectedDate, date2: date) {
        selectedDayButton?.dayInfo?.isSelected = false
        dayButton.dayInfo?.isSelected = true
        selectedDayButton = dayButton
      }
      
      selectedDate = date
      delegate?.calendarViewDaySelected(date)
    } else {
      assert(false)
    }
  }
  
  private func updateCalendar() {
    // Remove existing controls
    weekDayLabels = []
    dayButtons = []
    selectedDayButton = nil

    for subview in subviews {
      subview.removeFromSuperview()
    }

    // Create new ones
    createDaysInfo()
    createControls()
  }
  
  private var daysInfo: [CalendarViewDayInfo] = []
  private var weekDayLabels: [UILabel] = []
  private var dayButtons: [CalendarDayButton] = []
  private var selectedDayButton: CalendarDayButton?
  private let calendar = NSCalendar.currentCalendar()

}

private extension UIColor {
  func realColorFromColor(color: UIColor) -> UIColor {
    if isClearColor() && !color.isClearColor() {
      return color
    }
    
    return self
  }
}

class CalendarViewDayInfo {
  let calendarView: CalendarView
  let date: NSDate
  let dayOfCurrentMonth: Int
  let title: String
  let isWeekend: Bool
  let isToday: Bool
  let isCurrentMonth: Bool
  let isFuture: Bool
  
  var isSelected: Bool {
    didSet {
      changeHandler?()
    }
  }
  
  typealias ChangeHandler = () -> Void
  var changeHandler: ChangeHandler?
  
  init(calendarView: CalendarView, date: NSDate, dayOfCurrentMonth: Int, title: String, isWeekend: Bool, isInitial: Bool, isToday: Bool, isCurrentMonth: Bool, isFuture: Bool) {
    self.calendarView = calendarView
    self.date = date
    self.dayOfCurrentMonth = dayOfCurrentMonth
    self.title = title
    self.isWeekend = isWeekend
    self.isSelected = isInitial
    self.isToday = isToday
    self.isCurrentMonth = isCurrentMonth
    self.isFuture = isFuture
  }
  
  func computeColors() -> (text: UIColor, background: UIColor) {
    var result = (text: UIColor.clearColor(), background: UIColor.clearColor())
    
    if isToday {
      result.text = calendarView.todayTextColor
      result.background = calendarView.todayBackgroundColor
    }
    
    if isSelected {
      result.text = result.text.realColorFromColor(calendarView.selectedDayTextColor)
      result.background = result.background.realColorFromColor(calendarView.selectedDayBackgroundColor)
    }
    
    if isWeekend {
      result.text = result.text.realColorFromColor(calendarView.weekendTextColor)
      result.background = result.background.realColorFromColor(calendarView.weekendBackgroundColor)
    }
    
    if result.text.isClearColor() {
      result.text = calendarView.workDayTextColor
    }
    
    if result.background.isClearColor() {
      result.background = calendarView.workDayBackgroundColor
    }
    
    // Make colors more translutent for future days and for days of past month
    if isFuture {
      if !result.text.isClearColor() {
        result.text = result.text.colorWithAlphaComponent(calendarView.futureDaysTransparency)
      }
      
      if !result.background.isClearColor() {
        result.background = result.background.colorWithAlphaComponent(calendarView.futureDaysTransparency)
      }
    } else if !isCurrentMonth {
      if !result.text.isClearColor() {
        result.text = result.text.colorWithAlphaComponent(calendarView.anotherMonthTransparency)
      }
      
      if !result.background.isClearColor() {
        result.background = result.background.colorWithAlphaComponent(calendarView.anotherMonthTransparency)
      }
    }
    
    return result
  }
}

