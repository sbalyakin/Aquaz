//
//  WeekStatisticsViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 01.12.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData

class WeekStatisticsViewController: StyledViewController {
  
  @IBOutlet weak var weekStatisticsView: WeekStatisticsView!
  @IBOutlet weak var datePeriodLabel: UILabel!

  var date: NSDate = Settings.sharedInstance.uiWeekStatisticsDate.value {
    didSet {
      updateUI()
      Settings.sharedInstance.uiWeekStatisticsDate.value = date
    }
  }
  
  private var statisticsBeginDate: NSDate!
  private var statisticsEndDate: NSDate!
  private var isShowingDay = false
  private var leftSwipeGestureRecognizer: UISwipeGestureRecognizer!
  private var rightSwipeGestureRecognizer: UISwipeGestureRecognizer!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    weekStatisticsView.dataSource = self
    weekStatisticsView.delegate = self
    weekStatisticsView.titleForScaleFunction = getTitleForAmount
    
    updateUI()
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "leftSwipeGestureIsRecognized:")
    leftSwipeGestureRecognizer.direction = .Left
    weekStatisticsView.addGestureRecognizer(leftSwipeGestureRecognizer)
    
    rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "rightSwipeGestureIsRecognized:")
    rightSwipeGestureRecognizer.direction = .Right
    weekStatisticsView.addGestureRecognizer(rightSwipeGestureRecognizer)
    
    revealViewController()?.panGestureRecognizer()?.requireGestureRecognizerToFail(rightSwipeGestureRecognizer)

    if isShowingDay {
      updateUI()
      isShowingDay = false
    }
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    weekStatisticsView.removeGestureRecognizer(leftSwipeGestureRecognizer)
    weekStatisticsView.removeGestureRecognizer(rightSwipeGestureRecognizer)
    leftSwipeGestureRecognizer = nil
    rightSwipeGestureRecognizer = nil
  }

  private func updateUI() {
    computeStatisticsDateRange()
    updateDatePeriodLabel()
    updateWeekStatisticsView()
  }
  
  private func getTitleForAmount(amount: CGFloat) -> String {
    let quantity = Quantity(unit: Settings.sharedInstance.generalVolumeUnits.value.unit, amount: Double(amount))
    let title = quantity.getDescription(0, displayUnits: true)
    return title
  }

  @IBAction func switchToPreviousWeek(sender: AnyObject) {
    switchToPreviousWeek()
  }
  
  @IBAction func switchToNextWeek(sender: AnyObject) {
    switchToNextWeek()
  }
  
  func leftSwipeGestureIsRecognized(gestureRecognizer: UISwipeGestureRecognizer) {
    if gestureRecognizer.state == .Ended {
      switchToNextWeek()
    }
  }
  
  func rightSwipeGestureIsRecognized(gestureRecognizer: UISwipeGestureRecognizer) {
    if gestureRecognizer.state == .Ended {
      switchToPreviousWeek()
    }
  }
  
  private func switchToPreviousWeek() {
    date = DateHelper.addToDate(date, years: 0, months: 0, days: -7)
  }
  
  private func switchToNextWeek() {
    date = DateHelper.addToDate(date, years: 0, months: 0, days: 7)
  }
  
  private lazy var dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    let dateFormat = NSDateFormatter.dateFormatFromTemplate("ddMMMyy", options: 0, locale: NSLocale.currentLocale())
    formatter.dateFormat = dateFormat
    return formatter
    }()

  private func updateDatePeriodLabel() {
    let maxDate = DateHelper.addToDate(statisticsEndDate, years: 0, months: 0, days: -1)
    let fromDateTitle = dateFormatter.stringFromDate(statisticsBeginDate)
    let toDateTitle = dateFormatter.stringFromDate(maxDate)
    let title = "\(fromDateTitle) - \(toDateTitle)"
    datePeriodLabel.setTextWithAnimation(title)
  }

  private func fetchStatisticsItems(#beginDate: NSDate, endDate: NSDate) -> [WeekStatisticsView.ItemType] {
    let waterIntakes = Intake.fetchGroupedWaterAmounts(beginDate: beginDate, endDate: endDate, dayOffsetInHours: 0, groupingUnit: .Day, aggregateFunction: .Average, managedObjectContext: managedObjectContext)
    Logger.logSevere(waterIntakes.count == 7, "Unexpected count of grouped water intakes", logDetails: [Logger.Attributes.count: "\(waterIntakes.count)"])
    
    let goals = WaterGoal.fetchWaterGoalAmounts(beginDate: beginDate, endDate: endDate, managedObjectContext: managedObjectContext)
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
  
  private func updateWeekStatisticsView() {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
      let date = self.date
      let statisticsItems = self.fetchStatisticsItems(beginDate: self.statisticsBeginDate, endDate: self.statisticsEndDate)
      dispatch_async(dispatch_get_main_queue()) {
        if self.date === date {
          self.weekStatisticsView.setItems(statisticsItems)
        }
      }
    }
  }

  private func computeStatisticsDateRange() {
    let calendar = NSCalendar.currentCalendar()
    let weekdayOfDate = calendar.ordinalityOfUnit(.CalendarUnitWeekday, inUnit: .CalendarUnitWeekOfMonth, forDate: date)
    let daysPerWeek = calendar.maximumRangeOfUnit(.CalendarUnitWeekday).length
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

extension WeekStatisticsViewController: WeekStatisticsViewDataSource {
  
  func weekStatisticsViewIsFutureDay(dayIndex: Int) -> Bool {
    let date = DateHelper.addToDate(statisticsBeginDate, years: 0, months: 0, days: dayIndex)
    let daysBetween = DateHelper.calcDistanceBetweenDates(fromDate: NSDate(), toDate: date, calendarUnit: .CalendarUnitDay)
    return daysBetween > 0
  }
  
}


extension WeekStatisticsViewController: WeekStatisticsViewDelegate {
  
  func weekStatisticsViewDaySelected(dayIndex: Int) {
    let selectedDate = DateHelper.addToDate(statisticsBeginDate, years: 0, months: 0, days: dayIndex)
    let daysBetween = DateHelper.calcDistanceBetweenDates(fromDate: NSDate(), toDate: selectedDate, calendarUnit: .CalendarUnitDay)
    if daysBetween > 0 {
      return
    }
    
    if let dayViewController = storyboard?.instantiateViewControllerWithIdentifier("DayViewController") as? DayViewController {
      dayViewController.mode = .Statistics
      dayViewController.setCurrentDate(selectedDate)
      dayViewController.initializesRevealControls = false
      isShowingDay = true
      navigationController?.pushViewController(dayViewController, animated: true)
    }
  }
  
}
