//
//  CalendarViewController.swift
//  Water Me
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
  @IBOutlet weak var nextMonthButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    calendarView.currentDate = date
    switchToDate(date)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    setupNavigationBar()
  }
  
  func setupNavigationBar() {
    previousTitleView = navigationItem.titleView

    // Customize navigation bar
    let titleViewRect = navigationController!.navigationBar.frame.rectByInsetting(dx: 100, dy: 0)
    let titleView = UIView(frame: titleViewRect)
    
    let verticalAdjustment = navigationController!.navigationBar.titleVerticalPositionAdjustmentForBarMetrics(.Default)
    let titleLabelRect = titleView.bounds.rectByOffsetting(dx: 0, dy: -verticalAdjustment)
    let titleLabel = UILabel(frame: titleLabelRect)
    titleLabel.autoresizingMask = .FlexibleWidth
    titleLabel.backgroundColor = UIColor.clearColor()
    titleLabel.text = navigationItem.title
    titleLabel.font = UIFont.boldSystemFontOfSize(18)
    titleLabel.textAlignment = .Center
    titleView.addSubview(titleLabel)
    
    navigationItem.titleView = titleView
  }
  
  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    navigationItem.titleView = previousTitleView
  }
  
  private func switchToDate(date: NSDate) {
    calendarView.displayedMonthDate = date
    
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
  
  @IBAction func dayDidSelected(sender: CalendarView) {
    dayViewController.currentDate = sender.currentDate
    navigationController!.popViewControllerAnimated(true)
  }
  
  @IBAction func todayDidSelected(sender: AnyObject) {
    let adjustedDate = DateHelper.dateByJoiningDateTime(datePart: NSDate(), timePart: dayViewController.currentDate)
    dayViewController.currentDate = adjustedDate
    navigationController!.popViewControllerAnimated(true)
  }
  
  private var previousTitleView: UIView!
}
