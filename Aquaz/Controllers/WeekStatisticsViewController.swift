//
//  WeekStatisticsViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 01.12.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData

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
    
    if let dayViewController = storyboard?.instantiateViewControllerWithIdentifier("DayViewController") as? DayViewController {
      dayViewController.mode = .Statistics
      dayViewController.setCurrentDate(selectedDate)
      dayViewController.initializesRevealControls = false
      navigationController?.pushViewController(dayViewController, animated: true)
    }
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

  private lazy var dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    let dateFormat = NSDateFormatter.dateFormatFromTemplate("ddMMMyy", options: 0, locale: NSLocale.currentLocale())
    formatter.dateFormat = dateFormat
    return formatter
    }()

  private func initDatePeriodLabel() {
    let maxDate = DateHelper.addToDate(statisticsEndDate, years: 0, months: 0, days: -1)
    let fromDateTitle = dateFormatter.stringFromDate(statisticsBeginDate)
    let toDateTitle = dateFormatter.stringFromDate(maxDate)
    let title = "\(fromDateTitle) - \(toDateTitle)"
    datePeriodLabel.text = title
  }

  private func fetchStatisticsItems() -> [WeekStatisticsView.ItemType] {
    let waterIntakes = Intake.fetchGroupedWaterAmounts(beginDate: statisticsBeginDate, endDate: statisticsEndDate, dayOffsetInHours: 0, groupingUnit: .Day, aggregateFunction: .Average, managedObjectContext: managedObjectContext)
    Logger.logSevere(waterIntakes.count == 7, "Unexpected count of grouped water intakes", logDetails: [Logger.Attributes.count: "\(waterIntakes.count)"])
    
    let goals = WaterGoal.fetchWaterGoalAmounts(beginDate: statisticsBeginDate, endDate: statisticsEndDate, managedObjectContext: managedObjectContext)
    Logger.logSevere(goals.count == 7, "Unexpected count of water goals", logDetails: [Logger.Attributes.count: "\(goals.count)"])
    
    let displayedVolumeUnits = Settings.sharedInstance.generalVolumeUnits.value
    
    var statisticsItems: [WeekStatisticsView.ItemType] = []
    
    for (index, metricWaterIntake) in enumerate(waterIntakes) {
      let metricGoal = goals[index]
      
      let displayedWaterIntake = Units.sharedInstance.convertMetricAmountToDisplayed(metricAmount: metricWaterIntake, unitType: .Volume)
      let displayedGoal = Units.sharedInstance.convertMetricAmountToDisplayed(metricAmount: metricGoal, unitType: .Volume)
      
      let item: WeekStatisticsView.ItemType = (value: CGFloat(displayedWaterIntake), goal: CGFloat(displayedGoal))
      statisticsItems.append(item)
    }
    
    return statisticsItems
  }
  
  private func initWeekStatisticsView() {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
      let date = self.date
      let statisticsItems = self.fetchStatisticsItems()
      dispatch_async(dispatch_get_main_queue()) {
        if self.date === date {
          self.weekStatisticsView.setItems(statisticsItems)
        }
      }
    }
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
  
  private lazy var managedObjectContext: NSManagedObjectContext? = {
    if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
      return appDelegate.managedObjectContext
    } else {
      return nil
    }
  }()

}
