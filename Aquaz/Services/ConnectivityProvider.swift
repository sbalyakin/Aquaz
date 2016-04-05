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
  
  private var session: WCSession?
  
  private let queue = dispatch_queue_create("com.devmanifest.Aquaz.ConnectivityProvider", DISPATCH_QUEUE_SERIAL)

  private var needToUpdateWatchState: Bool = false
  
  private var settingObserverGeneralVolumeUnits: SettingsObserver?
  
  private var drinks = [DrinkType: Drink]()
  
  // If it's greater than 0 all savings of managed object context will be ignored.
  // It's used when ConnectivityProvider received add intage info from WatchApp.
  private var ignoreManagedObjectContextSavingsCounter = 0
  
  // MARK: Methods
  
  private override init() {
    super.init()

    setupConnectivity()
    
    setupCoreDataSynchronization()
    
    setupSettingsSynchronization()
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  private func setupConnectivity() {
    if WCSession.isSupported() {
      session = WCSession.defaultSession()
      session?.delegate = self
      session?.activateSession()
    }
  }
  
  private func composeCurrentStateInfo(sendHandler: ([String : AnyObject]) -> Void) {
    CoreDataStack.performOnPrivateContext { privateContext in
      let date = NSDate()

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

  private func setupCoreDataSynchronization() {
    CoreDataStack.performOnPrivateContext { privateContext in
      NSNotificationCenter.defaultCenter().addObserver(
        self,
        selector: #selector(self.managedObjectContextDidSave),
        name: NSManagedObjectContextDidSaveNotification,
        object: privateContext)
      
      NSNotificationCenter.defaultCenter().addObserver(
        self,
        selector: #selector(self.managedObjectContextDidSave),
        name: GlobalConstants.notificationManagedObjectContextWasMerged,
        object: privateContext)
    }
  }
  
  func managedObjectContextDidSave() {
    if !WCSession.isSupported() || !(session?.watchAppInstalled ?? false) {
      return
    }
    
    if isManagedObjectContextSavingIgnored() {
      return
    }
    
    composeCurrentStateInfo { info in
      self.session?.transferUserInfo(info)
    }
  }
  
  private func setupSettingsSynchronization() {
    settingObserverGeneralVolumeUnits = Settings.sharedInstance.generalVolumeUnits.addObserver { [weak self] _ in
      self?.settingsWasChanged()
    }
  }
  
  private func settingsWasChanged() {
    if !WCSession.isSupported() || !(session?.watchAppInstalled ?? false) {
      return
    }
    
    let message = ConnectivityMessageUpdatedSettings(settings: Settings.sharedInstance.getExportedSettingsForWatchApp())
    
    session?.transferUserInfo(message.composeMetadata())
  }

}

@available(iOS 9.0, *)
extension ConnectivityProvider: WCSessionDelegate {

  func sessionWatchStateDidChange(session: WCSession) {
    if session.paired && session.watchAppInstalled {
      composeCurrentStateInfo { info in
        self.session?.transferUserInfo(info)
      }
      
      settingsWasChanged()
    }
  }
  
  func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
    if let messageAddIntake = ConnectivityMessageAddIntake(metadata: userInfo) {
      addIntakeInfoWasReceived(messageAddIntake)
    }
  }
  
  func session(session: WCSession, didFinishUserInfoTransfer userInfoTransfer: WCSessionUserInfoTransfer, error: NSError?) {
    if let _ = error {
      // Trying to transfer the user info again
      session.transferUserInfo(userInfoTransfer.userInfo)
    }
  }
  
  private func addIntakeInfoWasReceived(message: ConnectivityMessageAddIntake) {
    CoreDataStack.performOnPrivateContext { privateContext in
      // Check for duplicates
      if let _ = Intake.fetchParticularIntake(date: message.date, drinkType: message.drinkType, amount: message.amount, managedObjectContext: privateContext) {
        Logger.logWarning("Duplicate intake from Apple Watch has been observed. The intake is ignored.")
        return
      }
      
      if self.drinks.isEmpty {
        self.drinks = Drink.fetchAllDrinksTyped(managedObjectContext: privateContext)
      }

      guard let drink = self.drinks[message.drinkType] else {
        Logger.logError(false, "The drink of intake from paired App Watch is not found in Aquaz")
        return
      }
      
      guard let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate,
            let viewController = appDelegate.window?.rootViewController else
      {
        Logger.logError(false, "The root view controller is not found")
        return
      }
      
      IntakeHelper.addIntakeWithHealthKitChecks(
        amount: message.amount,
        drink: drink,
        intakeDate: message.date,
        viewController: viewController,
        managedObjectContext: privateContext,
        actionBeforeAddingIntakeToCoreData: {
          self.increaseIgnoreManagedObjectContextSavingsCounter()
        },
        actionAfterAddingIntakeToCoreData: {
          self.decreaseIgnoreManagedObjectContextSavingsCounter()
        })
    }
  }
  
  private func isManagedObjectContextSavingIgnored() -> Bool {
    var ignore = false
    
    dispatch_sync(queue) {
      ignore = self.ignoreManagedObjectContextSavingsCounter > 0
    }
    
    return ignore
  }
  
  private func increaseIgnoreManagedObjectContextSavingsCounter() {
    dispatch_sync(queue) {
      self.ignoreManagedObjectContextSavingsCounter += 1
    }
  }
  
  private func decreaseIgnoreManagedObjectContextSavingsCounter() {
    dispatch_sync(queue) {
      self.ignoreManagedObjectContextSavingsCounter -= 1
    }
  }
  
}
