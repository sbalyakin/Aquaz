//
//  DayViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 03.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

private extension Units.Volume {
  var precision: Double {
    switch self {
    case Millilitres: return 1.0
    case FluidOunces: return 0.1
    }
  }
  
  var decimals: Int {
    switch self {
    case Millilitres: return 0
    case FluidOunces: return 1
    }
  }
}

class DayViewController: RevealedViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
  
  // MARK: UI elements -
  
  @IBOutlet weak var pageButton: UIBarButtonItem!
  @IBOutlet weak var summaryBar: UIView!
  @IBOutlet weak var consumptionProgressView: MultiProgressView!
  @IBOutlet weak var consumptionButton: UIButton!
  @IBOutlet weak var previousDayButton: UIButton!
  @IBOutlet weak var nextDayButton: UIButton!
  @IBOutlet weak var currentDayButton: UIButton!
  @IBOutlet weak var daySelectionBar: UIView!
  @IBOutlet weak var showDaySelectionButton: UIButton!
  @IBOutlet weak var highActivityButton: UIButton!
  @IBOutlet weak var hotDayButton: UIButton!
  
  var navigationTitleView: UIView!
  var navigationTitleLabel: UILabel!
  var navigationCurrentDayLabel: UILabel!

  // MARK: Public properties -
  
  /// Current date for managing water intake
  private var currentDate: NSDate! {
    didSet {
      if mode == .General {
        if DateHelper.areDatesEqualByDays(date1: currentDate, date2: NSDate()) {
          Settings.sharedInstance.uiUseCustomDateForDayView.value = false
        } else {
          Settings.sharedInstance.uiUseCustomDateForDayView.value = true
          Settings.sharedInstance.uiCustomDateForDayView.value = currentDate
        }
      }
    }
  }
  
  private var overallConsumption: Double = 0.0 {
    didSet {
      updateConsumptionButton()
    }
  }
  
  enum Mode {
    case General, Statistics
  }
  
  var mode: Mode = .General
  
  // MARK: Page setup -
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if mode == .General && Settings.sharedInstance.uiUseCustomDateForDayView.value {
      currentDate = Settings.sharedInstance.uiCustomDateForDayView.value
    } else {
      if currentDate == nil {
        currentDate = NSDate()
      }
    }
    
    summaryBarOriginalFrame = summaryBar.frame
    
    createCustomNavigationTitle()
    createPageViewController()
    setupSummaryBar()
    updateCurrentDateRelatedControls()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    if navigationTitleView != nil {
      navigationItem.titleView = navigationTitleView
    }
    
    applyStyle()
    refreshCurrentDay(showAlert: false)
  }
  
  func refreshCurrentDay(#showAlert: Bool) {
    let dayIsSwitched = !DateHelper.areDatesEqualByDays(date1: currentDate, date2: NSDate())
    
    if mode == .General && isCurrentDayToday && dayIsSwitched {
      if showAlert {
        let message = NSLocalizedString("DVC:Welcome to the next day", value: "Welcome to the next day", comment: "DayViewController: Title for alert displayed if tomorrow has come")
        let cancelButtonTitle = NSLocalizedString("DVC:OK", value: "OK", comment: "DayViewController: Cancel button title for alert displayed if tomorrow has come")
        let alert = UIAlertView(title: nil, message: message, delegate: nil, cancelButtonTitle: cancelButtonTitle)
        alert.show()
      }

      setCurrentDate(NSDate())
    }
  }
  
  func setCurrentDate(date: NSDate) {
    currentDate = date

    if isViewLoaded() {
      updateCurrentDateRelatedControls()
    }
  }
  
  func getCurrentDate() -> NSDate {
    return currentDate
  }
  
  private func createCustomNavigationTitle() {
    let titleParts = UIHelper.createNavigationTitleViewWithSubTitle(navigationController: navigationController!, titleText: navigationItem.title)
    
    navigationTitleView = titleParts.containerView
    navigationTitleLabel = titleParts.titleLabel
    navigationCurrentDayLabel = titleParts.subtitleLabel
    
    navigationItem.titleView = navigationTitleView
  }

  private func setupSummaryBar() {
    setDaySelectionBarVisible(Settings.sharedInstance.uiDisplayDaySelection.value, animated: false)
    setupMultiprogressControl()
  }
  
  private func setupMultiprogressControl() {
    for drinkIndex in 0..<Drink.getDrinksCount() {
      if let drink = Drink.getDrinkByIndex(drinkIndex) {
        let section = consumptionProgressView.addSection(color: drink.mainColor)
        multiProgressSections[drink] = section
      }
    }
  }
  
  private func createPageViewController() {
    let summaryBarHeight = summaryBar.bounds.height
    var rect = view.frame
    rect.size.height -= summaryBarHeight
    rect.offset(dx: 0.0, dy: summaryBarHeight)
    
    createPageViewControllerWithRect(rect)
  }
  
  private func createPageViewControllerWithRect(rect: CGRect) {
    pages = []
    
    // Add view controller for drink selection
    selectDrinkViewController = storyboard?.instantiateViewControllerWithIdentifier("SelectDrinkViewController") as? SelectDrinkViewController
    assert(selectDrinkViewController != nil)
    
    selectDrinkViewController.dayViewController = self
    pages.append(selectDrinkViewController)
    
    // Add consumptions diary view controller
    diaryViewController = storyboard?.instantiateViewControllerWithIdentifier("DiaryViewController") as? DiaryViewController
    assert(diaryViewController != nil)
    
    diaryViewController.dayViewController = self
    pages.append(diaryViewController)
    
    // Create, setup and add a page view controller
    pageViewController = storyboard?.instantiateViewControllerWithIdentifier("DayPageViewController") as? UIPageViewController
    assert(pageViewController != nil)
    
    pageViewController.dataSource = self
    pageViewController.delegate = self
    pageViewController.setViewControllers([selectDrinkViewController], direction: .Forward, animated: false, completion: nil)
    pageViewController.view.frame = rect
    
    addChildViewController(pageViewController)
    view.addSubview(pageViewController.view)
    
    pageViewController.didMoveToParentViewController(self)
  }
  
  // MARK: Summary bar actions -
  
  @IBAction func toggleDaySelectionBar(sender: AnyObject) {
    let visible = Settings.sharedInstance.uiDisplayDaySelection.value
    setDaySelectionBarVisible(!visible, animated: true)
  }
  
  private func setDaySelectionBarVisible(visible: Bool, animated: Bool) {
    let newSummaryBarHeight = visible ? summaryBarOriginalFrame.height : daySelectionBar.frame.minY
    var rects = view.bounds.rectsByDividing(newSummaryBarHeight, fromEdge: .MinYEdge)
    rects.remainder.size.height += rects.slice.height - daySelectionBar.frame.minY
    
    func changeFrame() {
      summaryBar.frame = rects.slice
      pageViewController.view.frame = rects.remainder
      for subview in pageViewController.view.subviews {
        if let view = subview as? UIView {
          view.frame = pageViewController.view.bounds
        }
      }
    }
    
    if animated {
      UIView.animateWithDuration(0.4, animations: changeFrame)
    } else {
      changeFrame()
    }
    
    Settings.sharedInstance.uiDisplayDaySelection.value = visible
    
    showDaySelectionButton.selected = visible
  }
  
  @IBAction func toggleHighActivityMode(sender: AnyObject) {
    if consumptionHighActivityFraction > 0 {
      consumptionHighActivityFraction = 0
    } else {
      consumptionHighActivityFraction = Settings.sharedInstance.generalExtraConsumptionHighActivity.value
    }
  }
  
  @IBAction func toggleHotDayMode(sender: AnyObject) {
    if consumptionHotDayFraction > 0 {
      consumptionHotDayFraction = 0
    } else {
      consumptionHotDayFraction = Settings.sharedInstance.generalExtraConsumptionHot.value
    }
  }
  
  @IBAction func switchToPreviousDay(sender: AnyObject) {
    setCurrentDate(DateHelper.addToDate(currentDate, years: 0, months: 0, days: -1))
  }

  @IBAction func switchToNextDay(sender: AnyObject) {
    setCurrentDate(DateHelper.addToDate(currentDate, years: 0, months: 0, days: 1))
  }
  
  // MARK: Change current screen -
  
  func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
    if let index = find(pages, viewController) {
      if index > 0 {
        return pages[index - 1]
      }
    }
    
    return nil
  }
  
  func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
    if let index = find(pages, viewController) {
      if index < pages.count - 1 {
        return pages[index + 1]
      }
    }
    
    return nil
  }
  
  func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
    let currentPage = pageViewController.viewControllers.last as UIViewController
    if currentPage == pages[0] {
      pageButton.image = UIImage(named: "iconDiary")?.imageWithRenderingMode(.AlwaysOriginal)
    } else if currentPage == pages[1] {
      pageButton.image = UIImage(named: "iconUp")?.imageWithRenderingMode(.AlwaysOriginal)
    }
  }
  
  @IBAction func pageButtonWasTapped(sender: AnyObject) {
    toggleCurrentPage()
  }
  
  private func toggleCurrentPage() {
    let currentPage = pageViewController.viewControllers.last as UIViewController
    if currentPage == pages[0] {
      pageViewController.setViewControllers([pages[1]], direction: .Forward, animated: true, completion: nil)
      pageButton.image = UIImage(named: "iconUp")?.imageWithRenderingMode(.AlwaysOriginal)
    } else if currentPage == pages[1] {
      pageViewController.setViewControllers([pages[0]], direction: .Reverse, animated: true, completion: nil)
      pageButton.image = UIImage(named: "iconDiary")?.imageWithRenderingMode(.AlwaysOriginal)
    }
  }
  
  func switchToSelectDrinkPage() {
    let currentPage = pageViewController.viewControllers.last as UIViewController
    if currentPage != pages[0] {
      toggleCurrentPage()
    }
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ShowCalendar" {
      if let calendarViewController = segue.destinationViewController as? CalendarViewController {
        calendarViewController.date = currentDate
        calendarViewController.dayViewController = self
      }
    }
  }
  
  // MARK: Consumptions management -
  
  private func fetchConsumptionRate() {
    consumptionRate = ConsumptionRate.fetchConsumptionRateForDate(currentDate)
    
    if let consumptionRate = consumptionRate {
      isConsumptionRateForCurrentDay = DateHelper.areDatesEqualByDays(date1: consumptionRate.date, date2: currentDate)
    } else {
      isConsumptionRateForCurrentDay = false
    }
    
    consumptionRateWasChanged()
  }

  private func fetchConsumptions() {
    // TODO: Take day offset in hours from settings
    consumptions = Consumption.fetchConsumptionsForDay(currentDate, dayOffsetInHours: 0)

    consumptionsWereChanged(doSort: false) // Sort is useless, because consumption are fetched already sorted
  }
  
  func addConsumption(consumption: Consumption) {
    consumptions.append(consumption)
    
    sortConsumptions()
    
    if let section = multiProgressSections[consumption.drink] {
      section.factor += CGFloat(consumption.waterIntake)
    }

    let needCheckForWaterIntakeCompletion = overallConsumption < consumptionRateAmount
    
    overallConsumption += consumption.waterIntake
    
    diaryViewController.updateTable(consumptions)
    
    updateNotifications(consumptionDate: consumption.date)
    
    if needCheckForWaterIntakeCompletion {
      checkForWaterIntakeCompletion()
    }
  }
  
  private func sortConsumptions() {
    consumptions.sort({ $0.date.isEarlierThan($1.date) })
  }
  
  private func updateNotifications(#consumptionDate: NSDate) {
    if !Settings.sharedInstance.notificationsEnabled.value {
      return
    }
    
    let isToday = DateHelper.areDatesEqualByDays(date1: NSDate(), date2: currentDate)
    if !isToday {
      return
    }
    
    if Settings.sharedInstance.notificationsUseWaterIntake.value && overallConsumption >= consumptionRateAmount {
      NotificationsHelper.removeAllNotifications()
      
      let nextDayDate = DateHelper.addToDate(consumptionDate, years: 0, months: 0, days: 1)
      NotificationsHelper.scheduleNotificationsFromSettingsForDate(nextDayDate)
    } else {
      NotificationsHelper.rescheduleNotificationsBecauseOfConsumption(consumptionDate: consumptionDate)
    }
  }

  private func checkForWaterIntakeCompletion() {
    let isToday = DateHelper.areDatesEqualByDays(date1: NSDate(), date2: currentDate)
    if !isToday {
      return
    }
    
    if overallConsumption >= consumptionRateAmount {
      if let completeViewController = storyboard?.instantiateViewControllerWithIdentifier("CompleteViewController") as? CompleteViewController {
        parentViewController?.presentViewController(completeViewController, animated: true, completion: nil)
      } else {
        assert(false)
      }
    }
  }

  func removeConsumption(consumption: Consumption) {
    let index = find(consumptions, consumption)
    if index == nil {
      assert(false, "Removed consumption is not found")
      return
    }
    
    consumptions.removeAtIndex(index!)
    
    if let section = multiProgressSections[consumption.drink] {
      section.factor -= CGFloat(consumption.waterIntake)
    }

    overallConsumption -= consumption.waterIntake
    
    diaryViewController.updateTable(consumptions)
  }
  
  func consumptionsWereChanged(#doSort: Bool) {
    if doSort {
      sortConsumptions()
    }
    
    // Group consumptions by drinks
    var consumptionsMap: [Drink: Double] = [:]
    
    for consumption in consumptions {
      if let amount = consumptionsMap[consumption.drink] {
        consumptionsMap[consumption.drink] = amount + Double(consumption.waterIntake)
      } else {
        consumptionsMap[consumption.drink] = Double(consumption.waterIntake)
      }
    }
    
    // Update diary page
    diaryViewController.updateTable(consumptions)
    
    // Clear all drink sections
    for (_, section) in multiProgressSections {
      section.factor = 0.0
    }
    
    // Fill sections with fetched amounts and compute overall consumption
    var overallAmount = 0.0
    for (drink, amount) in consumptionsMap {
      overallAmount += amount
      if let section = multiProgressSections[drink] {
        section.factor = CGFloat(amount)
      }
    }
    
    overallConsumption = overallAmount
  }
  
  @IBAction func consumptionButtonWasTapped(sender: AnyObject) {
    Settings.sharedInstance.uiDisplayDayConsumptionInPercents.value = !Settings.sharedInstance.uiDisplayDayConsumptionInPercents.value
    updateConsumptionButton()
  }
  
  private func updateConsumptionButton() {
    var consumptionText: String
    
    if Settings.sharedInstance.uiDisplayDayConsumptionInPercents.value {
      let percents = Int(overallConsumption / consumptionRateAmount * 100)
      consumptionText = "\(percents)%"
    } else {
      consumptionText = Units.sharedInstance.formatMetricAmountToText(
        metricAmount: overallConsumption,
        unitType: .Volume,
        roundPrecision: amountPrecision,
        decimals: amountDecimals,
        displayUnits: false)
    }
    
    let consumptionRateText = Units.sharedInstance.formatMetricAmountToText(
      metricAmount: consumptionRateAmount,
      unitType: .Volume,
      roundPrecision: amountPrecision,
      decimals: amountDecimals)
    
    let template = NSLocalizedString("DVC:%1$@ of %2$@", value: "%1$@ of %2$@", comment: "DayViewController: Current consumption of recommended one")
    let text = NSString(format: template, consumptionText, consumptionRateText)
    consumptionButton.setTitle(text, forState: .Normal)
  }
  
  private func consumptionRateWasChanged() {
    updateConsumptionButton()

    // Update maximum for multi progress control
    consumptionProgressView.maximum = CGFloat(consumptionRateAmount)

    highActivityButton.selected = consumptionHighActivityFraction > 0
    hotDayButton.selected = consumptionHotDayFraction > 0
  }
  
  private func saveConsumptionRateForCurrentDate(#baseRateAmount: Double, hotDayFraction: Double, highActivityFraction: Double) {
    consumptionRate = ConsumptionRate.addEntity(
      date: currentDate,
      baseRateAmount: baseRateAmount,
      hotDateFraction: hotDayFraction,
      highActivityFraction: highActivityFraction)
    isConsumptionRateForCurrentDay = true
  }
  
  // MARK: Date management -
  
  private func updateCurrentDateRelatedControls() {
    let formattedDate = DateHelper.stringFromDate(currentDate)
    currentDayButton.setTitle(formattedDate, forState: .Normal)
    navigationCurrentDayLabel.text = formattedDate
    
    let daysTillToday = DateHelper.computeUnitsFrom(currentDate, toDate: NSDate(), unit: .CalendarUnitDay)
    nextDayButton.enabled = daysTillToday > 0
    
    fetchConsumptionRate()
    
    fetchConsumptions()
  }
  
  // MARK: Private properties -
  
  private var consumptionRate: ConsumptionRate?
  private var isConsumptionRateForCurrentDay: Bool = false

  private var consumptionBaseRateAmount: Double {
    return consumptionRate?.baseRateAmount.doubleValue ?? Settings.sharedInstance.userDailyWaterIntake.value
  }
  
  private var consumptionRateAmount: Double {
    return consumptionBaseRateAmount * (1 + consumptionHotDayFraction + consumptionHighActivityFraction)
  }
  
  private var consumptionHotDayFraction: Double {
    get {
      if !isConsumptionRateForCurrentDay {
        return 0
      }
      
      return consumptionRate?.hotDayFraction.doubleValue ?? 0
    }
    set(newHotDayFraction) {
      if !isConsumptionRateForCurrentDay {
        saveConsumptionRateForCurrentDate(baseRateAmount: consumptionBaseRateAmount, hotDayFraction: newHotDayFraction, highActivityFraction: 0)
      } else if let consumptionRate = consumptionRate {
        consumptionRate.hotDayFraction = newHotDayFraction
        ModelHelper.sharedInstance.save()
      }

      consumptionRateWasChanged()
    }
  }
  
  private var consumptionHighActivityFraction: Double {
    get {
      if !isConsumptionRateForCurrentDay {
        return 0
      }

      return consumptionRate?.highActivityFraction.doubleValue ?? 0
    }
    set(newHighActivityFraction) {
      if !isConsumptionRateForCurrentDay {
        saveConsumptionRateForCurrentDate(baseRateAmount: consumptionBaseRateAmount, hotDayFraction: 0, highActivityFraction: newHighActivityFraction)
      } else if let consumptionRate = consumptionRate {
        consumptionRate.highActivityFraction = newHighActivityFraction
        ModelHelper.sharedInstance.save()
      }

      consumptionRateWasChanged()
    }
  }
  
  private var consumptions: [Consumption] = []
  private var multiProgressSections: [Drink: MultiProgressView.Section] = [:]
  
  private var pageViewController: UIPageViewController!
  private var pages: [UIViewController] = []
  private var selectDrinkViewController: SelectDrinkViewController!
  private var diaryViewController: DiaryViewController!
  private var summaryBarOriginalFrame: CGRect!

  private let amountPrecision = Settings.sharedInstance.generalVolumeUnits.value.precision
  private let amountDecimals = Settings.sharedInstance.generalVolumeUnits.value.decimals

  private var isCurrentDayToday: Bool {
    return !Settings.sharedInstance.uiUseCustomDateForDayView.value
  }
}
