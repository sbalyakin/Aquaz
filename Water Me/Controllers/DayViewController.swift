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
  var currentDayLabelInNavigationTitle: UILabel! // programmatically created in viewDidLoad()
  
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

    // Apply current date to all related labels
    applyDateSwitching()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  @IBAction func switchToPreviousDay(sender: AnyObject) {
    currentDate = DateHelper.addToDate(currentDate, years: 0, months: 0, days: -1)
  }

  @IBAction func switchToNextDay(sender: AnyObject) {
    currentDate = DateHelper.addToDate(currentDate, years: 0, months: 0, days: 1)
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
    // Update all related date labels
    let formattedDate = formatDate(currentDate)
    currentDayButton.setTitle(formattedDate, forState: .Normal)
    currentDayLabelInNavigationTitle.text = formattedDate
    
    // Disable switching to the next day if a current day is today
    let daysToToday = DateHelper.computeUnitsFrom(currentDate, toDate: NSDate(), unit: .CalendarUnitDay)
    nextDayButton.enabled = daysToToday > 0
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
}
