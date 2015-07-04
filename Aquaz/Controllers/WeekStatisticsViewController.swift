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
  private var managedObjectContext: NSManagedObjectContext { return CoreDataStack.privateContext }
  private var volumeObserverIdentifier: Int?
  
  private var helpTip: JDFTooltipView?

  private struct Constants {
    static let showDaySegue = "Show Day"
  }
  
  private struct LocalizedStrings {
    
    lazy var helpTipForTapSeeDayDetails = NSLocalizedString("WSVC:Tap a day to see details",
      value: "Tap a day to see details",
      comment: "WeekStatisticsViewController: Text for help tip about tapping a day button for details")
    
    lazy var helpTipForSwipeToChangeWeek = NSLocalizedString("WSVC:Swipe left or right to switch week",
      value: "Swipe left or right to switch week",
      comment: "WeekStatisticsViewController: Text for help tip about switching current week by swipe gesture")

  }
  
  private var localizedStrings = LocalizedStrings()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    setupNotificationsObservation()
    
    volumeObserverIdentifier = Settings.generalVolumeUnits.addObserver { [weak self] _ in
      self?.updateWeekStatisticsView(animated: false)
    }
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
    
    if let volumeObserverIdentifier = volumeObserverIdentifier {
      Settings.generalVolumeUnits.removeObserver(volumeObserverIdentifier)
    }
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
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    checkHelpTip()
  }

  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    weekStatisticsView.removeGestureRecognizer(leftSwipeGestureRecognizer)
    weekStatisticsView.removeGestureRecognizer(rightSwipeGestureRecognizer)
    leftSwipeGestureRecognizer = nil
    rightSwipeGestureRecognizer = nil
  }
  
  private func setupUI() {
    weekStatisticsView.backgroundColor = StyleKit.pageBackgroundColor
    weekStatisticsView.barsColor = StyleKit.weekStatisticsChartColor
    weekStatisticsView.goalLineColor = StyleKit.weekStatisticsGoalColor
    weekStatisticsView.titleFont = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
    weekStatisticsView.daysFont = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
    weekStatisticsView.daysColor = UIColor.darkGrayColor()
    weekStatisticsView.todayColor = StyleKit.weekStatisticsTodayTextColor
    weekStatisticsView.scaleMargin = 10
    weekStatisticsView.dataSource = self
    weekStatisticsView.delegate = self
    
    updateUI(animated: false)
  }
  
  private func setupNotificationsObservation() {
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "preferredContentSizeChanged",
      name: UIContentSizeCategoryDidChangeNotification, object: nil)
    
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "managedObjectContextDidChange:",
      name: NSManagedObjectContextDidSaveNotification, object: nil)

    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "managedObjectContextDidChange:",
      name: GlobalConstants.notificationManagedObjectContextWasMerged, object: nil)
    
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "fullVersionIsPurchased:",
      name: GlobalConstants.notificationFullVersionIsPurchased, object: nil)
  }
  
  func managedObjectContextDidChange(notification: NSNotification) {
    if Settings.generalFullVersion.value {
      updateWeekStatisticsView(animated: true)
    }
  }

  func fullVersionIsPurchased(notification: NSNotification) {
    updateWeekStatisticsView(animated: false)
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
    updateWeekStatisticsView(animated: animated)
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
    let amountPartsList = Intake.fetchIntakeAmountPartsGroupedBy(.Day,
      beginDate: beginDate,
      endDate: endDate,
      dayOffsetInHours: 0,
      aggregateFunction: .Average,
      managedObjectContext: managedObjectContext)
    
    Logger.logSevere(amountPartsList.count == 7, "Unexpected count of grouped water intakes", logDetails: [Logger.Attributes.count: "\(amountPartsList.count)"])
    
    let waterGoals = WaterGoal.fetchWaterGoalAmounts(
      beginDate: beginDate,
      endDate: endDate,
      managedObjectContext: managedObjectContext)
    
    Logger.logSevere(waterGoals.count == 7, "Unexpected count of water goals", logDetails: [Logger.Attributes.count: "\(waterGoals.count)"])
    
    let displayedVolumeUnits = Settings.generalVolumeUnits.value
    
    var statisticsItems: [WeekStatisticsView.ItemType] = []
    
    for (index, amountPart) in enumerate(amountPartsList) {
      let waterGoal = waterGoals[index] + amountPart.dehydration
      
      let displayedWaterHydration = Units.sharedInstance.convertMetricAmountToDisplayed(metricAmount: amountPart.hydration, unitType: .Volume)
      let displayedWaterGoal = Units.sharedInstance.convertMetricAmountToDisplayed(metricAmount: waterGoal, unitType: .Volume)
      
      let item: WeekStatisticsView.ItemType = (value: CGFloat(displayedWaterHydration), goal: CGFloat(displayedWaterGoal))
      statisticsItems.append(item)
    }
    
    return statisticsItems
  }
  
  private func updateWeekStatisticsView(#animated: Bool) {
    if Settings.generalFullVersion.value {
      managedObjectContext.performBlock {
        let date = self.date
        let statisticsItems = self.fetchStatisticsItems(beginDate: self.statisticsBeginDate, endDate: self.statisticsEndDate)
        dispatch_async(dispatch_get_main_queue()) {
          if self.date === date {
            self.weekStatisticsView.setItems(statisticsItems, animate: animated)
          }
        }
      }
    } else {
      // Demo mode
      var items: [WeekStatisticsView.ItemType] = []
      for index in 0..<weekStatisticsView.daysPerWeek {
        let item: WeekStatisticsView.ItemType = (value: CGFloat(200 + index * 300), goal: 1800)
        items.append(item)
      }
      weekStatisticsView.setItems(items, animate: animated)
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
    if segue.identifier == Constants.showDaySegue,
       let viewController = segue.destinationViewController.contentViewController as? DayViewController,
       let date = sender as? NSDate
    {
      viewController.mode = .Statistics
      viewController.setCurrentDate(date)
    } else {
      Logger.logError("Unable to setup DayViewController properly from week statistics")
    }
  }

  private func isFutureDate(dayIndex: Int) -> Bool {
    let date = DateHelper.addToDate(statisticsBeginDate, years: 0, months: 0, days: dayIndex)
    let daysBetween = DateHelper.calcDistanceBetweenCalendarDates(fromDate: NSDate(), toDate: date, calendarUnit: .CalendarUnitDay)
    return daysBetween > 0
  }
  
  // MARK: Help tips
  
  private func checkHelpTip() {
    if helpTip != nil || !Settings.generalFullVersion.value {
      return
    }
    
    switch Settings.uiWeekStatisticsPageHelpTipToShow.value {
    case .TapToSeeDayDetails: showHelpTipForTapSeeDayDetails()
    case .SwipeToChangeWeek: showHelpTipForSwipeToChangeWeek()
    case .None: return
    }
  }
  
  private func showHelpTipForTapSeeDayDetails() {
    SystemHelper.executeBlockWithDelay(GlobalConstants.helpTipDelayToShow) {
      if self.view.window == nil || self.helpTip != nil {
        return
      }

      let dayButton = self.weekStatisticsView.getDayButtonWithIndex(0)

      self.helpTip = JDFTooltipView(
        targetView: dayButton,
        hostView: self.weekStatisticsView,
        tooltipText: self.localizedStrings.helpTipForTapSeeDayDetails,
        arrowDirection: .Down,
        width: self.view.frame.width / 2)
      
      UIHelper.showHelpTip(self.helpTip!) {
        self.helpTip = nil
      }
      
      // Switch to the next help tip
      Settings.uiWeekStatisticsPageHelpTipToShow.value =
        Settings.WeekStatisticsPageHelpTip(rawValue: Settings.uiWeekStatisticsPageHelpTipToShow.value.rawValue + 1)!
    }
  }
  
  private func showHelpTipForSwipeToChangeWeek() {
    SystemHelper.executeBlockWithDelay(GlobalConstants.helpTipDelayToShow) {
      if self.view.window == nil || self.helpTip != nil {
        return
      }

      let point = CGPoint(x: self.weekStatisticsView.bounds.midX, y: self.weekStatisticsView.bounds.midY)

      self.helpTip = JDFTooltipView(
        targetPoint: point,
        hostView: self.weekStatisticsView,
        tooltipText: self.localizedStrings.helpTipForSwipeToChangeWeek,
        arrowDirection: .Down,
        width: self.view.frame.width / 2)
      
      UIHelper.showHelpTip(self.helpTip!) {
        self.helpTip = nil
      }

      // Switch to the next help tip
      Settings.uiWeekStatisticsPageHelpTipToShow.value =
        Settings.WeekStatisticsPageHelpTip(rawValue: Settings.uiWeekStatisticsPageHelpTipToShow.value.rawValue + 1)!
    }
  }

}

// MARK: WeekStatisticsViewDataSource -

extension WeekStatisticsViewController: WeekStatisticsViewDataSource {
  
  func weekStatisticsViewIsFutureDay(dayIndex: Int) -> Bool {
    return isFutureDate(dayIndex)
  }
  
  func weekStatisticsViewGetTitleForValue(value: CGFloat) -> String {
    let quantity = Quantity(unit: Settings.generalVolumeUnits.value.unit, amount: Double(value))
    let title = quantity.getDescription(Settings.generalVolumeUnits.value.decimals, displayUnits: true)

    return title
  }

  func weekStatisticsViewIsToday(dayIndex: Int) -> Bool {
    let date = DateHelper.addToDate(statisticsBeginDate, years: 0, months: 0, days: dayIndex)
    return DateHelper.areDatesEqualByDays(NSDate(), date)
  }
  
}

private extension Units.Volume {
  var decimals: Int {
    switch self {
    case Millilitres: return 0
    case FluidOunces: return 1
    }
  }
}

// MARK: WeekStatisticsViewDelegate -

extension WeekStatisticsViewController: WeekStatisticsViewDelegate {
  
  func weekStatisticsViewDaySelected(dayIndex: Int) {
    if !isFutureDate(dayIndex) {
      let selectedDate = DateHelper.addToDate(statisticsBeginDate, years: 0, months: 0, days: dayIndex)
      performSegueWithIdentifier(Constants.showDaySegue, sender: selectedDate)
      isShowingDay = true
    }
  }
  
}
