//
//  TodayContainerViewController.swift
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

class TodayContainerViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
  
  var pageViewController: UIPageViewController!
  
  var pages: [UIViewController] = []
  var pageTitles = ["Drinked", "Add"]
  
  @IBOutlet weak var revealButton: UIBarButtonItem!
  @IBOutlet weak var modeButton: UIBarButtonItem!
  @IBOutlet weak var summaryNavigationBar: UIView!
  @IBOutlet weak var consumptionProgressView: MultiProgressView!
  @IBOutlet weak var consumptionLabel: UILabel!
  
  var todayOverallConsumption: Double = 0.0 {
    didSet {
      setTodayOverallConsumption(todayOverallConsumption, maximum: getCurrentDailyWaterIntake())
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Add today view controller
    let todayViewController = storyboard!.instantiateViewControllerWithIdentifier("TodayViewController") as TodayViewController
    todayViewController.todayContainerViewController = self
    pages.append(todayViewController)

    // Add consumption view controller
    let consumptionViewController = storyboard!.instantiateViewControllerWithIdentifier("ConsumptionViewController") as UIViewController
    pages.append(consumptionViewController)
    
    // Add page view controller
    pageViewController = storyboard!.instantiateViewControllerWithIdentifier("TodayPageViewController") as UIPageViewController
    pageViewController.dataSource = self
    pageViewController.delegate = self
    pageViewController.setViewControllers([todayViewController], direction: .Forward, animated: false, completion: nil)
    
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
    consumptionProgressView.maximum = getCurrentDailyWaterIntake()
    
    // Additional setup for revealing
    revealButtonSetup()
    
    // Fetch existing consumptions for current day
    fetchTodayConsumptions()
  }
  
  func getCurrentDailyWaterIntake() -> Double {
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
      modeButton.title = pageTitles[0]
    } else if currentPage == pages[1] {
      modeButton.title = pageTitles[1]
    }
  }
  
  @IBAction func toggleCurrentPage(sender: AnyObject) {
    let currentPage = pageViewController.viewControllers.last as UIViewController
    if currentPage == pages[0] {
      pageViewController.setViewControllers([pages[1]], direction: .Forward, animated: true, completion: nil)
      modeButton.title = pageTitles[1]
    } else if currentPage == pages[1] {
      pageViewController.setViewControllers([pages[0]], direction: .Reverse, animated: true, completion: nil)
      modeButton.title = pageTitles[0]
    }
  }
  
  func addConsumptionForToday(drink: Drink, amount: Double) {
    if let section = multiProgressSections[drink] {
      section.factor += amount
    }
    consumptionProgressView.setNeedsDisplay()
    todayOverallConsumption += amount
  }
  
  private func setTodayOverallConsumption(amount: Double, maximum: Double) {
    assert(maximum > 0, "Maximum of recommended consumption is specified to 0")
    let consumptionText = Units.sharedInstance.formatAmountToText(amount: amount, unitType: .Volume, precision: amountPrecision, decimals: amountDecimals)
    consumptionLabel.text = consumptionText
  }
  
  private func fetchTodayConsumptions() {
    var overallAmount = 0.0
    if let consumptions = ModelHelper.sharedInstance.computeDrinkAmountsForDay(NSDate()) {
      for (drink, amount) in consumptions {
        overallAmount += amount
        if let section = multiProgressSections[drink] {
          section.factor = amount
        }
      }
    }
    consumptionProgressView.setNeedsDisplay()
    todayOverallConsumption = overallAmount
  }
  
  private func revealButtonSetup() {
    if let revealViewController = self.revealViewController() {
      revealButton.target = revealViewController
      revealButton.action = "revealToggle:"
      navigationController!.navigationBar.addGestureRecognizer(revealViewController.panGestureRecognizer())
      view.addGestureRecognizer(revealViewController.panGestureRecognizer())
    }
  }
  
  private let amountPrecision = Settings.sharedInstance.generalVolumeUnits.value.precision
  private let amountDecimals = Settings.sharedInstance.generalVolumeUnits.value.decimals
  private let drinkTypesCount = 9 // number of supported drinks types: water, tea etc.
  private var multiProgressSections: [Drink: MultiProgressView.Section] = [:]

}
