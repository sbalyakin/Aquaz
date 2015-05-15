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

  class Strings {
    
    lazy var descriptionLabelText = NSLocalizedString("FVVC:Description about full version purchase",
      value: "Purchase the full version of Aquaz in order to get:\n\t• Smart notifications\n\t• Extended statistics\n\t• No ads",
      comment: "FullVersionViewController: Description about full version purchase")

    lazy var priceLabelText = NSLocalizedString("FVVC:Price: %@", value: "Price: %@",
      comment: "FullVersionViewController: Template of price label for Full Version purchase")

    lazy var priceLabelErrorText = NSLocalizedString("FVVC:Error", value: "Error",
      comment: "FullVersionViewController: Text displayed as a value of price label if price fetching is failed")

  }
  
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var purchaseFullVersionButton: RoundedButton!

  private let strings = Strings()
  var activityIndicatorView: UIActivityIndicatorView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initUI()
    setupNotificationsObservation()
    fetchPrices()
  }

  private func initUI() {
    UIHelper.applyStyle(self)

    purchaseFullVersionButton.backgroundColor = StyleKit.controlTintColor
    
    descriptionLabel.text = strings.descriptionLabelText
    
    if InAppPurchaseManager.sharedInstance.isBusy {
      showActivityIndicator()
    }
  }
  
  private func setupNotificationsObservation() {
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "fullVersionIsPurchased:",
      name: GlobalConstants.notificationFullVersionIsPurchased, object: nil)

    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "inAppPurchaseManagedDidStartTask:",
      name: GlobalConstants.notificationInAppPurchaseManagerDidStartTask, object: nil)

    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "inAppPurchaseManagedDidFinishTask:",
      name: GlobalConstants.notificationInAppPurchaseManagerDidFinishTask, object: nil)
  }
  
  private func fetchPrices() {
    InAppPurchaseManager.sharedInstance.fetchFullVersionPrice { [weak self] price in
      if self != nil {
        let priceProcessed = price.isEmpty ? self!.strings.priceLabelErrorText : price
        self!.priceLabel.text = String.localizedStringWithFormat(self!.strings.priceLabelText, priceProcessed)
      }
    }
  }
  
  func fullVersionIsPurchased(notification: NSNotification) {
    navigationController?.popViewControllerAnimated(true)
  }

  func inAppPurchaseManagedDidStartTask(notification: NSNotification) {
    showActivityIndicator()
  }

  func inAppPurchaseManagedDidFinishTask(notification: NSNotification) {
    hideActivityIndicator()
  }

  @IBAction func purchaseFullVersion() {
    if InAppPurchaseManager.sharedInstance.purchaseFullVersion() {
      showActivityIndicator()
    }
  }
  
  @IBAction func restorePurchases() {
    showActivityIndicator()
    InAppPurchaseManager.sharedInstance.restorePurchases()
  }
  
  private func showActivityIndicator() {
    if activityIndicatorView != nil {
      return
    }
    
    activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    view.addSubview(activityIndicatorView!)
    activityIndicatorView!.layer.backgroundColor = UIColor(white: 0, alpha: 0.3).CGColor
    activityIndicatorView!.alpha = 0
    activityIndicatorView!.startAnimating()
    activityIndicatorView!.center = view.center
    activityIndicatorView!.frame = view.bounds
    
    UIView.animateWithDuration(0.3, animations: {
      self.activityIndicatorView!.alpha = 1
    }, completion: nil)
  }
  
  private func hideActivityIndicator() {
    if let activityIndicatorView = activityIndicatorView {
      UIView.animateWithDuration(0.3, animations: {
        activityIndicatorView.layer.opacity = 0
        }) { (finished) -> Void in
          activityIndicatorView.removeFromSuperview()
          self.activityIndicatorView = nil
      }
    }
  }

}
