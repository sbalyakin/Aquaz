//
//  StatisticsViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 03.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class StatisticsViewController: UIViewController {
  
  @IBOutlet weak var segmentedControl: UISegmentedControl!

  weak var pageViewController: StatisticsPageViewController!
  private var fullVersionBannerView: BannerView?
  private var demoOverlayView: UIView?
  
  private struct Constants {
    static let pageViewControllerEmbeddingSegue = "Page View Controller Embedding"
    static let fullVersionBannerViewNib = "FullVersionBannerView"
    static let fullVersionViewControllerIdentifier = "FullVersionViewController"
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    applyStyle()
    segmentedControl.tintColor = UIColor.whiteColor()
    segmentedControl.backgroundColor = StyleKit.controlTintColor
    
    initStatisticsPage()
    
    checkFullVersion()
    
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "fullVersionIsPurchased:",
      name: GlobalConstants.notificationFullVersionIsPurchased, object: nil)
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  private func applyStyle() {
    UIHelper.applyStyle(self)
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
    let lastStatisticsPage = Settings.uiSelectedStatisticsPage.value
    segmentedControl.selectedSegmentIndex = lastStatisticsPage.rawValue
    activateStatisticsPage(lastStatisticsPage)
  }
  
  private func activateStatisticsPage(page: Settings.StatisticsViewPage) {
    pageViewController.currentPage = page
    Settings.uiSelectedStatisticsPage.value = page
  }

  @IBAction func segmentChanged(sender: UISegmentedControl) {
    if let page = Settings.StatisticsViewPage(rawValue: sender.selectedSegmentIndex) {
      activateStatisticsPage(page)
    } else {
      assert(false, "Unknown statistics page is activated")
    }
  }
  
  private func checkFullVersion() {
    if !Settings.generalFullVersion.value {
      showDemoOverlay()
      showFullVersionBanner()
    }
  }
  
  private func showFullVersionBanner() {
    assert(fullVersionBannerView == nil)
    
    let nib = UINib(nibName: Constants.fullVersionBannerViewNib, bundle: nil)
    
    fullVersionBannerView = nib.instantiateWithOwner(nil, options: nil).first as? BannerView
    fullVersionBannerView!.setTranslatesAutoresizingMaskIntoConstraints(false)
    fullVersionBannerView!.backgroundColor = UIColor(white: 1, alpha: 0.9)
    fullVersionBannerView!.layer.opacity = 0
    fullVersionBannerView!.layer.transform = CATransform3DMakeScale(0.7, 0.7, 0.7)
    view.addSubview(fullVersionBannerView!)
    
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "fullVersionBannerWasTapped:")
    fullVersionBannerView!.addGestureRecognizer(tapGestureRecognizer)
    
    // Setup constraints
    let views = ["banner": fullVersionBannerView!]
    view.addConstraints("H:|-0-[banner]", views: views)
    view.addConstraints("H:[banner]-0-|", views: views)
    view.addConstraints("V:|-0-[banner(75)]", views: views)
    
    // Show the banner with animation
    UIView.animateWithDuration(0.6,
      delay: 0.6,
      usingSpringWithDamping: 0.4,
      initialSpringVelocity: 1.7,
      options: .CurveEaseInOut | .AllowUserInteraction,
      animations: {
        self.fullVersionBannerView!.layer.opacity = 1
        self.fullVersionBannerView!.layer.transform = CATransform3DMakeScale(1, 1, 1)
      },
      completion: nil)
  }
  
  func fullVersionIsPurchased(notification: NSNotification) {
    hideDemoOverlay()
    hideFullVersionBanner()
  }
  
  private func hideFullVersionBanner() {
    fullVersionBannerView?.removeFromSuperview()
    fullVersionBannerView = nil
  }
  
  func fullVersionBannerWasTapped(gestureRecognizer: UITapGestureRecognizer) {
    if gestureRecognizer.state == .Ended {
      if let fullVersionViewController: FullVersionViewController = LoggedActions.instantiateViewController(storyboard: storyboard, storyboardID: Constants.fullVersionViewControllerIdentifier) {
        navigationController!.pushViewController(fullVersionViewController, animated: true)
      }
    }
  }
  
  private func showDemoOverlay() {
    assert(demoOverlayView == nil)
    
    demoOverlayView = UIView()
    demoOverlayView!.setTranslatesAutoresizingMaskIntoConstraints(false)
    demoOverlayView!.backgroundColor = view.backgroundColor!.colorWithAlpha(0.7)
    view.addSubview(demoOverlayView!)

    let demoLabel = UILabel()
    demoLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
    demoLabel.textColor = UIColor.whiteColor()
    demoLabel.backgroundColor = UIColor.clearColor()
    demoLabel.alpha = 0.85
    demoLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 100)
    demoLabel.adjustsFontSizeToFitWidth = true
    demoLabel.textAlignment = .Center
    demoLabel.numberOfLines = 1

    demoLabel.text = NSLocalizedString("SVC:Demo", value: "Demo",
      comment: "StatisticsViewController: Caption above statistics page shown for not-full version of Aquaz").uppercaseString

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

}
