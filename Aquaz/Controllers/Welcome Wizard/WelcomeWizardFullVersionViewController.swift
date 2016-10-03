//
//  WelcomeWizardLastPageViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 04.04.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class WelcomeWizardLastPageViewController: UIViewController {

  @IBOutlet weak var getStartedButton: RoundedButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    getStartedButton.setTitleColor(UIColor.white, for: UIControlState())
  }
  
  @IBAction func getStartedButtonWasTapped() {
    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
      appDelegate.showDefaultRootViewControllerWithAnimation()
    }
  }
  
}
