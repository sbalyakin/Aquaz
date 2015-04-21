//
//  WelcomeWizardPageViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 04.04.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class WelcomeWizardPageViewController: UIPageViewController {

  private var ownViewControllers: [UIViewController!] = [nil, nil, nil]
  weak var pageControl: UIPageControl!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    baseSetup()
  }
  
  private func baseSetup() {
    let welcomePage: UIViewController    = LoggedActions.instantiateViewController(storyboard: storyboard, storyboardID: "Welcome Page")!
    let unitsPage: UIViewController      = LoggedActions.instantiateViewController(storyboard: storyboard, storyboardID: "Units Page")!
    let metricsPage: UIViewController    = LoggedActions.instantiateViewController(storyboard: storyboard, storyboardID: "Metrics Page")!
    let proVersionPage: UIViewController = LoggedActions.instantiateViewController(storyboard: storyboard, storyboardID: "Pro Version Page")!
    
    ownViewControllers = [
      welcomePage,
      unitsPage,
      metricsPage,
      proVersionPage]
    
    dataSource = self
    delegate = self
    setViewControllers([ownViewControllers[0]], direction: .Forward, animated: false, completion: nil)
    
    pageControl.numberOfPages = ownViewControllers.count
    pageControl.currentPage = 0
  }
  
  private func getPageIndexForViewController(viewController: UIViewController) -> Int {
    for (index, ownViewController) in enumerate(ownViewControllers) {
      if ownViewController === viewController {
        return index
      }
    }
    assert(false)
    return 0
  }
}

// MARK: UIPageViewControllerDataSource
extension WelcomeWizardPageViewController: UIPageViewControllerDataSource {
 
  func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
    let pageIndex = getPageIndexForViewController(viewController)
    if pageIndex > 0 {
      return ownViewControllers[pageIndex - 1]
    } else {
      return nil
    }
  }
  
  func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
    let pageIndex = getPageIndexForViewController(viewController)
    if pageIndex < ownViewControllers.count - 1 {
      return ownViewControllers[pageIndex + 1]
    } else {
      return nil
    }
  }

}

// MARK: UIPageViewControllerDelegate
extension WelcomeWizardPageViewController: UIPageViewControllerDelegate {

  func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
    if let currentViewController = pageViewController.viewControllers[0] as? UIViewController {
      let pageIndex = getPageIndexForViewController(currentViewController)
      pageControl.currentPage = pageIndex
    }
  }

}