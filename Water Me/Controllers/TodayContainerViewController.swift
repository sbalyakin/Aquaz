//
//  TodayContainerViewController.swift
//  Water Me
//
//  Created by Sergey Balyakin on 03.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class TodayContainerViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
  
  var pageViewController: UIPageViewController!
  
  var pages: [UIViewController] = []
  var pageTitles = ["Stat", "Today"]
  
  @IBOutlet weak var revealButton: UIBarButtonItem!
  @IBOutlet weak var modeButton: UIBarButtonItem!
  
  
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
    pageViewController.delegate = self
    pageViewController.setViewControllers([todayViewController], direction: .Forward, animated: false, completion: nil)
    
    addChildViewController(pageViewController)
    view.addSubview(pageViewController.view)
    
    pageViewController.didMoveToParentViewController(self)
    
    // Additional setup for revealing
    revealButtonSetup()
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
  
  func revealButtonSetup() {
    if let revealViewController = self.revealViewController() {
      revealButton.target = revealViewController
      revealButton.action = "revealToggle:"
      navigationController!.navigationBar.addGestureRecognizer(revealViewController.panGestureRecognizer())
      view.addGestureRecognizer(revealViewController.panGestureRecognizer())
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
  
  func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
    let currentPage = pageViewController.viewControllers.last as UIViewController
    if currentPage == pages[0] {
      modeButton.title = pageTitles[0]
    } else if currentPage == pages[1] {
      modeButton.title = pageTitles[1]
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}
