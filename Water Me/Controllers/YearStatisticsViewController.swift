//
//  YearStatisticsViewController.swift
//  Water Me
//
//  Created by Sergey Balyakin on 05.12.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class YearStatisticsViewController: StyledViewController {

  @IBOutlet weak var yearStatisticsView: YearStatisticsView!
  @IBOutlet weak var yearLabel: UILabel!
  @IBOutlet weak var nextYearButton: UIButton!
  
  var date: NSDate = Settings.sharedInstance.uiYearStatisticsDate.value {
    didSet {
      dateWasChanged()
      Settings.sharedInstance.uiYearStatisticsDate.value = date
    }
  }
  
  private var statisticsBeginDate: NSDate!
  private var statisticsEndDate: NSDate!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    yearStatisticsView.titleForHorizontalStep = getMonthTitleFromIndex
    yearStatisticsView.titleForVerticalStep = getTitleForAmount
    yearStatisticsView.backgroundColor = StyleKit.pageBackgroundColor
//    yearStatisticsView.backgroundDarkColor = StyleKit.pageBackgroundColor.colorWithShadow(0.03)
    yearStatisticsView.backgroundDarkColor = UIColor.clearColor()
    
    nextYearButton.setImage(UIImage(named: "iconRight"), forState: .Disabled)

    dateWasChanged()
  }

  private func dateWasChanged() {
    computeStatisticsDateRange()
    initYearLabel()
    initYearStatisticsView()
    updateSwitchButtons()
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

    let displayedVolumeUnits = Settings.sharedInstance.generalVolumeUnits.value

    var statisticsItems: [YearStatisticsView.ItemType] = []
    
    for (index, metricWaterIntake) in enumerate(waterIntakes) {
      let metricGoal = goals[index]
      
      let displayedWaterIntake = Units.sharedInstance.convertMetricAmountToDisplayed(metricAmount: metricWaterIntake, unitType: .Volume)
      let displayedGoal = Units.sharedInstance.convertMetricAmountToDisplayed(metricAmount: metricGoal, unitType: .Volume)

      let item: YearStatisticsView.ItemType = (value: CGFloat(displayedWaterIntake), goal: CGFloat(displayedGoal))
      statisticsItems.append(item)
    }
    
    yearStatisticsView.setItems(statisticsItems)
  }
  
  private func getMonthTitleFromIndex(monthIndex: CGFloat) -> String {
    let index = Int(monthIndex)
    let calendar = NSCalendar.currentCalendar()
    
    if index < 0 || index >= calendar.shortMonthSymbols.count {
      assert(false)
      return ""
    }
    
    return calendar.shortMonthSymbols[index] as String
  }
  
  private func getTitleForAmount(amount: CGFloat) -> String {
    let quantity = Quantity(unit: Settings.sharedInstance.generalVolumeUnits.value.unit, amount: Double(amount))
    let title = quantity.getDescription(0, displayUnits: true)
    return title
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
