//
//  DayViewController.swift
//  Water Me
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

class DayViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
  
  @IBOutlet weak var revealButton: UIBarButtonItem!
  @IBOutlet weak var pageButton: UIBarButtonItem!
  @IBOutlet weak var summaryBar: UIView!
  @IBOutlet weak var consumptionProgressView: MultiProgressView!
  @IBOutlet weak var consumptionLabel: UILabel!
  @IBOutlet weak var previousDayButton: UIButton!
  @IBOutlet weak var nextDayButton: UIButton!
  @IBOutlet weak var currentDayButton: UIButton!
  @IBOutlet weak var daySelectionBar: UIView!
  @IBOutlet weak var highActivityButton: UIButton!
  @IBOutlet weak var hotDayButton: UIButton!
  
  var currentDayLabelInNavigationTitle: UILabel! // is programmatically created in viewDidLoad()
  
  /// Current date for managing water intake
  var currentDate: NSDate = NSDate() {
    didSet {
      applyDateSwitching()
    }
  }
  
  var overallConsumption: Double = 0.0 {
    didSet {
      setOverallConsumption(overallConsumption, maximum: consumptionBaseRate)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Customize navigation bar
    let navigationTitleViewRect = navigationController!.navigationBar.frame.rectByInsetting(dx: 100, dy: 0)
    let navigationTitleView = UIView(frame: navigationTitleViewRect)
    
    let navigationTitleLabel = UILabel(frame: navigationTitleView.bounds)
    navigationTitleLabel.autoresizingMask = .FlexibleWidth
    navigationTitleLabel.backgroundColor = UIColor.clearColor()
    navigationTitleLabel.text = navigationItem.title
    navigationTitleLabel.font = UIFont.boldSystemFontOfSize(16)
    navigationTitleLabel.textAlignment = .Center
    navigationTitleView.addSubview(navigationTitleLabel)
    
    let currentDayLabelRect = navigationTitleView.bounds.rectByOffsetting(dx: 0, dy: 16)
    currentDayLabelInNavigationTitle = UILabel(frame: currentDayLabelRect)
    currentDayLabelInNavigationTitle.autoresizingMask = navigationTitleLabel.autoresizingMask
    currentDayLabelInNavigationTitle.backgroundColor = UIColor.clearColor()
    currentDayLabelInNavigationTitle.font = UIFont.systemFontOfSize(12)
    currentDayLabelInNavigationTitle.textAlignment = .Center
    navigationTitleView.addSubview(currentDayLabelInNavigationTitle)
    
    navigationItem.titleView = navigationTitleView
    navigationController!.navigationBar.setTitleVerticalPositionAdjustment(-8.0, forBarMetrics: .Default)
    
    // Add view controller for drink selection
    let selectDrinkViewController = storyboard!.instantiateViewControllerWithIdentifier("SelectDrinkViewController") as SelectDrinkViewController
    selectDrinkViewController.dayViewController = self
    pages.append(selectDrinkViewController)

    // Add consumptions diary view controller
    let diaryViewController = storyboard!.instantiateViewControllerWithIdentifier("DiaryViewController") as UIViewController
    pages.append(diaryViewController)
    
    // Add page view controller for a current day
    pageViewController = storyboard!.instantiateViewControllerWithIdentifier("DayPageViewController") as UIPageViewController
    pageViewController.dataSource = self
    pageViewController.delegate = self
    pageViewController.setViewControllers([selectDrinkViewController], direction: .Forward, animated: false, completion: nil)
    
    // Setup summary bar
    let summaryBarHeight = summaryBar.bounds.height
    var pageViewControllerRect = view.frame
    pageViewControllerRect.size.height -= summaryBarHeight
    pageViewControllerRect.offset(dx: 0.0, dy: summaryBarHeight)
    pageViewController.view.frame = pageViewControllerRect
    
    addChildViewController(pageViewController)
    view.addSubview(pageViewController.view)
    
    pageViewController.didMoveToParentViewController(self)
    
    setDaySelectionBarVisible(Settings.sharedInstance.uiDisplayDaySelection.value)
    
    // Setup multi progress control
    for i in 0..<drinkTypesCount {
      let drink = Drink.getDrinkByIndex(i)!
      let section = consumptionProgressView.addSection(color: drink.color as UIColor)
      multiProgressSections[drink] = section
    }
    
    // Additional setup for revealing
    revealButtonSetup()

    // Apply current date to all related labels
    applyDateSwitching()
  }
  
  @IBAction func toggleDaySelectionBar(sender: AnyObject) {
    setDaySelectionBarVisible(daySelectionBar.hidden)
  }
  
  private func setDaySelectionBarVisible(visible: Bool) {
    if daySelectionBar.hidden == !visible {
      return
    }
    
    Settings.sharedInstance.uiDisplayDaySelection.value = visible

    daySelectionBar.hidden = !visible
    if daySelectionBar.hidden {
      summaryBar.frame.size.height -= daySelectionBar.frame.height
      pageViewController.view.frame.size.height += daySelectionBar.frame.height
      pageViewController.view.frame.offset(dx: 0, dy: -daySelectionBar.frame.height)
    } else {
      summaryBar.frame.size.height += daySelectionBar.frame.height
      pageViewController.view.frame.size.height -= daySelectionBar.frame.height
      pageViewController.view.frame.offset(dx: 0, dy: daySelectionBar.frame.height)
    }
  }
  
  @IBAction func toggleHighActivityMode(sender: AnyObject) {
    if consumptionHighActivity > 0 {
      consumptionHighActivity = 0
    } else {
      consumptionHighActivity = Settings.sharedInstance.generalExtraConsumptionHighActivity.value
    }
  }
  
  @IBAction func toggleHotDayMode(sender: AnyObject) {
    if consumptionHotDay > 0 {
      consumptionHotDay = 0
    } else {
      consumptionHotDay = Settings.sharedInstance.generalExtraConsumptionHot.value
    }
  }
  
  @IBAction func switchToPreviousDay(sender: AnyObject) {
    currentDate = DateHelper.addToDate(currentDate, years: 0, months: 0, days: -1)
  }

  @IBAction func switchToNextDay(sender: AnyObject) {
    currentDate = DateHelper.addToDate(currentDate, years: 0, months: 0, days: 1)
  }
  
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
      pageButton.title = pageTitles[0]
    } else if currentPage == pages[1] {
      pageButton.title = pageTitles[1]
    }
  }
  
  @IBAction func toggleCurrentPage(sender: AnyObject) {
    let currentPage = pageViewController.viewControllers.last as UIViewController
    if currentPage == pages[0] {
      pageViewController.setViewControllers([pages[1]], direction: .Forward, animated: true, completion: nil)
      pageButton.title = pageTitles[1]
    } else if currentPage == pages[1] {
      pageViewController.setViewControllers([pages[0]], direction: .Reverse, animated: true, completion: nil)
      pageButton.title = pageTitles[0]
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
  
  func addConsumption(drink: Drink, amount: Double) {
    if let section = multiProgressSections[drink] {
      section.factor += amount
    }
    consumptionProgressView.setNeedsDisplay()
    overallConsumption += amount
  }
  
  private func setOverallConsumption(amount: Double, maximum: Double) {
    assert(maximum > 0, "Maximum of recommended consumption is specified to 0")
    let maximumText = Units.sharedInstance.formatAmountToText(amount: maximum, unitType: .Volume, precision: amountPrecision, decimals: amountDecimals)
    let consumptionText = Units.sharedInstance.formatAmountToText(amount: amount, unitType: .Volume, precision: amountPrecision, decimals: amountDecimals, displayUnits: false)
    consumptionLabel.text = "\(consumptionText) of \(maximumText)"
  }
  
  private func formatDate(date: NSDate) -> String {
    let today = NSDate()
    let daysToToday = DateHelper.computeUnitsFrom(today, toDate: date, unit: .CalendarUnitDay)
    let dateFormatter = NSDateFormatter()
    
    if abs(daysToToday) <= 1 {
      // Use standard date formatting for yesterday, today and tomorrow
      // in order to obtain "Yesterday", "Today" and "Tomorrow" localized date strings
      dateFormatter.dateStyle = .MediumStyle
      dateFormatter.timeStyle = .NoStyle
      dateFormatter.doesRelativeDateFormatting = true
    } else {
      // Use custom formatting. If year of a current date is year of today, hide them.
      let yearsToToday = DateHelper.computeUnitsFrom(today, toDate: date, unit: .CalendarUnitYear)
      let template = yearsToToday == 0 ? "dMMMM" : "dMMMMyyyy"
      let formatString = NSDateFormatter.dateFormatFromTemplate(template, options: 0, locale: NSLocale.currentLocale())
      dateFormatter.dateFormat = formatString
    }
    return dateFormatter.stringFromDate(date)
  }
  
  private func applyDateSwitching() {
    // Fetch consumption rate for current day
    fetchConsumptionRate()
    
    // Fetch existing consumptions for current day
    fetchConsumptions()

    // Update maximum for multi progress control
    consumptionProgressView.maximum = consumptionBaseRate
    
    // Update all related date labels
    let formattedDate = formatDate(currentDate)
    currentDayButton.setTitle(formattedDate, forState: .Normal)
    currentDayLabelInNavigationTitle.text = formattedDate
    
    // Disable switching to the next day if a current day is today
    let daysToToday = DateHelper.computeUnitsFrom(currentDate, toDate: NSDate(), unit: .CalendarUnitDay)
    nextDayButton.enabled = daysToToday > 0
  }
  
  private func fetchConsumptionRate() {
    let currentDateAdjusted = DateHelper.dateByClearingTime(ofDate: currentDate)
    consumptionRate = ConsumptionRate.fetchConsumptionRateForDate(currentDateAdjusted)
  }

  private func fetchConsumptions() {
    // Clear all drink sections
    for (_, section) in multiProgressSections {
      section.factor = 0.0
    }
    
    // Fill sections with fetched amounts and compute overall consumption
    var overallAmount = 0.0
    if let consumptions = ModelHelper.sharedInstance.computeDrinkAmountsForDay(currentDate) {
      for (drink, amount) in consumptions {
        overallAmount += amount
        if let section = multiProgressSections[drink] {
          section.factor = amount
        }
      }
    }
    
    consumptionProgressView.setNeedsDisplay()
    overallConsumption = overallAmount
  }
  
  private func isConsumptionRateForCurrentDay() -> Bool {
    if let rate = consumptionRate {
      return DateHelper.areDatesEqualByDays(date1: rate.date, date2: currentDate)
    } else {
      return false
    }
  }
  
  private func revealButtonSetup() {
    if let revealViewController = self.revealViewController() {
      revealButton.target = revealViewController
      revealButton.action = "revealToggle:"
      navigationController!.navigationBar.addGestureRecognizer(revealViewController.panGestureRecognizer())
      view.addGestureRecognizer(revealViewController.panGestureRecognizer())
    }
  }

  private var consumptionRate: ConsumptionRate?

  private var consumptionBaseRate: Double {
    if let rate = consumptionRate {
      let baseRate = rate.baseRateAmount.doubleValue
      return baseRate * (1 + consumptionHotDay + consumptionHighActivity)
    }
    return Settings.sharedInstance.userDailyWaterIntake.value
  }
  
  private var consumptionHotDay: Double {
    get {
      if let rate = consumptionRate {
        return rate.hotDayFraction.doubleValue
      }
      return 0
    }
    set(newConsumptionHotDay) {
      if !isConsumptionRateForCurrentDay() {
        consumptionRate = ConsumptionRate.addEntity(
          date: currentDate,
          baseRateAmount: consumptionBaseRate,
          hotDateFraction: newConsumptionHotDay,
          highActivityFraction: 0)
      } else if let rate = consumptionRate {
        rate.hotDayFraction = newConsumptionHotDay
      }

      // TODO: Should be re-written for image
      let hotDayColor = newConsumptionHotDay > 0 ? UIColor.greenColor() : UIColor.blueColor()
      hotDayButton.setTitleColor(hotDayColor, forState: .Normal)
    }
  }
  
  private var consumptionHighActivity: Double {
    get {
      if let rate = consumptionRate {
        return rate.highActivityFraction.doubleValue
      }
      return 0
    }
    set(newConsumptionHighActivity) {
      if !isConsumptionRateForCurrentDay() {
        consumptionRate = ConsumptionRate.addEntity(
          date: currentDate,
          baseRateAmount: consumptionBaseRate,
          hotDateFraction: 0,
          highActivityFraction: newConsumptionHighActivity)
      } else if let rate = consumptionRate {
        rate.highActivityFraction = newConsumptionHighActivity
      }
      
      // TODO: Should be re-written for image
      let highActivityColor = newConsumptionHighActivity > 0 ? UIColor.greenColor() : UIColor.blueColor()
      highActivityButton.setTitleColor(highActivityColor, forState: .Normal)
    }
  }
  
  private var pageViewController: UIPageViewController!
  private var pages: [UIViewController] = []
  private var multiProgressSections: [Drink: MultiProgressView.Section] = [:]
  
  private let pageTitles = ["Drinked", "Add"]
  private let amountPrecision = Settings.sharedInstance.generalVolumeUnits.value.precision
  private let amountDecimals = Settings.sharedInstance.generalVolumeUnits.value.decimals
  private let drinkTypesCount = 9 // number of supported drinks types: water, tea etc.
}
