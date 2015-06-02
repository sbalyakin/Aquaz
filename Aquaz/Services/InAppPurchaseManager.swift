//
//  InAppPurchaseManager.swift
//  Aquaz
//
//  Created by Admin on 15.05.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import StoreKit

class InAppPurchaseManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {

  class var sharedInstance: InAppPurchaseManager {
    struct Static {
      static let instance = InAppPurchaseManager()
    }
    return Static.instance
  }

  private class Strings {
    
    lazy var forbiddenPaymentsAlertMessage = NSLocalizedString("IAPM:It\'s forbidden to make payments due to parental controls",
      value: "It\'s forbidden to make payments due to parental controls",
      comment: "InAppPurchaseManager: Message shown to user if payments are forbidden according to parental controls")
    
    lazy var fullVersionRestoredAlertMessage = NSLocalizedString("IAPM:Full Version has been successfully restored",
      value: "Full Version has been successfully restored",
      comment: "InAppPurchaseManager: Message shown after successful restoring Full Version purchase")
    
    lazy var errorAlertTitle = NSLocalizedString("IAPM:Error", value: "Error",
      comment: "InAppPurchaseManager: Message title for alert shown if a purchase is failed")
    
    lazy var okButtonTitle = NSLocalizedString("IAPM:OK", value: "OK", comment: "InAppPurchaseManager: Title of OK button")
    
    lazy var transactionFailedClientInvalid = NSLocalizedString("IAPM:You is not allowed to perform the attempted action",
      value: "You is not allowed to perform the attempted action",
      comment: "InAppPurchaseManager: Message shown when payment transaction failed by reason: Client is not allowed to perform the attempted action")
    
    lazy var transactionFailedPaymentInvalid = NSLocalizedString("IAPM:Payment parameters was not recognized by the App Store",
      value: "Payment parameters was not recognized by the App Store",
      comment: "InAppPurchaseManager: Message shown when payment transaction failed by reason: Payment parameters was not recognized by the App Store")
    
    lazy var transactionFailedPaymentNotAllowed = NSLocalizedString("IAPM:You is not allowed to authorize payments",
      value: "You is not allowed to authorize payments",
      comment: "InAppPurchaseManager: Message shown when payment transaction failed by reason: User is not allowed to authorize payments")
    
    lazy var transactionFailedProductIsNotAvailable = NSLocalizedString("IAPM:The requested product is not available in the store",
      value: "The requested product is not available in the store",
      comment: "InAppPurchaseManager: Message shown when payment transaction failed by reason: The requested product is not available in the store")
    
    lazy var transactionFailedUnknownError = NSLocalizedString("IAPM:An unknown error occured",
      value: "An unknown error occured",
      comment: "InAppPurchaseManager: Message shown when payment transaction failed by reason: An unknown error occured")
    
  }
  
  private let strings = Strings()
  
  typealias PriceCompletionFunction = (price: String) -> ()
  
  private var purchaseRequest: SKProductsRequest?
  
  private var priceRequests: [SKProductsRequest: PriceCompletionFunction] = [:]
  
  var isPurchasing: Bool {
    if purchaseRequest != nil {
      return true
    }
    
    for transaction in SKPaymentQueue.defaultQueue().transactions as! [SKPaymentTransaction] {
      if transaction.payment.productIdentifier == GlobalConstants.inAppPurchaseFullVersion {
        return true
      }
    }
    
    return false
  }

  // Returns true if a purchasing transaction is deferred and a user are waiting for an approval from parents
  var isWaitingForApproval: Bool {
    for transaction in SKPaymentQueue.defaultQueue().transactions as! [SKPaymentTransaction] {
      if transaction.payment.productIdentifier == GlobalConstants.inAppPurchaseFullVersion &&
        transaction.transactionState == .Deferred {
          return true
      }
    }
    
    return false
  }

  var paymentAreAllowed: Bool {
    return SKPaymentQueue.canMakePayments()
  }
  
  private override init() {
    super.init()
    SKPaymentQueue.defaultQueue().addTransactionObserver(self)
  }
  
  deinit {
    SKPaymentQueue.defaultQueue().removeTransactionObserver(self)
    
    for (request, _) in priceRequests {
      request.cancel()
    }
  }
  
  func purchaseFullVersion() -> Bool {
    if Settings.generalFullVersion.value || isPurchasing {
      return false
    }
    
    Logger.logDebug("purchaseFullVersion()")

    if !SKPaymentQueue.canMakePayments() {
      let alert = UIAlertView(title: nil, message: strings.forbiddenPaymentsAlertMessage, delegate: nil, cancelButtonTitle: strings.okButtonTitle)
      alert.show()
      return false
    }
    
    purchaseRequest = SKProductsRequest(productIdentifiers: Set([GlobalConstants.inAppPurchaseFullVersion]))
    purchaseRequest!.delegate = self
    purchaseRequest!.start()
    return true
  }
  
  func fetchFullVersionPrice(#completion: PriceCompletionFunction) {
    Logger.logDebug("fetchFullVersionPrice()")

    let request = SKProductsRequest(productIdentifiers: Set([GlobalConstants.inAppPurchaseFullVersion]))
    priceRequests[request] = completion
    
    request.delegate = self
    request.start()
  }
  
  func restorePurchases() {
    Logger.logDebug("restorePurchases()")
    SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
  }

  private func formatPrice(#response: SKProductsResponse) -> String {
    if let product = response.products.first as? SKProduct where product.productIdentifier == GlobalConstants.inAppPurchaseFullVersion {
      let numberFormatter = NSNumberFormatter()
      numberFormatter.formatterBehavior = .Behavior10_4
      numberFormatter.numberStyle = .CurrencyStyle
      numberFormatter.locale = product.priceLocale
      let price = numberFormatter.stringFromNumber(product.price)!
      return price
    }

    return ""
  }
  
  func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
    Logger.logDebug("productsRequest()")

    if response.products.count == 0 {
      let invalidIdentifiers = response.invalidProductIdentifiers as! [String]
      let details = ", ".join(invalidIdentifiers)
      Logger.logError("No products are available for in-app purchases", logDetails: details)
      
      // Show an alert about an unknown error to user to indicate an error somehow
      let alert = UIAlertView(title: strings.errorAlertTitle, message: strings.transactionFailedUnknownError, delegate: nil, cancelButtonTitle: strings.okButtonTitle)
      alert.show()
    }

    // Price request
    if let completion = priceRequests[request] {
      let price = formatPrice(response: response)
      completion(price: price)
      return
    }

    // Purchase request
    if request != purchaseRequest {
      Logger.logError("Unknown product request. Purchase request is expected")
      return
    }
    
    if let product = response.products.first as? SKProduct {
      makePaymentForProduct(product)
    } else {
      assert(false)
    }
  }
  
  private func makePaymentForProduct(product: SKProduct) {
    Logger.logDebug("purchaseFullVersionProduct()")
    let payment = SKPayment(product: product)
    SKPaymentQueue.defaultQueue().addPayment(payment)
  }
  
  func requestDidFinish(request: SKRequest!) {
    if request == purchaseRequest {
      Logger.logDebug("requestDidFinish() for a purchase request")
      purchaseRequest = nil
    } else {
      Logger.logDebug("requestDidFinish() for a price request")
      priceRequests.removeValueForKey(request as! SKProductsRequest!)
    }
  }
  
  func request(request: SKRequest!, didFailWithError error: NSError!) {
    if request == purchaseRequest {
      Logger.logDebug("requestDidFinish(:didFailWithError) for a purchase request")
      purchaseRequest = nil

      let message = error.localizedDescription
      let alert = UIAlertView(title: strings.errorAlertTitle, message: message, delegate: nil, cancelButtonTitle: strings.okButtonTitle)
      alert.show()
    } else {
      Logger.logDebug("requestDidFinish(:didFailWithError) for a price request")
      if let completion = priceRequests.removeValueForKey(request as! SKProductsRequest!) {
        completion(price: "")
      }
    }
  }
  
  func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
    Logger.logDebug("paymentQueue()")
    
    for transaction in transactions as! [SKPaymentTransaction] {
      if transaction.payment.productIdentifier != GlobalConstants.inAppPurchaseFullVersion {
        Logger.logWarning("Unknown in-app purchase", logDetails: "identifier: \(transaction.payment.productIdentifier)")
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
        continue
      }
      
      switch transaction.transactionState {
      case .Purchasing:
        // Do nothing
        break
        
      case .Purchased:
        processPurchasedTransaction(transaction)
        
      case .Restored:
        processRestoredTransaction(transaction)
        
      case .Deferred:
        processDeferredTransaction(transaction)
        
      case .Failed:
        processFailedTransaction(transaction)
      }
      
      NSNotificationCenter.defaultCenter().postNotificationName(GlobalConstants.notificationFullVersionPurchaseStateDidChange, object: nil)
    }
  }
  
  func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue!) {
    Logger.logDebug("paymentQueueRestoreCompletedTransactionsFinished()")
  }

  func paymentQueue(queue: SKPaymentQueue!, restoreCompletedTransactionsFailedWithError error: NSError!) {
    Logger.logDebug("paymentQueue(queue:restoreCompletedTransactionsFailedWithError:), error: \(error.localizedDescription)")
    processError(error)
  }
  
  private func processPurchasedTransaction(transaction: SKPaymentTransaction) {
    Logger.logDebug("processPurchasedTransaction()")
    
    activateFullVersion()
    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
  }
  
  private func processRestoredTransaction(transaction: SKPaymentTransaction) {
    Logger.logDebug("processRestoredTransaction()")
    
    let alert = UIAlertView(title: nil, message: strings.fullVersionRestoredAlertMessage, delegate: self, cancelButtonTitle: strings.okButtonTitle)
    alert.show()
    
    activateFullVersion()
    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
  }
  
  private func activateFullVersion() {
    Settings.generalFullVersion.value = true
    NSNotificationCenter.defaultCenter().postNotificationName(GlobalConstants.notificationFullVersionIsPurchased, object: nil)
  }
  
  private func processDeferredTransaction(transaction: SKPaymentTransaction) {
    Logger.logDebug("processDeferredTransaction()")
  }
  
  private func processFailedTransaction(transaction: SKPaymentTransaction) {
    Logger.logDebug("processFailedTransaction()")
    
    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    
    processError(transaction.error)
  }

  private func processError(error: NSError) {
    let message: String?
    
    switch error.code {
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
      //Logger.logError("Payment transaction error", logDetails: "An unknown error occured")
      message = error.localizedDescription
    }
    
    if let message = message {
      let alert = UIAlertView(title: strings.errorAlertTitle, message: message, delegate: nil, cancelButtonTitle: strings.okButtonTitle)
      alert.show()
    }
  }
  
}
