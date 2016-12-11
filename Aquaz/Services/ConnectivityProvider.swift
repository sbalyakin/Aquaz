//
//  ConnectivityProvider.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 31.10.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import Foundation
import WatchConnectivity
import CoreData

@available(iOS 9.3, *)
final class ConnectivityProvider: NSObject {
  
  // MARK: Properties
  
  static let sharedInstance = ConnectivityProvider()
  
  fileprivate let session: WCSession? = WCSession.isSupported() ? WCSession.default() : nil
  
  fileprivate var validSession: WCSession? {
    if let session = session, session.isPaired && session.isWatchAppInstalled {
      return session
    }
    return nil
  }
  
  fileprivate var validReachableSession: WCSession? {
    if let session = validSession, session.isReachable {
      return session
    }
    return nil
  }
  
  fileprivate let queue = DispatchQueue(label: "\(GlobalConstants.bundleId).ConnectivityProvider", attributes: [])

  fileprivate var needToUpdateWatchState: Bool = false
  
  fileprivate var settingObserverGeneralVolumeUnits: SettingsObserver?
  
  fileprivate var drinks = [DrinkType: Drink]()
  
  // If it's greater than 0 all savings of managed object context will be ignored.
  // It's used when ConnectivityProvider received add intage info from WatchApp.
  fileprivate var ignoreManagedObjectContextSavingsCounter = 0
  
  // MARK: Methods
  
  fileprivate override init() {
    super.init()
    
    setupCoreDataSynchronization()
    
    setupSettingsSynchronization()
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  public func startSession() {
    session?.delegate = self
    session?.activate()
  }
  
  fileprivate func composeCurrentStateMessage() -> ConnectivityMessageCurrentState {
    var message: ConnectivityMessageCurrentState!
    
    CoreDataStack.performOnPrivateContextAndWait { privateContext in
      let date = Date()

      let waterGoalAmount: Double
      let highPhysicalActivityModeEnabled: Bool
      let hotWeatherModeEnabled: Bool

      if let waterGoal = WaterGoal.fetchWaterGoalForDate(date, managedObjectContext: privateContext) {
        waterGoalAmount = waterGoal.amount
        highPhysicalActivityModeEnabled = waterGoal.isHighActivity
        hotWeatherModeEnabled = waterGoal.isHotDay
      } else {
        waterGoalAmount = Settings.sharedInstance.userDailyWaterIntake.value
        highPhysicalActivityModeEnabled = false
        hotWeatherModeEnabled = false
      }

      let totalHydrationAmount = Intake.fetchTotalHydrationAmountForDay(date, dayOffsetInHours: 0, managedObjectContext: privateContext)
      let totalDehydrationAmount = Intake.fetchTotalDehydrationAmountForDay(date, dayOffsetInHours: 0, managedObjectContext: privateContext)

      message = ConnectivityMessageCurrentState(
        messageDate: date,
        hydrationAmount: totalHydrationAmount,
        dehydrationAmount: totalDehydrationAmount,
        dailyWaterGoal: waterGoalAmount,
        highPhysicalActivityModeEnabled: highPhysicalActivityModeEnabled,
        hotWeatherModeEnabled: hotWeatherModeEnabled,
        volumeUnits: Settings.sharedInstance.generalVolumeUnits.value)
    }

    return message
  }

  fileprivate func setupCoreDataSynchronization() {
    CoreDataStack.performOnPrivateContext { privateContext in
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(self.managedObjectContextDidSave),
        name: NSNotification.Name.NSManagedObjectContextDidSave,
        object: privateContext)
      
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(self.managedObjectContextDidSave),
        name: NSNotification.Name(rawValue: GlobalConstants.notificationManagedObjectContextWasMerged),
        object: privateContext)
    }
  }
  
  func managedObjectContextDidSave() {
    if isManagedObjectContextSavingIgnored() {
      return
    }
    
    sendCurrentState()
  }
  
  fileprivate func sendCurrentState() {
    guard session != nil && session!.isWatchAppInstalled && session!.activationState == .activated else {
      return
    }
    
    DispatchQueue.main.async {
      let message = self.composeCurrentStateMessage()

      do {
        try self.session?.updateApplicationContext(message.composeMetadata())
      } catch {
        print("Error occured on updating application context. Error: \(error)")
      }
    }
  }
  
  fileprivate func setupSettingsSynchronization() {
    settingObserverGeneralVolumeUnits = Settings.sharedInstance.generalVolumeUnits.addObserver { [weak self] _ in
      self?.sendCurrentState()
    }
  }

}


@available(iOS 9.3, *)
extension ConnectivityProvider: WCSessionDelegate {
  
  // Called when the session can no longer be used to modify or add any new transfers and, all interactive messages will be cancelled,
  // but delegate callbacks for background transfers can still occur. This will happen when the selected watch is being changed.
  func sessionDidBecomeInactive(_ session: WCSession) {
    // The session calls this method when it detects that the user has
    // switched to a different Apple Watch. While in the inactive state,
    // the session delivers any pending data to your delegate object and
    // prevents you from initiating any new data transfers. After the last
    // transfer finishes, the session moves to the deactivated state.
    //
    // Use this method to update any private data structures that might be
    // affected by the impending change to the active Apple Watch. For example,
    // you might clean up data structures and close files related to
    // outgoing content.
    
    // In Aquaz there is nothing to do here.
  }

  // Called when all delegate callbacks for the previously selected watch has occurred. 
  // The session can be re-activated for the now selected watch using activateSession.
  func sessionDidDeactivate(_ session: WCSession) {
    // The session calls this method when there is no more pending data
    // to deliver to your app and the previous session can be formally closed.
    //  
    // iOS apps that process content delivered from their Watch Extension
    // should finish processing that content, then call activateSession()
    // to initiate a session with the new Apple Watch.
    
    // Begin the activation process for the new Apple Watch
    session.activate()
  }

  // Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details.
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    if activationState == .activated {
      sendCurrentState()
    }
  }

  func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    if let message = ConnectivityMessageAddIntake(metadata: message) {
      processAddIntakeMessage(message)
    } else if let message = ConnectivityMessagePendingIntakes(metadata: message) {
      processPendingIntakesMessage(message)
    }
  }
  
  func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
    if let message = ConnectivityMessageAddIntake(metadata: message) {
      processAddIntakeMessage(message)
      let currentStateMessage = composeCurrentStateMessage()
      replyHandler(currentStateMessage.composeMetadata())
    } else if let message = ConnectivityMessagePendingIntakes(metadata: message) {
      processPendingIntakesMessage(message)
      let currentStateMessage = composeCurrentStateMessage()
      replyHandler(currentStateMessage.composeMetadata())
    }
    
    replyHandler([:])
  }
  
  fileprivate func processAddIntakeMessage(_ message: ConnectivityMessageAddIntake) {
    CoreDataStack.performOnPrivateContext { privateContext in
      self.addIntake(drinkType: message.drinkType,
                     amount: message.amount,
                     date: message.date,
                     saveImmediately: true,
                     managedObjectContext: privateContext)
    }
  }
  
  fileprivate func processPendingIntakesMessage(_ message: ConnectivityMessagePendingIntakes) {
    CoreDataStack.performOnPrivateContext { privateContext in
      for intake in message.pendingIntakes {
        self.addIntake(drinkType: intake.drinkType,
                       amount: intake.amount,
                       date: intake.date,
                       saveImmediately: false,
                       managedObjectContext: privateContext)
        
        CoreDataStack.saveContext(privateContext)
      }
    }
  }
  
  fileprivate func addIntake(drinkType: DrinkType,
                             amount: Double,
                             date: Date,
                             saveImmediately: Bool,
                             managedObjectContext: NSManagedObjectContext)
  {
    // Check for duplicates
    if let _ = Intake.fetchParticularIntake(date: date, drinkType: drinkType, amount: amount, managedObjectContext: managedObjectContext) {
      Logger.logWarning("Duplicate intake from Apple Watch has been observed. The intake is ignored.")
      return
    }
    
    if drinks.isEmpty {
      drinks = Drink.fetchAllDrinksTyped(managedObjectContext: managedObjectContext)
    }
    
    guard let drink = drinks[drinkType] else {
      Logger.logError(false, "The drink of intake from paired App Watch is not found in Aquaz")
      return
    }
    
    increaseIgnoreManagedObjectContextSavingsCounter()
    
    _ = Intake.addEntity(drink: drink, amount: amount, date: date, managedObjectContext: managedObjectContext, saveImmediately: saveImmediately)
    
    decreaseIgnoreManagedObjectContextSavingsCounter()
  }
  
  fileprivate func isManagedObjectContextSavingIgnored() -> Bool {
    var ignore = false
    
    queue.sync {
      ignore = self.ignoreManagedObjectContextSavingsCounter > 0
    }
    
    return ignore
  }
  
  fileprivate func increaseIgnoreManagedObjectContextSavingsCounter() {
    queue.sync {
      self.ignoreManagedObjectContextSavingsCounter += 1
    }
  }
  
  fileprivate func decreaseIgnoreManagedObjectContextSavingsCounter() {
    queue.sync {
      self.ignoreManagedObjectContextSavingsCounter -= 1
    }
  }
  
}
