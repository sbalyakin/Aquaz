//
//  CalendarViewController.swift
//  Water Me
//
//  Created by Sergey Balyakin on 11.11.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController, CalendarViewDelegate {

  var date: NSDate!
  
  var dayViewController: DayViewController!
  
  @IBOutlet weak var calendarView: CalendarView!
  @IBOutlet weak var currentMonthLabel: UILabel!
  @IBOutlet weak var nextMonthButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    calendarView.selectedDate = date
    calendarView.delegate = self

    switchToDate(date)
  }
  
  private func switchToDate(date: NSDate) {
    calendarView.switchToMonth(date)
    
    let formatter = NSDateFormatter()
    let dateFormat = NSDateFormatter.dateFormatFromTemplate("MMMMYYYY", options: 0, locale: NSLocale.currentLocale())
    formatter.dateFormat = dateFormat
    currentMonthLabel.text = formatter.stringFromDate(date)
    
    let isCurrentMonth = DateHelper.areDatesEqualByMonths(date1: date, date2: NSDate())
    nextMonthButton.enabled = !isCurrentMonth
  }
  
  @IBAction func switchToNextMonth(sender: AnyObject) {
    date = DateHelper.addToDate(date, years: 0, months: 1, days: 0)
    switchToDate(date)
  }
  
  @IBAction func switchToPreviousMonth(sender: AnyObject) {
    date = DateHelper.addToDate(date, years: 0, months: -1, days: 0)
    switchToDate(date)
  }
  
  func calendarViewDaySelected(date: NSDate) {
    dayViewController.setCurrentDate(date, updateControl: true)
    navigationController!.popViewControllerAnimated(true)
  }
  
  @IBAction func todayDidSelected(sender: AnyObject) {
    let adjustedDate = DateHelper.dateByJoiningDateTime(datePart: NSDate(), timePart: dayViewController.getCurrentDate())
    dayViewController.setCurrentDate(adjustedDate, updateControl: true)
    navigationController!.popViewControllerAnimated(true)
  }
  
}
