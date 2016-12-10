//
//  DayViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 03.10.14.
//  Copyright © 2014 Sergey Balyakin. All rights reserved.
//

import UIKit
import CoreData

class DayViewController: UIViewController, UIAlertViewDelegate {
  
  // MARK: UI elements -
  
  @IBOutlet weak var intakesMultiProgressView: MultiProgressView!
  @IBOutlet weak var intakeButton: UIButton!
  @IBOutlet weak var highActivityButton: UIButton!
  @IBOutlet weak var hotDayButton: UIButton!
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var navigationTitleLabel: UILabel!
  @IBOutlet weak var navigationDateLabel: UILabel!
  @IBOutlet weak var summaryView: BannerView!
  @IBOutlet weak var leftArrowForDateImage: UIImageView!
  @IBOutlet weak var rightArrowForDateImage: UIImageView!

  // MARK: Localization -
  
  fileprivate struct LocalizedStrings {
    
    lazy var welcomeToNextDayMessage: String = NSLocalizedString("DVC:Welcome to the next day",
      value: "Welcome to the next day",
      comment: "DayViewController: Title for alert displayed if tomorrow has come")
    
    lazy var okButtonTitle: String = NSLocalizedString("DVC:OK",
      value: "OK",
      comment: "DayViewController: Cancel button title for alert displayed if tomorrow has come")
    
    lazy var drinksTitle: String = NSLocalizedString("DVC:Drinks",
      value: "Drinks",
      comment: "DayViewController: Top bar title for page with drinks selection")
    
    lazy var diaryTitle: String = NSLocalizedString("DVC:Diary",
      value: "Diary",
      comment: "DayViewController: Top bar title for water intakes diary")
    
    lazy var rateApplicationAlertTitle: String = NSLocalizedString("DVC:Rate Aquaz",
      value: "Rate Aquaz",
      comment: "DayViewController: Alert\'s title suggesting user to rate the application")
    
    lazy var rateApplicationAlertMessage: String = NSLocalizedString("DVC:If you enjoy using Aquaz, would you mind taking a moment to rate it?\nThanks for your support!",
      value: "If you enjoy using Aquaz, would you mind taking a moment to rate it?\nThanks for your support!",
      comment: "DayViewController: Alert\'s message suggesting user to rate the application")
    
    lazy var rateApplicationAlertRateText: String = NSLocalizedString("DVC:Rate It Now",
      value: "Rate It Now",
      comment: "DayViewController: Title for alert\'s button allowing user to rate the application")
    
    lazy var rateApplicationAlertRemindLaterText: String = NSLocalizedString("DVC:Remind Me Later",
      value: "Remind Me Later",
      comment: "DayViewController: Title for alert\'s button allowing user to postpone rating the application")
    
    lazy var rateApplicationAlertNoText: String = NSLocalizedString("DVC:No, Thanks",
      value: "No, Thanks",
      comment: "DayViewController: Title for alert\'s button allowing user to reject rating the applcation")
    
    lazy var intakeButtonTextTemplate: String = NSLocalizedString("DVC:%1$@ of %2$@",
      value: "%1$@ of %2$@",
      comment: "DayViewController: Current daily water intake of water intake goal")

    lazy var helpTipAlcoholicDehydration: String = NSLocalizedString("DVC:Alcoholic drinks increase required daily water intake",
      value: "Alcoholic drinks increase required daily water intake",
      comment: "DayViewController: Text for help tip about dehydration because of intake of an alcoholic drink")

    lazy var helpTipSwipeToSeeDiary: String = NSLocalizedString("DVC:Swipe up to see the diary",
      value: "Swipe up to see the diary",
      comment: "DayViewController: Text for help tip about swiping for seeing the diary")

    lazy var helpTipSwipeToChangeDay: String = NSLocalizedString("DVC:Swipe left or right to switch day",
      value: "Swipe left or right to switch day",
      comment: "DayViewController: Text for help tip about swiping for switching displaying day")

    lazy var helpTipHighActivityMode: String = NSLocalizedString("DVC:Tap to toggle High Activity mode",
      value: "Tap to toggle High Activity mode",
      comment: "DayViewController: Text for help tip about activating/deactivating High Activity mode")
    
    lazy var helpTipHotWeatherMode: String = NSLocalizedString("DVC:Tap to toggle Hot Weather mode",
      value: "Tap to toggle Hot Weather mode",
      comment: "DayViewController: Text for help tip about activating/deactivating Hot Weather mode")

    lazy var helpTipSwitchToPercentAndViceVersa: String = NSLocalizedString("DVC:Tap to switch between percentages and volume",
      value: "Tap to switch between percentages and volume",
      comment: "DayViewController: Text for help tip about switching between percentages and volume representation of overall intake for a day")

    lazy var helpTipLongPressToChooseAlcohol: String = NSLocalizedString("DVC:Long press to choose an alcoholic drink",
      value: "Long press to choose an alcoholic drink",
      comment: "DayViewController: Text for help tip about choosing an alcoholic drink")

    lazy var congratulationsBannerText: String = NSLocalizedString("DVC:Congratulations!\nYou have drunk your daily water intake.",
      value: "Congratulations!\nYou have drunk your daily water intake.",
      comment: "DayViewController: Text for banner shown if a user drink his daily water intake")

  }
  
  fileprivate var localizedStrings = LocalizedStrings()

  // MARK: Properties -
  
  /// Current date for managing water intake
  fileprivate var date: Date! {
    didSet {
      Logger.logError(date != nil, "Nil date for DayViewController is passed")
      
      if mode == .general {
        if DateHelper.areEqualDays(date, Date()) {
          Settings.sharedInstance.uiUseCustomDateForDayView.value = false
        } else {
          Settings.sharedInstance.uiUseCustomDateForDayView.value = true
          Settings.sharedInstance.uiCustomDateForDayView.value = date
        }
      }
      
      diaryViewController?.date = date
      selectDrinkViewController?.date = date
    }
  }
  
  fileprivate var totalHydrationAmount: Double = 0.0
  
  enum Mode {
    case general, statistics
  }
  
  var mode: Mode = .general
  
  fileprivate var helpTip: JDFTooltipView?
  
  fileprivate struct Constants {
    static let selectDrinkViewControllerStoryboardID = "SelectDrinkViewController"
    static let diaryViewControllerStoryboardID = "DiaryViewController"
    static let showCalendarSegue = "ShowCalendar"
    static let pageViewEmbedSegue = "PageViewEmbed"
  }
  
  fileprivate var volumeObserver: SettingsObserver?
  
  // MARK: Page setup -
  
  override func viewDidLoad() {
    super.viewDidLoad()

    setupCurrentDate()

    setupUI()
    
    setupNotificationsObservation()

    setupGestureRecognizers()
  }
  
  deinit {
    pageViewController?.dataSource = nil
    pageViewController?.delegate = nil

    NotificationCenter.default.removeObserver(self)
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    UIHelper.adjustNavigationTitleViewSize(navigationItem)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    refreshCurrentDay(showAlert: false)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    helpTip?.hide(animated: true)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    if mode == .general && Settings.sharedInstance.uiDayPageHelpTipToShow.value == Settings.DayPageHelpTip(rawValue: 0)! {
      showNextHelpTip()
    }
  }
  
  fileprivate func setupUI() {
    applyStyle()
    
    setupMultiprogressControl()
    
    intakeButton.setTitle("", for: UIControlState())
    
    updateUIRelatedToCurrentDate(animated: false)
    
    updateSummaryBar(animated: false, completion: nil)
    
    volumeObserver = Settings.sharedInstance.generalVolumeUnits.addObserver { [weak self] _ in
      self?.updateIntakeButton(animated: false)
    }
  }
  
  fileprivate func setupNotificationsObservation() {
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
  
  func managedObjectContextDidChange(_ notification: Notification) {
    updateSummaryBar(animated: true) {
      #if AQUAZLITE
      self.checkCounterForInterstitialAds(notification: notification)
      #endif
      
      if !self.checkForCongratulationsAboutWaterGoalReaching(notification) {
        self.checkForHelpTip(notification)
      }
      
      self.checkForRateApplicationAlert(notification)
    }
  }

  #if AQUAZLITE
  private func checkCounterForInterstitialAds(notification: Notification) {
    if Settings.sharedInstance.generalFullVersion.value || Settings.sharedInstance.generalAdCounter.value <= 0 {
      return
    }
    
    if let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> {
      for insertedObject in insertedObjects {
        if insertedObject is Intake {
          Settings.sharedInstance.generalAdCounter.value -= 1
          break
        }
      }
    }
  }
  #endif
  
  fileprivate func updateWaterGoalRelatedValues() {
    isWaterGoalForCurrentDay = waterGoal != nil ? DateHelper.areEqualDays(waterGoal!.date, date) : false
    
    isHotDay = isWaterGoalForCurrentDay ? (waterGoal?.isHotDay ?? false) : false
    
    isHighActivity = isWaterGoalForCurrentDay ? (waterGoal?.isHighActivity ?? false) : false
    
    waterGoalBaseAmount = waterGoal?.baseAmount ?? Settings.sharedInstance.userDailyWaterIntake.value

    hotDayExtraFactor = isWaterGoalForCurrentDay ? (self.waterGoal?.hotDayFactor ?? 0) : 0
    
    highActivityExtraFactor = isWaterGoalForCurrentDay ? (self.waterGoal?.highActivityFactor ?? 0) : 0
  }
  
  fileprivate func setupCurrentDate() {
    if mode == .general && Settings.sharedInstance.uiUseCustomDateForDayView.value {
      date = Settings.sharedInstance.uiCustomDateForDayView.value as Date!
    } else {
      if date == nil {
        date = Date()
      }
    }
  }
  
  fileprivate func applyStyle() {
    UIHelper.applyStyleToViewController(self)
    navigationTitleLabel.textColor = StyleKit.barTextColor
    navigationDateLabel.textColor = StyleKit.barTextColor
    leftArrowForDateImage.tintColor = StyleKit.barTextColor
    rightArrowForDateImage.tintColor = StyleKit.barTextColor
    // Just for sure in iOS 7
    leftArrowForDateImage.image = leftArrowForDateImage.image?.withRenderingMode(.alwaysTemplate)
    rightArrowForDateImage.image = rightArrowForDateImage.image?.withRenderingMode(.alwaysTemplate)
  }
  
  func refreshCurrentDay(showAlert: Bool) {
    if date == nil {
      // It's useless to refresh current date if it's not specified yet. So just go away.
      return
    }
    
    let dayIsSwitched = !DateHelper.areEqualDays(date, Date())
    
    if mode == .general && isCurrentDayToday && dayIsSwitched {
      if showAlert {
        let alert = UIAlertView(title: nil, message: localizedStrings.welcomeToNextDayMessage, delegate: nil, cancelButtonTitle: localizedStrings.okButtonTitle)
        alert.show()
      }

      setCurrentDate(Date())
    }
  }
  
  func setCurrentDate(_ date: Date) {
    self.date = date

    if isViewLoaded {
      updateUIRelatedToCurrentDate(animated: true)
      updateSummaryBar(animated: true, completion: nil)
    }
  }
  
  func getCurrentDate() -> Date {
    return date ?? Date()
  }
  
  fileprivate func setupGestureRecognizers() {
    if let navigationBar = navigationController?.navigationBar {
      let leftSwipe = UISwipeGestureRecognizer(
        target: self,
        action: #selector(self.leftSwipeGestureIsRecognized(_:)))
      
      leftSwipe.direction = .left
      navigationBar.addGestureRecognizer(leftSwipe)
      
      let rightSwipe = UISwipeGestureRecognizer(
        target: self,
        action: #selector(self.rightSwipeGestureIsRecognized(_:)))
      
      rightSwipe.direction = .right
      navigationBar.addGestureRecognizer(rightSwipe)
    }
  }
  
  fileprivate func setupMultiprogressControl() {
    intakesMultiProgressView.animationDuration = 0.7
    intakesMultiProgressView.borderColor = UIColor(red: 167/255, green: 169/255, blue: 171/255, alpha: 0.8)
    intakesMultiProgressView.emptySectionColor = UIColor(red: 241/255, green: 241/255, blue: 242/255, alpha: 1)
    
    for drinkIndex in 0..<Drink.getDrinksCount() {
      if let drinkType = DrinkType(rawValue: drinkIndex) {
        let section = intakesMultiProgressView.addSection(color: drinkType.mainColor)
        multiProgressSections[drinkIndex] = section
      } else {
        Logger.logError("Drink type with index(\(drinkIndex)) is not found.")
      }
    }
  }
  
  fileprivate func setupPageViewController(_ pageViewController: UIPageViewController) {
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
    pageViewController.setViewControllers([selectDrinkViewController], direction: .forward, animated: false, completion: nil)
    
    updateUIAccordingToCurrentPage(selectDrinkViewController, initial: true)
  }
  
  // MARK: Day selection -
  
  func leftSwipeGestureIsRecognized(_ gestureRecognizer: UISwipeGestureRecognizer) {
    if gestureRecognizer.state == .ended {
      let daysTillToday = DateHelper.calendarDays(fromDate: date, toDate: Date())
        
      if daysTillToday > 0 {
        switchToNextDay()
      }
    }
  }
  
  func rightSwipeGestureIsRecognized(_ gestureRecognizer: UISwipeGestureRecognizer) {
    if gestureRecognizer.state == .ended {
      switchToPreviousDay()
    }
  }
  
  fileprivate func switchToNextDay() {
    setCurrentDate(DateHelper.nextDayFrom(date))
  }

  fileprivate func switchToPreviousDay() {
    setCurrentDate(DateHelper.previousDayBefore(date))
  }

  fileprivate func updateUIRelatedToCurrentDate(animated: Bool) {
    updateDateArrows(animated: animated)
    updateDateLabel(animated: animated)
  }
  
  fileprivate func updateDateArrows(animated: Bool) {
    let daysTillToday = DateHelper.calendarDays(fromDate: date, toDate: Date())
    let rightArrowIsVisible = daysTillToday > 0
    let newAlphaForRightImage: CGFloat = rightArrowIsVisible ? 1 : 0
    
    if animated {
      UIView.animate(withDuration: 0.15, animations: {
        self.leftArrowForDateImage.alpha = 0
        self.rightArrowForDateImage.alpha = 0
        }, completion: { _ in
          UIView.animate(withDuration: 0.15, animations: {
            self.leftArrowForDateImage.alpha = 1
            self.rightArrowForDateImage.alpha = newAlphaForRightImage
          }) 
      })
    } else {
      rightArrowForDateImage.alpha = newAlphaForRightImage
    }
  }
  
  fileprivate func updateDateLabel(animated: Bool) {
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
  
  fileprivate func updateSummaryBar(animated: Bool, completion: (() -> ())?) {
    CoreDataStack.performOnPrivateContext { privateContext in
      self.totalDehydrationAmount = Intake.fetchTotalDehydrationAmountForDay(self.date,
        dayOffsetInHours: 0, managedObjectContext: privateContext)

      self.waterGoal = WaterGoal.fetchWaterGoalForDate(self.date, managedObjectContext: privateContext)
      
      let intakeHydrationAmounts = Intake.fetchHydrationAmountsGroupedByDrinksForDay(self.date,
        dayOffsetInHours: 0, managedObjectContext: privateContext)
      
      DispatchQueue.main.async {
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
      }
      
      completion?()
    }
  }
  
  // MARK: Summary bar actions -
  
  @IBAction func toggleHighActivityMode(_ sender: Any) {
    isHighActivity = !isHighActivity
    saveWaterGoalForCurrentDate(baseAmount: waterGoalBaseAmount, isHotDay: isHotDay, isHighActivity: isHighActivity)
  }
  
  @IBAction func toggleHotDayMode(_ sender: Any) {
    isHotDay = !isHotDay
    saveWaterGoalForCurrentDate(baseAmount: waterGoalBaseAmount, isHotDay: isHotDay, isHighActivity: isHighActivity)
  }
  
  // MARK: Change current screen -
  
  func switchToSelectDrinkPage() {
    if let currentPage = pageViewController?.viewControllers?.last
      , selectDrinkViewController != nil && currentPage != selectDrinkViewController
    {
      updateUIAccordingToCurrentPage(currentPage, initial: false)
      pageViewController.setViewControllers([selectDrinkViewController], direction: .reverse, animated: true, completion: nil)
    }
  }

  fileprivate func updateUIAccordingToCurrentPage(_ page: UIViewController, initial: Bool) {
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
      
      helpTip?.hide(animated: false)
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
      case Constants.showCalendarSegue:
        if let calendarViewController = segue.destination.contentViewController as? CalendarViewController {
          calendarViewController.date = date
          calendarViewController.dayViewController = self
        }
      case Constants.pageViewEmbedSegue:
        if let pageViewController = segue.destination as? UIPageViewController {
          self.pageViewController = pageViewController
          setupPageViewController(pageViewController)
        }
      default: break;
      }
    }
  }
  
  // MARK: Intakes management -
  
  fileprivate func updateIntakeHydrationAmounts(_ intakeHydrationAmounts: [DrinkType: Double]) {
    // Clear all drink sections
    for (_, section) in multiProgressSections {
      section.factor = 0.0
    }
    
    // Fill sections with fetched intakes and compute daily water intake
    var totalHydrationAmount: Double = 0
    for (drinkType, hydrationAmount) in intakeHydrationAmounts {
      totalHydrationAmount += hydrationAmount
      if let section = multiProgressSections[drinkType.rawValue] {
        section.factor = CGFloat(hydrationAmount)
      }
    }
    
    self.totalHydrationAmount = totalHydrationAmount
  }
  
  fileprivate func checkForCongratulationsAboutWaterGoalReaching(_ notification: Notification) -> Bool {
    let currentDate = Date()
    
    let isToday = DateHelper.areEqualDays(currentDate, date)
    if !isToday {
      return false
    }
    
    let waterGoalReachingIsShownForToday = DateHelper.areEqualDays(currentDate, Settings.sharedInstance.uiWaterGoalReachingIsShownForDate.value)
    if waterGoalReachingIsShownForToday {
      return false
    }
    
    if totalHydrationAmount < waterGoalAmount {
      return false
    }
    
    if let insertedObjects = (notification as NSNotification).userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> {
      for insertedObject in insertedObjects {
        if let intake = insertedObject as? Intake , DateHelper.areEqualDays(intake.date, currentDate) {
          Settings.sharedInstance.uiWaterGoalReachingIsShownForDate.value = currentDate
          showCongratulationsAboutWaterGoalReaching()
          
          return true
        }
      }
    }
    
    return false
  }

  fileprivate func checkForRateApplicationAlert(_ notification: Notification) {
    if Settings.sharedInstance.uiWritingReviewAlertSelection.value != .remindLater {
      return
    }
    
    SystemHelper.executeBlockWithDelay(0.5) {
      if let insertedObjects = (notification as NSNotification).userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> {
        for insertedObject in insertedObjects {
          if insertedObject is Intake {
            Settings.sharedInstance.uiIntakesCountTillShowWritingReviewAlert.value -= 1
            
            if Settings.sharedInstance.uiIntakesCountTillShowWritingReviewAlert.value > 0 {
              return
            }

            self.showRateApplicationAlert()
            Settings.sharedInstance.uiIntakesCountTillShowWritingReviewAlert.value = GlobalConstants.numberOfIntakesToShowReviewAlert * 2
            return
          }
        }
      }
    }
  }
  
  fileprivate func showRateApplicationAlert() {
    DispatchQueue.main.async {
      let alert = UIAlertView(
        title: self.localizedStrings.rateApplicationAlertTitle,
        message: self.localizedStrings.rateApplicationAlertMessage,
        delegate: self,
        cancelButtonTitle: self.localizedStrings.rateApplicationAlertNoText,
        otherButtonTitles: self.localizedStrings.rateApplicationAlertRateText,
        self.localizedStrings.rateApplicationAlertRemindLaterText)

      alert.show()
    }
  }
  
  func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
    switch buttonIndex {
    case 0: // No, Thanks
      Settings.sharedInstance.uiWritingReviewAlertSelection.value = .no
      
    case 1: // Rate It Now
      if let url = URL(string: GlobalConstants.appReviewLink) {
        UIApplication.shared.openURL(url)
      }
      Settings.sharedInstance.uiWritingReviewAlertSelection.value = .rateApplication
      
    case 2: // Remind Me Later
      Settings.sharedInstance.uiWritingReviewAlertSelection.value = .remindLater
      
    default: break
    }
  }

  fileprivate func showCongratulationsAboutWaterGoalReaching() {
    DispatchQueue.main.async {
      let banner = InfoBannerView.create()
      banner.infoLabel.text = self.localizedStrings.congratulationsBannerText
      banner.infoImageView.image = ImageHelper.loadImage(.BannerReward)
      banner.bannerWasTappedFunction = { _ in banner.hide(animated: true) }
      banner.accessoryImageView.isHidden = true

      let frame = self.summaryView.convert(self.summaryView.frame, to: self.navigationController!.view)
      banner.showAndHide(animated: true, displayTime: 4, parentView: self.navigationController!.view, height: frame.height, minY: frame.minY)
    }
  }

  @IBAction func intakeButtonWasTapped(_ sender: Any) {
    Settings.sharedInstance.uiDisplayDailyWaterIntakeInPercents.value = !Settings.sharedInstance.uiDisplayDailyWaterIntakeInPercents.value
    updateIntakeButton(animated: true)
  }
  
  fileprivate func updateIntakeButton(animated: Bool) {
    let intakeText: String
    
    if Settings.sharedInstance.uiDisplayDailyWaterIntakeInPercents.value {
      let formatter = NumberFormatter()
      formatter.numberStyle = .percent
      formatter.maximumFractionDigits = 0
      formatter.multiplier = 100
      let hydrationFactor = totalHydrationAmount / waterGoalAmount
      intakeText = formatter.string(for: hydrationFactor)!
    } else {
      intakeText = Units.sharedInstance.formatMetricAmountToText(
        metricAmount: totalHydrationAmount,
        unitType: .volume,
        roundPrecision: amountPrecision,
        decimals: amountDecimals,
        displayUnits: false)
    }
    
    let waterGoalText = Units.sharedInstance.formatMetricAmountToText(
      metricAmount: waterGoalAmount,
      unitType: .volume,
      roundPrecision: amountPrecision,
      decimals: amountDecimals)
    
    let text = String.localizedStringWithFormat(localizedStrings.intakeButtonTextTemplate, intakeText, waterGoalText)
    
    if totalDehydrationAmount == 0 {
      intakeButton.setAttributedTitle(nil, for: UIControlState())

      if animated {
        intakeButton.setTitle(text, for: UIControlState())
        intakeButton.layoutIfNeeded()
      } else {
        UIView.performWithoutAnimation {
          self.intakeButton.setTitle(text, for: UIControlState())
          self.intakeButton.layoutIfNeeded()
        }
      }
    } else {
      // If user does intake of an alcoholic drink, water goal is increased.
      // In order to make it noticeable paint water goal part of title with different color.
      let coloredText = makeColoredText(text as NSString, mainColor: UIColor.darkGray, coloredParts: [(text: waterGoalText, color: StyleKit.wineColor)])
      if animated {
        intakeButton.setAttributedTitle(coloredText, for: UIControlState())
        intakeButton.layoutIfNeeded()
      } else {
        UIView.performWithoutAnimation {
          self.intakeButton.setAttributedTitle(coloredText, for: UIControlState())
          self.intakeButton.layoutIfNeeded()
        }
      }
    }
  }
  
  fileprivate func makeColoredText(_ text: NSString, mainColor: UIColor, coloredParts: [(text: String, color: UIColor)]) -> NSAttributedString {
    let attributes = [NSForegroundColorAttributeName: mainColor]
    let coloredText = NSMutableAttributedString(string: text as String, attributes: attributes)
    coloredText.beginEditing()
    
    for (textPart, color) in coloredParts {
      let range = text.range(of: textPart)
      if range.length > 0 {
        coloredText.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
      }
    }
    
    coloredText.endEditing()
    
    return coloredText
  }
  
  fileprivate func waterGoalWasChanged(animated: Bool) {
    updateIntakeButton(animated: animated)

    if animated {
      // Update maximum for multi progress control
      intakesMultiProgressView.updateWithAnimation { [weak self] in
        if let _self = self {
          _self.intakesMultiProgressView.maximum = CGFloat(_self.waterGoalAmount)
        }
      }
    } else {
      // Update maximum for multi progress control
      intakesMultiProgressView.update { [weak self] in
        if let _self = self {
          _self.intakesMultiProgressView.maximum = CGFloat(_self.waterGoalAmount)
        }
      }
    }

    highActivityButton.isSelected = isHighActivity
    hotDayButton.isSelected = isHotDay
  }
  
  fileprivate func saveWaterGoalForCurrentDate(baseAmount: Double, isHotDay: Bool, isHighActivity: Bool) {
    CoreDataStack.performOnPrivateContext { privateContext in
      self.waterGoal = WaterGoal.addEntity(
        date: self.date,
        baseAmount: baseAmount,
        isHotDay: isHotDay,
        isHighActivity: isHighActivity,
        managedObjectContext: privateContext)
    }
  }
  
  // MARK: Help tips -

  fileprivate func checkForHelpTip(_ notification: Notification) {
    if checkForHighPriorityHelpTips(notification) {
      return
    }
    
    checkForRegularHelpTips(notification)
  }
  
  fileprivate func checkForHighPriorityHelpTips(_ notification: Notification) -> Bool {
    if Settings.sharedInstance.uiDayPageAlcoholicDehydratrionHelpTipIsShown.value == true {
      return false
    }
    
    if let insertedObjects = (notification as NSNotification).userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> {
      for insertedObject in insertedObjects {
        if let intake = insertedObject as? Intake , DateHelper.areEqualDays(intake.date, date) && intake.dehydrationAmount > 0 {
          showAlcoholicDehydrationHelpTip()
          return true
        }
      }
    }
    
    return false
  }
  
  fileprivate func checkForRegularHelpTips(_ notification: Notification) {
    if Settings.sharedInstance.uiDayPageHelpTipToShow.value == .none {
      return
    }
    
    if let insertedObjects = (notification as NSNotification).userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> {
      for insertedObject in insertedObjects {
        if let intake = insertedObject as? Intake , DateHelper.areEqualDays(intake.date, date) {
          Settings.sharedInstance.uiDayPageIntakesCountTillHelpTip.value = Settings.sharedInstance.uiDayPageIntakesCountTillHelpTip.value - 1
          if Settings.sharedInstance.uiDayPageIntakesCountTillHelpTip.value <= 0 {
            DispatchQueue.main.async {
              self.showNextHelpTip()
            }
          }
          break
        }
      }
    }
  }
  
  fileprivate func showAlcoholicDehydrationHelpTip() {
    DispatchQueue.main.async {
      SystemHelper.executeBlockWithDelay(GlobalConstants.helpTipDelayToShow) {
        if self.view.window == nil || self.helpTip != nil {
          return
        }
        
        if let helpTip = JDFTooltipView(
          targetView: self.intakeButton,
          hostView: self.view,
          tooltipText: self.localizedStrings.helpTipAlcoholicDehydration,
          arrowDirection: .up,
          width: self.view.frame.width / 2)
        {
          self.showHelpTip(helpTip)
          Settings.sharedInstance.uiDayPageAlcoholicDehydratrionHelpTipIsShown.value = true
        }
      }
    }
  }
  
  fileprivate func showNextHelpTip() {
    if helpTip != nil {
      return
    }

    switch Settings.sharedInstance.uiDayPageHelpTipToShow.value {
    case .swipeToSeeDiary:
      showHelpTipForSwipeToSeeDiary()
      
    case .swipeToChangeDay:
      showHelpTipForSwipeToChangeDay()
      
    case .highActivityMode:
      showHelpTipForHighActivityMode()
      
    case .hotWeatherMode:
      showHelpTipForHotWeatherMode()
      
    case .switchToPercentsAndViceVersa:
      showHelpTipForSwitchToPercentAndViceVersa()
      
    case .longPressToChooseAlcohol:
      showHelpTipForLongPressToChooseAlcohol()
      
    case .none: break
    }
  }
  
  fileprivate func showHelpTipForSwipeToSeeDiary() {
    SystemHelper.executeBlockWithDelay(GlobalConstants.helpTipDelayToShow) {
      if self.view.window == nil || self.helpTip != nil {
        return
      }
      
      let bounds = self.selectDrinkViewController!.collectionView.bounds
      
      if let helpTip = JDFTooltipView(
        targetPoint: CGPoint(x: bounds.midX, y: bounds.height * 0.65),
        hostView: self.selectDrinkViewController!.collectionView,
        tooltipText: self.localizedStrings.helpTipSwipeToSeeDiary,
        arrowDirection: .up,
        width: self.view.frame.width / 2)
      {
        self.showHelpTip(helpTip)
        self.switchToNextHelpTip()
      }
    }
  }
  
  fileprivate func showHelpTipForSwipeToChangeDay() {
    SystemHelper.executeBlockWithDelay(GlobalConstants.helpTipDelayToShow) {
      if self.view.window == nil || self.helpTip != nil {
        return
      }
      
      if let helpTip = JDFTooltipView(
        targetView: self.navigationDateLabel,
        hostView: self.navigationController?.view,
        tooltipText: self.localizedStrings.helpTipSwipeToChangeDay,
        arrowDirection: .up,
        width: self.view.frame.width / 2)
      {
        self.showHelpTip(helpTip)
        self.switchToNextHelpTip()
      }
    }
  }
  
  fileprivate func showHelpTipForHighActivityMode() {
    SystemHelper.executeBlockWithDelay(GlobalConstants.helpTipDelayToShow) {
      if self.view.window == nil || self.helpTip != nil {
        return
      }
      
      if let helpTip = JDFTooltipView(
        targetView: self.highActivityButton,
        hostView: self.view,
        tooltipText: self.localizedStrings.helpTipHighActivityMode,
        arrowDirection: .up,
        width: self.view.frame.width / 2)
      {
        self.showHelpTip(helpTip)
        self.switchToNextHelpTip()
      }
    }
  }
  
  fileprivate func showHelpTipForHotWeatherMode() {
    SystemHelper.executeBlockWithDelay(GlobalConstants.helpTipDelayToShow) {
      if self.view.window == nil || self.helpTip != nil {
        return
      }
      
      if let helpTip = JDFTooltipView(
        targetView: self.hotDayButton,
        hostView: self.view,
        tooltipText: self.localizedStrings.helpTipHotWeatherMode,
        arrowDirection: .up,
        width: self.view.frame.width / 2)
      {
        self.showHelpTip(helpTip)
        self.switchToNextHelpTip()
      }
    }
  }
  
  fileprivate func showHelpTipForSwitchToPercentAndViceVersa() {
    SystemHelper.executeBlockWithDelay(GlobalConstants.helpTipDelayToShow) {
      if self.view.window == nil || self.helpTip != nil {
        return
      }
      
      if let helpTip = JDFTooltipView(
        targetView: self.intakeButton,
        hostView: self.view,
        tooltipText: self.localizedStrings.helpTipSwitchToPercentAndViceVersa,
        arrowDirection: .up,
        width: self.view.frame.width / 2)
      {
        self.showHelpTip(helpTip)
        self.switchToNextHelpTip()
      }
    }
  }
  
  fileprivate func showHelpTipForLongPressToChooseAlcohol() {
    SystemHelper.executeBlockWithDelay(GlobalConstants.helpTipDelayToShow) {
      if self.view.window == nil || self.helpTip != nil {
        return
      }
      
      let lastCellIndex = self.selectDrinkViewController!.collectionView.numberOfItems(inSection: 0) - 1
      let cell = self.selectDrinkViewController!.collectionView.cellForItem(at: IndexPath(row: lastCellIndex, section: 0))
      
      if let tooltip = JDFTooltipView(
        targetView: cell,
        hostView: self.selectDrinkViewController!.collectionView,
        tooltipText: self.localizedStrings.helpTipLongPressToChooseAlcohol,
        arrowDirection: .down,
        width: self.view.frame.width / 2)
      {
        self.showHelpTip(tooltip)
        self.switchToNextHelpTip()
      }
    }
  }
  
  fileprivate func showHelpTip(_ helpTip: JDFTooltipView) {
    self.helpTip = helpTip

    UIHelper.showHelpTip(helpTip) {
      self.helpTip = nil
    }
  }

  fileprivate func switchToNextHelpTip() {
    Settings.sharedInstance.uiDayPageHelpTipToShow.value = (Settings.DayPageHelpTip(rawValue: Settings.sharedInstance.uiDayPageHelpTipToShow.value.rawValue + 1) ?? .none)!
    
    // Reset help tips counter. Help tips should be shown after every 2 intakes.
    Settings.sharedInstance.uiDayPageIntakesCountTillHelpTip.value = 2
  }
  
  // MARK: Private properties -
  
  fileprivate var waterGoal: WaterGoal? {
    didSet {
      updateWaterGoalRelatedValues()
    }
  }
  
  fileprivate var totalDehydrationAmount: Double = 0
  fileprivate var isWaterGoalForCurrentDay = false
  fileprivate var isHotDay = false
  fileprivate var isHighActivity = false
  fileprivate var waterGoalBaseAmount: Double = 0
  fileprivate var hotDayExtraFactor: Double = 0
  fileprivate var highActivityExtraFactor: Double = 0

  fileprivate var waterGoalAmount: Double {
    return waterGoalBaseAmount * (1 + hotDayExtraFactor + highActivityExtraFactor) + totalDehydrationAmount
  }

  fileprivate var multiProgressSections: [Int: MultiProgressView.Section] = [:]
  
  fileprivate var pages: [UIViewController] = []
  fileprivate weak var pageViewController: UIPageViewController!
  fileprivate var diaryViewController: DiaryViewController!
  fileprivate var selectDrinkViewController: SelectDrinkViewController!

  fileprivate var amountPrecision: Double { return Settings.sharedInstance.generalVolumeUnits.value.precision }
  fileprivate var amountDecimals: Int { return Settings.sharedInstance.generalVolumeUnits.value.decimals }

  fileprivate var isCurrentDayToday: Bool {
    return !Settings.sharedInstance.uiUseCustomDateForDayView.value
  }
  
}

// MARK: UIPageViewControllerDataSource -

extension DayViewController: UIPageViewControllerDataSource {
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    if let index = pages.index(of: viewController) {
      if index > 0 {
        return pages[index - 1]
      }
    }
    
    return nil
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    if let index = pages.index(of: viewController) {
      if index < pages.count - 1 {
        return pages[index + 1]
      }
    }
    
    return nil
  }
  
}

// MARK: UIPageViewControllerDelegate -

extension DayViewController: UIPageViewControllerDelegate {

  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    if let currentPage = pageViewController.viewControllers?.last {
      updateUIAccordingToCurrentPage(currentPage, initial: false)
    }
  }
  
}


private extension Units.Volume {
  var precision: Double {
    switch self {
    case .millilitres: return 1.0
    case .fluidOunces: return 0.1
    }
  }
  
  var decimals: Int {
    switch self {
    case .millilitres: return 0
    case .fluidOunces: return 1
    }
  }
}
