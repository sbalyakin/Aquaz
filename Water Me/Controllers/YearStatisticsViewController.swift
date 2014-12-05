//
//  YearStatisticsViewController.swift
//  Water Me
//
//  Created by Sergey Balyakin on 05.12.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class YearStatisticsViewController: UIViewController {

  @IBOutlet weak var yearStatisticsView: YearStatisticsView!
  @IBOutlet weak var yearLabel: UILabel!
  @IBOutlet weak var nextYearButton: UIButton!
  
  var date: NSDate = NSDate() {
    didSet {
      computeStatisticsDateRange()
      initYearLabel()
      initYearStatisticsView()
      updateSwitchButtons()
    }
  }
  
  private var statisticsBeginDate: NSDate!
  private var statisticsEndDate: NSDate!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // TODO: Specify from the settings
    date = NSDate()
  }

  @IBAction func switchToPreviousYear(sender: AnyObject) {
    date = DateHelper.addToDate(date, years: -1, months: 0, days: 0)
  }
  
  @IBAction func switchToNextYear(sender: AnyObject) {
    date = DateHelper.addToDate(date, years: 1, months: 0, days: 0)
  }
  
  private func initYearLabel() {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "YYYY"
    let yearTitle = dateFormatter.stringFromDate(date)
    yearLabel.text = yearTitle
  }
  
  private func initYearStatisticsView() {
    let waterIntakes = Consumption.fetchGroupedWaterIntake(beginDate: statisticsBeginDate, endDate: statisticsEndDate, dayOffsetInHours: 0, groupingUnit: .Month, computeAverageAmounts: true)
    
    let goals = ConsumptionRate.fetchConsumptionRateAmountsGroupedByMonths(beginDate: statisticsBeginDate, endDate: statisticsEndDate)
    assert(waterIntakes.count == goals.count)
    
    var statisticsItems: [YearStatisticsView.ItemType] = []
    
    for (index, waterIntake) in enumerate(waterIntakes) {
      let goal = goals[index]
      let item: YearStatisticsView.ItemType = (value: CGFloat(waterIntake), goal: CGFloat(goal))
      statisticsItems.append(item)
    }
    
    yearStatisticsView.setItems(statisticsItems)
  }
  
  private func computeStatisticsDateRange() {
    let calendar = NSCalendar.currentCalendar()
    let dateComponents = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay | .CalendarUnitTimeZone | .CalendarUnitCalendar, fromDate: date)
    
    dateComponents.day = 1
    dateComponents.month = 1
    statisticsBeginDate = calendar.dateFromComponents(dateComponents)
    statisticsEndDate = DateHelper.addToDate(statisticsBeginDate, years: 1, months: 0, days: 0)
  }

  private func updateSwitchButtons() {
    let isCurrentYear = DateHelper.areDatesEqualByYears(date1: date, date2: NSDate())
    nextYearButton.enabled = !isCurrentYear
  }

}
