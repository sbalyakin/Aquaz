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
    
    createCustomNavigationTitle()
  }
  
  func createCustomNavigationTitle() {
    // TODO: Remove magical 100 value and find another way to calculate proper rectangle for the title view
    let titleViewRect = navigationController!.navigationBar.frame.rectByInsetting(dx: 100, dy: 0)
    
    // Container view is used for adjusting inner label by offsetting inside it
    // without changing global titleVerticalPositionAdjustmentForBarMetrics,
    // because if change it on view appearing/disappearing there will be noticable title item jumping.
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

}
