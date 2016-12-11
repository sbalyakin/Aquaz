//
//  WelcomeWizardLastPageViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 04.04.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

final class WelcomeWizardLastPageViewController: UIViewController {

  @IBAction func getStartedButtonWasTapped() {
    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
      appDelegate.showDefaultRootViewControllerWithAnimation()
    }
  }
  
}
