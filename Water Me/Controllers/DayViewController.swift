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
  
  // MARK: UI elements -
  
  @IBOutlet weak var revealButton: UIBarButtonItem!
  @IBOutlet weak var pageButton: UIBarButtonItem!
  @IBOutlet weak var summaryBar: UIView!
  @IBOutlet weak var consumptionProgressView: MultiProgressView!
  @IBOutlet weak var consumptionLabel: UILabel!
  @IBOutlet weak var previousDayButton: UIButton!
  @IBOutlet weak var nextDayButton: UIButton!
  @IBOutlet weak var currentDayButton: UIButton!
  @IBOutlet weak var daySelectionBar: UIView!
  @IBOutlet weak var showDaySelectionButton: UIButton!
  @IBOutlet weak var highActivityButton: UIButton!
  @IBOutlet weak var hotDayButton: UIButton!
  
  var navigationTitleLabel: UILabel! // is programmatically created in viewDidLoad()
  var navigationCurrentDayLabel: UILabel! // is programmatically created in viewDidLoad()

  // MARK: Public properties -
  
  /// Current date for managing water intake
  var currentDate: NSDate = NSDate() {
    didSet {
      currentDateWasChanged()
    }
  }
  
  var overallConsumption: Double = 0.0 {
    didSet {
      updateConsumptionLabel()
    }
  }
  
  // MARK: Page setup -
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Customize navigation bar
    createNavigationTitle()
    
    // Add view controller for drink selection
    selectDrinkViewController = storyboard!.instantiateViewControllerWithIdentifier("SelectDrinkViewController") as SelectDrinkViewController
    selectDrinkViewController.dayViewController = self
    pages.append(selectDrinkViewController)

    // Add consumptions diary view controller
    diaryViewController = storyboard!.instantiateViewControllerWithIdentifier("DiaryViewController") as DiaryViewController
    diaryViewController.dayViewController = self
    pages.append(diaryViewController)
    
    // Add page view controller for a current day
    pageViewController = storyboard!.instantiateViewControllerWithIdentifier("DayPageViewController") as UIPageViewController
    pageViewController.dataSource = self
    pageViewController.delegate = self
    pageViewController.setViewControllers([selectDrinkViewController], direction: .Forward, animated: false, completion: nil)
    pageButton.title = pageTitles[0]

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
    currentDateWasChanged()
  }
  
  private func createNavigationTitle() {
    let navigationTitleViewRect = navigationController!.navigationBar.frame.rectByInsetting(dx: 100, dy: 0)
    let navigationTitleView = UIView(frame: navigationTitleViewRect)
    
    navigationTitleLabel = UILabel(frame: navigationTitleView.bounds)
    navigationTitleLabel.autoresizingMask = .FlexibleWidth
    navigationTitleLabel.backgroundColor = UIColor.clearColor()
    navigationTitleLabel.text = navigationItem.title
    navigationTitleLabel.font = UIFont.boldSystemFontOfSize(16)
    navigationTitleLabel.textAlignment = .Center
    navigationTitleView.addSubview(navigationTitleLabel)
    
    let currentDayLabelRect = navigationTitleView.bounds.rectByOffsetting(dx: 0, dy: 16)
    navigationCurrentDayLabel = UILabel(frame: currentDayLabelRect)
    navigationCurrentDayLabel.autoresizingMask = navigationTitleLabel.autoresizingMask
    navigationCurrentDayLabel.backgroundColor = UIColor.clearColor()
    navigationCurrentDayLabel.font = UIFont.systemFontOfSize(12)
    navigationCurrentDayLabel.textAlignment = .Center
    navigationTitleView.addSubview(navigationCurrentDayLabel)
    
    navigationItem.titleView = navigationTitleView
    navigationController!.navigationBar.setTitleVerticalPositionAdjustment(-8.0, forBarMetrics: .Default)
  }
  
  private func revealButtonSetup() {
    if let revealViewController = self.revealViewController() {
      revealButton.target = revealViewController
      revealButton.action = "revealToggle:"
      navigationController!.navigationBar.addGestureRecognizer(revealViewController.panGestureRecognizer())
      view.addGestureRecognizer(revealViewController.panGestureRecognizer())
    }
  }
  
  // MARK: Summary bar actions -
  
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
    
    // TODO: Should be re-written for image
    let color: UIColor? = visible ? UIColor.greenColor() : nil
    showDaySelectionButton.setTitleColor(color, forState: .Normal)
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
    currentDate = DateHelper.addToDate(currentDate, years: 0, months: 0, days: -1)
  }

  @IBAction func switchToNextDay(sender: AnyObject) {
    currentDate = DateHelper.addToDate(currentDate, years: 0, months: 0, days: 1)
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
  
  // MARK: Consumptions management -
  
  private func fetchConsumptionRate() {
    consumptionRate = ConsumptionRate.fetchConsumptionRateForDate(currentDate)
    
    if let rate = consumptionRate {
      isConsumptionRateForCurrentDay = DateHelper.areDatesEqualByDays(date1: rate.date, date2: currentDate)
    } else {
      isConsumptionRateForCurrentDay = false
    }
    
    consumptionRateWasChanged()
  }

  private func fetchConsumptions() {
    consumptions = Consumption.fetchConsumptionsForDay(currentDate)

    updateConsumptions()
  }
  
  func addConsumption(consumption: Consumption) {
    consumptions.append(consumption)
    
    if let section = multiProgressSections[consumption.drink] {
      section.factor += consumption.amount.doubleValue
    }
    consumptionProgressView.setNeedsDisplay()
    overallConsumption += consumption.amount.doubleValue
    
    diaryViewController.updateTable(consumptions)
  }
  
  func removeConsumption(consumption: Consumption) {
    let index = find(consumptions, consumption)
    if index == nil {
      assert(false, "Removed consumption is not found")
      return
    }
    
    consumptions.removeAtIndex(index!)
    
    if let section = multiProgressSections[consumption.drink] {
      section.factor -= consumption.amount.doubleValue
    }
    consumptionProgressView.setNeedsDisplay()
    overallConsumption += consumption.amount.doubleValue
    
    diaryViewController.updateTable(consumptions)
  }
  
  func updateConsumptions() {
    // Group consumptions by drinks
    var consumptionsMap: [Drink: Double] = [:]
    
    for consumption in consumptions {
      if let amount = consumptionsMap[consumption.drink] {
        consumptionsMap[consumption.drink] = amount + Double(consumption.amount)
      } else {
        consumptionsMap[consumption.drink] = Double(consumption.amount)
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
        section.factor = amount
      }
    }
    
    consumptionProgressView.setNeedsDisplay()
    overallConsumption = overallAmount
  }
  
  private func updateConsumptionLabel() {
    let consumptionText = Units.sharedInstance.formatAmountToText(amount: overallConsumption, unitType: .Volume, precision: amountPrecision, decimals: amountDecimals, displayUnits: false)
    let consumptionRateText = Units.sharedInstance.formatAmountToText(amount: consumptionRateAmount, unitType: .Volume, precision: amountPrecision, decimals: amountDecimals)
    consumptionLabel.text = "\(consumptionText) of \(consumptionRateText)"
  }
  
  private func consumptionRateWasChanged() {
    updateConsumptionLabel()

    // Update maximum for multi progress control
    consumptionProgressView.maximum = consumptionRateAmount

    // TODO: Should be re-written for image
    let highActivityColor: UIColor? = consumptionHighActivityFraction > 0 ? UIColor.greenColor() : nil
    highActivityButton.setTitleColor(highActivityColor, forState: .Normal)

    // TODO: Should be re-written for image
    let hotDayColor: UIColor? = consumptionHotDayFraction > 0 ? UIColor.greenColor() : nil
    hotDayButton.setTitleColor(hotDayColor, forState: .Normal)
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
  
  private func currentDateWasChanged() {
    // Update all related date labels
    let formattedDate = DateHelper.stringFromDate(currentDate)
    currentDayButton.setTitle(formattedDate, forState: .Normal)
    navigationCurrentDayLabel.text = formattedDate
    
    // Disable switching to the next day if a current day is today
    let daysTillToday = DateHelper.computeUnitsFrom(currentDate, toDate: NSDate(), unit: .CalendarUnitDay)
    nextDayButton.enabled = daysTillToday > 0
    
    // Fetch consumption rate for current day
    fetchConsumptionRate()
    
    // Fetch existing consumptions for current day
    fetchConsumptions()
  }
  
  // MARK: Private properties -
  
  private var consumptionRate: ConsumptionRate?
  private var isConsumptionRateForCurrentDay: Bool = false

  private var consumptionBaseRateAmount: Double {
    if let rate = consumptionRate {
      return rate.baseRateAmount.doubleValue
    }
    return Settings.sharedInstance.userDailyWaterIntake.value
  }
  
  private var consumptionRateAmount: Double {
    return consumptionBaseRateAmount * (1 + consumptionHotDayFraction + consumptionHighActivityFraction)
  }
  
  private var consumptionHotDayFraction: Double {
    get {
      if !isConsumptionRateForCurrentDay {
        return 0
      }
      
      if let rate = consumptionRate {
        return rate.hotDayFraction.doubleValue
      }

      return 0
    }
    set(newHotDayFraction) {
      if !isConsumptionRateForCurrentDay {
        saveConsumptionRateForCurrentDate(baseRateAmount: consumptionBaseRateAmount, hotDayFraction: newHotDayFraction, highActivityFraction: 0)
      } else if let rate = consumptionRate {
        rate.hotDayFraction = newHotDayFraction
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

      if let rate = consumptionRate {
        return rate.highActivityFraction.doubleValue
      }

      return 0
    }
    set(newHighActivityFraction) {
      if !isConsumptionRateForCurrentDay {
        saveConsumptionRateForCurrentDate(baseRateAmount: consumptionBaseRateAmount, hotDayFraction: 0, highActivityFraction: newHighActivityFraction)
      } else if let rate = consumptionRate {
        rate.highActivityFraction = newHighActivityFraction
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
  private let pageTitles = ["Diary", "Drinks"]

  private let amountPrecision = Settings.sharedInstance.generalVolumeUnits.value.precision
  private let amountDecimals = Settings.sharedInstance.generalVolumeUnits.value.decimals
  private let drinkTypesCount = 9 // number of supported drinks types: water, tea etc.
  
}
