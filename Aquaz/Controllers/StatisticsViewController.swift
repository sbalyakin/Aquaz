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
  
  fileprivate struct Constants {
    static let pageViewControllerEmbeddingSegue = "Page View Controller Embedding"
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    applyStyle()
    segmentedControl.tintColor = UIColor.white
    segmentedControl.backgroundColor = StyleKit.controlTintColor
    
    initStatisticsPage()
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  fileprivate func applyStyle() {
    UIHelper.applyStyleToViewController(self)
    segmentedControl.layer.cornerRadius = 3
    segmentedControl.layer.masksToBounds = true
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Constants.pageViewControllerEmbeddingSegue {
      if let pageViewController = segue.destination.contentViewController as? StatisticsPageViewController {
        self.pageViewController = pageViewController
      }
    }
  }

  fileprivate func pageWasSwitched(_ page: Settings.StatisticsViewPage) {
    segmentedControl.selectedSegmentIndex = page.rawValue
  }
  
  fileprivate func initStatisticsPage() {
    let lastStatisticsPage = Settings.sharedInstance.uiSelectedStatisticsPage.value
    segmentedControl.selectedSegmentIndex = lastStatisticsPage.rawValue
    activateStatisticsPage(lastStatisticsPage)
  }
  
  fileprivate func activateStatisticsPage(_ page: Settings.StatisticsViewPage) {
    pageViewController.currentPage = page
    Settings.sharedInstance.uiSelectedStatisticsPage.value = page
  }

  @IBAction func segmentChanged(_ sender: UISegmentedControl) {
    if let page = Settings.StatisticsViewPage(rawValue: sender.selectedSegmentIndex) {
      activateStatisticsPage(page)
    } else {
      assert(false, "Unknown statistics page is activated")
    }
  }
  
}
