//
//  ConnectivityProvider.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 09.11.16.
//  Copyright © 2016 Sergey Balyakin. All rights reserved.
//

import Foundation
import WatchKit
import WatchConnectivity

class ConnectivityProvider: NSObject {

  // MARK: Public properties

  static let sharedInstance = ConnectivityProvider()
  
  // MARK: Public methods

  func addIntake(drinkType: DrinkType, amount: Double, date: Date) {
    if let session = reachableSession {
      // If the session is available (active and reachable) try to send message to iOS app immediately
      let addIntakeMessage = ConnectivityMessageAddIntake(drinkType: drinkType, amount: amount, date: date)
      
      session.sendMessage(
        addIntakeMessage.composeMetadata(),
        replyHandler: { metadata in
          self.processCurrentStateMessage(metadata: metadata)
        },
        errorHandler: { _ in
          // If an error happens during sending the message, add intake to pending intakes
          WatchSettings.sharedInstance.pendingIntakes.addIntake(drinkType: drinkType, amount: amount, date: date)
        }
      )
    } else {
      // If the session is not available, add intake to pending intakes
      WatchSettings.sharedInstance.pendingIntakes.addIntake(drinkType: drinkType, amount: amount, date: date)
    }
  }
  
  // MARK: Private properties
  
  fileprivate let session: WCSession? = WCSession.isSupported() ? WCSession.default : nil

  fileprivate var reachableSession: WCSession? {
    if let session = session, session.activationState == .activated && session.isReachable {
      return session
    }
    return nil
  }
  
  // MARK: Private methods
  
  private override init() {
    super.init()
  }
  
  public func startSession() {
    session?.delegate = self
    session?.activate()
  }
  
  fileprivate func processCurrentStateMessage(metadata: [String: Any]) {
    guard let message = ConnectivityMessageCurrentState(metadata: metadata) else {
      return
    }
    
    NotificationCenter.default.post(name: Notification.Name(rawValue: GlobalConstants.notificationWatchCurrentState), object: message)
  }
  
}


// MARK: WCSessionDelegate

extension ConnectivityProvider: WCSessionDelegate {
  
  // Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details.
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    // Do nothing here
  }
  
  // Called when the reachable state of the counterpart app changes. The receiver should check the reachable property on receiving this delegate callback.
  func sessionReachabilityDidChange(_ session: WCSession) {
    sendPendingIntakes()
  }

  private func sendPendingIntakes() {
    guard let session = reachableSession, WatchSettings.sharedInstance.pendingIntakes.isEmpty else {
      return
    }
    
    let message = WatchSettings.sharedInstance.pendingIntakes.getMessage()
    
    if let metadata = message.composeMetadata() {
      WatchSettings.sharedInstance.pendingIntakes.clear()
      
      session.sendMessage(
        metadata,
        replyHandler: { metadata in
          self.processCurrentStateMessage(metadata: metadata)
        },
        errorHandler: { _ in
          // If an error occurs on sending message with pending intakes, put the pending intakes back to the settings
         WatchSettings.sharedInstance.pendingIntakes.setMessage(message)
        }
      )
    }
  }
  
  // Called on the delegate of the receiver. Will be called on startup if an applicationContext is available.
  func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
    processCurrentStateMessage(metadata: applicationContext)
  }

}
