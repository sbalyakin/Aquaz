//
//  StatisticsPageViewController.swift
//  Aquaz
//
//  Created by Admin on 27.03.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class StatisticsPageViewController: UIPageViewController {

  var currentPage: Settings.StatisticsViewPage = .Week {
    didSet {
      let controller = getViewControllerByStatisticsPage(currentPage)
      setViewControllers([controller], direction: .Forward, animated: false, completion: nil)
    }
  }
  
  private var ownViewControllers: [UIViewController!] = [nil, nil, nil]

  private func getViewControllerByStatisticsPage(page: Settings.StatisticsViewPage) -> UIViewController! {
    if let controller = ownViewControllers[page.rawValue] {
      return controller
    }
    
    let controller: UIViewController!
    
    switch page {
    case .Week:  controller = LoggedActions.instantiateViewController(storyboard: storyboard, storyboardID: "Week Statistics View Controller")
    case .Month: controller = LoggedActions.instantiateViewController(storyboard: storyboard, storyboardID: "Month Statistics View Controller")
    case .Year:  controller = LoggedActions.instantiateViewController(storyboard: storyboard, storyboardID: "Year Statistics View Controller")
    }
    
    ownViewControllers[page.rawValue] = controller
    return controller
  }

}
