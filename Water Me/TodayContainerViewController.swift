//
//  TodayContainerViewController.swift
//  Water Me
//
//  Created by Sergey Balyakin on 03.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class TodayContainerViewController: UIViewController, UIPageViewControllerDataSource {
  
  var pageViewController: UIPageViewController!
  
  var pages: [UIViewController] = []
  
  @IBOutlet weak var revealButton: UIBarButtonItem!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Create view controllers for pages
    let todayViewController = storyboard!.instantiateViewControllerWithIdentifier("TodayViewController") as UIViewController
    let statisticsViewController = storyboard!.instantiateViewControllerWithIdentifier("StatisticsViewController") as UIViewController
    pages.append(todayViewController)
    pages.append(statisticsViewController)
    
    // Create page view controller
    pageViewController = storyboard!.instantiateViewControllerWithIdentifier("TodayPageViewController") as UIPageViewController
    pageViewController.dataSource = self
    pageViewController.setViewControllers([todayViewController], direction: .Forward, animated: false, completion: nil)
    
    addChildViewController(pageViewController)
    view.addSubview(pageViewController.view)
    
    pageViewController.didMoveToParentViewController(self)
    
    // Additional setup for revealing
    revealButtonSetup()
  }
  
  func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
    if let index = find(pages, viewController) {
      return (index > 0) ? pages[index - 1] : nil
    }
    
    return nil
  }
  
  func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
    if let index = find(pages, viewController) {
      return (index < pages.count - 1) ? pages[index + 1] : nil
    }
    
    return nil
  }
  
  func revealButtonSetup() {
    if let revealViewController = self.revealViewController() {
      revealButton.target = revealViewController
      revealButton.action = "revealToggle:"
      navigationController!.navigationBar.addGestureRecognizer(revealViewController.panGestureRecognizer())
      view.addGestureRecognizer(revealViewController.panGestureRecognizer())
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}
