//
//  YearStatisticsViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 05.12.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit
import CoreData

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
    yearStatisticsView.backgroundDarkColor = UIColor.clearColor()
    
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
  
  private lazy var dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    let dateFormat = NSDateFormatter.dateFormatFromTemplate("yyyy", options: 0, locale: NSLocale.currentLocale())
    formatter.dateFormat = dateFormat
    return formatter
    }()

  private func initYearLabel() {
    let yearTitle = dateFormatter.stringFromDate(date)
    yearLabel.text = yearTitle
  }
  
  private func fetchStatisticsItems() -> [YearStatisticsView.ItemType] {
    let waterIntakes = Intake.fetchGroupedWaterAmounts(beginDate: statisticsBeginDate, endDate: statisticsEndDate, dayOffsetInHours: 0, groupingUnit: .Month, aggregateFunction: .Average, managedObjectContext: managedObjectContext)
    
    let goals = WaterGoal.fetchWaterGoalAmountsGroupedByMonths(beginDate: statisticsBeginDate, endDate: statisticsEndDate, managedObjectContext: managedObjectContext)
    Logger.logSevere(waterIntakes.count == goals.count, Logger.Messages.inconsistentWaterIntakesAndGoals)
    
    let displayedVolumeUnits = Settings.sharedInstance.generalVolumeUnits.value
    
    var statisticsItems: [YearStatisticsView.ItemType] = []
    
    for (index, metricWaterIntake) in enumerate(waterIntakes) {
      let metricGoal = goals[index]
      
      let displayedWaterIntake = Units.sharedInstance.convertMetricAmountToDisplayed(metricAmount: metricWaterIntake, unitType: .Volume)
      let displayedGoal = Units.sharedInstance.convertMetricAmountToDisplayed(metricAmount: metricGoal, unitType: .Volume)
      
      let item: YearStatisticsView.ItemType = (value: CGFloat(displayedWaterIntake), goal: CGFloat(displayedGoal))
      statisticsItems.append(item)
    }
    
    return statisticsItems
  }
  
  private func initYearStatisticsView() {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
      let date = self.date
      let statisticsItems = self.fetchStatisticsItems()
      dispatch_async(dispatch_get_main_queue()) {
        if self.date === date {
          self.yearStatisticsView.setItems(statisticsItems)
        }
      }
    }
  }
  
  private func getMonthTitleFromIndex(monthIndex: CGFloat) -> String {
    let index = Int(monthIndex)
    let calendar = NSCalendar.currentCalendar()
    
    if index < 0 || index >= calendar.shortMonthSymbols.count {
      assert(false)
      return ""
    }
    
    return calendar.shortMonthSymbols[index] as! String
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

  private lazy var managedObjectContext: NSManagedObjectContext? = {
    if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
      return appDelegate.managedObjectContext
    } else {
      return nil
    }
  }()

}
