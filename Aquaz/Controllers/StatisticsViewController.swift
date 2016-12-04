//
//  StatisticsViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 03.10.14.
//  Copyright © 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

final class StatisticsViewController: UIViewController {
  
  @IBOutlet weak var segmentedControl: UISegmentedControl!

  weak var pageViewController: StatisticsPageViewController!
  
  #if AQUAZLITE
  private struct LocalizedStrings {
    lazy var fullVersionBannerText = NSLocalizedString("SVC:Statistics are available in the full version only.",
      value: "Statistics are available in the full version only.",
      comment: "StatisticsViewController: Text for banner shown to promote the full version of Aquaz")
    
    lazy var demoOverlayText = NSLocalizedString("SVC:DEMO",
      value: "DEMO",
      comment: "StatisticsViewController: Caption above statistics page shown for not-full version of Aquaz. It should be uppercased.")
  }
  
  private var fullVersionBannerView: InfoBannerView?
  private var demoOverlayView: UIView?
  private var localizedStrings = LocalizedStrings()
  #endif
  
  fileprivate struct Constants {
    static let pageViewControllerEmbeddingSegue = "Page View Controller Embedding"
    #if AQUAZLITE
    static let fullVersionViewControllerIdentifier = "FullVersionViewController"
    #endif
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    applyStyle()
    segmentedControl.tintColor = UIColor.white
    segmentedControl.backgroundColor = StyleKit.controlTintColor
    
    initStatisticsPage()
    
    #if AQUAZLITE
    checkFullVersion()
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(fullVersionIsPurchased(_:)),
                                           name: NSNotification.Name(rawValue: GlobalConstants.notificationFullVersionIsPurchased),
                                           object: nil)
    #endif
  }

  #if AQUAZLITE
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  #endif
  
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
  
  #if AQUAZLITE
  private func checkFullVersion() {
    if !Settings.sharedInstance.generalFullVersion.value {
      showDemoOverlay()
      showFullVersionBanner()
    }
  }
  
  private func showFullVersionBanner() {
    assert(fullVersionBannerView == nil)
    
    fullVersionBannerView = InfoBannerView.create()
    fullVersionBannerView!.infoLabel.text = localizedStrings.fullVersionBannerText
    fullVersionBannerView!.infoImageView.image = ImageHelper.loadImage(.BannerFullVersion)
    fullVersionBannerView!.bannerWasTappedFunction = { [weak self] _ in self?.fullVersionBannerWasTapped() }
    fullVersionBannerView!.showDelay = 0.6
    fullVersionBannerView!.show(animated: true, parentView: view)
  }
  
  func fullVersionIsPurchased(_ notification: NSNotification) {
    hideDemoOverlay()
    hideFullVersionBanner()
  }
  
  private func hideFullVersionBanner() {
    fullVersionBannerView?.hide(animated: false) { _ in
      self.fullVersionBannerView = nil
    }
  }
  
  func fullVersionBannerWasTapped() {
    if let fullVersionViewController: FullVersionViewController = LoggedActions.instantiateViewController(storyboard: storyboard, storyboardID: Constants.fullVersionViewControllerIdentifier) {
      navigationController!.pushViewController(fullVersionViewController, animated: true)
    }
  }
  
  private func showDemoOverlay() {
    assert(demoOverlayView == nil)
    
    demoOverlayView = UIView()
    demoOverlayView!.translatesAutoresizingMaskIntoConstraints = false
    demoOverlayView!.backgroundColor = view.backgroundColor!.colorWithAlpha(0.7)
    view.addSubview(demoOverlayView!)
    
    let demoLabel = UILabel()
    demoLabel.translatesAutoresizingMaskIntoConstraints = false
    demoLabel.textColor = UIColor.white
    demoLabel.backgroundColor = UIColor.clear
    demoLabel.alpha = 0.85
    demoLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 100)
    demoLabel.adjustsFontSizeToFitWidth = true
    demoLabel.textAlignment = .center
    demoLabel.numberOfLines = 1
    demoLabel.text = localizedStrings.demoOverlayText
    
    demoOverlayView!.addSubview(demoLabel)
    
    // Setup constraints
    
    let overlayViews = ["overlay": demoOverlayView!]
    view.addConstraints("H:|-0-[overlay]", views: overlayViews)
    view.addConstraints("H:[overlay]-0-|", views: overlayViews)
    view.addConstraints("V:|-0-[overlay]", views: overlayViews)
    view.addConstraints("V:[overlay]-0-|", views: overlayViews)
    
    let labelViews = ["label": demoLabel]
    demoOverlayView!.addConstraints("H:|-30-[label]", views: labelViews)
    demoOverlayView!.addConstraints("H:[label]-30-|", views: labelViews)
    demoOverlayView!.addConstraints("V:|-30-[label]", views: labelViews)
    demoOverlayView!.addConstraints("V:[label]-30-|", views: labelViews)
  }
  
  private func hideDemoOverlay() {
    demoOverlayView?.removeFromSuperview()
    demoOverlayView = nil
  }
  #endif
  
}
