//
//  FullVersionViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 12.05.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit
import StoreKit

class FullVersionViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {

  class Strings {
    
    lazy var descriptionLabelText = NSLocalizedString("FVVC:Description about full version purchase",
      value: "Purchase the full version of Aquaz in order to get:\n\t• Smart notifications\n\t• Extended statistics\n\t• No ads",
      comment: "FullVersionViewController: Description about full version purchase")

    lazy var priceLabelText = NSLocalizedString("FVVC:Price: %@", value: "Price: %@",
      comment: "FullVersionViewController: Template of price label for Full Version purchase")

    lazy var forbiddenPaymentsAlertMessage = NSLocalizedString("FVVC:It\'s forbidden to make payments due to parental controls",
      value: "It\'s forbidden to make payments due to parental controls",
      comment: "FullVersionViewController: Message shown to user if payments are forbidden according to parental controls")
    
    lazy var fullVersionRestoredAlertMessage = NSLocalizedString("FVVC:Full Version has been successfully restored",
      value: "Full Version has been successfully restored",
      comment: "FullVersionViewController: Message shown after successful restoring Full Version purchase")
    
    lazy var fullVersionPurchasedAlertMessage = NSLocalizedString("FVVC:Full Version has been successfully purchased",
      value: "Full Version has been successfully purchased",
      comment: "FullVersionViewController: Message shown after successful purchasing Full Version")
    
    lazy var purchaseFailedAlertTitle = NSLocalizedString("FVVC:Purchase Failed", value: "Purchase Failed",
      comment: "FullVersionViewController: Message title for alert shown if a purchase is failed")
    
    lazy var okButtonTitle = NSLocalizedString("FVVC:OK", value: "OK", comment: "FullVersionViewController: Title of OK button")
    
    lazy var transactionFailedClientInvalid = NSLocalizedString("FVVC:You is not allowed to perform the attempted action",
      value: "You is not allowed to perform the attempted action",
      comment: "FullVersionViewController: Message shown when payment transaction failed by reason: Client is not allowed to perform the attempted action")

    lazy var transactionFailedPaymentInvalid = NSLocalizedString("FVVC:Payment parameters was not recognized by the App Store",
      value: "Payment parameters was not recognized by the App Store",
      comment: "FullVersionViewController: Message shown when payment transaction failed by reason: Payment parameters was not recognized by the App Store")

    lazy var transactionFailedPaymentNotAllowed = NSLocalizedString("FVVC:You is not allowed to authorize payments",
      value: "You is not allowed to authorize payments",
      comment: "FullVersionViewController: Message shown when payment transaction failed by reason: User is not allowed to authorize payments")

    lazy var transactionFailedProductIsNotAvailable = NSLocalizedString("FVVC:The requested product is not available in the store",
      value: "The requested product is not available in the store",
      comment: "FullVersionViewController: Message shown when payment transaction failed by reason: The requested product is not available in the store")

    lazy var transactionFailedUnknownError = NSLocalizedString("FVVC:An unknown error occured",
      value: "An unknown error occured",
      comment: "FullVersionViewController: Message shown when payment transaction failed by reason: An unknown error occured")

  }
  

  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var purchaseFullVersionButton: RoundedButton!

  let strings = Strings()
  var activityIndicatorView: UIActivityIndicatorView?
  var productRequestForPrice: SKProductsRequest?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    UIHelper.applyStyle(self)
    purchaseFullVersionButton.backgroundColor = StyleKit.controlTintColor

    descriptionLabel.text = strings.descriptionLabelText
    
    fetchPrices()
  }
  
  private func fetchPrices() {
    productRequestForPrice = requestFullVersionProduct()
  }
  
  private func displayPrice(#response: SKProductsResponse) {
    productRequestForPrice = nil
    
    let productsCount = response.products.count
    
    if productsCount == 0 {
      return
    }
    
    if let product = response.products[0] as? SKProduct where product.productIdentifier == GlobalConstants.inAppPurchaseFullVersion {
      let numberFormatter = NSNumberFormatter()
      numberFormatter.formatterBehavior = .Behavior10_4
      numberFormatter.numberStyle = .CurrencyStyle
      numberFormatter.locale = product.priceLocale
      let price = numberFormatter.stringFromNumber(product.price)!
      priceLabel.text = String.localizedStringWithFormat(strings.priceLabelText, price)
    } else {
      assert(false)
    }
  }

  
  @IBAction func purchaseFullVersion() {
    if !SKPaymentQueue.canMakePayments() {
      let alert = UIAlertView(title: nil, message: strings.forbiddenPaymentsAlertMessage, delegate: nil, cancelButtonTitle: strings.okButtonTitle)
      alert.show()
      return
    }
    
    showActivityIndicator()
    requestFullVersionProduct()
  }
  
  private func requestFullVersionProduct() -> SKProductsRequest {
    let productsRequest = SKProductsRequest(productIdentifiers: Set([GlobalConstants.inAppPurchaseFullVersion]))
    productsRequest.delegate = self
    productsRequest.start()
    return productsRequest
  }
  
  @IBAction func restorePurchases() {
    showActivityIndicator()
    SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
  }
  
  func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
    if request == productRequestForPrice {
      displayPrice(response: response)
      return
    }
    
    let productsCount = response.products.count
    
    if productsCount == 0 {
      hideActivityIndicator()
      let invalidIdentifiers = response.invalidProductIdentifiers as! [String]
      let details = ", ".join(invalidIdentifiers)
      Logger.logError("No products are available for in-app purchases", logDetails: details)
      
      // Show an alert about an unknown error to user to indicate an error somehow
      let alert = UIAlertView(title: strings.purchaseFailedAlertTitle, message: strings.transactionFailedUnknownError, delegate: nil, cancelButtonTitle: strings.okButtonTitle)
      alert.show()

      return
    }
    
    if let product = response.products[0] as? SKProduct {
      purchaseProduct(product)
    } else {
      assert(false)
      hideActivityIndicator()
    }
  }

  private func purchaseProduct(product: SKProduct) {
    let payment = SKPayment(product: product)
    SKPaymentQueue.defaultQueue().addTransactionObserver(self)
    SKPaymentQueue.defaultQueue().addPayment(payment)
  }
  
  private func activateFullVersion() {
    Settings.generalFullVersion.value = true
  }
  
  func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
    for transaction in transactions as! [SKPaymentTransaction] {
      if transaction.payment.productIdentifier != GlobalConstants.inAppPurchaseFullVersion {
        Logger.logError("Unknown in-app purchase", logDetails: "identifier: \(transaction.payment.productIdentifier)")
        continue
      }

      switch transaction.transactionState {
      case .Purchased:
        processPurchasedTransaction(transaction)

      case .Restored:
        processRestoredTransaction(transaction)

      case .Failed:
        processFailedTransaction(transaction)
        
      default: break;
      }
    }
  }
  
  private func processPurchasedTransaction(transaction: SKPaymentTransaction) {
    activateFullVersion()
    hideActivityIndicator()
    
    let alert = UIAlertView(title: nil, message: strings.fullVersionPurchasedAlertMessage, delegate: nil, cancelButtonTitle: strings.okButtonTitle)
    alert.show()
    
    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
  }
  
  private func processRestoredTransaction(transaction: SKPaymentTransaction) {
    activateFullVersion()
    hideActivityIndicator()
    
    let alert = UIAlertView(title: nil, message: strings.fullVersionRestoredAlertMessage, delegate: nil, cancelButtonTitle: strings.okButtonTitle)
    alert.show()
    
    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
  }
  
  private func processFailedTransaction(transaction: SKPaymentTransaction) {
    hideActivityIndicator()
    
    let message: String?
    
    switch transaction.error.code {
    case SKErrorPaymentCancelled:
      message = nil // do not show an alert because user cancelled the request by himself
      
    case SKErrorClientInvalid:
      message = strings.transactionFailedClientInvalid
      
    case SKErrorPaymentInvalid:
      Logger.logError("Payment transaction error", logDetails: "The payment parameters was not recognized by the Apple App Store")
      message = strings.transactionFailedPaymentInvalid
      
    case SKErrorPaymentNotAllowed:
      Logger.logError("Payment transaction error", logDetails: "The client is not allowed to authorize payments")
      message = strings.transactionFailedPaymentNotAllowed
      
    case SKErrorStoreProductNotAvailable:
      Logger.logError("Payment transaction error", logDetails: "The requested product is not available in the store")
      message = strings.transactionFailedProductIsNotAvailable
      
    default:
      Logger.logError("Payment transaction error", logDetails: "An unknown error occured")
      message = strings.transactionFailedUnknownError
    }
    
    if let message = message {
      let alert = UIAlertView(title: strings.purchaseFailedAlertTitle, message: message, delegate: nil, cancelButtonTitle: strings.okButtonTitle)
      alert.show()
    }
    
    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
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
