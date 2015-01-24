//
//  WeekStatisticsViewController.swift
//  Water Me
//
//  Created by Sergey Balyakin on 01.12.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation

class WeekStatisticsViewController: StyledViewController, WeekStatisticsViewDelegate {
  
  @IBOutlet weak var weekStatisticsView: WeekStatisticsView!
  @IBOutlet weak var datePeriodLabel: UILabel!
  @IBOutlet weak var nextWeekButton: UIButton!
  

  var date: NSDate = Settings.sharedInstance.uiWeekStatisticsDate.value {
    didSet {
      dateWasChanged()
      Settings.sharedInstance.uiWeekStatisticsDate.value = date
    }
  }
  
  private var statisticsBeginDate: NSDate!
  private var statisticsEndDate: NSDate!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    weekStatisticsView.delegate = self
    weekStatisticsView.titleForScaleFunction = getTitleForAmount
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    dateWasChanged()
  }
  
  private func dateWasChanged() {
    computeStatisticsDateRange()
    initDatePeriodLabel()
    initWeekStatisticsView()
    updateSwitchButtons()
  }
  
  func weekStatisticsViewDaySelected(dayIndex: Int) {
    let selectedDate = DateHelper.addToDate(statisticsBeginDate, years: 0, months: 0, days: dayIndex)
    
    let dayViewController = storyboard!.instantiateViewControllerWithIdentifier("DayViewController") as DayViewController
    dayViewController.mode = .Statistics
    dayViewController.setCurrentDate(selectedDate)
    dayViewController.initializesRevealControls = false
    
    navigationController!.pushViewController(dayViewController, animated: true)
  }
  
  private func getTitleForAmount(amount: CGFloat) -> String {
    let quantity = Quantity(unit: Settings.sharedInstance.generalVolumeUnits.value.unit, amount: Double(amount))
    let title = quantity.getDescription(0, displayUnits: true)
    return title
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
    
    let displayedVolumeUnits = Settings.sharedInstance.generalVolumeUnits.value
    
    var statisticsItems: [WeekStatisticsView.ItemType] = []
    
    for (index, metricWaterIntake) in enumerate(waterIntakes) {
      let metricGoal = goals[index]
      
      let displayedWaterIntake = Units.sharedInstance.convertMetricAmountToDisplayed(metricAmount: metricWaterIntake, unitType: .Volume)
      let displayedGoal = Units.sharedInstance.convertMetricAmountToDisplayed(metricAmount: metricGoal, unitType: .Volume)
      
      let item: WeekStatisticsView.ItemType = (value: CGFloat(displayedWaterIntake), goal: CGFloat(displayedGoal))
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
