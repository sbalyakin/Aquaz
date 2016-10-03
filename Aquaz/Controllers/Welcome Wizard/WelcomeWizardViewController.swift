//
//  WelcomeWizardViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 04.04.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class WelcomeWizardViewController: UIViewController {

  @IBOutlet weak var pageControl: UIPageControl!
  @IBOutlet weak var skipButton: UIButton!
  weak var pageViewController: WelcomeWizardPageViewController!
  
  fileprivate struct Constants {
    static let pageEmbedSegue = "Page Embed"
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    UIApplication.shared.setStatusBarStyle(.default, animated: false)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    UIApplication.shared.setStatusBarStyle(.lightContent, animated: false)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Constants.pageEmbedSegue {
      if let pageViewController = segue.destination.contentViewController as? WelcomeWizardPageViewController {
        pageViewController.pageControl = pageControl
        pageViewController.skipButton = skipButton
        self.pageViewController = pageViewController
      }
    }
  }
  
  @IBAction func skipButtonWasTapped() {
    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
      appDelegate.showDefaultRootViewControllerWithAnimation()
    }
  }
}
