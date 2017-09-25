//
//  WeekStatisticsViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 01.12.14.
//  Copyright © 2014 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData

class WeekStatisticsViewController: UIViewController {
  
  @IBOutlet weak var weekStatisticsView: WeekStatisticsView!
  @IBOutlet weak var datePeriodLabel: UILabel!

  var date: Date = Date() {
    didSet {
      updateUI(animated: true)
    }
  }
  
  fileprivate var statisticsBeginDate: Date!
  fileprivate var statisticsEndDate: Date!
  fileprivate var isShowingDay = false
  fileprivate var leftSwipeGestureRecognizer: UISwipeGestureRecognizer!
  fileprivate var rightSwipeGestureRecognizer: UISwipeGestureRecognizer!
  fileprivate var volumeObserver: SettingsObserver?
  
  fileprivate var helpTip: JDFTooltipView?

  fileprivate struct Constants {
    static let dayViewController = "DayViewController"
  }
  
  fileprivate struct LocalizedStrings {
    
    lazy var helpTipForTapSeeDayDetails: String = NSLocalizedString("WSVC:Tap a day to see details",
      value: "Tap a day to see details",
      comment: "WeekStatisticsViewController: Text for help tip about tapping a day button for details")
    
    lazy var helpTipForSwipeToChangeWeek: String = NSLocalizedString("WSVC:Swipe left or right to switch week",
      value: "Swipe left or right to switch week",
      comment: "WeekStatisticsViewController: Text for help tip about switching current week by swipe gesture")

  }
  
  fileprivate var localizedStrings = LocalizedStrings()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    setupNotificationsObservation()
    
    volumeObserver = Settings.sharedInstance.generalVolumeUnits.addObserver { [weak self] _ in
      self?.updateWeekStatisticsView(animated: false)
    }
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.leftSwipeGestureIsRecognized(_:)))
    leftSwipeGestureRecognizer.direction = .left
    weekStatisticsView.addGestureRecognizer(leftSwipeGestureRecognizer)
    
    rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.rightSwipeGestureIsRecognized(_:)))
    rightSwipeGestureRecognizer.direction = .right
    weekStatisticsView.addGestureRecognizer(rightSwipeGestureRecognizer)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    checkHelpTip()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    weekStatisticsView.removeGestureRecognizer(leftSwipeGestureRecognizer)
    weekStatisticsView.removeGestureRecognizer(rightSwipeGestureRecognizer)
    leftSwipeGestureRecognizer = nil
    rightSwipeGestureRecognizer = nil
  }
  
  fileprivate func setupUI() {
    weekStatisticsView.backgroundColor = StyleKit.pageBackgroundColor
    weekStatisticsView.barsColor = StyleKit.weekStatisticsChartColor
    weekStatisticsView.goalLineColor = StyleKit.weekStatisticsGoalColor
    weekStatisticsView.titleFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
    weekStatisticsView.daysFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
    weekStatisticsView.daysColor = UIColor.darkGray
    weekStatisticsView.todayColor = StyleKit.weekStatisticsTodayTextColor
    weekStatisticsView.scaleMargin = 10
    weekStatisticsView.dataSource = self
    weekStatisticsView.delegate = self
    
    datePeriodLabel.backgroundColor = StyleKit.pageBackgroundColor // remove blending
    
    updateUI(animated: false)
  }
  
  fileprivate func setupNotificationsObservation() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.preferredContentSizeChanged),
      name: NSNotification.Name.UIContentSizeCategoryDidChange,
      object: nil)
    
    #if AQUAZLITE
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(fullVersionIsPurchased(_:)),
      name: NSNotification.Name(rawValue: GlobalConstants.notificationFullVersionIsPurchased), object: nil)
    #endif
    
    CoreDataStack.performOnPrivateContext { privateContext in
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(self.managedObjectContextDidChange(_:)),
        name: NSNotification.Name.NSManagedObjectContextDidSave,
        object: privateContext)
      
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(self.managedObjectContextDidChange(_:)),
        name: NSNotification.Name(rawValue: GlobalConstants.notificationManagedObjectContextWasMerged),
        object: privateContext)
    }
  }
  
  @objc func managedObjectContextDidChange(_ notification: Notification) {
    #if AQUAZLITE
      if !Settings.sharedInstance.generalFullVersion.value {
        return
      }
    #endif
    
    updateWeekStatisticsView(animated: true)
  }

  @objc func preferredContentSizeChanged() {
    datePeriodLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
    weekStatisticsView.titleFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
    weekStatisticsView.daysFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
    view.invalidateIntrinsicContentSize()
  }

  #if AQUAZLITE
  @objc func fullVersionIsPurchased(_ notification: NSNotification) {
    updateWeekStatisticsView(animated: false)
  }
  #endif
  
  fileprivate func updateUI(animated: Bool) {
    computeStatisticsDateRange()
    updateDatePeriodLabel(animated: animated)
    updateWeekStatisticsView(animated: animated)
  }

  @IBAction func switchToPreviousWeek(_ sender: Any) {
    switchToPreviousWeek()
  }
  
  @IBAction func switchToNextWeek(_ sender: Any) {
    switchToNextWeek()
  }
  
  @objc func leftSwipeGestureIsRecognized(_ gestureRecognizer: UISwipeGestureRecognizer) {
    if gestureRecognizer.state == .ended {
      switchToNextWeek()
    }
  }
  
  @objc func rightSwipeGestureIsRecognized(_ gestureRecognizer: UISwipeGestureRecognizer) {
    if gestureRecognizer.state == .ended {
      switchToPreviousWeek()
    }
  }
  
  fileprivate func switchToPreviousWeek() {
    date = DateHelper.addToDate(date, years: 0, months: 0, days: -7)
  }
  
  fileprivate func switchToNextWeek() {
    date = DateHelper.addToDate(date, years: 0, months: 0, days: 7)
  }
  
  fileprivate lazy var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    let dateFormat = DateFormatter.dateFormat(fromTemplate: "ddMMMyy", options: 0, locale: Locale.current)
    formatter.dateFormat = dateFormat
    return formatter
    }()

  fileprivate func updateDatePeriodLabel(animated: Bool) {
    let maxDate = DateHelper.previousDayBefore(statisticsEndDate)
    let fromDateTitle = dateFormatter.string(from: statisticsBeginDate)
    let toDateTitle = dateFormatter.string(from: maxDate)
    let title = "\(fromDateTitle) - \(toDateTitle)"
    if animated {
      datePeriodLabel.setTextWithAnimation(title)
    } else {
      datePeriodLabel.text = title
    }
  }

  fileprivate func fetchStatisticsItems(beginDate: Date, endDate: Date, privateContext: NSManagedObjectContext) -> [WeekStatisticsView.ItemType] {
    let amountPartsList = Intake.fetchIntakeAmountPartsGroupedBy(.day,
      beginDate: beginDate,
      endDate: endDate,
      dayOffsetInHours: 0,
      aggregateFunction: .average,
      managedObjectContext: privateContext)
    
    Logger.logSevere(amountPartsList.count == 7, "Unexpected count of grouped water intakes", logDetails: [Logger.Attributes.count: "\(amountPartsList.count)"])
    
    let waterGoals = WaterGoal.fetchWaterGoalAmounts(
      beginDate: beginDate,
      endDate: endDate,
      managedObjectContext: privateContext)
    
    Logger.logSevere(waterGoals.count == 7, "Unexpected count of water goals", logDetails: [Logger.Attributes.count: "\(waterGoals.count)"])

    var statisticsItems: [WeekStatisticsView.ItemType] = []

    for (index, amountPart) in amountPartsList.enumerated() {
      let waterGoal = waterGoals[index] + amountPart.dehydration
      
      let displayedWaterHydration = Units.sharedInstance.convertMetricAmountToDisplayed(metricAmount: amountPart.hydration, unitType: .volume)
      let displayedWaterGoal = Units.sharedInstance.convertMetricAmountToDisplayed(metricAmount: waterGoal, unitType: .volume)
      
      let item: WeekStatisticsView.ItemType = (value: CGFloat(displayedWaterHydration), goal: CGFloat(displayedWaterGoal))
      statisticsItems.append(item)
    }

    return statisticsItems
  }
  
  fileprivate func updateWeekStatisticsView(animated: Bool) {
    #if AQUAZLITE
      if !Settings.sharedInstance.generalFullVersion.value {
        // Demo mode
        var items: [WeekStatisticsView.ItemType] = []
        
        for index in 0..<weekStatisticsView.daysPerWeek {
          let item: WeekStatisticsView.ItemType = (value: CGFloat(200 + index * 300), goal: 1800)
          items.append(item)
        }
        
        weekStatisticsView.setItems(items, animate: animated)
        return
      }
    #endif
    
    CoreDataStack.performOnPrivateContext { privateContext in
      let date = self.date
      let statisticsItems = self.fetchStatisticsItems(beginDate: self.statisticsBeginDate, endDate: self.statisticsEndDate, privateContext: privateContext)
      
      DispatchQueue.main.async {
        if self.date == date {
          self.weekStatisticsView.setItems(statisticsItems, animate: animated)
        }
      }
    }
  }

  fileprivate func computeStatisticsDateRange() {
    let weekdayOfDate = Calendar.current.ordinality(of: .weekday, in: .weekOfMonth, for: date)!
    let daysPerWeek = DateHelper.daysPerWeek()
    statisticsBeginDate = DateHelper.addToDate(date, years: 0, months: 0, days: -weekdayOfDate + 1)
    statisticsEndDate = DateHelper.addToDate(statisticsBeginDate, years: 0, months: 0, days: daysPerWeek)
  }
  
  fileprivate func isFutureDate(_ dayIndex: Int) -> Bool {
    let date = DateHelper.addToDate(statisticsBeginDate, years: 0, months: 0, days: dayIndex)
    return DateHelper.calendarDays(fromDate: Date(), toDate: date) > 0
  }
  
  // MARK: Help tips
  
  fileprivate func checkHelpTip() {
    #if AQUAZLITE
    if !Settings.sharedInstance.generalFullVersion.value {
      return
    }
    #endif
    
    if helpTip != nil {
      return
    }
    
    switch Settings.sharedInstance.uiWeekStatisticsPageHelpTipToShow.value {
    case .tapToSeeDayDetails: showHelpTipForTapSeeDayDetails()
    case .swipeToChangeWeek: showHelpTipForSwipeToChangeWeek()
    case .none: return
    }
  }
  
  fileprivate func showHelpTipForTapSeeDayDetails() {
    SystemHelper.executeBlockWithDelay(GlobalConstants.helpTipDelayToShow) {
      if self.view.window == nil || self.helpTip != nil {
        return
      }

      let dayButton = self.weekStatisticsView.getDayButtonWithIndex(0)

      self.helpTip = JDFTooltipView(
        targetView: dayButton,
        hostView: self.weekStatisticsView,
        tooltipText: self.localizedStrings.helpTipForTapSeeDayDetails,
        arrowDirection: .down,
        width: self.view.frame.width / 2)
      
      UIHelper.showHelpTip(self.helpTip!) {
        self.helpTip = nil
      }
      
      // Switch to the next help tip
      Settings.sharedInstance.uiWeekStatisticsPageHelpTipToShow.value =
        Settings.WeekStatisticsPageHelpTip(rawValue: Settings.sharedInstance.uiWeekStatisticsPageHelpTipToShow.value.rawValue + 1)!
    }
  }
  
  fileprivate func showHelpTipForSwipeToChangeWeek() {
    SystemHelper.executeBlockWithDelay(GlobalConstants.helpTipDelayToShow) {
      if self.view.window == nil || self.helpTip != nil {
        return
      }

      let point = CGPoint(x: self.weekStatisticsView.bounds.midX, y: self.weekStatisticsView.bounds.midY)

      self.helpTip = JDFTooltipView(
        targetPoint: point,
        hostView: self.weekStatisticsView,
        tooltipText: self.localizedStrings.helpTipForSwipeToChangeWeek,
        arrowDirection: .down,
        width: self.view.frame.width / 2)
      
      UIHelper.showHelpTip(self.helpTip!) {
        self.helpTip = nil
      }

      // Switch to the next help tip
      Settings.sharedInstance.uiWeekStatisticsPageHelpTipToShow.value =
        Settings.WeekStatisticsPageHelpTip(rawValue: Settings.sharedInstance.uiWeekStatisticsPageHelpTipToShow.value.rawValue + 1)!
    }
  }

}

// MARK: WeekStatisticsViewDataSource -

extension WeekStatisticsViewController: WeekStatisticsViewDataSource {
  
  func weekStatisticsViewIsFutureDay(_ dayIndex: Int) -> Bool {
    return isFutureDate(dayIndex)
  }
  
  func weekStatisticsViewGetTitleForValue(_ value: CGFloat) -> String {
    let quantity = Quantity(unit: Settings.sharedInstance.generalVolumeUnits.value.unit, amount: Double(value))
    let title = quantity.getDescription(fractionDigits: Settings.sharedInstance.generalVolumeUnits.value.decimals, displayUnits: true)

    return title
  }

  func weekStatisticsViewIsToday(_ dayIndex: Int) -> Bool {
    let date = DateHelper.addToDate(statisticsBeginDate, years: 0, months: 0, days: dayIndex)
    return DateHelper.areEqualDays(Date(), date)
  }
  
}

private extension Units.Volume {
  var decimals: Int {
    switch self {
    case .millilitres: return 0
    case .fluidOunces: return 1
    }
  }
}

// MARK: WeekStatisticsViewDelegate -

extension WeekStatisticsViewController: WeekStatisticsViewDelegate {
  
  func weekStatisticsViewDaySelected(_ dayIndex: Int) {
    if isFutureDate(dayIndex) {
      return
    }

    // Unfortunately Show seque does not work properly in iOS 7, so straight pushViewController() method is used instead.

    if let dayViewController: DayViewController = LoggedActions.instantiateViewController(storyboard: storyboard, storyboardID: "DayViewController") {
      let selectedDate = DateHelper.addToDate(statisticsBeginDate, years: 0, months: 0, days: dayIndex)
      dayViewController.mode = .statistics
      dayViewController.setCurrentDate(selectedDate)
      
      navigationController?.pushViewController(dayViewController, animated: true)
      
      isShowingDay = true
    }
  }
  
}
