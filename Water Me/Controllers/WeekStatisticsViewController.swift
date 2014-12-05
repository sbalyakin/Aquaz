//
//  WeekStatisticsViewController.swift
//  Water Me
//
//  Created by Sergey Balyakin on 01.12.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation

class WeekStatisticsViewController: UIViewController, WeekStatisticsViewDelegate {
  
  @IBOutlet weak var weekStatisticsView: WeekStatisticsView!
  @IBOutlet weak var datePeriodLabel: UILabel!
  @IBOutlet weak var nextWeekButton: UIButton!
  
  var date: NSDate = NSDate() {
    didSet {
      computeStatisticsDateRange()
      initDatePeriodLabel()
      initWeekStatisticsView()
      updateSwitchButtons()
    }
  }
  
  private var statisticsBeginDate: NSDate!
  private var statisticsEndDate: NSDate!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    weekStatisticsView.delegate = self
    // TODO: Specify from the settings
    date = NSDate()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  func weekStatisticsViewDaySelected(dayIndex: Int) {
    let selectedDate = DateHelper.addToDate(statisticsBeginDate, years: 0, months: 0, days: dayIndex)
    
    let dayViewController = storyboard!.instantiateViewControllerWithIdentifier("DayViewController") as DayViewController
    dayViewController.setCurrentDate(selectedDate, updateControl: false)
    dayViewController.initializesRevealControls = false
    
    navigationController!.pushViewController(dayViewController, animated: true)
  }

  @IBAction func switchToPreviousWeek(sender: AnyObject) {
    date = DateHelper.addToDate(date, years: 0, months: 0, days: -7)
  }
  
  @IBAction func switchToNextWeek(sender: AnyObject) {
    date = DateHelper.addToDate(date, years: 0, months: 0, days: 7)
  }

  private func initDatePeriodLabel() {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateStyle = .MediumStyle
    dateFormatter.timeStyle = .NoStyle
    let maxDate = DateHelper.addToDate(statisticsEndDate, years: 0, months: 0, days: -1)
    let fromDateTitle = dateFormatter.stringFromDate(statisticsBeginDate)
    let toDateTitle = dateFormatter.stringFromDate(maxDate)
    let title = "\(fromDateTitle) - \(toDateTitle)"
    datePeriodLabel.text = title
  }

  private func initWeekStatisticsView() {
    let waterIntakes = Consumption.fetchGroupedWaterIntake(beginDate: statisticsBeginDate, endDate: statisticsEndDate, dayOffsetInHours: 0, groupingUnit: .Day, computeAverageAmounts: true)
    assert(waterIntakes.count == 7)
    
    let goals = ConsumptionRate.fetchConsumptionRateAmounts(beginDate: statisticsBeginDate, endDate: statisticsEndDate)
    assert(waterIntakes.count == 7)
    
    var statisticsItems: [WeekStatisticsView.ItemType] = []
    
    for (index, waterIntake) in enumerate(waterIntakes) {
      let goal = goals[index]
      let item: WeekStatisticsView.ItemType = (value: CGFloat(waterIntake), goal: CGFloat(goal))
      statisticsItems.append(item)
    }
    
    weekStatisticsView.setItems(statisticsItems)
  }

  private func updateSwitchButtons() {
    let isCurrentWeek = statisticsEndDate.isLaterThan(NSDate())
    nextWeekButton.enabled = !isCurrentWeek
  }
  
  private func computeStatisticsDateRange() {
    let calendar = NSCalendar.currentCalendar()
    let weekdayOfDate = calendar.ordinalityOfUnit(.CalendarUnitWeekday, inUnit: .WeekCalendarUnit, forDate: date)
    let daysPerWeek = calendar.maximumRangeOfUnit(.WeekdayCalendarUnit).length
    statisticsBeginDate = DateHelper.addToDate(date, years: 0, months: 0, days: -weekdayOfDate + 1)
    statisticsEndDate = DateHelper.addToDate(statisticsBeginDate, years: 0, months: 0, days: daysPerWeek)
  }
}
