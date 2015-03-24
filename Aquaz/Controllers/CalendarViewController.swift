//
//  CalendarViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 11.11.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController {

  var date: NSDate!
  
  var dayViewController: DayViewController!
  
  @IBOutlet weak var calendarView: CalendarView!
  @IBOutlet weak var currentMonthLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    calendarView.selectedDate = date
    calendarView.delegate = self
    calendarView.switchToMonth(date)
    updateUI(initial: true)
  }
  
  private lazy var dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    let dateFormat = NSDateFormatter.dateFormatFromTemplate("MMMMyyyy", options: 0, locale: NSLocale.currentLocale())
    formatter.dateFormat = dateFormat
    return formatter
  }()
  
  private func updateUI(#initial: Bool) {
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
    navigationController?.popViewControllerAnimated(true)
  }
  
  @IBAction func cancelWasTapped(sender: UIBarButtonItem) {
    navigationController?.popViewControllerAnimated(true)
  }
}

extension CalendarViewController: CalendarViewDelegate {

  func calendarViewDaySelected(dayInfo: CalendarViewDayInfo) {
    dayViewController.setCurrentDate(dayInfo.date)
    navigationController?.popViewControllerAnimated(true)
  }

  func calendarViewDayWasSwitched(date: NSDate) {
    self.date = date
    updateUI(initial: false)
  }

}