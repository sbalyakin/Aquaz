//
//  CalendarView.swift
//  OmegaCalendar
//
//  Created by Sergey Balyakin on 17.03.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

protocol CalendarViewDelegate: class {
  
  func calendarViewDaySelected(dayInfo: CalendarViewDayInfo)
  
  func calendarViewDayWasSwitched(date: NSDate)
  
}

@IBDesignable class CalendarView: UIView {
  
  @IBInspectable var font: UIFont = UIFont.systemFontOfSize(16)
  @IBInspectable var weekDayTitleTextColor: UIColor = UIColor.blackColor()
  @IBInspectable var weekDayTitlesHeightScale: CGFloat = 1
  @IBInspectable var weekDayFont: UIFont = UIFont.systemFontOfSize(14)
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
  @IBInspectable var dayRowHeightScale: CGFloat = 1
  @IBInspectable var markSelectedDay: Bool = true
  
  private var displayedMonthDate: NSDate
  
  var selectedDate: NSDate?
  
  let daysPerWeek: Int = NSCalendar.currentCalendar().maximumRangeOfUnit(.CalendarUnitWeekday).length

  weak var delegate: CalendarViewDelegate?

  private var initialDisplayedMonthDate: NSDate
  private var scrollView: InfiniteScrollView!
  
  override init(frame: CGRect) {
    let startOfMonth = DateHelper.startDateFromDate(NSDate(), calendarUnit: .CalendarUnitMonth)
    initialDisplayedMonthDate = startOfMonth
    displayedMonthDate = startOfMonth
    
    super.init(frame: frame)
    baseInit()
  }
  
  required init(coder aDecoder: NSCoder) {
    let startOfMonth = DateHelper.startDateFromDate(NSDate(), calendarUnit: .CalendarUnitMonth)
    initialDisplayedMonthDate = startOfMonth
    displayedMonthDate = startOfMonth

    super.init(coder: aDecoder)
    baseInit()
  }
  
  func setDisplayedMonthDate(date: NSDate) {
    displayedMonthDate = date
    let monthIndex = calcDeltaMonthsBetweenDates(fromDate: initialDisplayedMonthDate, toDate: displayedMonthDate)
    scrollView.switchToIndex(monthIndex, animated: true)
  }
  
  func getDisplayedMonthDate() -> NSDate {
    return displayedMonthDate
  }
  
  func resetToDisplayMonthDate(date: NSDate) {
    let startOfMonth = DateHelper.startDateFromDate(date, calendarUnit: .CalendarUnitMonth)
    initialDisplayedMonthDate = startOfMonth
    displayedMonthDate = startOfMonth
    refresh()
  }
  
  private func baseInit() {
    scrollView = InfiniteScrollView(frame: bounds)
    scrollView.delegate = self
    addSubview(scrollView)
  }
  
  override func intrinsicContentSize() -> CGSize {
    return CGSizeMake(300, 300)
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    if scrollView.dataSource == nil {
      scrollView.dataSource = self
    }
    
    scrollView.frame = bounds
  }
  
  func refresh() {
    scrollView.refresh()
  }
  
  func switchToMonth(date: NSDate) {
    setDisplayedMonthDate(DateHelper.startDateFromDate(date, calendarUnit: .CalendarUnitMonth))
  }
  
  func switchToNextMonth() {
    setDisplayedMonthDate(DateHelper.addToDate(displayedMonthDate, years:0, months: 1, days: 0))
  }
  
  func switchToPreviousMonth() {
    setDisplayedMonthDate(DateHelper.addToDate(displayedMonthDate, years:0, months: -1, days: 0))
  }
  
  func calcDeltaMonthsBetweenDates(#fromDate: NSDate, toDate: NSDate) -> Int {
    return DateHelper.calcDistanceBetweenDates(fromDate: fromDate, toDate: toDate, calendarUnit: .CalendarUnitMonth)
  }

}

extension CalendarView: InfiniteScrollViewDataSource {

  func infiniteScrollViewNeedsPage(#index: Int) -> UIView {
    let viewContent = createCalendarViewContent()
    
    viewContent.selectedDate = selectedDate
    viewContent.dataSource = self
    viewContent.delegate = delegate
    viewContent.date = DateHelper.addToDate(initialDisplayedMonthDate, years: 0, months: index, days: 0)
    viewContent.backgroundColor = UIColor.clearColor()
    viewContent.weekDayTitleTextColor = weekDayTitleTextColor
    viewContent.workDayTextColor = workDayTextColor
    viewContent.workDayBackgroundColor = workDayBackgroundColor
    viewContent.weekendTextColor = weekendTextColor
    viewContent.weekendBackgroundColor = weekendBackgroundColor
    viewContent.todayTextColor = todayTextColor
    viewContent.todayBackgroundColor = todayBackgroundColor
    viewContent.selectedDayTextColor = selectedDayTextColor
    viewContent.selectedDayBackgroundColor = selectedDayBackgroundColor
    viewContent.anotherMonthTransparency = anotherMonthTransparency
    viewContent.futureDaysTransparency = futureDaysTransparency
    viewContent.futureDaysEnabled = futureDaysEnabled
    viewContent.dayRowHeightScale = dayRowHeightScale
    viewContent.weekDayTitlesHeightScale = weekDayTitlesHeightScale
    viewContent.markSelectedDay = markSelectedDay
    viewContent.font = font
    viewContent.weekDayFont = weekDayFont

    return viewContent
  }
  
  func createCalendarViewContent() -> CalendarContentView {
    return CalendarContentView(frame: bounds)
  }

}

extension CalendarView: InfiniteScrollViewDelegate {

  func infiniteScrollViewPageCanBeRemoved(#index: Int, view: UIView?) {
    // Do nothing, because a calendar view does not manage its content views
  }
  
  func infinteScrollViewPageWasSwitched(#pageIndex: Int) {
    displayedMonthDate = DateHelper.addToDate(initialDisplayedMonthDate, years: 0, months: pageIndex, days: 0)

    if let delegate = delegate {
      delegate.calendarViewDayWasSwitched(displayedMonthDate)
    }
  }
  
}

extension CalendarView: CalendarViewContentDataSource {
  
  func createCalendarViewDaysInfoForMonth(#calendarContentView: CalendarContentView, monthDate: NSDate) -> [CalendarViewDayInfo] {
    return CalendarViewDataSource.createCalendarViewDaysInfoForMonth(monthDate)
  }
  
}

