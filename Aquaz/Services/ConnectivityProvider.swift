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
  
  private var session: WCSession!
  
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
      session.delegate = self
      session.activateSession()
    }
  }
  
  private func composeCurrentStateInfo(sendHandler: ([String : AnyObject]) -> Void) {
    CoreDataStack.inPrivateContext { privateContext in
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
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "managedObjectContextDidSave",
      name: NSManagedObjectContextDidSaveNotification,
      object: nil)
  }
  
  func managedObjectContextDidSave() {
    if ignoreManagedObjectContextSavingsCounter > 0 {
      return
    }
    
    if !WCSession.isSupported() || !session.watchAppInstalled {
      return
    }
    
    composeCurrentStateInfo { info in
      self.session.transferUserInfo(info)
    }
  }
  
  private func setupSettingsSynchronization() {
    settingObserverGeneralVolumeUnits = Settings.sharedInstance.generalVolumeUnits.addObserver { [weak self] _ in
      self?.settingsWasChanged()
    }
  }
  
  private func settingsWasChanged() {
    if !WCSession.isSupported() || !session.watchAppInstalled {
      return
    }
    
    let message = ConnectivityMessageUpdatedSettings(settings: Settings.sharedInstance.getExportedSettingsForWatchApp())
    
    session.transferUserInfo(message.composeMetadata())
  }
  
}

@available(iOS 9.0, *)
extension ConnectivityProvider: WCSessionDelegate {

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
    CoreDataStack.inPrivateContext { privateContext in
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
          self.ignoreManagedObjectContextSavingsCounter++
        },
        actionAfterAddingIntakeToCoreData: {
          self.ignoreManagedObjectContextSavingsCounter--
        })
    }
  }
  
}
