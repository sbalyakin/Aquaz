//
//  WelcomeWizardViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 04.04.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class WelcomeWizardViewController: UIViewController {

  @IBOutlet weak var pageControl: UIPageControl!
  @IBOutlet weak var skipButton: UIButton!
  weak var pageViewController: WelcomeWizardPageViewController!
  
  private struct Constants {
    static let pageEmbedSegue = "Page Embed"
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: false)
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == Constants.pageEmbedSegue {
      if let pageViewController = segue.destinationViewController.contentViewController as? WelcomeWizardPageViewController {
        pageViewController.pageControl = pageControl
        pageViewController.skipButton = skipButton
        self.pageViewController = pageViewController
      }
    }
  }
  
  @IBAction func skipButtonWasTapped() {
    if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
      appDelegate.showDefaultRootViewControllerWithAnimation()
    }
  }
}
