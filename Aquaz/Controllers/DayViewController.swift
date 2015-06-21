//
//  DayViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 03.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit
import CoreData
import iAd

class DayViewController: UIViewController, UIAlertViewDelegate, ADInterstitialAdDelegate {
  
  // MARK: UI elements -
  
  @IBOutlet weak var intakesMultiProgressView: MultiProgressView!
  @IBOutlet weak var intakeButton: UIButton!
  @IBOutlet weak var highActivityButton: UIButton!
  @IBOutlet weak var hotDayButton: UIButton!
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var navigationTitleLabel: UILabel!
  @IBOutlet weak var navigationDateLabel: UILabel!
  @IBOutlet weak var summaryView: BannerView!

  // MARK: Localization -
  
  private struct LocalizedStrings {
    
    lazy var welcomeToNextDayMessage = NSLocalizedString("DVC:Welcome to the next day",
      value: "Welcome to the next day",
      comment: "DayViewController: Title for alert displayed if tomorrow has come")
    
    lazy var okButtonTitle = NSLocalizedString("DVC:OK",
      value: "OK",
      comment: "DayViewController: Cancel button title for alert displayed if tomorrow has come")
    
    lazy var drinksTitle = NSLocalizedString("DVC:Drinks",
      value: "Drinks",
      comment: "DayViewController: Top bar title for page with drinks selection")
    
    lazy var diaryTitle = NSLocalizedString("DVC:Diary",
      value: "Diary",
      comment: "DayViewController: Top bar title for water intakes diary")
    
    lazy var rateApplicationAlertTitle = NSLocalizedString("DVC:Rate Aquaz",
      value: "Rate Aquaz",
      comment: "DayViewController: Alert\'s title suggesting user to rate the application")
    
    lazy var rateApplicationAlertMessage = NSLocalizedString("DVC:If you enjoy using Aquaz, would you mind taking a moment to rate it?\nThanks for your support!",
      value: "If you enjoy using Aquaz, would you mind taking a moment to rate it?\nThanks for your support!",
      comment: "DayViewController: Alert\'s message suggesting user to rate the application")
    
    lazy var rateApplicationAlertRateText = NSLocalizedString("DVC:Rate It Now",
      value: "Rate It Now",
      comment: "DayViewController: Title for alert\'s button allowing user to rate the application")
    
    lazy var rateApplicationAlertRemindLaterText = NSLocalizedString("DVC:Remind Me Later",
      value: "Remind Me Later",
      comment: "DayViewController: Title for alert\'s button allowing user to postpone rating the application")
    
    lazy var rateApplicationAlertNoText = NSLocalizedString("DVC:No, Thanks",
      value: "No, Thanks",
      comment: "DayViewController: Title for alert\'s button allowing user to reject rating the applcation")
    
    lazy var intakeButtonTextTemplate = NSLocalizedString("DVC:%1$@ of %2$@",
      value: "%1$@ of %2$@",
      comment: "DayViewController: Current daily water intake of water intake goal")

    lazy var helpTipSwipeToSeeDiary = NSLocalizedString("DVC:Swipe up to see the diary",
      value: "Swipe up to see the diary",
      comment: "DayViewController: Text for help tip about swiping for seeing the diary")

    lazy var helpTipSwipeToChangeDay = NSLocalizedString("DVC:Swipe to change day",
      value: "Swipe to change day",
      comment: "DayViewController: Text for help tip about swiping for changing day")

    lazy var helpTipHighActivityMode = NSLocalizedString("DVC:Tap to toggle High Activity mode",
      value: "Tap to toggle High Activity mode",
      comment: "DayViewController: Text for help tip about activating/deactivating High Activity mode")
    
    lazy var helpTipHotWeatherMode = NSLocalizedString("DVC:Tap to toggle Hot Weather mode",
      value: "Tap to toggle Hot Weather mode",
      comment: "DayViewController: Text for help tip about activating/deactivating Hot Weather mode")

    lazy var helpTipSwitchToPercentAndViceVersa = NSLocalizedString("DVC:Tap to switch between percents and volume",
      value: "Tap to switch between percents and volume",
      comment: "DayViewController: Text for help tip about switching between percents and volume representation of overall intake for a day")

    lazy var helpTipLongPressToChooseAlcohol = NSLocalizedString("DVC:Long press to choose an alcoholic drink",
      value: "Long press to choose an alcoholic drink",
      comment: "DayViewController: Text for help tip about choosing an alcoholic drink")

    lazy var congratulationsBannerText = NSLocalizedString("DVC:Congratulations!\nYou have drunk your daily water intake.",
      value: "Congratulations!\nYou have drunk your daily water intake.",
      comment: "DayViewController: Text for banner shown if a user drink his daily water intake")

  }
  
  private var localizedStrings = LocalizedStrings()

  // MARK: Properties -
  
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
  
  private var totalHydrationAmount: Double = 0.0
  
  enum Mode {
    case General, Statistics
  }
  
  var mode: Mode = .General
  private var helptip: JDFTooltipView?
  
  private struct Constants {
    static let selectDrinkViewControllerStoryboardID = "SelectDrinkViewController"
    static let diaryViewControllerStoryboardID = "DiaryViewController"
    static let showCalendarSegue = "ShowCalendar"
    static let pageViewEmbedSegue = "PageViewEmbed"
  }
  
  private var volumeObserverIdentifier: Int?
  
  private var managedObjectContext: NSManagedObjectContext { return CoreDataStack.privateContext }
  
  private var interstitialAd: ADInterstitialAd?
  private var viewForAd: UIView?
  
  // MARK: Page setup -
  
  override func viewDidLoad() {
    super.viewDidLoad()

    applyStyle()
    setupNotificationsObservation()
    setupGestureRecognizers()
    setupMultiprogressControl()
    obtainCurrentDate()
    
    intakeButton.setTitle("", forState: .Normal)

    updateUIRelatedToCurrentDate(animated: false)
    updateSummaryBar(animated: false, completion: nil)
    
    volumeObserverIdentifier = Settings.generalVolumeUnits.addObserver { [unowned self] value in
      self.updateIntakeButton(animated: false)
    }
    
    if !Settings.generalFullVersion.value {
      initInterstitialAd()
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

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    refreshCurrentDay(showAlert: false)
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    helptip?.hideAnimated(true)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    if mode == .General && Settings.uiDayPageHelpTipToShow.value == Settings.DayPageHelpTip(rawValue: 0)! {
        checkHelpTip()
    }
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
    updateSummaryBar(animated: true) {
      if !self.checkForCongratulationsAboutWaterGoalReaching(notification) {
        self.checkForHelpTip(notification)
      }
      
      if !Settings.generalFullVersion.value {
        self.checkForShowInterstialAd(notification)
      }
    }
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
        let alert = UIAlertView(title: nil, message: localizedStrings.welcomeToNextDayMessage, delegate: nil, cancelButtonTitle: localizedStrings.okButtonTitle)
        alert.show()
      }

      setCurrentDate(NSDate())
    }
  }
  
  func setCurrentDate(date: NSDate) {
    self.date = date

    if isViewLoaded() {
      updateUIRelatedToCurrentDate(animated: true)
      updateSummaryBar(animated: true, completion: nil)
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
    intakesMultiProgressView.animationDuration = 0.7
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

  private func updateUIRelatedToCurrentDate(#animated: Bool) {
    let formattedDate = DateHelper.stringFromDate(date)
    
    if animated {
      navigationDateLabel.setTextWithAnimation(formattedDate) {
        UIHelper.adjustNavigationTitleViewSize(self.navigationItem)
      }
    } else {
      navigationDateLabel.text = formattedDate
      UIHelper.adjustNavigationTitleViewSize(navigationItem)
    }
  }
  
  private func updateSummaryBar(#animated: Bool, completion: (() -> ())?) {
    managedObjectContext.performBlock {
      self.waterGoal = WaterGoal.fetchWaterGoalForDate(self.date, managedObjectContext: self.managedObjectContext)
      
      self.totalDehydrationAmount = Intake.fetchTotalDehydrationAmountForDay(self.date,
        dayOffsetInHours: 0, managedObjectContext: self.managedObjectContext)
      
      let intakeHydrationAmounts = Intake.fetchHydrationAmountsGroupedByDrinksForDay(self.date,
        dayOffsetInHours: 0, managedObjectContext: self.managedObjectContext)
      
      dispatch_async(dispatch_get_main_queue()) {
        if animated {
          self.intakesMultiProgressView.updateWithAnimation {
            self.updateIntakeHydrationAmounts(intakeHydrationAmounts)
            self.waterGoalWasChanged(animated: animated)
          }
        } else {
          self.intakesMultiProgressView.update {
            self.updateIntakeHydrationAmounts(intakeHydrationAmounts)
            self.waterGoalWasChanged(animated: animated)
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
    
    let title = (page == selectDrinkViewController) ? localizedStrings.drinksTitle : localizedStrings.diaryTitle
    
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
  
  private func updateIntakeHydrationAmounts(intakeHydrationAmounts: [Drink: Double]) {
    // Clear all drink sections
    for (_, section) in multiProgressSections {
      section.factor = 0.0
    }
    
    // Fill sections with fetched intakes and compute daily water intake
    var totalHydrationAmount: Double = 0
    for (drink, hydrationAmount) in intakeHydrationAmounts {
      totalHydrationAmount += hydrationAmount
      if let section = multiProgressSections[drink] {
        section.factor = CGFloat(hydrationAmount)
      }
    }
    
    self.totalHydrationAmount = totalHydrationAmount
  }
  
  private func checkForCongratulationsAboutWaterGoalReaching(notification: NSNotification) -> Bool {
    let currentDate = NSDate()
    
    let isToday = DateHelper.areDatesEqualByDays(currentDate, date)
    if !isToday {
      return false
    }
    
    let waterGoalReachingIsShownForToday = DateHelper.areDatesEqualByDays(currentDate, Settings.uiWaterGoalReachingIsShownForDate.value)
    if waterGoalReachingIsShownForToday {
      return false
    }
    
    if totalHydrationAmount < waterGoalAmount {
      return false
    }
    
    if let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> {
      for insertedObject in insertedObjects {
        if let intake = insertedObject as? Intake where DateHelper.areDatesEqualByDays(intake.date, currentDate) {
          Settings.uiWaterGoalReachingIsShownForDate.value = currentDate
          showCongratulationsAboutWaterGoalReaching()
          
          SystemHelper.executeBlockWithDelay(2) {
            self.checkForRateApplicationAlert(notification)
          }
          
          return true
        }
      }
    }
    
    return false
  }

  private func checkForHelpTip(notification: NSNotification) {
    if Settings.uiDayPageHelpTipToShow.value == .None {
      return
    }
    
    let currentDate = NSDate()

    if let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> {
      for insertedObject in insertedObjects {
        if let intake = insertedObject as? Intake where DateHelper.areDatesEqualByDays(intake.date, currentDate) {
          Settings.uiDayPageIntakesCountTillHelpTip.value = Settings.uiDayPageIntakesCountTillHelpTip.value - 1
          if Settings.uiDayPageIntakesCountTillHelpTip.value <= 0 {
            checkHelpTip()
          }
          break
        }
      }
    }
  }
  
  private func checkForRateApplicationAlert(notification: NSNotification) {
    if Settings.uiWritingReviewAlertSelection.value != .RemindLater {
      return
    }
    
    if DateHelper.calcDistanceBetweenCalendarDates(fromDate: Settings.uiWritingReviewAlertLastShownDate.value, toDate: NSDate(), calendarUnit: .CalendarUnitDay) < 3 {
      return
    }
    
    let currentDate = NSDate()
    
    if let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> {
      for insertedObject in insertedObjects {
        if let intake = insertedObject as? Intake where DateHelper.areDatesEqualByDays(intake.date, currentDate) {
          showRateApplicationAlert()
          break
        }
      }
    }
  }
  
  private func showRateApplicationAlert() {
    Settings.uiWritingReviewAlertLastShownDate.value = NSDate()

    let alert = UIAlertView(
      title: localizedStrings.rateApplicationAlertTitle,
      message: localizedStrings.rateApplicationAlertMessage,
      delegate: self,
      cancelButtonTitle: localizedStrings.rateApplicationAlertNoText,
      otherButtonTitles: localizedStrings.rateApplicationAlertRateText, localizedStrings.rateApplicationAlertRemindLaterText)

    alert.show()
  }
  
  func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
    switch buttonIndex {
    case 0: // No, Thanks
      Settings.uiWritingReviewAlertSelection.value = .No
      
    case 1: // Rate It Now
      if let url = NSURL(string: GlobalConstants.appStoreLink) {
        UIApplication.sharedApplication().openURL(url)
      }
      Settings.uiWritingReviewAlertSelection.value = .RateApplication
      
    case 2: // Remind Me Later
      Settings.uiWritingReviewAlertSelection.value = .RemindLater
      
    default: break
    }
  }

  private func showCongratulationsAboutWaterGoalReaching() {
    let banner = InfoBannerView.create()
    banner.infoLabel.text = localizedStrings.congratulationsBannerText
    banner.infoImageView.image = ImageHelper.loadImage(.BannerReward)
    banner.bannerWasTappedFunction = { _ in banner.hide(animated: true) }
    banner.accessoryImageView.hidden = true

    let frame = summaryView.convertRect(summaryView.frame, toView: navigationController!.view)
    banner.showAndHide(animated: true, displayTime: 4, parentView: navigationController!.view, height: frame.height, minY: frame.minY)
  }

  @IBAction func intakeButtonWasTapped(sender: AnyObject) {
    Settings.uiDisplayDailyWaterIntakeInPercents.value = !Settings.uiDisplayDailyWaterIntakeInPercents.value
    updateIntakeButton(animated: true)
  }
  
  private func updateIntakeButton(#animated: Bool) {
    let intakeText: String
    
    if Settings.uiDisplayDailyWaterIntakeInPercents.value {
      let formatter = NSNumberFormatter()
      formatter.numberStyle = .PercentStyle
      formatter.maximumFractionDigits = 0
      formatter.multiplier = 100
      let hydrationFactor = totalHydrationAmount / waterGoalAmount
      intakeText = formatter.stringFromNumber(hydrationFactor)!
    } else {
      intakeText = Units.sharedInstance.formatMetricAmountToText(
        metricAmount: totalHydrationAmount,
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
    
    let text = String.localizedStringWithFormat(localizedStrings.intakeButtonTextTemplate, intakeText, waterGoalText)
    
    if animated {
      intakeButton.setTitle(text, forState: .Normal)
    } else {
      UIView.performWithoutAnimation {
        self.intakeButton.setTitle(text, forState: .Normal)
        self.intakeButton.layoutIfNeeded()
      }
    }
  }
  
  private func waterGoalWasChanged(#animated: Bool) {
    updateIntakeButton(animated: animated)

    if animated {
      // Update maximum for multi progress control
      intakesMultiProgressView.updateWithAnimation { [unowned self] in
        self.intakesMultiProgressView.maximum = CGFloat(self.waterGoalAmount)
      }
    } else {
      // Update maximum for multi progress control
      intakesMultiProgressView.update { [unowned self] in
        self.intakesMultiProgressView.maximum = CGFloat(self.waterGoalAmount)
      }
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
  
  // MARK: iAd -
  
  private func initInterstitialAd() {
    interstitialPresentationPolicy = .Manual
  }
  
  private func showInterstitialAd() {
    if interstitialAd != nil {
      return
    }
    
    interstitialAd = ADInterstitialAd()
    interstitialAd!.delegate = self
    UIViewController.prepareInterstitialAds()
    
    requestInterstitialAdPresentation()
  }
  
  private func checkForShowInterstialAd(notification: NSNotification) {
    if let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> where !insertedObjects.isEmpty {
      Settings.generalAdCounter.value = Settings.generalAdCounter.value - 1
      
      if Settings.generalAdCounter.value <= 0 {
        showInterstitialAd()
      }
    }	
  }

  private func closeAd() {
    if interstitialAd == nil {
      return
    }
    
    UIView.animateWithDuration(0.5, animations: {
      self.viewForAd!.alpha = 0
      self.viewForAd!.frame.offset(dx: 0, dy: self.viewForAd!.frame.height)
    }) { (finished) -> Void in
      self.interstitialAd = nil
      self.viewForAd?.removeFromSuperview()
      self.viewForAd = nil
    }
  }
  
  func interstitialAdDidLoad(interstitialAd: ADInterstitialAd!) {
    if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate,
       let rootView = appDelegate.window?.rootViewController?.view
    {
      Settings.generalAdCounter.value = GlobalConstants.numberOfIntakesToShowAd

      viewForAd = UIView(frame: rootView.frame.rectByOffsetting(dx: 0, dy: rootView.frame.height))
      viewForAd!.alpha = 0
      interstitialAd.presentInView(viewForAd!)

      rootView.addSubview(self.viewForAd!)

      UIView.animateWithDuration(0.5, animations: {
        self.viewForAd!.alpha = 1
        self.viewForAd!.frame = rootView.frame
      }, completion: nil)
    }
  }
  
  func interstitialAdDidUnload(interstitialAd: ADInterstitialAd!) {
    closeAd()
  }
  
  func interstitialAd(interstitialAd: ADInterstitialAd!, didFailWithError error: NSError!) {
    closeAd()
  }
  
  func interstitialAdActionDidFinish(interstitialAd: ADInterstitialAd!) {
    closeAd()
  }
  
  // MARK: Help tips -

  private func checkHelpTip() {
    if helptip != nil {
      return
    }
    
    switch Settings.uiDayPageHelpTipToShow.value {
    case .SlideToSeeDiary:
      showHelpTipForSlideToSeeDiary()
      
    case .SlideToChangeDay:
      showHelpTipForSlideToChangeDay()
      
    case .HighActivityMode:
      showHelpTipForHighActivityMode()
      
    case .HotWeatherMode:
      showHelpTipForHotWeatherMode()
      
    case .SwitchToPercentsAndViceVersa:
      showHelpTipForSwitchToPercentAndViceVersa()
      
    case .LongPressToChooseAlcohol:
      showHelpTipForLongPressToChooseAlcohol()
      
    case .None: break
    }
  }
  
  private func switchToNextHelpTip() {
    Settings.uiDayPageHelpTipToShow.value = Settings.DayPageHelpTip(rawValue: Settings.uiDayPageHelpTipToShow.value.rawValue + 1)!
    
    // Reset help tips counter. Help tips should be shown after every 2 intakes.
    Settings.uiDayPageIntakesCountTillHelpTip.value = 2
  }
  
  private func showHelpTipForSlideToSeeDiary() {
    SystemHelper.executeBlockWithDelay(GlobalConstants.helpTipDelayToShow) {
      if self.view.window == nil {
        return
      }
      
      let helpTip = JDFTooltipView(
        targetPoint: CGPoint(x: self.view.center.x, y: self.view.bounds.maxY - 10),
        hostView: self.view,
        tooltipText: self.localizedStrings.helpTipSwipeToSeeDiary,
        arrowDirection: .Down,
        width: self.view.frame.width / 2)
      
      self.showHelpTip(helpTip)
    }
  }
  
  private func showHelpTipForSlideToChangeDay() {
    SystemHelper.executeBlockWithDelay(GlobalConstants.helpTipDelayToShow) {
      if self.view.window == nil {
        return
      }
      
      let helpTip = JDFTooltipView(
        targetView: self.navigationDateLabel,
        hostView: self.navigationController?.view,
        tooltipText: self.localizedStrings.helpTipSwipeToChangeDay,
        arrowDirection: .Up,
        width: self.view.frame.width / 2)
      
      self.showHelpTip(helpTip)
    }
  }
  
  private func showHelpTipForHighActivityMode() {
    SystemHelper.executeBlockWithDelay(GlobalConstants.helpTipDelayToShow) {
      if self.view.window == nil {
        return
      }
      
      let helpTip = JDFTooltipView(
        targetView: self.highActivityButton,
        hostView: self.view,
        tooltipText: self.localizedStrings.helpTipHighActivityMode,
        arrowDirection: .Up,
        width: self.view.frame.width / 2)
      
      self.showHelpTip(helpTip)
    }
  }
  
  private func showHelpTipForHotWeatherMode() {
    SystemHelper.executeBlockWithDelay(GlobalConstants.helpTipDelayToShow) {
      if self.view.window == nil {
        return
      }
      
      let helpTip = JDFTooltipView(
        targetView: self.hotDayButton,
        hostView: self.view,
        tooltipText: self.localizedStrings.helpTipHotWeatherMode,
        arrowDirection: .Up,
        width: self.view.frame.width / 2)
      
      self.showHelpTip(helpTip)
    }
  }
  
  private func showHelpTipForSwitchToPercentAndViceVersa() {
    SystemHelper.executeBlockWithDelay(GlobalConstants.helpTipDelayToShow) {
      if self.view.window == nil {
        return
      }
      
      let helpTip = JDFTooltipView(
        targetView: self.intakeButton,
        hostView: self.view,
        tooltipText: self.localizedStrings.helpTipSwitchToPercentAndViceVersa,
        arrowDirection: .Up,
        width: self.view.frame.width / 2)
      
      self.showHelpTip(helpTip)
    }
  }
  
  private func showHelpTipForLongPressToChooseAlcohol() {
    SystemHelper.executeBlockWithDelay(GlobalConstants.helpTipDelayToShow) {
      if self.view.window == nil {
        return
      }
      
      let lastCellIndex = self.selectDrinkViewController!.collectionView.numberOfItemsInSection(0) - 1
      let cell = self.selectDrinkViewController!.collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: lastCellIndex, inSection: 0))
      
      let tooltip = JDFTooltipView(
        targetView: cell,
        hostView: self.selectDrinkViewController!.collectionView,
        tooltipText: self.localizedStrings.helpTipLongPressToChooseAlcohol,
        arrowDirection: .Down,
        width: self.view.frame.width / 2)
      
      self.showHelpTip(tooltip)
    }
  }
  
  private func showHelpTip(helpTip: JDFTooltipView) {
    self.helptip = helpTip

    switchToNextHelpTip()

    UIHelper.showHelpTip(helpTip) {
      self.helptip = nil
    }
  }

  // MARK: Private properties -
  
  private var waterGoal: WaterGoal?
  
  private var totalDehydrationAmount: Double = 0
  
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
      saveWaterGoalForCurrentDate(baseAmount: waterGoalBaseAmount, isHotDay: newValue, isHighActivity: isHighActivity)
    }
  }

  private var isHighActivity: Bool {
    get {
      return isWaterGoalForCurrentDay ? (waterGoal?.isHighActivity ?? false) : false
    }
    set {
      saveWaterGoalForCurrentDate(baseAmount: waterGoalBaseAmount, isHotDay: isHotDay, isHighActivity: newValue)
    }
  }
  
  private var waterGoalBaseAmount: Double {
    return waterGoal?.baseAmount ?? Settings.userDailyWaterIntake.value
  }
  
  private var waterGoalAmount: Double {
    return waterGoalBaseAmount * (1 + hotDayExtraFactor + highActivityExtraFactor) + totalDehydrationAmount
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