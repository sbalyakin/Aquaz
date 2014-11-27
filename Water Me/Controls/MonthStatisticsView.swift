//
//  MonthStatisticsView.swift
//  Water Me
//
//  Created by Sergey Balyakin on 26.11.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

protocol MonthStatisticsViewDelegate {
  func monthStatisticsDaySelected(date: NSDate)
}

protocol MonthStatisticsViewDataSource {
  func monthStatisticsGetConsumptionFractionForDate(date: NSDate) -> Double
}

@IBDesignable class MonthStatisticsView: UIView, UITableViewDataSource, UITableViewDelegate, MonthStatisticsTableViewCellDelegate {
  
  @IBInspectable var weekDaysTextColor: UIColor = UIColor.blackColor()
  @IBInspectable var workDayTextColor: UIColor = UIColor.blackColor()
  @IBInspectable var workDayBackgroundColor: UIColor = UIColor.clearColor()
  @IBInspectable var weekendTextColor: UIColor = UIColor.redColor()
  @IBInspectable var weekendBackgroundColor: UIColor = UIColor.clearColor()
  @IBInspectable var todayTextColor: UIColor = UIColor.whiteColor()
  @IBInspectable var todayBackgroundColor: UIColor = UIColor.redColor()
  @IBInspectable var selectedDayTextColor: UIColor = UIColor.blueColor()
  @IBInspectable var selectedDayBackgroundColor: UIColor = UIColor.clearColor()
  @IBInspectable var dayConsumptionColor: UIColor = UIColor(red: 80/255, green: 184/255, blue: 187/255, alpha: 1.0)
  @IBInspectable var dayConsumptionBackgroundColor: UIColor = UIColor(red: 80/255, green: 184/255, blue: 187/255, alpha: 0.1)
  @IBInspectable var dayConsumptionLineWidth: CGFloat = 4
  @IBInspectable var anotherMonthTransparency: CGFloat = 0.4
  @IBInspectable var futureDaysTransparency: CGFloat = 0.1
  @IBInspectable var futureDaysEnabled: Bool = false
  
  /// Date of month displayed in the calendar
  var displayedMonthDate: NSDate = NSDate() {
    didSet {
      // Clean specified date and adjust it to the first day
      let components = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay, fromDate: displayedMonthDate)
      components.day = 1
      displayedMonthDate = calendar.dateFromComponents(components)!
      
      updateCalendar()
      tableView.reloadData()
    }
  }
  
  var selectedDate: NSDate = NSDate()
  
  var delegate: MonthStatisticsViewDelegate?
  var dataSource: MonthStatisticsViewDataSource?
  
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
    initControls()
  }
  
  func dayButtonTapped(dayButton: MonthStatisticsDayButton) {
    assert(dayButton.dayInfo != nil)
    
    let date = dayButton.dayInfo!.date
    
    if !DateHelper.areDatesEqualByDays(date1: selectedDate, date2: date) {
      if let selectedDayButton = selectedDayButton {
        selectedDayButton.dayInfo!.isSelected = false
      }

      dayButton.dayInfo!.isSelected = true
      selectedDayButton = dayButton
    }
    
    selectedDate = date
    
    if let delegate = delegate {
      delegate.monthStatisticsDaySelected(date)
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    if tableView == nil {
      initControls()
    } else {
      layoutControls()
    }
  }
  
  private func layoutControls() {
    let areas = computeUIAreas()
    
    tableView.frame = areas.table
    
    let weekDayRects = computeWeekDayRects(containerRect: areas.weekdays)
    assert(weekDayRects.count == weekDayLabels.count)
    for (index, label) in enumerate(weekDayLabels) {
      let rect = weekDayRects[index]
      label.frame = rect
    }
  }
  
  func switchToNextMonth() {
    displayedMonthDate = DateHelper.addToDate(displayedMonthDate, years:0, months: 1, days: 0)
  }
  
  func switchToPreviousMonth() {
    displayedMonthDate = DateHelper.addToDate(displayedMonthDate, years:0, months: -1, days: 0)
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return days.count / daysPerWeek
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(tableCellIdentifier, forIndexPath: indexPath) as MonthStatisticsTableViewCell
    cell.backgroundColor = UIColor.clearColor()
    cell.selectionStyle = .None
    cell.delegate = self
    
    // Remove separators gaps
    if cell.respondsToSelector("setSeparatorInset:") {
      cell.separatorInset = UIEdgeInsetsZero
    }
    if cell.respondsToSelector("setLayoutMargins:") {
      cell.layoutMargins = UIEdgeInsetsZero
    }
    
    for i in 0..<daysPerWeek {
      let dayIndex = indexPath.row * daysPerWeek + i
      let dayInfo = days[dayIndex]
      let dayButton = cell.dayButtons[i]
      dayButton.dayInfo = dayInfo
      if dayInfo.isSelected {
        selectedDayButton = dayButton
      }
    }
    
    return cell
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 0.01
  }
  
  private func computeDays(date: NSDate) {
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
    days = []
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
      let consumptionFraction = requestForConsumptionFractionForDate(date)
      
      let dayInfo = DayInfo(
        monthStatisticsView: self,
        date: date,
        title: title,
        consumptionFraction: consumptionFraction,
        isWeekend: isWeekend,
        isInitial: isInitial,
        isToday: isToday,
        isCurrentMonth: isCurrentMonth,
        isFuture: isFuture)
      
      days.append(dayInfo)
    }
  }
  
  private func initControls() {
    let areas = computeUIAreas()
    
    // Create table view
    tableView = UITableView(frame: areas.table, style: .Grouped)
    tableView.registerClass(MonthStatisticsTableViewCell.self, forCellReuseIdentifier: tableCellIdentifier)
    tableView.dataSource = self
    tableView.delegate = self
    tableView.alwaysBounceVertical = false
    tableView.backgroundColor = UIColor.clearColor()
    
    // Remove separators gaps
    if self.tableView.respondsToSelector("setSeparatorInset:") {
      self.tableView.separatorInset = UIEdgeInsetsZero
    }
    if self.tableView.respondsToSelector("setLayoutMargins:") {
      self.tableView.layoutMargins = UIEdgeInsetsZero
    }
    
    //self.tableView.layoutIfNeeded()
    
    addSubview(tableView)
    updateCalendar()
    
    // Create weekdays titles
    let weekDaySymbols = calendar.veryShortWeekdaySymbols
    let weekDayRects = computeWeekDayRects(containerRect: areas.weekdays)
    assert(weekDaySymbols.count == weekDayRects.count)
    
    for (index, title) in enumerate(weekDaySymbols) {
      let rect = weekDayRects[index]
      let weekDayLabel = UILabel(frame: rect)
      weekDayLabel.textColor = weekDaysTextColor
      weekDayLabel.backgroundColor = UIColor.clearColor()
      weekDayLabel.textAlignment = .Center
      weekDayLabel.text = title as? String
      
      addSubview(weekDayLabel)
      weekDayLabels.append(weekDayLabel)
    }
  }
  
  private func computeUIAreas() -> (weekdays: CGRect, table: CGRect) {
    let rects = bounds.rectsByDividing(40, fromEdge: .MinYEdge)
    return (weekdays: rects.slice, table: rects.remainder)
  }
  
  private func computeWeekDayRects(#containerRect: CGRect) -> [CGRect] {
    var rects: [CGRect] = []
    let labelWidth = containerRect.width / CGFloat(daysPerWeek)
    
    for i in 0..<daysPerWeek {
      let x = containerRect.minX + CGFloat(i) * labelWidth
      var rect = CGRectMake(trunc(x), containerRect.minY, ceil(labelWidth), containerRect.height)
      rects.append(rect)
    }
    
    return rects
  }
  
  private func updateCalendar() {
    computeDays(displayedMonthDate)
    selectedDayButton = nil
  }
  
  private func requestForConsumptionFractionForDate(date: NSDate) -> Double {
    #if TARGET_INTERFACE_BUILDER
      return 0.5
    #else
      if let dataSource = dataSource {
        return dataSource.monthStatisticsGetConsumptionFractionForDate(date)
      }
      return 0
    #endif
  }
  
  class DayInfo {
    let monthStatisticsView: MonthStatisticsView
    let date: NSDate
    let title: String
    let consumptionFraction: Double
    let isWeekend: Bool
    let isToday: Bool
    let isCurrentMonth: Bool
    let isFuture: Bool

    var isSelected: Bool {
      didSet {
        if let changeHandler = changeHandler {
          changeHandler()
        }
      }
    }

    typealias ChangeHandler = () -> Void
    var changeHandler: ChangeHandler?
    
    init(monthStatisticsView: MonthStatisticsView, date: NSDate, title: String, consumptionFraction: Double, isWeekend: Bool, isInitial: Bool, isToday: Bool, isCurrentMonth: Bool, isFuture: Bool) {
      self.monthStatisticsView = monthStatisticsView
      self.date = date
      self.title = title
      self.consumptionFraction = consumptionFraction
      self.isWeekend = isWeekend
      self.isSelected = isInitial
      self.isToday = isToday
      self.isCurrentMonth = isCurrentMonth
      self.isFuture = isFuture
    }
    
    func computeColors() -> (text: UIColor, background: UIColor) {
      var result = (text: UIColor.clearColor(), background: UIColor.clearColor())
      
      if isToday {
        result.text = monthStatisticsView.todayTextColor
        result.background = monthStatisticsView.todayBackgroundColor
      }
      
      if isSelected {
        if result.text == UIColor.clearColor() {
          result.text = monthStatisticsView.selectedDayTextColor
        }
        
        if result.background == UIColor.clearColor() {
          result.background = monthStatisticsView.selectedDayBackgroundColor
        }
      }
      
      if isWeekend {
        if result.text == UIColor.clearColor() {
          result.text = monthStatisticsView.weekendTextColor
        }
        
        if result.background == UIColor.clearColor() {
          result.background = monthStatisticsView.weekendBackgroundColor
        }
      }
      
      if result.text == UIColor.clearColor() {
        result.text = monthStatisticsView.workDayTextColor
      }
      
      if result.background == UIColor.clearColor() {
        result.background = monthStatisticsView.workDayBackgroundColor
      }
      
      // Make colors more translutent for future days and for days of past month
      if isFuture {
        if result.text != UIColor.clearColor() {
          result.text = result.text.colorWithAlphaComponent(monthStatisticsView.futureDaysTransparency)
        }
        
        if result.background != UIColor.clearColor() {
          result.background = result.background.colorWithAlphaComponent(monthStatisticsView.futureDaysTransparency)
        }
      } else if !isCurrentMonth {
        if result.text != UIColor.clearColor() {
          result.text = result.text.colorWithAlphaComponent(monthStatisticsView.anotherMonthTransparency)
        }
        
        if result.background != UIColor.clearColor() {
          result.background = result.background.colorWithAlphaComponent(monthStatisticsView.anotherMonthTransparency)
        }
      }
      
      return result
    }
  }
  
  private var days: [DayInfo] = []
  private var tableView: UITableView!
  private var weekDayLabels: [UILabel] = []
  private var selectedDayButton: MonthStatisticsDayButton?
  
  private let calendar = NSCalendar.currentCalendar()
  let daysPerWeek: Int = NSCalendar.currentCalendar().maximumRangeOfUnit(.WeekdayCalendarUnit).length
  private let tableCellIdentifier = "MonthStatisticsTableViewCell"
  
}
