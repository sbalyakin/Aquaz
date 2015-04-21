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
      updateUI(animated: true)
    }
  }
  
  private var statisticsBeginDate: NSDate!
  private var statisticsEndDate: NSDate!
  private var leftSwipeGestureRecognizer: UISwipeGestureRecognizer!
  private var rightSwipeGestureRecognizer: UISwipeGestureRecognizer!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    setupUI()
    setupNotificationsObservation()
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  private func setupUI() {
    yearStatisticsView.backgroundColor = UIColor.clearColor()
    yearStatisticsView.backgroundDarkColor = UIColor.clearColor()
    yearStatisticsView.valuesChartLineColor = StyleKit.yearStatisticsChartStrokeColor
    yearStatisticsView.valuesChartFillColor = StyleKit.yearStatisticsChartFillColor
    yearStatisticsView.goalsChartColor = StyleKit.yearStatisticsGoalColor
    yearStatisticsView.scaleTextColor = UIColor.darkGrayColor()
    yearStatisticsView.gridColor = UIColor(red: 230/255, green: 231/255, blue: 232/255, alpha: 1.0)
    yearStatisticsView.pinsColor = UIColor.whiteColor()
    yearStatisticsView.titleFont = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
    yearStatisticsView.dataSource = self
    
    updateUI(animated: false)
  }
  
  private func setupNotificationsObservation() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "preferredContentSizeChanged", name: UIContentSizeCategoryDidChangeNotification, object: nil)
    
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "managedObjectContextDidChange:",
      name: NSManagedObjectContextDidSaveNotification,
      object: CoreDataProvider.sharedInstance.managedObjectContext)
    
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "managedObjectContextDidChange:",
      name: GlobalConstants.notificationManagedObjectContextWasMerged,
      object: nil)
  }
  
  func managedObjectContextDidChange(notification: NSNotification) {
    updateYearStatisticsView()
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "leftSwipeGestureIsRecognized:")
    leftSwipeGestureRecognizer.direction = .Left
    yearStatisticsView.addGestureRecognizer(leftSwipeGestureRecognizer)
    
    rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "rightSwipeGestureIsRecognized:")
    rightSwipeGestureRecognizer.direction = .Right
    yearStatisticsView.addGestureRecognizer(rightSwipeGestureRecognizer)
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    yearStatisticsView.removeGestureRecognizer(leftSwipeGestureRecognizer)
    yearStatisticsView.removeGestureRecognizer(rightSwipeGestureRecognizer)
    leftSwipeGestureRecognizer = nil
    rightSwipeGestureRecognizer = nil
  }

  func preferredContentSizeChanged() {
    yearStatisticsView.titleFont = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
    yearLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
    view.invalidateIntrinsicContentSize()
  }
  
  private func updateUI(#animated: Bool) {
    computeStatisticsDateRange()
    updateYearLabel(animated: animated)
    updateYearStatisticsView()
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
    let waterIntakes = Intake.fetchGroupedWaterAmounts(beginDate: beginDate, endDate: endDate, dayOffsetInHours: 0, groupingUnit: .Month, aggregateFunction: .Average, managedObjectContext: CoreDataProvider.sharedInstance.managedObjectContext)
    
    let goals = WaterGoal.fetchWaterGoalAmountsGroupedByMonths(beginDate: beginDate, endDate: endDate, managedObjectContext: CoreDataProvider.sharedInstance.managedObjectContext)
    Logger.logSevere(waterIntakes.count == goals.count, Logger.Messages.inconsistentWaterIntakesAndGoals)
    
    let displayedVolumeUnits = Settings.generalVolumeUnits.value
    
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
  
  private func computeStatisticsDateRange() {
    let calendar = NSCalendar.currentCalendar()
    let dateComponents = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay | .CalendarUnitTimeZone | .CalendarUnitCalendar, fromDate: date)
    
    dateComponents.day = 1
    dateComponents.month = 1
    statisticsBeginDate = calendar.dateFromComponents(dateComponents)
    statisticsEndDate = DateHelper.addToDate(statisticsBeginDate, years: 1, months: 0, days: 0)
  }

}

extension YearStatisticsViewController: YearStatisticsViewDataSource {
  
  func yearStatisticsViewGetTitleForHorizontalValue(value: CGFloat) -> String {
    let index = Int(value)
    let calendar = NSCalendar.currentCalendar()
    
    if index < 0 || index >= calendar.shortMonthSymbols.count {
      assert(false)
      return ""
    }
    
    return calendar.shortMonthSymbols[index] as! String
  }
  
  func yearStatisticsViewGetTitleForVerticalValue(value: CGFloat) -> String {
    let quantity = Quantity(unit: Settings.generalVolumeUnits.value.unit, amount: Double(value))
    let title = quantity.getDescription(0, displayUnits: true)
    return title
  }
  

}