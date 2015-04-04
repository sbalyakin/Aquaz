//
//  WelcomeWizardProVersionViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 04.04.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class WelcomeWizardProVersionViewController: UIViewController {

  @IBOutlet weak var getStartedButton: RoundedButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    getStartedButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
  }
  
  @IBAction func getStartedButtonWasTapped() {
    if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
      appDelegate.showDefaultRootViewControllerWithAnimation()
    }
  }
  
}
