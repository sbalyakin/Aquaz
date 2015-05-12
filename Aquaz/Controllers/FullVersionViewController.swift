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

  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var purchaseFullVersionButton: RoundedButton!

  class Strings {
    
    lazy var descriptionLabelText = NSLocalizedString("FVVC:Description about full version purchase",
      value: "Purchase the full version of Aquaz in order to get:\n\t• Smart notifications\n\t• Extended statistics\n\t• No ads",
      comment: "FullVersionViewController: Description about full version purchase")

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

  }
  
  let strings = Strings()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    UIHelper.applyStyle(self)
    purchaseFullVersionButton.backgroundColor = StyleKit.controlTintColor

    descriptionLabel.text = strings.descriptionLabelText
  }
  
  @IBAction func purchaseFullVersion() {
    if !SKPaymentQueue.canMakePayments() {
      let alert = UIAlertView(title: nil, message: strings.forbiddenPaymentsAlertMessage, delegate: nil, cancelButtonTitle: strings.okButtonTitle)
      alert.show()
      return
    }
    
    let productsRequest = SKProductsRequest(productIdentifiers: Set([GlobalConstants.inAppPurchaseFullVersion]))
    productsRequest.delegate = self
    productsRequest.start()
  }
  
  @IBAction func restorePurchases() {
    SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
  }
  
  func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
    let productsCount = response.products.count
    
    if productsCount == 0 {
      let invalidIdentifiers = response.invalidProductIdentifiers as! [String]
      let details = ", ".join(invalidIdentifiers)
      Logger.logError("No products are available for in-app purchases", logDetails: details)
      return
    }
    
    if let product = response.products[0] as? SKProduct {
      purchaseProduct(product)
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
      if transaction.transactionIdentifier != GlobalConstants.inAppPurchaseFullVersion {
        Logger.logError("Unknown in-app purchase", logDetails: "identifier: \(transaction.transactionIdentifier)")
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
    
    let alert = UIAlertView(title: nil, message: strings.fullVersionPurchasedAlertMessage, delegate: nil, cancelButtonTitle: strings.okButtonTitle)
    alert.show()
    
    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
  }
  
  private func processRestoredTransaction(transaction: SKPaymentTransaction) {
    activateFullVersion()
    
    let alert = UIAlertView(title: nil, message: strings.fullVersionRestoredAlertMessage, delegate: nil, cancelButtonTitle: strings.okButtonTitle)
    alert.show()
    
    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
  }
  
  private func processFailedTransaction(transaction: SKPaymentTransaction) {
    let alert = UIAlertView(title: strings.purchaseFailedAlertTitle, message: transaction.error.localizedDescription, delegate: nil, cancelButtonTitle: strings.okButtonTitle)
    alert.show()
    
    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
  }

}
