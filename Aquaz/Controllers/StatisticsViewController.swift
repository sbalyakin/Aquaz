//
//  StatisticsViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 03.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class StatisticsViewController: RevealedViewController {
  
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  
  var viewControllers: [UIViewController!] = [nil, nil, nil]
  var currentViewController: UIViewController!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    applyStyle()
    
    let lastStatisticsPage = Settings.sharedInstance.uiSelectedStatisticsPage.value
    segmentedControl.selectedSegmentIndex = lastStatisticsPage.rawValue
    activateStatisticsPage(lastStatisticsPage)
  }

  private func applyStyle() {
    UIHelper.applyStyle(self)
    segmentedControl.layer.cornerRadius = 3
    segmentedControl.layer.masksToBounds = true
  }
  
  private func activateStatisticsPage(page: Settings.StatisticsViewPage) {
    for viewController in viewControllers {
      viewController?.view.removeFromSuperview()
    }

    let rects = view.bounds.rectsByDividing(segmentedControl.frame.maxY, fromEdge: .MinYEdge)
    let viewController = getViewControllerByStatisticsPage(page)
    viewController.view.frame = rects.remainder
    
    for controller in childViewControllers {
      controller.removeFromParentViewController()
    }
    
    addChildViewController(viewController)
    view.addSubview(viewController.view)
    
    Settings.sharedInstance.uiSelectedStatisticsPage.value = page
  }

  private func getViewControllerByStatisticsPage(page: Settings.StatisticsViewPage) -> UIViewController {
    if let controller = viewControllers[page.rawValue] {
      return controller
    }
    
    let controller: UIViewController!
    
    switch page {
    case .Week:  controller = LoggedActions.instantiateViewController(storyboard: storyboard, storyboardID: "Week Statistics View Controller")
    case .Month: controller = LoggedActions.instantiateViewController(storyboard: storyboard, storyboardID: "Month Statistics View Controller")
    case .Year:  controller = LoggedActions.instantiateViewController(storyboard: storyboard, storyboardID: "Year Statistics View Controller")
    }
    
    viewControllers[page.rawValue] = controller
    return controller
  }
  
  @IBAction func segmentChanged(sender: UISegmentedControl) {
    if let page = Settings.StatisticsViewPage(rawValue: sender.selectedSegmentIndex) {
      activateStatisticsPage(page)
    } else {
      assert(false, "Unknown statistics page is activated")
    }
  }
}
