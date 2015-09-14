//
//  InAppPurchaseManager.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 15.05.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import StoreKit

class InAppPurchaseManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {

  static let sharedInstance = InAppPurchaseManager()

  private struct LocalizedStrings {
    
    lazy var forbiddenPaymentsAlertMessage: String = NSLocalizedString("IAPM:It\'s forbidden to make payments due to parental controls",
      value: "It\'s forbidden to make payments due to parental controls",
      comment: "InAppPurchaseManager: Message shown to user if payments are forbidden according to parental controls")
    
    lazy var fullVersionRestoredAlertMessage: String = NSLocalizedString("IAPM:Full Version has been successfully restored",
      value: "Full Version has been successfully restored",
      comment: "InAppPurchaseManager: Message shown after successful restoring Full Version purchase")
    
    lazy var errorAlertTitle: String = NSLocalizedString("IAPM:Error", value: "Error",
      comment: "InAppPurchaseManager: Message title for alert shown if a purchase is failed")
    
    lazy var okButtonTitle: String = NSLocalizedString("IAPM:OK", value: "OK", comment: "InAppPurchaseManager: Title of OK button")
    
    lazy var transactionFailedClientInvalid: String = NSLocalizedString("IAPM:You is not allowed to perform the attempted action",
      value: "You is not allowed to perform the attempted action",
      comment: "InAppPurchaseManager: Message shown when payment transaction failed by reason: Client is not allowed to perform the attempted action")
    
    lazy var transactionFailedUnknownError: String = NSLocalizedString("IAPM:An unknown error occured",
      value: "An unknown error occured",
      comment: "InAppPurchaseManager: Message shown when payment transaction failed by reason: An unknown error occured")
    
  }
  
  private var localizedStrings = LocalizedStrings()
  
  typealias PriceCompletionFunction = (price: String) -> ()
  
  private var purchaseRequest: SKProductsRequest?
  
  private var priceRequests: [SKProductsRequest: PriceCompletionFunction] = [:]
  
  var isPurchasing: Bool {
    if purchaseRequest != nil {
      return true
    }
    
    for transaction in SKPaymentQueue.defaultQueue().transactions {
      if transaction.payment.productIdentifier == GlobalConstants.inAppPurchaseFullVersion {
        return true
      }
    }
    
    return false
  }

  // Returns true if a purchasing transaction is deferred and a user are waiting for an approval from parents
  var isWaitingForApproval: Bool {
    if #available(iOS 8.0, *) {
      for transaction in SKPaymentQueue.defaultQueue().transactions {
        if transaction.payment.productIdentifier == GlobalConstants.inAppPurchaseFullVersion &&
          transaction.transactionState == .Deferred {
            return true
        }
      }
      return false
      
    } else {
      // Fallback on earlier versions
      return false
    }
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
    if Settings.sharedInstance.generalFullVersion.value || isPurchasing {
      return false
    }
    
    Logger.logDebug("purchaseFullVersion()")

    if !SKPaymentQueue.canMakePayments() {
      let alert = UIAlertView(title: nil, message: localizedStrings.forbiddenPaymentsAlertMessage, delegate: nil, cancelButtonTitle: localizedStrings.okButtonTitle)
      alert.show()
      return false
    }
    
    purchaseRequest = SKProductsRequest(productIdentifiers: Set([GlobalConstants.inAppPurchaseFullVersion]))
    purchaseRequest!.delegate = self
    purchaseRequest!.start()
    return true
  }
  
  func fetchFullVersionPrice(completion completion: PriceCompletionFunction) {
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

  private func formatPrice(response response: SKProductsResponse) -> String {
    if let product = response.products.first where product.productIdentifier == GlobalConstants.inAppPurchaseFullVersion {
      let numberFormatter = NSNumberFormatter()
      numberFormatter.formatterBehavior = .Behavior10_4
      numberFormatter.numberStyle = .CurrencyStyle
      numberFormatter.locale = product.priceLocale
      let price = numberFormatter.stringFromNumber(product.price)!
      return price
    }

    return ""
  }
  
  func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
    Logger.logDebug("productsRequest()")

    if response.products.count == 0 {
      let invalidIdentifiers = response.invalidProductIdentifiers 
      let details = invalidIdentifiers.joinWithSeparator(", ")
      Logger.logError("No products are available for in-app purchases", logDetails: details)
      
      // Show an alert about an unknown error to user to indicate an error somehow
      let alert = UIAlertView(title: localizedStrings.errorAlertTitle, message: localizedStrings.transactionFailedUnknownError, delegate: nil, cancelButtonTitle: localizedStrings.okButtonTitle)
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
    
    if let product = response.products.first {
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
  
  func requestDidFinish(request: SKRequest) {
    if request == purchaseRequest {
      Logger.logDebug("requestDidFinish() for a purchase request")
      purchaseRequest = nil
    } else {
      Logger.logDebug("requestDidFinish() for a price request")
      priceRequests.removeValueForKey(request as! SKProductsRequest)
    }
  }
  
  func request(request: SKRequest, didFailWithError error: NSError) {
    if request == purchaseRequest {
      Logger.logDebug("requestDidFinish(:didFailWithError) for a purchase request", logDetails: error.localizedDescription)
      purchaseRequest = nil

      let message = error.localizedDescription
      let alert = UIAlertView(title: localizedStrings.errorAlertTitle, message: message, delegate: nil, cancelButtonTitle: localizedStrings.okButtonTitle)
      alert.show()
    } else {
      Logger.logDebug("requestDidFinish(:didFailWithError) for a price request", logDetails: error.localizedDescription)
      if let completion = priceRequests.removeValueForKey(request as! SKProductsRequest) {
        completion(price: "")
      }
    }
  }
  
  func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    Logger.logDebug("paymentQueue()")
    
    for transaction in transactions {
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
      
      dispatch_async(dispatch_get_main_queue()) {
        NSNotificationCenter.defaultCenter().postNotificationName(GlobalConstants.notificationFullVersionPurchaseStateDidChange, object: nil)
      }
    }
  }
  
  func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
    Logger.logDebug("paymentQueueRestoreCompletedTransactionsFinished()")
  }

  func paymentQueue(queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: NSError) {
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
    
    let alert = UIAlertView(title: nil, message: localizedStrings.fullVersionRestoredAlertMessage, delegate: self, cancelButtonTitle: localizedStrings.okButtonTitle)
    alert.show()
    
    activateFullVersion()
    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
  }
  
  private func activateFullVersion() {
    Settings.sharedInstance.generalFullVersion.value = true
    
    dispatch_async(dispatch_get_main_queue()) {
      NSNotificationCenter.defaultCenter().postNotificationName(GlobalConstants.notificationFullVersionIsPurchased, object: nil)
    }
  }
  
  private func processDeferredTransaction(transaction: SKPaymentTransaction) {
    Logger.logDebug("processDeferredTransaction()")
  }
  
  private func processFailedTransaction(transaction: SKPaymentTransaction) {
    Logger.logDebug("processFailedTransaction()")
    
    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    
    processError(transaction.error)
  }

  private func processError(error: NSError!) {
    let message: String?
    
    if error != nil {
      switch error.code {
      case SKErrorPaymentCancelled:
        message = nil // do not show an alert because user cancelled the request by himself
        
      case SKErrorClientInvalid:
        message = localizedStrings.transactionFailedClientInvalid
        
      case SKErrorPaymentInvalid:
        Logger.logError("Payment transaction error", logDetails: "The payment parameters was not recognized by the Apple App Store")
        message = localizedStrings.transactionFailedUnknownError
        
      case SKErrorPaymentNotAllowed:
        Logger.logError("Payment transaction error", logDetails: "The client is not allowed to authorize payments")
        message = localizedStrings.transactionFailedUnknownError
        
      case SKErrorStoreProductNotAvailable:
        Logger.logError("Payment transaction error", logDetails: "The requested product is not available in the store")
        message = localizedStrings.transactionFailedUnknownError
        
      default:
        Logger.logError("Payment transaction error", logDetails: "An unknown error occured - \(error.localizedDescription)")
        message = error.localizedDescription
      }
    } else {
      Logger.logError("Payment transaction error", logDetails: "An unknown error occured")
      message = localizedStrings.transactionFailedUnknownError
    }
    
    if let message = message {
      let alert = UIAlertView(title: localizedStrings.errorAlertTitle, message: message, delegate: nil, cancelButtonTitle: localizedStrings.okButtonTitle)
      alert.show()
    }
  }
  
}
