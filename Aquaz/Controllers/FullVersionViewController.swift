//
//  FullVersionViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 12.05.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit
import StoreKit

class FullVersionViewController: UIViewController {

  private class LocalizedStrings {
    
    lazy var descriptionLabelText = NSLocalizedString("FVVC:Description about full version purchase",
      value: "Purchase the full version of Aquaz in order to get:\n\t• Smart notifications\n\t• Extended statistics\n\t• No ads",
      comment: "FullVersionViewController: Description about full version purchase")

    lazy var priceLabelText = NSLocalizedString("FVVC:Price: %@", value: "Price: %@",
      comment: "FullVersionViewController: Template of price label for Full Version purchase")

    lazy var priceLabelErrorText = NSLocalizedString("FVVC:Error", value: "Error",
      comment: "FullVersionViewController: Text displayed as a value of price label if price fetching is failed")

  }
  
  private struct Constants {
    static let approvalBannerViewNib = "ApprovalBannerView"
  }

  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var purchaseFullVersionButton: RoundedButton!

  private let localizedStrings = LocalizedStrings()
  
  private var approvalBannerView: UIView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initUI()
    setupNotificationsObservation()
    fetchPrices()
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    checkDeferredState()
  }
  
  private func initUI() {
    UIHelper.applyStyle(self)

    purchaseFullVersionButton.backgroundColor = StyleKit.controlTintColor
    
    descriptionLabel.text = localizedStrings.descriptionLabelText
  }

  private func checkDeferredState() {
    if InAppPurchaseManager.sharedInstance.isWaitingForApproval {
      showApprovalBanner()
    } else {
      hideApprovalBanner()
    }
  }

  private func showApprovalBanner() {
    if approvalBannerView != nil {
      return
    }
    
    let nib = UINib(nibName: Constants.approvalBannerViewNib, bundle: nil)
    
    approvalBannerView = nib.instantiateWithOwner(nil, options: nil).first as? BannerView
    approvalBannerView!.setTranslatesAutoresizingMaskIntoConstraints(false)
    approvalBannerView!.backgroundColor = UIColor(white: 1, alpha: 0.9)
    approvalBannerView!.layer.opacity = 0
    approvalBannerView!.layer.transform = CATransform3DMakeScale(0.7, 0.7, 0.7)
    view.addSubview(approvalBannerView!)
    
    // Setup constraints
    let views = ["banner": approvalBannerView!]
    view.addConstraints("H:|-0-[banner]", views: views)
    view.addConstraints("H:[banner]-0-|", views: views)
    view.addConstraints("V:|-0-[banner(75)]", views: views)
    
    // Show the banner with animation
    UIView.animateWithDuration(0.6,
      delay: 0,
      usingSpringWithDamping: 0.4,
      initialSpringVelocity: 1.7,
      options: .CurveEaseInOut | .AllowUserInteraction,
      animations: {
        self.approvalBannerView!.layer.opacity = 1
        self.approvalBannerView!.layer.transform = CATransform3DMakeScale(1, 1, 1)
      },
      completion: nil)
  }
  
  private func hideApprovalBanner() {
    if approvalBannerView == nil {
      return
    }
    
    UIView.animateWithDuration(0.6,
      delay: 0,
      usingSpringWithDamping: 0.8,
      initialSpringVelocity: 10,
      options: .CurveEaseInOut | .AllowUserInteraction,
      animations: {
        self.approvalBannerView!.layer.opacity = 0
        self.approvalBannerView!.layer.transform = CATransform3DMakeScale(0.7, 0.7, 0.7)
      },
      completion: { (finished) -> Void in
        self.approvalBannerView!.removeFromSuperview()
        self.approvalBannerView = nil
    })
  }

  private func setupNotificationsObservation() {
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "fullVersionIsPurchased:",
      name: GlobalConstants.notificationFullVersionIsPurchased, object: nil)

    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "fullVersionPurchaseStateDidChange:",
      name: GlobalConstants.notificationFullVersionPurchaseStateDidChange, object: nil)
  }
  
  private func fetchPrices() {
    InAppPurchaseManager.sharedInstance.fetchFullVersionPrice { [weak self] price in
      if self != nil {
        let priceProcessed = price.isEmpty ? self!.localizedStrings.priceLabelErrorText : price
        self!.priceLabel.text = String.localizedStringWithFormat(self!.localizedStrings.priceLabelText, priceProcessed)
      }
    }
  }
  
  func fullVersionIsPurchased(notification: NSNotification) {
    navigationController?.popViewControllerAnimated(true)
  }

  func fullVersionPurchaseStateDidChange(notification: NSNotification) {
    checkDeferredState()
  }
  
  @IBAction func purchaseFullVersion() {
    InAppPurchaseManager.sharedInstance.purchaseFullVersion()
  }
  
  @IBAction func restorePurchases() {
    InAppPurchaseManager.sharedInstance.restorePurchases()
  }
  
}
