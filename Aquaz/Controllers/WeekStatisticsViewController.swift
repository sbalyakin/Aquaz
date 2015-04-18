//
//  WeekStatisticsViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 01.12.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData

class WeekStatisticsViewController: UIViewController {
  
  @IBOutlet weak var weekStatisticsView: WeekStatisticsView!
  @IBOutlet weak var datePeriodLabel: UILabel!

  var date: NSDate = NSDate() {
    didSet {
      updateUI(animated: true)
    }
  }
  
  private var statisticsBeginDate: NSDate!
  private var statisticsEndDate: NSDate!
  private var isShowingDay = false
  private var leftSwipeGestureRecognizer: UISwipeGestureRecognizer!
  private var rightSwipeGestureRecognizer: UISwipeGestureRecognizer!
  
  private struct Constants {
    static let showDaySegue = "Show Day"
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    setupNotificationsObservation()
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "leftSwipeGestureIsRecognized:")
    leftSwipeGestureRecognizer.direction = .Left
    weekStatisticsView.addGestureRecognizer(leftSwipeGestureRecognizer)
    
    rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "rightSwipeGestureIsRecognized:")
    rightSwipeGestureRecognizer.direction = .Right
    weekStatisticsView.addGestureRecognizer(rightSwipeGestureRecognizer)
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    weekStatisticsView.removeGestureRecognizer(leftSwipeGestureRecognizer)
    weekStatisticsView.removeGestureRecognizer(rightSwipeGestureRecognizer)
    leftSwipeGestureRecognizer = nil
    rightSwipeGestureRecognizer = nil
  }
  
  private func setupUI() {
    weekStatisticsView.titleFont = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
    weekStatisticsView.daysFont = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
    weekStatisticsView.dataSource = self
    weekStatisticsView.delegate = self
    
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
    updateWeekStatisticsView()
  }

  func preferredContentSizeChanged() {
    datePeriodLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
    weekStatisticsView.titleFont = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
    weekStatisticsView.daysFont = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
    view.invalidateIntrinsicContentSize()
  }

  private func updateUI(#animated: Bool) {
    computeStatisticsDateRange()
    updateDatePeriodLabel(animated: animated)
    updateWeekStatisticsView()
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

  private func updateDatePeriodLabel(#animated: Bool) {
    let maxDate = DateHelper.addToDate(statisticsEndDate, years: 0, months: 0, days: -1)
    let fromDateTitle = dateFormatter.stringFromDate(statisticsBeginDate)
    let toDateTitle = dateFormatter.stringFromDate(maxDate)
    let title = "\(fromDateTitle) - \(toDateTitle)"
    if animated {
      datePeriodLabel.setTextWithAnimation(title)
    } else {
      datePeriodLabel.text = title
    }
  }

  private func fetchStatisticsItems(#beginDate: NSDate, endDate: NSDate) -> [WeekStatisticsView.ItemType] {
    let waterIntakes = Intake.fetchGroupedWaterAmounts(beginDate: beginDate, endDate: endDate, dayOffsetInHours: 0, groupingUnit: .Day, aggregateFunction: .Average, managedObjectContext: CoreDataProvider.sharedInstance.managedObjectContext)
    Logger.logSevere(waterIntakes.count == 7, "Unexpected count of grouped water intakes", logDetails: [Logger.Attributes.count: "\(waterIntakes.count)"])
    
    let goals = WaterGoal.fetchWaterGoalAmounts(beginDate: beginDate, endDate: endDate, managedObjectContext: CoreDataProvider.sharedInstance.managedObjectContext)
    Logger.logSevere(goals.count == 7, "Unexpected count of water goals", logDetails: [Logger.Attributes.count: "\(goals.count)"])
    
    let displayedVolumeUnits = Settings.generalVolumeUnits.value
    
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
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == Constants.showDaySegue {
      if let viewController = segue.destinationViewController.contentViewController as? DayViewController, date = sender as? NSDate {
        viewController.mode = .Statistics
        viewController.setCurrentDate(date)
      }
    }
  }

  private func isFutureDate(dayIndex: Int) -> Bool {
    let date = DateHelper.addToDate(statisticsBeginDate, years: 0, months: 0, days: dayIndex)
    let daysBetween = DateHelper.calcDistanceBetweenDates(fromDate: NSDate(), toDate: date, calendarUnit: .CalendarUnitDay)
    return daysBetween > 0
  }
  
}

extension WeekStatisticsViewController: WeekStatisticsViewDataSource {
  
  func weekStatisticsViewIsFutureDay(dayIndex: Int) -> Bool {
    return isFutureDate(dayIndex)
  }
  
  func weekStatisticsViewGetTitleForValue(value: CGFloat) -> String {
    let quantity = Quantity(unit: Settings.generalVolumeUnits.value.unit, amount: Double(value))
    let title = quantity.getDescription(0, displayUnits: true)
    return title
  }
  
}


extension WeekStatisticsViewController: WeekStatisticsViewDelegate {
  
  func weekStatisticsViewDaySelected(dayIndex: Int) {
    if !isFutureDate(dayIndex) {
      let selectedDate = DateHelper.addToDate(statisticsBeginDate, years: 0, months: 0, days: dayIndex)
      performSegueWithIdentifier(Constants.showDaySegue, sender: selectedDate)
      isShowingDay = true
    }
  }
  
}
