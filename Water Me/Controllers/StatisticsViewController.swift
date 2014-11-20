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
  @IBOutlet weak var revealButton: UIBarButtonItem!
  
  var viewControllers: [UIViewController!] = [nil, nil, nil]
  var currentViewController: UIViewController!
  
  enum ViewControllerType: Int {
    case Week = 0, Month, Year
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    revealButtonSetup()
    
    let viewControllerTypeToActivate = Settings.sharedInstance.uiSelectedStatisticsPage.value
    segmentedControl.selectedSegmentIndex = viewControllerTypeToActivate.rawValue
    activateViewControllerWithType(viewControllerTypeToActivate)
  }

  private func activateViewControllerWithType(type: ViewControllerType) {
    for viewController in viewControllers {
      if let controller = viewController {
        controller.view.removeFromSuperview()
      }
    }

    let rects = view.bounds.rectsByDividing(segmentedControl.frame.maxY, fromEdge: .MinYEdge)
    let viewController = getViewControllerWithType(type)
    viewController.view.frame = rects.remainder
    view.addSubview(viewController.view)
    
    Settings.sharedInstance.uiSelectedStatisticsPage.value = type
  }

  private func getViewControllerWithType(type: ViewControllerType) -> UIViewController {
    if let controller = viewControllers[type.rawValue] {
      return controller
    }
    
    var controller: UIViewController!
    
    switch type {
    case .Week:  controller = storyboard!.instantiateViewControllerWithIdentifier("Week Statistics View Controller") as UIViewController
    case .Month: controller = storyboard!.instantiateViewControllerWithIdentifier("Month Statistics View Controller") as UIViewController
    case .Year:  controller = storyboard!.instantiateViewControllerWithIdentifier("Year Statistics View Controller") as UIViewController
    }
    
    viewControllers[type.rawValue] = controller
    return controller
  }
  
  @IBAction func segmentChanged(sender: UISegmentedControl) {
    let type = ViewControllerType(rawValue: sender.selectedSegmentIndex)
    assert(type != nil, "Segment for unknown view controller is activated")
    if let type = type {
      activateViewControllerWithType(type)
    }
  }
  
  private func revealButtonSetup() {
    if let revealViewController = self.revealViewController() {
      revealButton.target = revealViewController
      revealButton.action = "revealToggle:"
      navigationController!.navigationBar.addGestureRecognizer(revealViewController.panGestureRecognizer())
      view.addGestureRecognizer(revealViewController.panGestureRecognizer())
    }
  }

}
