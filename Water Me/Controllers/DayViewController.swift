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
  @IBOutlet weak var summaryNavigationBar: UIView!
  @IBOutlet weak var consumptionProgressView: MultiProgressView!
  @IBOutlet weak var consumptionLabel: UILabel!
  @IBOutlet weak var previousDayButton: UIButton!
  @IBOutlet weak var nextDayButton: UIButton!
  @IBOutlet weak var currentDayButton: UIButton!
  var currentDayLabelInNavigationBar: UILabel! // programmatically created in viewDidLoad()
  
  /// Current date for managing water intake
  var currentDate: NSDate = NSDate() {
    didSet {
      applyDateSwitching()
      fetchConsumptions()
    }
  }
  
  var overallConsumption: Double = 0.0 {
    didSet {
      setOverallConsumption(overallConsumption, maximum: getRecommendedWaterIntake())
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
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
    
    let summaryNavigationBarHeight = summaryNavigationBar.bounds.height
    var pageViewControllerRect = view.frame
    pageViewControllerRect.size.height -= summaryNavigationBarHeight
    pageViewControllerRect.offset(dx: 0.0, dy: summaryNavigationBarHeight)
    pageViewController.view.frame = pageViewControllerRect
    
    addChildViewController(pageViewController)
    view.addSubview(pageViewController.view)
    
    pageViewController.didMoveToParentViewController(self)
    
    // Setup multi progress control
    for i in 0..<drinkTypesCount {
      let drink = Drink.getDrinkByIndex(i)!
      let section = consumptionProgressView.addSection(color: drink.color as UIColor)
      multiProgressSections[drink] = section
    }
    consumptionProgressView.maximum = getRecommendedWaterIntake()
    
    // Additional setup for revealing
    revealButtonSetup()
    
    // Fetch existing consumptions for current day
    fetchConsumptions()

    // Customize navigation bar
    let navigationBarRect = navigationController!.navigationBar.frame
    let navigationBarTitleLabel = UILabel(frame: navigationBarRect)
    navigationBarTitleLabel.autoresizingMask = .FlexibleWidth
    navigationBarTitleLabel.backgroundColor = UIColor.clearColor()
    navigationBarTitleLabel.text = navigationItem.title
    navigationBarTitleLabel.font = UIFont.boldSystemFontOfSize(16)
    navigationBarTitleLabel.textAlignment = .Center
    navigationItem.titleView = navigationBarTitleLabel

    currentDayLabelInNavigationBar = UILabel(frame: navigationBarRect)
    currentDayLabelInNavigationBar.autoresizingMask = .FlexibleWidth
    currentDayLabelInNavigationBar.backgroundColor = UIColor.clearColor()
    currentDayLabelInNavigationBar.font = UIFont.systemFontOfSize(12)
    currentDayLabelInNavigationBar.textAlignment = .Center
    navigationItem.titleView!.addSubview(currentDayLabelInNavigationBar)
    
    navigationController!.navigationBar.setTitleVerticalPositionAdjustment(-10.0, forBarMetrics: UIBarMetrics.Default)

    // Apply current date to all related labels
    applyDateSwitching()
  }
  
  @IBAction func switchToPreviousDay(sender: AnyObject) {
    currentDate = NSDate(timeInterval: -secondsPerDay, sinceDate: currentDate)
  }

  @IBAction func switchToNextDay(sender: AnyObject) {
    currentDate = NSDate(timeInterval: secondsPerDay, sinceDate: currentDate)
  }
  
  @IBAction func showCalendar(sender: AnyObject) {
  }
  
  func getRecommendedWaterIntake() -> Double {
    return Settings.sharedInstance.userDailyWaterIntake.value
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
  
  func addConsumption(drink: Drink, amount: Double) {
    if let section = multiProgressSections[drink] {
      section.factor += amount
    }
    consumptionProgressView.setNeedsDisplay()
    overallConsumption += amount
  }
  
  private func setOverallConsumption(amount: Double, maximum: Double) {
    assert(maximum > 0, "Maximum of recommended consumption is specified to 0")
    let consumptionText = Units.sharedInstance.formatAmountToText(amount: amount, unitType: .Volume, precision: amountPrecision, decimals: amountDecimals)
    consumptionLabel.text = consumptionText
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

  private func compareDateComponentsWithoutTime(component1: NSDateComponents, _ component2: NSDateComponents) -> Bool {
    return component1.day == component2.day &&
           component1.month == component2.month &&
           component1.year == component2.year
  }
  
  private func formatDate(date: NSDate) -> String {
    let today = NSDate()
    let yesterday = NSDate(timeInterval: -secondsPerDay, sinceDate: today)
    let tomorrow = NSDate(timeInterval: secondsPerDay, sinceDate: today)

    let calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)!
    let todayComponents       = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay, fromDate: today)
    let yesterdayComponents   = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay, fromDate: yesterday)
    let tomorrowComponents    = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay, fromDate: tomorrow)
    let currentDateComponents = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay, fromDate: date)

    let dateFormatter = NSDateFormatter()
    
    if compareDateComponentsWithoutTime(currentDateComponents, todayComponents) ||
       compareDateComponentsWithoutTime(currentDateComponents, tomorrowComponents) ||
       compareDateComponentsWithoutTime(currentDateComponents, yesterdayComponents) {
      // Use standard date formatting for yeasterday, today and tomorrow
      // in order to obtain "Yeasterday", "Today" and "Tomorrow" localized date strings
      dateFormatter.dateStyle = .MediumStyle
      dateFormatter.timeStyle = .NoStyle
      dateFormatter.doesRelativeDateFormatting = true
    } else {
      // Use custom formatting. If year of a current date is year of today, hide them.
      let template = currentDateComponents.year == todayComponents.year ? "dMMMM" : "dMMMMyyyy"
      let formatString = NSDateFormatter.dateFormatFromTemplate(template, options: 0, locale: NSLocale.currentLocale())
      dateFormatter.dateFormat = formatString
    }
    return dateFormatter.stringFromDate(date)
  }
  
  private func applyDateSwitching() {
    // Update all related date labels
    let formattedDate = formatDate(currentDate)
    currentDayButton.setTitle(formattedDate, forState: .Normal)
    currentDayLabelInNavigationBar.text = formattedDate
    
    // Disable switching to the next day if a current day is today
    let calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)!
    NSCalendarUnit.DayCalendarUnit
    
    let today = NSDate()
    let todayComponents      = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay, fromDate: today)
    let currentDayComponents = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay, fromDate: currentDate)
    nextDayButton.enabled = !compareDateComponentsWithoutTime(todayComponents, currentDayComponents)
  }
  
  private func revealButtonSetup() {
    if let revealViewController = self.revealViewController() {
      revealButton.target = revealViewController
      revealButton.action = "revealToggle:"
      navigationController!.navigationBar.addGestureRecognizer(revealViewController.panGestureRecognizer())
      view.addGestureRecognizer(revealViewController.panGestureRecognizer())
    }
  }

  private var pageViewController: UIPageViewController!
  private var pages: [UIViewController] = []
  private var multiProgressSections: [Drink: MultiProgressView.Section] = [:]

  private let pageTitles = ["Drinked", "Add"]
  private let amountPrecision = Settings.sharedInstance.generalVolumeUnits.value.precision
  private let amountDecimals = Settings.sharedInstance.generalVolumeUnits.value.decimals
  private let drinkTypesCount = 9 // number of supported drinks types: water, tea etc.
  private let secondsPerDay: NSTimeInterval = 60 * 60 * 24
}
