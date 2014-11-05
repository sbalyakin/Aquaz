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
  @IBOutlet weak var consumptionProgressView: UIProgressView!
  @IBOutlet weak var consumptionLabel: UILabel!
  
  var todayConsumption: Double = 0.0 {
    didSet {
      setTodayConsumption(todayConsumption, maximum: Double(Settings.sharedInstance.userDailyWaterIntake.value))
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
    
    // Additional setup for revealing
    revealButtonSetup()
    
    // Specify existing consumptions
    todayConsumption = getTodayConsumption()
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
  
  func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
    let currentPage = pageViewController.viewControllers.last as UIViewController
    if currentPage == pages[0] {
      modeButton.title = pageTitles[0]
    } else if currentPage == pages[1] {
      modeButton.title = pageTitles[1]
    }
  }
  
  func addConsumptionForToday(drink: Drink, amount: Double) {
    todayConsumption += amount
  }
  
  private func revealButtonSetup() {
    if let revealViewController = self.revealViewController() {
      revealButton.target = revealViewController
      revealButton.action = "revealToggle:"
      navigationController!.navigationBar.addGestureRecognizer(revealViewController.panGestureRecognizer())
      view.addGestureRecognizer(revealViewController.panGestureRecognizer())
    }
  }
  
  private func setTodayConsumption(amount: Double, maximum: Double) {
    assert(maximum > 0, "Maximum of recommended consumption is specified to 0")
    let progress = amount / maximum
    consumptionProgressView.progress = Float(progress)
    
    let consumptionText = Units.sharedInstance.formatAmountToText(amount: amount, unitType: .Volume, precision: amountPrecision, decimals: amountDecimals)
    consumptionLabel.text = consumptionText
  }
  
  private func getTodayConsumption() -> Double {
    if let consumptions = ModelHelper.sharedInstance.computeDrinkAmountsForDay(NSDate()) {
      var overallAmount = 0.0
      for (drink, amount) in consumptions {
        overallAmount += amount
      }
      return overallAmount
    } else {
      return 0.0
    }
  }
  
  private let amountPrecision = Settings.sharedInstance.generalVolumeUnits.value.precision
  private let amountDecimals = Settings.sharedInstance.generalVolumeUnits.value.decimals

}
