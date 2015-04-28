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
  
  @IBOutlet weak var intakesMultiProgressView: MultiProgressView!
  @IBOutlet weak var intakeButton: UIButton!
  @IBOutlet weak var highActivityButton: UIButton!
  @IBOutlet weak var hotDayButton: UIButton!
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var navigationTitleLabel: UILabel!
  @IBOutlet weak var navigationDateLabel: UILabel!
  @IBOutlet weak var summaryView: DaySummaryView!

  // MARK: Public properties -
  
  /// Current date for managing water intake
  private var date: NSDate! {
    didSet {
      if mode == .General {
        if DateHelper.areDatesEqualByDays(date, NSDate()) {
          Settings.uiUseCustomDateForDayView.value = false
        } else {
          Settings.uiUseCustomDateForDayView.value = true
          Settings.uiCustomDateForDayView.value = date
        }
      }
      
      diaryViewController?.date = date
      selectDrinkViewController?.date = date
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
    static let dayGuide1ViewControllerStoryboardID = "DayGuide1ViewController"
    static let dayGuide2ViewControllerStoryboardID = "DayGuide2ViewController"
    static let congratulationsViewNib = "CongratulationsView"
  }
  
  private enum GuideState {
    case None, Page1, Page2, Finished
  }
  
  private var guideState: GuideState = .None
  private var dayGuide1ViewController: DayGuide1ViewController!
  private var dayGuide2ViewController: DayGuide2ViewController!
  
  private var volumeObserverIdentifier: Int?
  
  private var managedObjectContext: NSManagedObjectContext { return CoreDataStack.privateContext }
  
  
  // MARK: Page setup -
  
  override func viewDidLoad() {
    super.viewDidLoad()

    applyStyle()
    setupNotificationsObservation()
    setupGestureRecognizers()
    setupMultiprogressControl()
    obtainCurrentDate()
    updateUIRelatedToCurrentDate(animate: false)
    updateSummaryBar(animate: false, completion: nil)
    
    volumeObserverIdentifier = Settings.generalVolumeUnits.addObserver { [unowned self] value in
      self.updateIntakeButton()
    }
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
    
    if let volumeObserverIdentifier = volumeObserverIdentifier {
      Settings.generalVolumeUnits.removeObserver(volumeObserverIdentifier)
    }
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    UIHelper.adjustNavigationTitleViewSize(navigationItem)
  }
    
  private func setupNotificationsObservation() {
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "managedObjectContextDidChange:",
      name: GlobalConstants.notificationManagedObjectContextWasMerged,
      object: nil)
    
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "managedObjectContextDidChange:",
      name: NSManagedObjectContextDidSaveNotification,
      object: nil)
  }
  
  func managedObjectContextDidChange(notification: NSNotification) {
    updateSummaryBar(animate: true) {
      self.checkForCongratulationsAboutWaterGoalReaching(notification)
    }
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    refreshCurrentDay(showAlert: false)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    if !Settings.uiDayPageHasDisplayedOnce.value {
//      continueGuide()
    }
  }
  
  func continueGuide() {
    switch guideState {
    case .None: showGuidePage1()
    case .Page1: showGuidePage2()
    case .Page2: finishGuide()//Settings.uiDayPageHasDisplayedOnce.value = true
    case .Finished: break
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
    
    guideState = .Finished
  }
  
  private func obtainCurrentDate() {
    if mode == .General && Settings.uiUseCustomDateForDayView.value {
      date = Settings.uiCustomDateForDayView.value
    } else {
      if date == nil {
        date = NSDate()
      }
    }
  }
  
  private func applyStyle() {
    UIHelper.applyStyle(self)
    navigationTitleLabel.textColor = StyleKit.barTextColor
    navigationDateLabel.textColor = StyleKit.barTextColor
  }
  
  func refreshCurrentDay(#showAlert: Bool) {
    let dayIsSwitched = !DateHelper.areDatesEqualByDays(date, NSDate())
    
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
    self.date = date

    if isViewLoaded() {
      updateUIRelatedToCurrentDate(animate: true)
      updateSummaryBar(animate: true, completion: nil)
    }
  }
  
  func getCurrentDate() -> NSDate {
    return date
  }
  
  private func setupGestureRecognizers() {
    if let navigationBar = navigationController?.navigationBar {
      let leftSwipe = UISwipeGestureRecognizer(target: self, action: "leftSwipeGestureIsRecognized:")
      leftSwipe.direction = .Left
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
    selectDrinkViewController.date = date
    
    pages.append(selectDrinkViewController)
    
    // Add intakes diary view controller
    diaryViewController = LoggedActions.instantiateViewController(storyboard: storyboard, storyboardID: Constants.diaryViewControllerStoryboardID)
    diaryViewController.date = date
    
    pages.append(diaryViewController)
    
    pageViewController.dataSource = self
    pageViewController.delegate = self
    pageViewController.setViewControllers([selectDrinkViewController], direction: .Forward, animated: false, completion: nil)
    
    updateUIAccordingToCurrentPage(selectDrinkViewController, initial: true)
  }
  
  // MARK: Day selection -
  
  func leftSwipeGestureIsRecognized(gestureRecognizer: UISwipeGestureRecognizer) {
    if gestureRecognizer.state == .Ended {
      let daysTillToday = DateHelper.computeUnitsFrom(date, toDate: NSDate(), unit: .CalendarUnitDay)
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
    setCurrentDate(DateHelper.addToDate(date, years: 0, months: 0, days: 1))
  }

  private func switchToPreviousDay() {
    setCurrentDate(DateHelper.addToDate(date, years: 0, months: 0, days: -1))
  }

  private func updateUIRelatedToCurrentDate(#animate: Bool) {
    let formattedDate = DateHelper.stringFromDate(date)
    
    if animate {
      navigationDateLabel.setTextWithAnimation(formattedDate) {
        UIHelper.adjustNavigationTitleViewSize(self.navigationItem)
      }
    } else {
      navigationDateLabel.text = formattedDate
      UIHelper.adjustNavigationTitleViewSize(navigationItem)
    }
  }
  
  private func updateSummaryBar(#animate: Bool, completion: (() -> ())?) {
    managedObjectContext.performBlock {
      self.waterGoal = WaterGoal.fetchWaterGoalForDate(self.date, managedObjectContext: self.managedObjectContext)
      self.intakes = Intake.fetchIntakesForDay(self.date, dayOffsetInHours: 0, managedObjectContext: self.managedObjectContext)
      
      let intakeAmounts = Intake.fetchTotalWaterAmountsGroupedByDrinksForDay(self.date, dayOffsetInHours: 0, managedObjectContext: self.managedObjectContext)
      
      dispatch_async(dispatch_get_main_queue()) {
        if animate {
          self.intakesMultiProgressView.updateWithAnimation {
            self.waterGoalWasChanged()
            self.updateWaterIntakeAmounts(intakeAmounts)
          }
        } else {
          self.intakesMultiProgressView.update {
            self.waterGoalWasChanged()
            self.updateWaterIntakeAmounts(intakeAmounts)
          }
        }
        
        completion?()
      }
    }
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
      title = NSLocalizedString("DVC:Drinks", value: "Drinks", comment: "DayViewController: Top bar title for page with drinks selection")
    } else {
      title = NSLocalizedString("DVC:Diary", value: "Diary", comment: "DayViewController: Top bar title for water intakes diary")
    }
    
    if initial {
      navigationTitleLabel.text = title
      UIHelper.adjustNavigationTitleViewSize(navigationItem)
    } else {
      navigationTitleLabel.setTextWithAnimation(title) {
        UIHelper.adjustNavigationTitleViewSize(self.navigationItem)
      }
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let identifier = segue.identifier {
      switch identifier {
      case Constants.showCalendarSegue:
        if let calendarViewController = segue.destinationViewController.contentViewController as? CalendarViewController {
          calendarViewController.date = date
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
  
  private func updateWaterIntakeAmounts(intakeAmounts: [Drink: Double]) {
    // Clear all drink sections
    for (_, section) in multiProgressSections {
      section.factor = 0.0
    }
    
    // Fill sections with fetched intakes and compute daily water intake
    var overallWaterIntake: Double = 0
    for (drink, amount) in intakeAmounts {
      overallWaterIntake += amount
      if let section = multiProgressSections[drink] {
        section.factor = CGFloat(amount)
      }
    }
    dailyWaterIntake = overallWaterIntake
  }
  
  private func checkForCongratulationsAboutWaterGoalReaching(notification: NSNotification) {
    let currentDate = NSDate()
    
    let isToday = DateHelper.areDatesEqualByDays(currentDate, date)
    if !isToday {
      return
    }
    
    let waterGoalReachingIsShownForToday = DateHelper.areDatesEqualByDays(currentDate, Settings.uiWaterGoalReachingIsShownForDate.value)
    if waterGoalReachingIsShownForToday {
      return
    }
    
    if dailyWaterIntake < waterGoalAmount {
      return
    }
    
    if let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> {
      for insertedObject in insertedObjects {
        if let intake = insertedObject as? Intake where DateHelper.areDatesEqualByDays(intake.date, currentDate) {
          Settings.uiWaterGoalReachingIsShownForDate.value = currentDate
          showCongratulationsAboutWaterGoalReaching()
          break
        }
      }
    }
  }

  private func showCongratulationsAboutWaterGoalReaching() {
    let nib = UINib(nibName: Constants.congratulationsViewNib, bundle: nil)
    
    if let congratulationsView = nib.instantiateWithOwner(nil, options: nil).first as? UIView {
      let frame = summaryView.convertRect(summaryView.frame, toView: navigationController!.view)

      congratulationsView.frame = frame.rectByInsetting(dx: 0, dy: 1)
      congratulationsView.layer.opacity = 0
      congratulationsView.layer.transform = CATransform3DMakeScale(0.7, 0.7, 0.7)
      
      navigationController!.view.addSubview(congratulationsView)
        
      UIView.animateWithDuration(0.6,
        delay: 0,
        usingSpringWithDamping: 0.4,
        initialSpringVelocity: 1.7,
        options: .CurveEaseInOut | .AllowUserInteraction,
        animations: {
          congratulationsView.layer.opacity = 1
          congratulationsView.layer.transform = CATransform3DMakeScale(1, 1, 1)
        },
        completion: { (finished) -> Void in
          UIView.animateWithDuration(0.6,
            delay: 5,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 10,
            options: .CurveEaseInOut | .AllowUserInteraction,
            animations: {
              congratulationsView.layer.opacity = 0
              congratulationsView.layer.transform = CATransform3DMakeScale(0.7, 0.7, 0.7)
            },
            completion: { (finished) -> Void in
              congratulationsView.removeFromSuperview()
            })
        }
      )
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
    intakesMultiProgressView.updateWithAnimation { [unowned self] in
      self.intakesMultiProgressView.maximum = CGFloat(self.waterGoalAmount)
    }

    highActivityButton.selected = isHighActivity
    hotDayButton.selected = isHotDay
  }
  
  private func saveWaterGoalForCurrentDate(#baseAmount: Double, isHotDay: Bool, isHighActivity: Bool) {
    managedObjectContext.performBlock {
      self.waterGoal = WaterGoal.addEntity(
        date: self.date,
        baseAmount: baseAmount,
        isHotDay: isHotDay,
        isHighActivity: isHighActivity,
        managedObjectContext: self.managedObjectContext)
    }
  }
  
  // MARK: Private properties -
  
  private var waterGoal: WaterGoal?
  
  private var isWaterGoalForCurrentDay: Bool {
    if let waterGoal = waterGoal {
      return DateHelper.areDatesEqualByDays(waterGoal.date, date)
    } else {
      return false
    }
  }
  
  private var isHotDay: Bool {
    get {
      return isWaterGoalForCurrentDay ? (waterGoal?.isHotDay ?? false) : false
    }
    set {
      saveWaterGoalForCurrentDate(baseAmount: waterGoalBaseAmount, isHotDay: newValue, isHighActivity: false)
    }
  }

  private var isHighActivity: Bool {
    get {
      return isWaterGoalForCurrentDay ? (waterGoal?.isHighActivity ?? false) : false
    }
    set {
      saveWaterGoalForCurrentDate(baseAmount: waterGoalBaseAmount, isHotDay: false, isHighActivity: newValue)
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

  private var amountPrecision: Double { return Settings.generalVolumeUnits.value.precision }
  private var amountDecimals: Int { return Settings.generalVolumeUnits.value.decimals }

  private var isCurrentDayToday: Bool {
    return !Settings.uiUseCustomDateForDayView.value
  }
  
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