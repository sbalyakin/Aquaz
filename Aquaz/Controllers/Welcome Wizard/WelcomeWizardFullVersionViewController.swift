//
//  WelcomeWizardFullVersionViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 04.04.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class WelcomeWizardFullVersionViewController: UIViewController {

  @IBOutlet weak var getStartedButton: RoundedButton!
  
  struct Constants {
    static let fullVersionViewControllerIdentifier = "FullVersionViewController"
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    getStartedButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
  }
  
  @IBAction func getStartedButtonWasTapped() {
    if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
      appDelegate.showDefaultRootViewControllerWithAnimation()
    }
  }
  
  @IBAction func seeFullVersionButtonWasTapped() {
    let storyboard = UIStoryboard(name: GlobalConstants.storyboardMain, bundle: nil)
    if let fullVersionViewController: UIViewController = LoggedActions.instantiateViewController(storyboard: storyboard, storyboardID: Constants.fullVersionViewControllerIdentifier) {
      presentViewController(fullVersionViewController, animated: true, completion: nil)
    }
  }
  
}
