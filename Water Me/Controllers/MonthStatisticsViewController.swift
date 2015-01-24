//
//  MonthStatisticsViewController.swift
//  Water Me
//
//  Created by Sergey Balyakin on 05.12.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

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
  
  private func initMonthLabel() {
    let dateFormatter = NSDateFormatter()
    
    let formatString = NSDateFormatter.dateFormatFromTemplate("MMMMYYYY", options: 0, locale: NSLocale.currentLocale())
    dateFormatter.dateFormat = formatString

    let monthTitle = dateFormatter.stringFromDate(statisticsBeginDate)
    monthLabel.text = monthTitle
  }
  
  private func initMonthStatisticsView() {
    let waterIntakes = Consumption.fetchGroupedWaterIntake(beginDate: statisticsBeginDate, endDate: statisticsEndDate, dayOffsetInHours: 0, groupingUnit: .Day, computeAverageAmounts: true)
    
    let goals = ConsumptionRate.fetchConsumptionRateAmounts(beginDate: statisticsBeginDate, endDate: statisticsEndDate)
    assert(waterIntakes.count == goals.count)
    
    consumptionFractions = []
    
    for (index, waterIntake) in enumerate(waterIntakes) {
      let goal = goals[index]
      var consumptionFraction: Double = 0
      if goal > 0 {
        consumptionFraction = waterIntake / goal
      } else {
        assert(false)
      }
      consumptionFractions.append(consumptionFraction)
    }
    
    monthStatisticsView.switchToMonth(date)
  }
  
  func monthStatisticsGetConsumptionFractionForDate(date: NSDate, dayOfCurrentMonth: Int) -> Double {
    if dayOfCurrentMonth < 1 || dayOfCurrentMonth > consumptionFractions.count {
      return 0
    }
    
    return consumptionFractions[dayOfCurrentMonth - 1]
  }

  func calendarViewDaySelected(date: NSDate) {
    let dayViewController = storyboard!.instantiateViewControllerWithIdentifier("DayViewController") as DayViewController
    dayViewController.mode = .Statistics
    dayViewController.setCurrentDate(date)
    dayViewController.initializesRevealControls = false
    
    navigationController!.pushViewController(dayViewController, animated: true)
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

  private var consumptionFractions: [Double] = []

}
