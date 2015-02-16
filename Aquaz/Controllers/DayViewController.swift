//
//  DayViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 03.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit
import CoreData

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
  @IBOutlet weak var intakesMultiProgressView: MultiProgressView!
  @IBOutlet weak var intakeButton: UIButton!
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
  
  private var dailyWaterIntake: Double = 0.0 {
    didSet {
      updateIntakeButton()
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
    intakesMultiProgressView.borderColor = UIColor(red: 167/255, green: 169/255, blue: 171/255, alpha: 0.8)
    intakesMultiProgressView.emptySectionColor = UIColor(red: 241/255, green: 241/255, blue: 242/255, alpha: 1)
    
    for drinkIndex in 0..<Drink.getDrinksCount() {
      if let drink = Drink.getDrinkByIndex(drinkIndex, managedObjectContext: managedObjectContext) {
        let section = intakesMultiProgressView.addSection(color: drink.mainColor)
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
    
    // Add intakes diary view controller
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
    if highActivityExtraFactor > 0 {
      highActivityExtraFactor = 0
    } else {
      highActivityExtraFactor = Settings.sharedInstance.generalHighActivityExtraFactor.value
    }
  }
  
  @IBAction func toggleHotDayMode(sender: AnyObject) {
    if hotDayExtraFactor > 0 {
      hotDayExtraFactor = 0
    } else {
      hotDayExtraFactor = Settings.sharedInstance.generalHotDayExtraFactor.value
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
    let currentPage = pageViewController.viewControllers.last as! UIViewController
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
    let currentPage = pageViewController.viewControllers.last as! UIViewController
    if currentPage == pages[0] {
      pageViewController.setViewControllers([pages[1]], direction: .Forward, animated: true, completion: nil)
      pageButton.image = UIImage(named: "iconUp")?.imageWithRenderingMode(.AlwaysOriginal)
    } else if currentPage == pages[1] {
      pageViewController.setViewControllers([pages[0]], direction: .Reverse, animated: true, completion: nil)
      pageButton.image = UIImage(named: "iconDiary")?.imageWithRenderingMode(.AlwaysOriginal)
    }
  }
  
  func switchToSelectDrinkPage() {
    let currentPage = pageViewController.viewControllers.last as! UIViewController
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
  
  // MARK: Intakes management -
  
  private func fetchWaterGoal() {
    waterGoal = WaterGoal.fetchWaterGoalForDate(currentDate, managedObjectContext: managedObjectContext)
    
    if let waterGoal = waterGoal {
      isWaterGoalForCurrentDay = DateHelper.areDatesEqualByDays(date1: waterGoal.date, date2: currentDate)
    } else {
      isWaterGoalForCurrentDay = false
    }
    
    waterGoalWasChanged()
  }

  private func fetchIntakes() {
    // TODO: Take day offset in hours from settings
    intakes = Intake.fetchIntakesForDay(currentDate, dayOffsetInHours: 0, managedObjectContext: managedObjectContext)

    intakesWereChanged(doSort: false) // Sort is useless, because fetched intakes are already sorted
  }
  
  func addIntake(intake: Intake) {
    intakes.append(intake)
    
    sortIntakes()
    
    if let section = multiProgressSections[intake.drink] {
      section.factor += CGFloat(intake.waterAmount)
    }

    let needCheckForWaterIntakeCompletion = dailyWaterIntake < waterGoalAmount
    
    dailyWaterIntake += intake.waterAmount
    
    diaryViewController.updateTable(intakes)
    
    updateNotifications(intakeDate: intake.date)
    
    if needCheckForWaterIntakeCompletion {
      checkForWaterIntakeCompletion()
    }
  }
  
  private func sortIntakes() {
    intakes.sort() {
      $0.date.isEarlierThan($1.date)
    }
  }
  
  private func updateNotifications(#intakeDate: NSDate) {
    if !Settings.sharedInstance.notificationsEnabled.value {
      return
    }
    
    let isToday = DateHelper.areDatesEqualByDays(date1: NSDate(), date2: currentDate)
    if !isToday {
      return
    }
    
    if Settings.sharedInstance.notificationsUseWaterIntake.value && dailyWaterIntake >= waterGoalAmount {
      NotificationsHelper.removeAllNotifications()
      
      let nextDayDate = DateHelper.addToDate(intakeDate, years: 0, months: 0, days: 1)
      NotificationsHelper.scheduleNotificationsFromSettingsForDate(nextDayDate)
    } else {
      NotificationsHelper.rescheduleNotificationsBecauseOfIntake(intakeDate: intakeDate)
    }
  }

  private func checkForWaterIntakeCompletion() {
    let isToday = DateHelper.areDatesEqualByDays(date1: NSDate(), date2: currentDate)
    if !isToday {
      return
    }
    
    if dailyWaterIntake >= waterGoalAmount {
      if let completeViewController = storyboard?.instantiateViewControllerWithIdentifier("CompleteViewController") as? CompleteViewController {
        parentViewController?.presentViewController(completeViewController, animated: true, completion: nil)
      } else {
        assert(false)
      }
    }
  }

  func removeIntake(intake: Intake) {
    let index = find(intakes, intake)
    if index == nil {
      assert(false, "Removed intake is not found")
      return
    }
    
    intakes.removeAtIndex(index!)
    
    if let section = multiProgressSections[intake.drink] {
      section.factor -= CGFloat(intake.waterAmount)
    }

    dailyWaterIntake -= intake.waterAmount
    
    diaryViewController.updateTable(intakes)
  }
  
  func intakesWereChanged(#doSort: Bool) {
    if doSort {
      sortIntakes()
    }
    
    // Group intakes by drinks
    var intakesMap: [Drink: Double] = [:]
    
    for intake in intakes {
      if let amount = intakesMap[intake.drink] {
        intakesMap[intake.drink] = amount + Double(intake.waterAmount)
      } else {
        intakesMap[intake.drink] = Double(intake.waterAmount)
      }
    }
    
    // Update diary page
    diaryViewController.updateTable(intakes)
    
    // Clear all drink sections
    for (_, section) in multiProgressSections {
      section.factor = 0.0
    }
    
    // Fill sections with fetched intakes and compute daily water intake
    dailyWaterIntake = 0.0
    for (drink, amount) in intakesMap {
      dailyWaterIntake += amount
      if let section = multiProgressSections[drink] {
        section.factor = CGFloat(amount)
      }
    }
  }
  
  @IBAction func intakeButtonWasTapped(sender: AnyObject) {
    Settings.sharedInstance.uiDisplayDailyWaterIntakeInPercents.value = !Settings.sharedInstance.uiDisplayDailyWaterIntakeInPercents.value
    updateIntakeButton()
  }
  
  private func updateIntakeButton() {
    let intakeText: String
    
    if Settings.sharedInstance.uiDisplayDailyWaterIntakeInPercents.value {
      let formatter = NSNumberFormatter()
      formatter.numberStyle = .PercentStyle
      formatter.maximumFractionDigits = 0
      formatter.multiplier = 100
      let drinkedPart = dailyWaterIntake / waterGoalAmount
      intakeText = formatter.stringFromNumber(drinkedPart)!
    } else {
      intakeText = Units.sharedInstance.formatMetricAmountToText(
        metricAmount: dailyWaterIntake,
        unitType: .Volume,
        roundPrecision: amountPrecision,
        decimals: amountDecimals,
        displayUnits: false)
    }
    
    let waterGoalText = Units.sharedInstance.formatMetricAmountToText(
      metricAmount: waterGoalAmount,
      unitType: .Volume,
      roundPrecision: amountPrecision,
      decimals: amountDecimals)
    
    let template = NSLocalizedString("DVC:%1$@ of %2$@", value: "%1$@ of %2$@", comment: "DayViewController: Current daily water intake of water intake goal")
    let text = NSString(format: template, intakeText, waterGoalText)
    intakeButton.setTitle(text as String, forState: .Normal)
  }
  
  private func waterGoalWasChanged() {
    updateIntakeButton()

    // Update maximum for multi progress control
    intakesMultiProgressView.maximum = CGFloat(waterGoalAmount)

    highActivityButton.selected = highActivityExtraFactor > 0
    hotDayButton.selected = hotDayExtraFactor > 0
  }
  
  private func saveWaterGoalForCurrentDate(#baseAmount: Double, hotDayFactor: Double, highActivityFactor: Double) {
    waterGoal = WaterGoal.addEntity(
      date: currentDate,
      baseAmount: baseAmount,
      hotDayFactor: hotDayFactor,
      highActivityFactor: highActivityFactor,
      managedObjectContext: managedObjectContext)
    isWaterGoalForCurrentDay = true
  }
  
  // MARK: Date management -
  
  private func updateCurrentDateRelatedControls() {
    let formattedDate = DateHelper.stringFromDate(currentDate)
    currentDayButton.setTitle(formattedDate, forState: .Normal)
    navigationCurrentDayLabel.text = formattedDate
    
    let daysTillToday = DateHelper.computeUnitsFrom(currentDate, toDate: NSDate(), unit: .CalendarUnitDay)
    nextDayButton.enabled = daysTillToday > 0
    
    fetchWaterGoal()
    
    fetchIntakes()
  }
  
  // MARK: Private properties -
  
  private var waterGoal: WaterGoal?
  private var isWaterGoalForCurrentDay: Bool = false

  private var waterGoalBaseAmount: Double {
    return waterGoal?.baseAmount.doubleValue ?? Settings.sharedInstance.userWaterGoal.value
  }
  
  private var waterGoalAmount: Double {
    return waterGoalBaseAmount * (1 + hotDayExtraFactor + highActivityExtraFactor)
  }
  
  private var hotDayExtraFactor: Double {
    get {
      if !isWaterGoalForCurrentDay {
        return 0
      }
      
      return waterGoal?.hotDayFactor.doubleValue ?? 0
    }
    set(newHotDayFactor) {
      if !isWaterGoalForCurrentDay {
        saveWaterGoalForCurrentDate(baseAmount: waterGoalBaseAmount, hotDayFactor: newHotDayFactor, highActivityFactor: 0)
      } else if let waterGoal = waterGoal {
        waterGoal.hotDayFactor = newHotDayFactor
        ModelHelper.save(managedObjectContext: managedObjectContext)
      }

      waterGoalWasChanged()
    }
  }
  
  private var highActivityExtraFactor: Double {
    get {
      if !isWaterGoalForCurrentDay {
        return 0
      }

      return waterGoal?.highActivityFactor.doubleValue ?? 0
    }
    set(newHighActivityFactor) {
      if !isWaterGoalForCurrentDay {
        saveWaterGoalForCurrentDate(baseAmount: waterGoalBaseAmount, hotDayFactor: 0, highActivityFactor: newHighActivityFactor)
      } else if let waterGoal = waterGoal {
        waterGoal.highActivityFactor = newHighActivityFactor
        ModelHelper.save(managedObjectContext: managedObjectContext)
      }

      waterGoalWasChanged()
    }
  }
  
  private var intakes: [Intake] = []
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
  
  private lazy var managedObjectContext: NSManagedObjectContext? = {
    if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
      return appDelegate.managedObjectContext
    } else {
      return nil
    }
  }()
}
