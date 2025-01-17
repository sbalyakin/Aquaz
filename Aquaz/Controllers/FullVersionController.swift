//
//  FullVersionViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 12.05.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit
import StoreKit

class FullVersionViewController: UIViewController {
  
  private struct LocalizedStrings {
    
    lazy var descriptionLabelText: String = NSLocalizedString("FVVC:Description about full version purchase",
                                                              value: "Purchase the full version of Aquaz in order to:\n\t• use smart notifications\n\t• activate statistics\n\t• remove ads",
                                                              comment: "FullVersionViewController: Description about full version purchase")
    
    lazy var priceLabelText: String = NSLocalizedString("FVVC:Price: %@",
                                                        value: "Price: %@",
                                                        comment: "FullVersionViewController: Template of price label for Full Version purchase")
    
    lazy var priceLabelErrorText: String = NSLocalizedString("FVVC:Error",
                                                             value: "Error",
                                                             comment: "FullVersionViewController: Text displayed as a value of price label if price fetching is failed")
    
    lazy var approvalBannerText: String = NSLocalizedString("FVVC:Waiting for an approval from your family delegate...",
                                                            value: "Waiting for an approval from your family delegate...",
                                                            comment: "FullVersionViewController: Text for a banner shown if full version purchase is deffered and waits for an approval from parents")
    
  }
  
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var purchaseFullVersionButton: RoundedButton!
  
  private var localizedStrings = LocalizedStrings()
  
  private var approvalBannerView: InfoBannerView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initUI()
    setupNotificationsObservation()
    fetchPrices()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    checkDeferredState()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  private func initUI() {
    UIHelper.applyStyleToViewController(self)
    
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
    approvalBannerView!.infoImageView.image = ImageHelper.loadImage(.BannerParentalControl)
    approvalBannerView!.accessoryImageView.isHidden = true
    approvalBannerView!.show(animated: true, parentView: view)
  }
  
  private func hideApprovalBanner() {
    if approvalBannerView == nil {
      return
    }
    
    approvalBannerView?.hide(animated: false) { [weak self] _ in
      self?.approvalBannerView = nil
    }
  }
  
  private func setupNotificationsObservation() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(fullVersionIsPurchased(_:)),
                                           name: NSNotification.Name(rawValue: GlobalConstants.notificationFullVersionIsPurchased), object: nil)
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(fullVersionPurchaseStateDidChange(_:)),
                                           name: NSNotification.Name(rawValue: GlobalConstants.notificationFullVersionPurchaseStateDidChange), object: nil)
  }
  
  private func fetchPrices() {
    InAppPurchaseManager.sharedInstance.fetchFullVersionPrice { [weak self] price in
      if let _self = self {
        let priceProcessed = price.isEmpty ? _self.localizedStrings.priceLabelErrorText : price
        _self.priceLabel.text = String.localizedStringWithFormat(_self.localizedStrings.priceLabelText, priceProcessed)
      }
    }
  }
  
  @objc func fullVersionIsPurchased(_ notification: NSNotification) {
    _ = navigationController?.popViewController(animated: true)
  }
  
  @objc func fullVersionPurchaseStateDidChange(_ notification: NSNotification) {
    checkDeferredState()
  }
  
  @IBAction func purchaseFullVersion() {
    _ = InAppPurchaseManager.sharedInstance.purchaseFullVersion()
  }
  
  @IBAction func restorePurchases() {
    InAppPurchaseManager.sharedInstance.restorePurchases()
  }
  
}
