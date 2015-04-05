//
//  DayViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 03.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit
import CoreData

class DayViewController: UIViewController {
  
  // MARK: UI elements -
  
  @IBOutlet weak var summaryBar: UIView!
  @IBOutlet weak var intakesMultiProgressView: MultiProgressView!
  @IBOutlet weak var intakeButton: UIButton!
  @IBOutlet weak var highActivityButton: UIButton!
  @IBOutlet weak var hotDayButton: UIButton!
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var navigationTitleLabel: UILabel!
  @IBOutlet weak var navigationDateLabel: UILabel!

  // MARK: Public properties -
  
  /// Current date for managing water intake
  private var currentDate: NSDate! {
    didSet {
      if mode == .General {
        if DateHelper.areDatesEqualByDays(date1: currentDate, date2: NSDate()) {
          Settings.uiUseCustomDateForDayView.value = false
        } else {
          Settings.uiUseCustomDateForDayView.value = true
          Settings.uiCustomDateForDayView.value = currentDate
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
  
  private struct Constants {
    static let selectDrinkViewControllerStoryboardID = "SelectDrinkViewController"
    static let diaryViewControllerStoryboardID = "DiaryViewController"
    static let showCalendarSegue = "ShowCalendar"
    static let pageViewEmbedSegue = "PageViewEmbed"
    static let showCompleteSegue = "ShowComplete"
    static let dayGuide1ViewControllerStoryboardID = "DayGuide1ViewController"
    static let dayGuide2ViewControllerStoryboardID = "DayGuide2ViewController"
  }
  
  private enum GuideState {
    case None, Page1, Page2
  }
  
  private var guideState: GuideState = .None
  private var dayGuide1ViewController: DayGuide1ViewController!
  private var dayGuide2ViewController: DayGuide2ViewController!
  
  
  // MARK: Page setup -
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initCurrentDay()
    setupGestureRecognizers()
    setupMultiprogressControl()
    updateCurrentDateRelatedControls(initial: true)
    applyStyle()
    if mode == .General {
      UIHelper.setupReveal(self)
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    refreshCurrentDay(showAlert: false)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    if !Settings.uiDayPageHasDisplayedOnce.value {
      continueGuide()
    }
  }
  
  func continueGuide() {
    switch guideState {
    case .None: showGuidePage1()
    case .Page1: showGuidePage2()
    case .Page2: finishGuide()//Settings.uiDayPageHasDisplayedOnce.value = true
    }
  }
  
  private func showGuidePage1() {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let window = appDelegate.window!

    dayGuide1ViewController = storyboard!.instantiateViewControllerWithIdentifier(Constants.dayGuide1ViewControllerStoryboardID) as! DayGuide1ViewController
    dayGuide1ViewController.view.layer.opacity = 0
    dayGuide1ViewController.view.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5)
    dayGuide1ViewController.view.frame = window.frame
    dayGuide1ViewController.view.backgroundColor = UIColor(white: 0, alpha: 0.7)
    dayGuide1ViewController.dayViewController = self

    window.addSubview(dayGuide1ViewController.view)
    
    UIView.animateWithDuration(0.65, delay: 0, options: .CurveEaseInOut, animations: {
      self.dayGuide1ViewController.view.layer.opacity = 1
      self.dayGuide1ViewController.view.layer.transform = CATransform3DMakeScale(1, 1, 1)
    }, completion: nil)

    guideState = .Page1
  }

  private func showGuidePage2() {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let window = appDelegate.window!
    
    dayGuide2ViewController = storyboard!.instantiateViewControllerWithIdentifier(Constants.dayGuide2ViewControllerStoryboardID) as! DayGuide2ViewController
    dayGuide2ViewController.view.layer.opacity = 0
    dayGuide2ViewController.view.frame = window.frame
    dayGuide2ViewController.view.backgroundColor = UIColor(white: 0, alpha: 0.7)
    dayGuide2ViewController.dayViewController = self
    
    window.addSubview(dayGuide2ViewController.view)

    UIView.animateWithDuration(0.65, delay: 0, options: .CurveEaseInOut, animations: {
      self.dayGuide1ViewController.view.layer.opacity = 0
      self.dayGuide2ViewController.view.layer.opacity = 1
    }, completion: { (finished) -> Void in
      self.dayGuide1ViewController.view.removeFromSuperview()
      self.dayGuide1ViewController = nil
    })

    guideState = .Page2
  }

  private func finishGuide() {
    UIView.animateWithDuration(0.65, delay: 0, options: .CurveEaseInOut, animations: {
      self.dayGuide2ViewController.view.layer.opacity = 0
      self.dayGuide2ViewController.view.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5)
    }, completion: { (finished) -> Void in
      self.dayGuide2ViewController.view.removeFromSuperview()
      self.dayGuide2ViewController = nil
    })
  }
  
  private func initCurrentDay() {
    if mode == .General && Settings.uiUseCustomDateForDayView.value {
      currentDate = Settings.uiCustomDateForDayView.value
    } else {
      if currentDate == nil {
        currentDate = NSDate()
      }
    }
  }
  
  private func applyStyle() {
    UIHelper.applyStyle(self)
    navigationTitleLabel.textColor = StyleKit.barTextColor
    navigationDateLabel.textColor = StyleKit.barTextColor
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
      updateCurrentDateRelatedControls(initial: false)
    }
  }
  
  func getCurrentDate() -> NSDate {
    return currentDate
  }
  
  private func setupGestureRecognizers() {
    if let navigationBar = navigationController?.navigationBar {
      let leftSwipe = UISwipeGestureRecognizer(target: self, action: "leftSwipeGestureIsRecognized:")
      leftSwipe.direction = .Left
      self.navigationItem
      navigationBar.addGestureRecognizer(leftSwipe)
      
      let rightSwipe = UISwipeGestureRecognizer(target: self, action: "rightSwipeGestureIsRecognized:")
      rightSwipe.direction = .Right
      navigationBar.addGestureRecognizer(rightSwipe)
    }
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
  
  private func setupPageViewController(pageViewController: UIPageViewController) {
    pages = []
    
    // Add view controller for drink selection
    selectDrinkViewController = LoggedActions.instantiateViewController(storyboard: storyboard, storyboardID: Constants.selectDrinkViewControllerStoryboardID)
    
    selectDrinkViewController.dayViewController = self
    pages.append(selectDrinkViewController)
    
    // Add intakes diary view controller
    diaryViewController = LoggedActions.instantiateViewController(storyboard: storyboard, storyboardID: Constants.diaryViewControllerStoryboardID)
    
    diaryViewController.dayViewController = self
    pages.append(diaryViewController)
    
    pageViewController.dataSource = self
    pageViewController.delegate = self
    pageViewController.setViewControllers([selectDrinkViewController], direction: .Forward, animated: false, completion: nil)
    
    updateUIAccordingToCurrentPage(selectDrinkViewController, initial: true)
  }
  
  // MARK: Day selection -
  
  func leftSwipeGestureIsRecognized(gestureRecognizer: UISwipeGestureRecognizer) {
    if gestureRecognizer.state == .Ended {
      let daysTillToday = DateHelper.computeUnitsFrom(currentDate, toDate: NSDate(), unit: .CalendarUnitDay)
      if daysTillToday > 0 {
        switchToNextDay()
      }
    }
  }
  
  func rightSwipeGestureIsRecognized(gestureRecognizer: UISwipeGestureRecognizer) {
    if gestureRecognizer.state == .Ended {
      switchToPreviousDay()
    }
  }
  
  private func switchToNextDay() {
    setCurrentDate(DateHelper.addToDate(currentDate, years: 0, months: 0, days: 1))
  }

  private func switchToPreviousDay() {
    setCurrentDate(DateHelper.addToDate(currentDate, years: 0, months: 0, days: -1))
  }

  private func updateCurrentDateRelatedControls(#initial: Bool) {
    let formattedDate = DateHelper.stringFromDate(currentDate)
    
    if initial {
      navigationDateLabel.text = formattedDate
    } else {
      navigationDateLabel.setTextWithAnimation(formattedDate)
    }

    fetchWaterGoal()
    fetchIntakes()
  }
  
  // MARK: Summary bar actions -
  
  @IBAction func toggleHighActivityMode(sender: AnyObject) {
    isHighActivity = !isHighActivity
  }
  
  @IBAction func toggleHotDayMode(sender: AnyObject) {
    isHotDay = !isHotDay
  }
  
  // MARK: Change current screen -
  
  private func toggleCurrentPage() {
    let currentPage = pageViewController.viewControllers.last as! UIViewController
    updateUIAccordingToCurrentPage(currentPage, initial: false)
    if currentPage == pages[0] {
      pageViewController.setViewControllers([pages[1]], direction: .Forward, animated: true, completion: nil)
    } else if currentPage == pages[1] {
      pageViewController.setViewControllers([pages[0]], direction: .Reverse, animated: true, completion: nil)
    }
  }
  
  func switchToSelectDrinkPage() {
    let currentPage = pageViewController.viewControllers.last as! UIViewController
    if currentPage != pages[0] {
      toggleCurrentPage()
    }
  }

  private func updateUIAccordingToCurrentPage(page: UIViewController, initial: Bool) {
    if navigationTitleLabel == nil {
      return
    }
    
    let title: String
    if page == selectDrinkViewController {
      title = NSLocalizedString("DVC:Water Balance", value: "Water Balance", comment: "DayViewController: Top bar title for water balance page")
    } else {
      title = NSLocalizedString("DVC:Diary", value: "Diary", comment: "DayViewController: Top bar title for water intakes diary")
    }
    
    if initial {
      navigationTitleLabel.text = title
    } else {
      navigationTitleLabel.setTextWithAnimation(title)
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let identifier = segue.identifier {
      switch identifier {
      case Constants.showCalendarSegue:
        if let calendarViewController = segue.destinationViewController.contentViewController as? CalendarViewController {
          calendarViewController.date = currentDate
          calendarViewController.dayViewController = self
        }
      case Constants.pageViewEmbedSegue:
        if let pageViewController = segue.destinationViewController as? UIPageViewController {
          self.pageViewController = pageViewController
          setupPageViewController(pageViewController)
        }
      default: break;
      }
    }
  }
  
  // MARK: Intakes management -
  
  private func fetchWaterGoal() {
    waterGoal = WaterGoal.fetchWaterGoalForDate(currentDate, managedObjectContext: managedObjectContext)
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
    if !Settings.notificationsEnabled.value {
      return
    }
    
    let isToday = DateHelper.areDatesEqualByDays(date1: NSDate(), date2: currentDate)
    if !isToday {
      return
    }
    
    if Settings.notificationsUseWaterIntake.value && dailyWaterIntake >= waterGoalAmount {
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
      performSegueWithIdentifier(Constants.showCompleteSegue, sender: self)
    }
  }

  func removeIntake(intake: Intake) {
    let index = find(intakes, intake)
    if index == nil {
      Logger.logError("Intake for removing is not found")
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
    Settings.uiDisplayDailyWaterIntakeInPercents.value = !Settings.uiDisplayDailyWaterIntakeInPercents.value
    updateIntakeButton()
  }
  
  private func updateIntakeButton() {
    let intakeText: String
    
    if Settings.uiDisplayDailyWaterIntakeInPercents.value {
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

    highActivityButton.selected = isHighActivity
    hotDayButton.selected = isHotDay
  }
  
  private func saveWaterGoalForCurrentDate(#baseAmount: Double, isHotDay: Bool, isHighActivity: Bool) {
    waterGoal = WaterGoal.addEntity(
      date: currentDate,
      baseAmount: baseAmount,
      isHotDay: isHotDay,
      isHighActivity: isHighActivity,
      managedObjectContext: managedObjectContext)
  }
  
  // MARK: Private properties -
  
  private var waterGoal: WaterGoal?
  
  private var isWaterGoalForCurrentDay: Bool {
    if let waterGoal = waterGoal {
      return DateHelper.areDatesEqualByDays(date1: waterGoal.date, date2: currentDate)
    } else {
      return false
    }
  }
  
  private var isHotDay: Bool {
    get {
      if isWaterGoalForCurrentDay {
        return waterGoal?.isHotDay ?? false
      } else {
        return false
      }
    }
    set {
      if !isWaterGoalForCurrentDay {
        saveWaterGoalForCurrentDate(baseAmount: waterGoalBaseAmount, isHotDay: newValue, isHighActivity: false)
      } else {
        waterGoal?.isHotDay = newValue
        ModelHelper.save(managedObjectContext: managedObjectContext)
      }
      
      waterGoalWasChanged()
    }
  }

  private var isHighActivity: Bool {
    get {
      if isWaterGoalForCurrentDay {
        return waterGoal?.isHighActivity ?? false
      } else {
        return false
      }
    }
    set {
      if !isWaterGoalForCurrentDay {
        saveWaterGoalForCurrentDate(baseAmount: waterGoalBaseAmount, isHotDay: false, isHighActivity: newValue)
      } else {
        waterGoal?.isHighActivity = newValue
        ModelHelper.save(managedObjectContext: managedObjectContext)
      }
      
      waterGoalWasChanged()
    }
  }
  
  private var waterGoalBaseAmount: Double {
    return waterGoal?.baseAmount ?? Settings.userWaterGoal.value
  }
  
  private var waterGoalAmount: Double {
    return waterGoalBaseAmount * (1 + hotDayExtraFactor + highActivityExtraFactor)
  }
  
  private var hotDayExtraFactor: Double {
    if isWaterGoalForCurrentDay {
      return waterGoal?.hotDayFactor ?? 0
    } else {
      return 0
    }
  }

  private var highActivityExtraFactor: Double {
    if isWaterGoalForCurrentDay {
      return waterGoal?.highActivityFactor ?? 0
    } else {
      return 0
    }
  }
  
  private var intakes: [Intake] = []
  private var multiProgressSections: [Drink: MultiProgressView.Section] = [:]
  
  private var pages: [UIViewController] = []
  private weak var pageViewController: UIPageViewController!
  private var diaryViewController: DiaryViewController!
  private var selectDrinkViewController: SelectDrinkViewController!
  private var summaryBarOriginalHeight: CGFloat!

  private let amountPrecision = Settings.generalVolumeUnits.value.precision
  private let amountDecimals = Settings.generalVolumeUnits.value.decimals

  private var isCurrentDayToday: Bool {
    return !Settings.uiUseCustomDateForDayView.value
  }
  
  private lazy var managedObjectContext: NSManagedObjectContext? = {
    if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
      return appDelegate.managedObjectContext
    } else {
      return nil
    }
  }()
}

// MARK: UIPageViewControllerDataSource -

extension DayViewController: UIPageViewControllerDataSource {
  
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
  
}

// MARK: UIPageViewControllerDelegate -

extension DayViewController: UIPageViewControllerDelegate {

  func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
    let currentPage = pageViewController.viewControllers.last as! UIViewController
    updateUIAccordingToCurrentPage(currentPage, initial: false)
  }
  
}

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