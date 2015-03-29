//
//  YearStatisticsViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 05.12.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit
import CoreData

class YearStatisticsViewController: UIViewController {

  @IBOutlet weak var yearStatisticsView: YearStatisticsView!
  @IBOutlet weak var yearLabel: UILabel!
  
  var date: NSDate = NSDate() {
    didSet {
      updateUI(initial: false)
    }
  }
  
  private var statisticsBeginDate: NSDate!
  private var statisticsEndDate: NSDate!
  private var leftSwipeGestureRecognizer: UISwipeGestureRecognizer!
  private var rightSwipeGestureRecognizer: UISwipeGestureRecognizer!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    yearStatisticsView.titleForHorizontalStep = getMonthTitleFromIndex
    yearStatisticsView.titleForVerticalStep = getTitleForAmount
    
    updateUI(initial: true)
    applyStyle()
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "leftSwipeGestureIsRecognized:")
    leftSwipeGestureRecognizer.direction = .Left
    yearStatisticsView.addGestureRecognizer(leftSwipeGestureRecognizer)
    
    rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "rightSwipeGestureIsRecognized:")
    rightSwipeGestureRecognizer.direction = .Right
    yearStatisticsView.addGestureRecognizer(rightSwipeGestureRecognizer)
    
    revealViewController()?.panGestureRecognizer()?.requireGestureRecognizerToFail(rightSwipeGestureRecognizer)
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    yearStatisticsView.removeGestureRecognizer(leftSwipeGestureRecognizer)
    yearStatisticsView.removeGestureRecognizer(rightSwipeGestureRecognizer)
    leftSwipeGestureRecognizer = nil
    rightSwipeGestureRecognizer = nil
  }

  private func updateUI(#initial: Bool) {
    computeStatisticsDateRange()
    updateYearLabel(animated: !initial)
    updateYearStatisticsView()
  }
  
  private func applyStyle() {
    yearStatisticsView.backgroundColor = UIColor.clearColor()
    yearStatisticsView.backgroundDarkColor = UIColor.clearColor()
    yearStatisticsView.valuesChartLineColor = UIColor(red: 80/255, green: 184/255, blue: 187/255, alpha: 1.0)
    yearStatisticsView.valuesChartFillColor = UIColor(red: 80/255, green: 184/255, blue: 187/255, alpha: 0.1)
    yearStatisticsView.goalsChartColor = UIColor(red: 239/255, green: 64/255, blue: 79/255, alpha: 0.5)
    yearStatisticsView.scaleTitleColor = UIColor(red: 147/255, green: 149/255, blue: 152/255, alpha: 1.0)
    yearStatisticsView.gridColor = UIColor(red: 230/255, green: 231/255, blue: 232/255, alpha: 1.0)
    yearStatisticsView.pinsColor = UIColor.whiteColor()
  }
  
  @IBAction func switchToPreviousYear(sender: AnyObject) {
    switchToPreviousYear()
  }
  
  @IBAction func switchToNextYear(sender: AnyObject) {
    switchToNextYear()
  }

  func leftSwipeGestureIsRecognized(gestureRecognizer: UISwipeGestureRecognizer) {
    if gestureRecognizer.state == .Ended {
      switchToNextYear()
    }
  }
  
  func rightSwipeGestureIsRecognized(gestureRecognizer: UISwipeGestureRecognizer) {
    if gestureRecognizer.state == .Ended {
      switchToPreviousYear()
    }
  }
  
  private func switchToPreviousYear() {
    date = DateHelper.addToDate(date, years: -1, months: 0, days: 0)
  }
  
  private func switchToNextYear() {
    date = DateHelper.addToDate(date, years: 1, months: 0, days: 0)
  }

  private lazy var dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    let dateFormat = NSDateFormatter.dateFormatFromTemplate("yyyy", options: 0, locale: NSLocale.currentLocale())
    formatter.dateFormat = dateFormat
    return formatter
    }()

  private func updateYearLabel(#animated: Bool) {
    let title = dateFormatter.stringFromDate(date)
    
    if animated {
      yearLabel.setTextWithAnimation(title)
    } else {
      yearLabel.text = title
    }
  }
  
  private func fetchStatisticsItems(#beginDate: NSDate, endDate: NSDate) -> [YearStatisticsView.ItemType] {
    let waterIntakes = Intake.fetchGroupedWaterAmounts(beginDate: beginDate, endDate: endDate, dayOffsetInHours: 0, groupingUnit: .Month, aggregateFunction: .Average, managedObjectContext: managedObjectContext)
    
    let goals = WaterGoal.fetchWaterGoalAmountsGroupedByMonths(beginDate: beginDate, endDate: endDate, managedObjectContext: managedObjectContext)
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
  
  private func updateYearStatisticsView() {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
      let date = self.date
      let statisticsItems = self.fetchStatisticsItems(beginDate: self.statisticsBeginDate, endDate: self.statisticsEndDate)
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

  private lazy var managedObjectContext: NSManagedObjectContext? = {
    if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
      return appDelegate.managedObjectContext
    } else {
      return nil
    }
  }()

}
