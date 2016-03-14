//
//  StatisticsViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 03.10.14.
//  Copyright © 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class StatisticsViewController: UIViewController {
  
  @IBOutlet weak var segmentedControl: UISegmentedControl!

  weak var pageViewController: StatisticsPageViewController!
  
  private struct Constants {
    static let pageViewControllerEmbeddingSegue = "Page View Controller Embedding"
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    applyStyle()
    segmentedControl.tintColor = UIColor.whiteColor()
    segmentedControl.backgroundColor = StyleKit.controlTintColor
    
    initStatisticsPage()
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  private func applyStyle() {
    UIHelper.applyStyleToViewController(self)
    segmentedControl.layer.cornerRadius = 3
    segmentedControl.layer.masksToBounds = true
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == Constants.pageViewControllerEmbeddingSegue {
      if let pageViewController = segue.destinationViewController.contentViewController as? StatisticsPageViewController {
        self.pageViewController = pageViewController
      }
    }
  }

  private func pageWasSwitched(page: Settings.StatisticsViewPage) {
    segmentedControl.selectedSegmentIndex = page.rawValue
  }
  
  private func initStatisticsPage() {
    let lastStatisticsPage = Settings.sharedInstance.uiSelectedStatisticsPage.value
    segmentedControl.selectedSegmentIndex = lastStatisticsPage.rawValue
    activateStatisticsPage(lastStatisticsPage)
  }
  
  private func activateStatisticsPage(page: Settings.StatisticsViewPage) {
    pageViewController.currentPage = page
    Settings.sharedInstance.uiSelectedStatisticsPage.value = page
  }

  @IBAction func segmentChanged(sender: UISegmentedControl) {
    if let page = Settings.StatisticsViewPage(rawValue: sender.selectedSegmentIndex) {
      activateStatisticsPage(page)
    } else {
      assert(false, "Unknown statistics page is activated")
    }
  }
  
}
