//
//  WelcomeWizardPageViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 04.04.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

final class WelcomeWizardPageViewController: UIPageViewController {

  fileprivate var ownViewControllers = [UIViewController]()
  weak var pageControl: UIPageControl!
  weak var skipButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    baseSetup()
  }
  
  fileprivate func baseSetup() {
    let welcomePage: UIViewController = LoggedActions.instantiateViewController(storyboard: storyboard, storyboardID: "Welcome Page")!
    let unitsPage: UIViewController   = LoggedActions.instantiateViewController(storyboard: storyboard, storyboardID: "Units Page")!
    let metricsPage: UIViewController = LoggedActions.instantiateViewController(storyboard: storyboard, storyboardID: "Metrics Page")!
    let lastPage: UIViewController    = LoggedActions.instantiateViewController(storyboard: storyboard, storyboardID: "Last Page")!

    if #available(iOS 9.0, *) {
      let appleHealthPage: UIViewController = LoggedActions.instantiateViewController(storyboard: storyboard, storyboardID: "Apple Health Page")!
      ownViewControllers = [
        welcomePage,
        appleHealthPage,
        unitsPage,
        metricsPage,
        lastPage]
    } else {
      ownViewControllers = [
        welcomePage,
        unitsPage,
        metricsPage,
        lastPage]
    }
    
    dataSource = self
    delegate = self
    setViewControllers([ownViewControllers[0]], direction: .forward, animated: false, completion: nil)
    
    pageControl.numberOfPages = ownViewControllers.count
    pageControl.currentPage = 0
  }
  
  fileprivate func getPageIndexForViewController(_ viewController: UIViewController) -> Int {
    for (index, ownViewController) in ownViewControllers.enumerated() {
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
 
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    let pageIndex = getPageIndexForViewController(viewController)
    if pageIndex > 0 {
      return ownViewControllers[pageIndex - 1]
    } else {
      return nil
    }
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
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

  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    if let currentViewController = pageViewController.viewControllers?[0] {
      let pageIndex = getPageIndexForViewController(currentViewController)
      pageControl.currentPage = pageIndex
      
      if pageIndex == ownViewControllers.count - 1 {
        UIView.animate(withDuration: 0.4, animations: {
          self.skipButton.alpha = 0
        }, completion: { _ in
          self.skipButton.isHidden = true
        })
      } else if skipButton.isHidden {
        skipButton.alpha = 0
        skipButton.isHidden = false
        
        UIView.animate(withDuration: 0.4, animations: {
          self.skipButton.alpha = 1
        }) 
      }
    }
  }

}
