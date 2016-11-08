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

@available(iOS 9.0, *)
final class ConnectivityProvider: NSObject {
  
  // MARK: Properties
  
  static let sharedInstance = ConnectivityProvider()
  
  fileprivate var session: WCSession?
  
  fileprivate let queue = DispatchQueue(label: "com.devmanifest.Aquaz.ConnectivityProvider", attributes: [])

  fileprivate var needToUpdateWatchState: Bool = false
  
  fileprivate var settingObserverGeneralVolumeUnits: SettingsObserver?
  
  fileprivate var drinks = [DrinkType: Drink]()
  
  // If it's greater than 0 all savings of managed object context will be ignored.
  // It's used when ConnectivityProvider received add intage info from WatchApp.
  fileprivate var ignoreManagedObjectContextSavingsCounter = 0
  
  // MARK: Methods
  
  fileprivate override init() {
    super.init()

    setupConnectivity()
    
    setupCoreDataSynchronization()
    
    setupSettingsSynchronization()
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  fileprivate func setupConnectivity() {
    if WCSession.isSupported() {
      session = WCSession.default()
      session?.delegate = self
      session?.activate()
    }
  }
  
  fileprivate func composeCurrentStateInfo(_ sendHandler: @escaping ([String : Any]) -> Void) {
    CoreDataStack.performOnPrivateContext { privateContext in
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

      let message = ConnectivityMessageCurrentState(
        messageDate: date,
        hydrationAmount: totalHydrationAmount,
        dehydrationAmount: totalDehydrationAmount,
        dailyWaterGoal: waterGoalAmount,
        highPhysicalActivityModeEnabled: highPhysicalActivityModeEnabled,
        hotWeatherModeEnabled: hotWeatherModeEnabled)

      let metadata = message.composeMetadata()
      
      sendHandler(metadata)
    }
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
    if !WCSession.isSupported() || !(session?.isWatchAppInstalled ?? false) {
      return
    }
    
//    if isManagedObjectContextSavingIgnored() {
//      return
//    }
    
    composeCurrentStateInfo { info in
      self.session?.transferUserInfo(info)
    }
  }
  
  fileprivate func setupSettingsSynchronization() {
    settingObserverGeneralVolumeUnits = Settings.sharedInstance.generalVolumeUnits.addObserver { [weak self] _ in
      self?.settingsWasChanged()
    }
  }
  
  fileprivate func settingsWasChanged() {
    if !WCSession.isSupported() || !(session?.isWatchAppInstalled ?? false) {
      return
    }
    
    let message = ConnectivityMessageUpdatedSettings(settings: Settings.sharedInstance.getExportedSettingsForWatchApp())
    
    session?.transferUserInfo(message.composeMetadata())
  }

}

@available(iOS 9.0, *)
extension ConnectivityProvider: WCSessionDelegate {
  /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
  @available(iOS 9.3, *)
  public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
  }
  
  
  /** ------------------------- iOS App State For Watch ------------------------ */
  
  /** Called when the session can no longer be used to modify or add any new transfers and, all interactive messages will be cancelled, but delegate callbacks for background transfers can still occur. This will happen when the selected watch is being changed. */
  @available(iOS 9.3, *)
  public func sessionDidBecomeInactive(_ session: WCSession) {
    
  }

  
  
  /** Called when all delegate callbacks for the previously selected watch has occurred. The session can be re-activated for the now selected watch using activateSession. */
  @available(iOS 9.3, *)
  public func sessionDidDeactivate(_ session: WCSession) {
  }
}

//@available(iOS 9.0, *)
//extension ConnectivityProvider: WCSessionDelegate {
//  
//  // Called when all delegate callbacks for the previously selected watch has occurred. The session can be re-activated for the now selected watch using activateSession.
//  @available(iOS 9.3, *)
//  public func sessionDidDeactivate(_ session: WCSession) {
//    // TODO: Need implementation here
//  }
//
//  // Called when the session can no longer be used to modify or add any new transfers and, all interactive messages will be cancelled, 
//  // but delegate callbacks for background transfers can still occur. This will happen when the selected watch is being changed.
//  @available(iOS 9.3, *)
//  public func sessionDidBecomeInactive(_ session: WCSession) {
//    // TODO: Need implementation here
//  }
//
//  // Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details.
//  @available(iOS 9.3, *)
//  public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
//    // TODO: Need implementation here
//  }
//
//  public func sessionWatchStateDidChange(_ session: WCSession) {
//    if session.isPaired && session.isWatchAppInstalled {
//      composeCurrentStateInfo { info in
//        self.session?.transferUserInfo(info)
//      }
//      
//      settingsWasChanged()
//    }
//  }
//  
//  public func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
//    if let messageAddIntake = ConnectivityMessageAddIntake(metadata: userInfo as [String : AnyObject]) {
//      addIntakeInfoWasReceived(messageAddIntake)
//    }
//  }
//  
//  public func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
//    if let _ = error {
//      // Trying to transfer the user info again
//      session.transferUserInfo(userInfoTransfer.userInfo)
//    }
//  }
//  
//  fileprivate func addIntakeInfoWasReceived(_ message: ConnectivityMessageAddIntake) {
//    CoreDataStack.performOnPrivateContext { privateContext in
//      // Check for duplicates
//      if let _ = Intake.fetchParticularIntake(date: message.date, drinkType: message.drinkType, amount: message.amount, managedObjectContext: privateContext) {
//        Logger.logWarning("Duplicate intake from Apple Watch has been observed. The intake is ignored.")
//        return
//      }
//      
//      if self.drinks.isEmpty {
//        self.drinks = Drink.fetchAllDrinksTyped(managedObjectContext: privateContext)
//      }
//
//      guard let drink = self.drinks[message.drinkType] else {
//        Logger.logError(false, "The drink of intake from paired App Watch is not found in Aquaz")
//        return
//      }
//      
//      guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
//            let viewController = appDelegate.window?.rootViewController else
//      {
//        Logger.logError(false, "The root view controller is not found")
//        return
//      }
//      
//      IntakeHelper.addIntakeWithHealthKitChecks(
//        amount: message.amount,
//        drink: drink,
//        intakeDate: message.date,
//        viewController: viewController,
//        managedObjectContext: privateContext,
//        actionBeforeAddingIntakeToCoreData: {
//          self.increaseIgnoreManagedObjectContextSavingsCounter()
//        },
//        actionAfterAddingIntakeToCoreData: {
//          self.decreaseIgnoreManagedObjectContextSavingsCounter()
//        })
//    }
//  }
//  
//  fileprivate func isManagedObjectContextSavingIgnored() -> Bool {
//    var ignore = false
//    
//    queue.sync {
//      ignore = self.ignoreManagedObjectContextSavingsCounter > 0
//    }
//    
//    return ignore
//  }
//  
//  fileprivate func increaseIgnoreManagedObjectContextSavingsCounter() {
//    queue.sync {
//      self.ignoreManagedObjectContextSavingsCounter += 1
//    }
//  }
//  
//  fileprivate func decreaseIgnoreManagedObjectContextSavingsCounter() {
//    queue.sync {
//      self.ignoreManagedObjectContextSavingsCounter -= 1
//    }
//  }
//  
//}
