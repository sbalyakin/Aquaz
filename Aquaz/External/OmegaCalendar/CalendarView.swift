//
//  CalendarView.swift
//  OmegaCalendar
//
//  Created by Sergey Balyakin on 17.03.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

protocol CalendarViewDelegate: class {
  
  func calendarViewDaySelected(_ dayInfo: CalendarViewDayInfo)
  
  func calendarViewDayWasSwitched(_ date: Date)
  
}

@IBDesignable class CalendarView: UIView, CalendarViewContentDataSource {
  
  @IBInspectable var font: UIFont = UIFont.systemFont(ofSize: 16)
  @IBInspectable var weekDayTitleTextColor: UIColor = UIColor.black
  @IBInspectable var weekDayTitlesHeightScale: CGFloat = 1
  @IBInspectable var weekDayFont: UIFont = UIFont.systemFont(ofSize: 14)
  @IBInspectable var workDayTextColor: UIColor = UIColor.black
  @IBInspectable var workDayBackgroundColor: UIColor = UIColor.clear
  @IBInspectable var weekendTextColor: UIColor = UIColor.red
  @IBInspectable var weekendBackgroundColor: UIColor = UIColor.clear
  @IBInspectable var todayTextColor: UIColor = UIColor.white
  @IBInspectable var todayBackgroundColor: UIColor = UIColor.red
  @IBInspectable var selectedDayTextColor: UIColor = UIColor.blue
  @IBInspectable var selectedDayBackgroundColor: UIColor = UIColor.clear
  @IBInspectable var anotherMonthTransparency: CGFloat = 0.4
  @IBInspectable var futureDaysTransparency: CGFloat = 0.4
  @IBInspectable var futureDaysEnabled: Bool = false
  @IBInspectable var dayRowHeightScale: CGFloat = 1
  @IBInspectable var markSelectedDay: Bool = true
  
  fileprivate var displayedMonthDate: Date
  
  var selectedDate: Date?
  
  let daysPerWeek = DateHelper.daysPerWeek()

  weak var delegate: CalendarViewDelegate?

  fileprivate var initialDisplayedMonthDate: Date
  fileprivate var scrollView: InfiniteScrollView!
  
  override init(frame: CGRect) {
    let startOfMonth = DateHelper.startOfMonth(Date())
    initialDisplayedMonthDate = startOfMonth
    displayedMonthDate = startOfMonth
    
    super.init(frame: frame)
    baseInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    let startOfMonth = DateHelper.startOfMonth(Date())
    initialDisplayedMonthDate = startOfMonth
    displayedMonthDate = startOfMonth

    super.init(coder: aDecoder)
    baseInit()
  }
  
  func setDisplayedMonthDate(_ date: Date) {
    displayedMonthDate = date
    let monthIndex = calcDeltaMonthsBetweenDates(fromDate: initialDisplayedMonthDate, toDate: displayedMonthDate)
    scrollView.switchToIndex(monthIndex, animated: true)
  }
  
  func getDisplayedMonthDate() -> Date {
    return displayedMonthDate
  }
  
  func resetToDisplayMonthDate(_ date: Date) {
    let startOfMonth = DateHelper.startOfMonth(date)
    initialDisplayedMonthDate = startOfMonth
    displayedMonthDate = startOfMonth
    refresh()
  }
  
  fileprivate func baseInit() {
    scrollView = InfiniteScrollView(frame: bounds)
    scrollView.delegate = self
    addSubview(scrollView)
  }
  
  override var intrinsicContentSize : CGSize {
    return CGSize(width: 300, height: 300)
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
  
  func switchToMonth(_ date: Date) {
    setDisplayedMonthDate(DateHelper.startOfMonth(date))
  }
  
  func switchToNextMonth() {
    setDisplayedMonthDate(DateHelper.nextMonthFrom(displayedMonthDate))
  }
  
  func switchToPreviousMonth() {
    setDisplayedMonthDate(DateHelper.previousMonthBefore(displayedMonthDate))
  }
  
  func calcDeltaMonthsBetweenDates(fromDate: Date, toDate: Date) -> Int {
    return DateHelper.calendarMonths(fromDate: fromDate, toDate: toDate)
  }

  func createCalendarViewDaysInfoForMonth(calendarContentView: CalendarContentView, monthDate: Date) -> [CalendarViewDayInfo] {
    return CalendarViewDataSource.createCalendarViewDaysInfoForMonth(monthDate)
  }

}

extension CalendarView: InfiniteScrollViewDataSource {

  func infiniteScrollViewNeedsPage(index: Int) -> UIView {
    let viewContent = createCalendarViewContent()
    
    viewContent.selectedDate = selectedDate
    viewContent.dataSource = self
    viewContent.delegate = delegate
    viewContent.date = DateHelper.addToDate(initialDisplayedMonthDate, years: 0, months: index, days: 0)
    viewContent.backgroundColor = backgroundColor
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
  
  @objc func createCalendarViewContent() -> CalendarContentView {
    return CalendarContentView(frame: bounds)
  }

}

extension CalendarView: InfiniteScrollViewDelegate {

  func infiniteScrollViewPageCanBeRemoved(index: Int, view: UIView?) {
    // Do nothing, because a calendar view does not manage its content views
  }
  
  func infiniteScrollViewPageWasSwitched(pageIndex: Int) {
    displayedMonthDate = DateHelper.addToDate(initialDisplayedMonthDate, years: 0, months: pageIndex, days: 0)
    delegate?.calendarViewDayWasSwitched(displayedMonthDate)
  }
  
}
