//
//  CalendarViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 11.11.14.
//  Copyright © 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController {

  var date: NSDate!
  
  weak var dayViewController: DayViewController!
  
  @IBOutlet weak var calendarView: CalendarView!
  @IBOutlet weak var currentMonthLabel: UILabel!

  private lazy var dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    let dateFormat = NSDateFormatter.dateFormatFromTemplate("MMMMyyyy", options: 0, locale: NSLocale.currentLocale())
    formatter.dateFormat = dateFormat
    return formatter
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    
    NSNotificationCenter.defaultCenter().addObserver(
      self,
      selector: #selector(self.preferredContentSizeChanged),
      name: UIContentSizeCategoryDidChangeNotification,
      object: nil)
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  private func setupUI() {
    UIHelper.applyStyleToViewController(self)

    calendarView.backgroundColor = StyleKit.pageBackgroundColor
    calendarView.workDayTextColor = StyleKit.calendarWorkDayTextColor
    calendarView.weekendBackgroundColor = StyleKit.calendarWeekendBackgroundColor
    calendarView.weekendTextColor = StyleKit.calendarWeekendTextColor
    calendarView.weekDayTitleTextColor = StyleKit.calendarWeekDayTitleTextColor
    calendarView.selectedDayTextColor = StyleKit.calendarSelectedDayTextColor
    calendarView.selectedDayBackgroundColor = StyleKit.calendarSelectedDayBackgroundColor
    calendarView.todayBackgroundColor = StyleKit.calendarTodayBackgroundColor
    calendarView.todayTextColor = StyleKit.calendarTodayTextColor
    calendarView.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
    calendarView.weekDayFont = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
    calendarView.futureDaysTransparency = 0.1
    calendarView.resetToDisplayMonthDate(date)
    calendarView.selectedDate = date
    calendarView.delegate = self
    
    currentMonthLabel.backgroundColor = StyleKit.pageBackgroundColor // remove blending
    
    updateUI(initial: true)
  }
  
  func preferredContentSizeChanged() {
    currentMonthLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
    calendarView.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
    calendarView.weekDayFont = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
    calendarView.refresh()
    view.invalidateIntrinsicContentSize()
  }
  
  private func updateUI(initial initial: Bool) {
    let title = dateFormatter.stringFromDate(date)
    
    if initial {
      currentMonthLabel.text = title
    } else {
      currentMonthLabel.setTextWithAnimation(title)
    }
  }

  @IBAction func switchToNextMonth(sender: AnyObject) {
    date = DateHelper.addToDate(date, years: 0, months: 1, days: 0)
    calendarView.switchToNextMonth()
    updateUI(initial: false) // Updating month label before scroll view animation is finished
  }
  
  @IBAction func switchToPreviousMonth(sender: AnyObject) {
    date = DateHelper.addToDate(date, years: 0, months: -1, days: 0)
    calendarView.switchToPreviousMonth()
    updateUI(initial: false) // Updating month label before scroll view animation is finished
  }
  
  @IBAction func todayDidSelected(sender: AnyObject) {
    let date = DateHelper.dateByJoiningDateTime(datePart: NSDate(), timePart: dayViewController.getCurrentDate())
    dayViewController.setCurrentDate(date)
    navigationController?.dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func cancelWasTapped(sender: UIBarButtonItem) {
    navigationController?.dismissViewControllerAnimated(true, completion: nil)
  }
}

extension CalendarViewController: CalendarViewDelegate {

  func calendarViewDaySelected(dayInfo: CalendarViewDayInfo) {
    dayViewController.setCurrentDate(dayInfo.date)
    navigationController?.dismissViewControllerAnimated(true, completion: nil)
  }

  func calendarViewDayWasSwitched(date: NSDate) {
    self.date = date
    updateUI(initial: false)
  }

}