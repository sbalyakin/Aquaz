//
//  CalendarView.swift
//  Water Me
//
//  Created by Sergey Balyakin on 10.11.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

protocol CalendarViewDelegate {
  func calendarCurrentDayChanged(date: NSDate)
}

@IBDesignable class CalendarView: UIView, UITableViewDataSource, UITableViewDelegate, DaySelectionDelegate {

  @IBInspectable var headerTextColor: UIColor = UIColor.blackColor()
  @IBInspectable var workDayTextColor: UIColor = UIColor.blackColor()
  @IBInspectable var workDayBackgroundColor: UIColor = UIColor.clearColor()
  @IBInspectable var weekendTextColor: UIColor = UIColor.redColor()
  @IBInspectable var weekendBackgroundColor: UIColor = UIColor.clearColor()
  @IBInspectable var todayTextColor: UIColor = UIColor.whiteColor()
  @IBInspectable var todayBackgroundColor: UIColor = UIColor.redColor()
  @IBInspectable var initialDayTextColor: UIColor = UIColor.blueColor()
  @IBInspectable var initialDayBackgroundColor: UIColor = UIColor.clearColor()
  @IBInspectable var anotherMonthTransparency: CGFloat = 0.4
  @IBInspectable var futureTransparency: CGFloat = 0.1
  @IBInspectable var disableFutureDays: Bool = true
  
  /// Date of month displayed in the calendar
  var displayedMonthDate: NSDate = NSDate() {
    didSet {
      // Clean specified date and adjust it to the first day
      let components = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay, fromDate: displayedMonthDate)
      components.day = 1
      displayedMonthDate = calendar.dateFromComponents(components)!
      
      updateCalendar()
    }
  }
  
  var delegate: CalendarViewDelegate? = nil
  
  /// Current selected date of the calendar
  var currentDate: NSDate = NSDate()
  
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
    initControls()
  }
  
  override func prepareForInterfaceBuilder() {
    initControls()
  }

  func currentDayWasChanged(date: NSDate) {
    currentDate = date
    if let delegate = delegate {
      delegate.calendarCurrentDayChanged(date)
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
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
    let cell = tableView.dequeueReusableCellWithIdentifier(tableCellIdentifier, forIndexPath: indexPath) as CalendarTableViewCell
    cell.backgroundColor = UIColor.clearColor()
    cell.selectionStyle = .None
    cell.daySelectionDelegate = self
    
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
    let checkForInitial = DateHelper.areDatesEqualByMonths(date1: date, date2: currentDate)
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
      
      let isInitial = checkForInitial ? DateHelper.areDatesEqualByDays(date1: date, date2: currentDate) : false
      let isToday = checkForToday ? DateHelper.areDatesEqualByDays(date1: date, date2: today) : false
      let isCurrentMonth = i >= daysInMonth.location && i <= daysInMonth.length
      let dayOrdinalNumber = isCurrentMonth ? i : calendar.ordinalityOfUnit(.CalendarUnitDay, inUnit: .CalendarUnitMonth, forDate: date)
      let title = "\(dayOrdinalNumber)"
      let isFuture = disableFutureDays ? date.compare(today) == .OrderedDescending : false
      
      let dayInfo = DayInfo(calendarView: self,
                            date: date,
                            title: title,
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
    tableView.registerClass(CalendarTableViewCell.self, forCellReuseIdentifier: tableCellIdentifier)
    tableView.dataSource = self
    tableView.delegate = self
    tableView.alwaysBounceVertical = false
    tableView.backgroundColor = backgroundColor
    
    // Remove separators gaps
    if self.tableView.respondsToSelector("setSeparatorInset:") {
      self.tableView.separatorInset = UIEdgeInsetsZero
    }
    if self.tableView.respondsToSelector("setLayoutMargins:") {
      self.tableView.layoutMargins = UIEdgeInsetsZero
    }
    
    self.tableView.layoutIfNeeded()
    
    addSubview(tableView)
    updateCalendar()
    
    // Create weekdays titles
    let weekDaySymbols = calendar.veryShortWeekdaySymbols
    
    for title in weekDaySymbols {
      let weekDayLabel = UILabel()
      weekDayLabel.textColor = headerTextColor
      weekDayLabel.backgroundColor = tableView.backgroundColor
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
    tableView.reloadData()
  }
  
  class DayInfo {
    let calendarView: CalendarView
    let date: NSDate
    let title: String
    let isWeekend: Bool
    let isInitial: Bool
    let isToday: Bool
    let isCurrentMonth: Bool
    let isFuture: Bool
    
    init(calendarView: CalendarView, date: NSDate, title: String, isWeekend: Bool, isInitial: Bool, isToday: Bool, isCurrentMonth: Bool, isFuture: Bool) {
      self.calendarView = calendarView
      self.date = date
      self.title = title
      self.isWeekend = isWeekend
      self.isInitial = isInitial
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
      
      if isInitial {
        if result.text == UIColor.clearColor() {
          result.text = calendarView.initialDayTextColor
        }
        
        if result.background == UIColor.clearColor() {
          result.background = calendarView.initialDayBackgroundColor
        }
      }
      
      if isWeekend {
        if result.text == UIColor.clearColor() {
          result.text = calendarView.weekendTextColor
        }
        
        if result.background == UIColor.clearColor() {
          result.background = calendarView.weekendBackgroundColor
        }
      }
      
      if result.text == UIColor.clearColor() {
        result.text = calendarView.workDayTextColor
      }
      
      if result.background == UIColor.clearColor() {
        result.background = calendarView.workDayBackgroundColor
      }

      // Make colors more translutent for future days and for days of past month
      if isFuture {
        if result.text != UIColor.clearColor() {
          result.text = result.text.colorWithAlphaComponent(calendarView.futureTransparency)
        }
        
        if result.background != UIColor.clearColor() {
          result.background = result.background.colorWithAlphaComponent(calendarView.futureTransparency)
        }
      } else if !isCurrentMonth {
        if result.text != UIColor.clearColor() {
          result.text = result.text.colorWithAlphaComponent(calendarView.anotherMonthTransparency)
        }
        
        if result.background != UIColor.clearColor() {
          result.background = result.background.colorWithAlphaComponent(calendarView.anotherMonthTransparency)
        }
      }
      
      return result
    }
  }
  
  private typealias MonthDays = [DayInfo]
  
  private var months: [MonthDays] = []
  private var days: [DayInfo] = []
  private var tableView: UITableView!
  private var weekDayLabels: [UILabel] = []

  private let calendar = NSCalendar.currentCalendar()
  let daysPerWeek: Int = NSCalendar.currentCalendar().maximumRangeOfUnit(.WeekdayCalendarUnit).length
  private let tableCellIdentifier = "CalendarDayCell"

}
