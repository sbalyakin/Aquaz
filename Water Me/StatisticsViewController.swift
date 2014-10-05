//
//  StatisticsViewController.swift
//  Water Me
//
//  Created by Sergey Balyakin on 03.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class StatisticsViewController: UIViewController {
  
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  var viewControllers: [UIViewController] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    let todayStatisticsViewController = storyboard!.instantiateViewControllerWithIdentifier("Today Statistics View Controller") as UIViewController
    let monthStatisticsViewController = storyboard!.instantiateViewControllerWithIdentifier("Month Statistics View Controller") as UIViewController
    let yearStatisticsViewController = storyboard!.instantiateViewControllerWithIdentifier("Year Statistics View Controller") as UIViewController
    
    viewControllers.append(todayStatisticsViewController)
    viewControllers.append(monthStatisticsViewController)
    viewControllers.append(yearStatisticsViewController)
    
    // TODO: Controller index for activation should be taken from saved settings
    activateViewController(0)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func activateViewController(index: Int) {
    for viewController in viewControllers {
      viewController.view.removeFromSuperview()
    }
    
    assert(index >= 0 && index < viewControllers.count, "View controller for activation is invalid")
    if (index < 0 || index >= viewControllers.count) {
      return
    }
    
    let viewController = viewControllers[index]
    let currentView = viewController.view
    currentView.frame = view.frame
    currentView.frame.origin.y = segmentedControl.frame.origin.y + segmentedControl.frame.size.height + 20
    
    view.addSubview(viewController.view)
  }
  
  @IBAction func segmentChanged(sender: UISegmentedControl) {
    activateViewController(sender.selectedSegmentIndex)
  }
}
