//
//  RevealedViewControllers.swift
//  Water Me
//
//  Created by Sergey Balyakin on 05.12.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

private class RevealInitializer {

  class func revealButtonSetup(viewController: UIViewController) {
    if let revealViewController = viewController.revealViewController() {
      // TODO: Should be replaced with image button
      let revealButton = UIBarButtonItem(title: "Menu", style: .Plain, target: revealViewController, action: "revealToggle:")
      viewController.navigationItem.setLeftBarButtonItem(revealButton, animated: true)
      viewController.navigationController!.navigationBar.addGestureRecognizer(revealViewController.panGestureRecognizer())
      viewController.view.addGestureRecognizer(revealViewController.panGestureRecognizer())
    }
  }
  
}

class RevealedViewController: StyledViewController {
  
  var initializesRevealControls = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if initializesRevealControls {
      RevealInitializer.revealButtonSetup(self)
    }
  }
}

class RevealedTableViewController: StyledTableViewController {
  
  var initializesRevealControls = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if initializesRevealControls {
      RevealInitializer.revealButtonSetup(self)
    }
  }
}
