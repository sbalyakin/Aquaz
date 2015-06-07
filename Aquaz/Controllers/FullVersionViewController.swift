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
      value: "Purchase the full version of Aquaz in order to:\n\t• get smart notifications\n\t• activate statistics\n\t• remove ads",
      comment: "FullVersionViewController: Description about full version purchase")

    lazy var priceLabelText = NSLocalizedString("FVVC:Price: %@",
      value: "Price: %@",
      comment: "FullVersionViewController: Template of price label for Full Version purchase")

    lazy var priceLabelErrorText = NSLocalizedString("FVVC:Error",
      value: "Error",
      comment: "FullVersionViewController: Text displayed as a value of price label if price fetching is failed")

    lazy var approvalBannerText = NSLocalizedString("FVVC:Waiting for an approval from your family delegate...",
      value: "Waiting for an approval from your family delegate...",
      comment: "FullVersionViewController: Text for a banner shown if full version purchase is deffered and waits for an approval from parents")
    
  }
  
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var purchaseFullVersionButton: RoundedButton!

  private let localizedStrings = LocalizedStrings()
  
  private var approvalBannerView: InfoBannerView?
  
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
    
    approvalBannerView = InfoBannerView.create()
    approvalBannerView!.infoLabel.text = localizedStrings.approvalBannerText
    approvalBannerView!.infoImageView.image = UIImage(named: "welcomeFullVersion")
    approvalBannerView!.accessoryImageView.hidden = true
    approvalBannerView!.show(animated: true, parentView: view)
  }
  
  private func hideApprovalBanner() {
    if approvalBannerView == nil {
      return
    }

    approvalBannerView?.hide(animated: false) { _ in
      self.approvalBannerView = nil
    }
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
