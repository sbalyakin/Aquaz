//
//  MonthStatisticsViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 05.12.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit
import CoreData

class MonthStatisticsViewController: StyledViewController, MonthStatisticsViewDataSource, CalendarViewDelegate {

  @IBOutlet weak var monthStatisticsView: MonthStatisticsView!
  @IBOutlet weak var monthLabel: UILabel!
  @IBOutlet weak var nextMonthButton: UIButton!

  
  var date: NSDate = Settings.sharedInstance.uiMonthStatisticsDate.value {
    didSet {
      dateWasChanged()
      Settings.sharedInstance.uiMonthStatisticsDate.value = date
    }
  }
  
  private var statisticsBeginDate: NSDate!
  private var statisticsEndDate: NSDate!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    monthStatisticsView.dataSource = self
    monthStatisticsView.delegate = self
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    dateWasChanged()
  }
  
  private func dateWasChanged() {
    computeStatisticsDateRange()
    initMonthLabel()
    initMonthStatisticsView()
    updateSwitchButtons()
  }
  
  @IBAction func switchToPreviousMonth(sender: AnyObject) {
    date = DateHelper.addToDate(date, years: 0, months: -1, days: 0)
  }
  
  @IBAction func switchToNextMonth(sender: AnyObject) {
    date = DateHelper.addToDate(date, years: 0, months: 1, days: 0)
  }
  
  private lazy var dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    let dateFormat = NSDateFormatter.dateFormatFromTemplate("MMMMyyyy", options: 0, locale: NSLocale.currentLocale())
    formatter.dateFormat = dateFormat
    return formatter
    }()

  private func initMonthLabel() {
    let monthTitle = dateFormatter.stringFromDate(statisticsBeginDate)
    monthLabel.text = monthTitle
  }
  
  private func initMonthStatisticsView() {
    let waterIntakes = Intake.fetchGroupedWaterAmounts(beginDate: statisticsBeginDate, endDate: statisticsEndDate, dayOffsetInHours: 0, groupingUnit: .Day, aggregateFunction: .Average, managedObjectContext: managedObjectContext)
    
    let goals = WaterGoal.fetchWaterGoalAmounts(beginDate: statisticsBeginDate, endDate: statisticsEndDate, managedObjectContext: managedObjectContext)
    assert(waterIntakes.count == goals.count)
    
    intakeFractions = []
    
    for (index, waterIntake) in enumerate(waterIntakes) {
      let goal = goals[index]
      var intakeFraction: Double = 0
      if goal > 0 {
        intakeFraction = waterIntake / goal
      } else {
        assert(false)
      }
      intakeFractions.append(intakeFraction)
    }
    
    monthStatisticsView.switchToMonth(date)
  }
  
  func monthStatisticsGetValueForDate(date: NSDate, dayOfCurrentMonth: Int) -> Double {
    if dayOfCurrentMonth < 1 || dayOfCurrentMonth > intakeFractions.count {
      return 0
    }
    
    return intakeFractions[dayOfCurrentMonth - 1]
  }

  func calendarViewDaySelected(date: NSDate) {
    if let dayViewController = storyboard?.instantiateViewControllerWithIdentifier("DayViewController") as? DayViewController {
      dayViewController.mode = .Statistics
      dayViewController.setCurrentDate(date)
      dayViewController.initializesRevealControls = false
      navigationController?.pushViewController(dayViewController, animated: true)
    } else {
      assert(false)
    }
  }
  
  private func computeStatisticsDateRange() {
    let calendar = NSCalendar.currentCalendar()
    let dateComponents = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay | .CalendarUnitTimeZone | .CalendarUnitCalendar, fromDate: date)
    dateComponents.day = 1
    statisticsBeginDate = calendar.dateFromComponents(dateComponents)
    statisticsEndDate = DateHelper.addToDate(statisticsBeginDate, years: 0, months: 1, days: 0)
  }

  private func updateSwitchButtons() {
    let isCurrentMonth = DateHelper.areDatesEqualByMonths(date1: date, date2: NSDate())
    nextMonthButton.enabled = !isCurrentMonth
  }

  private var intakeFractions: [Double] = []

  private lazy var managedObjectContext: NSManagedObjectContext? = {
    if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
      return appDelegate.managedObjectContext
    } else {
      return nil
    }
  }()

}
