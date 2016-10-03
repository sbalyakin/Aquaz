//
//  StatisticsPageViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 27.03.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class StatisticsPageViewController: UIPageViewController {

  var currentPage: Settings.StatisticsViewPage = .week {
    didSet {
      let controller = getViewControllerByStatisticsPage(currentPage)
      setViewControllers([controller!], direction: .forward, animated: false, completion: nil)
    }
  }
  
  fileprivate var ownViewControllers: [UIViewController?] = [nil, nil, nil]

  fileprivate func getViewControllerByStatisticsPage(_ page: Settings.StatisticsViewPage) -> UIViewController! {
    if let controller = ownViewControllers[page.rawValue] {
      return controller
    }
    
    let controller: UIViewController!
    
    switch page {
    case .week:  controller = LoggedActions.instantiateViewController(storyboard: storyboard, storyboardID: "Week Statistics View Controller")
    case .month: controller = LoggedActions.instantiateViewController(storyboard: storyboard, storyboardID: "Month Statistics View Controller")
    case .year:  controller = LoggedActions.instantiateViewController(storyboard: storyboard, storyboardID: "Year Statistics View Controller")
    }
    
    ownViewControllers[page.rawValue] = controller
    return controller
  }

}
