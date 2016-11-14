//
//  SnapshotsInitializer.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 04.10.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData

#if DEBUG && AQUAZPRO
  import SimulatorStatusMagic
#endif

@available(iOS 9.3, *)
final class SnapshotsInitializer {

  class func prepareUserData() {
    setupGeneralSettings()
    setupUserPersonalInfo()
    setupExtraFactorsForWaterGoal()
    setupUI()
    setupNotifications()
    setupStatusBar()

    deactivateHelpTips()

    generateUserContent()
  }
  
  fileprivate class func setupGeneralSettings() {
    Settings.sharedInstance.generalVolumeUnits.value = .millilitres
    Settings.sharedInstance.generalWeightUnits.value = .kilograms
    Settings.sharedInstance.generalHeightUnits.value = .centimeters
  }
  
  fileprivate class func setupUserPersonalInfo() {
    Settings.sharedInstance.userAge.value = 30
    Settings.sharedInstance.userGender.value = .man
    Settings.sharedInstance.userHeight.value = 175
    Settings.sharedInstance.userWeight.value = 75
    Settings.sharedInstance.userPhysicalActivity.value = .occasional
    Settings.sharedInstance.userDailyWaterIntake.value = Settings.calcUserDailyWaterIntakeSetting()
  }
  
  fileprivate class func setupExtraFactorsForWaterGoal() {
    Settings.sharedInstance.generalHighActivityExtraFactor.value = 0.1
    Settings.sharedInstance.generalHotDayExtraFactor.value = 0.1
  }
  
  fileprivate class func setupUI() {
    Settings.sharedInstance.uiUseCustomDateForDayView.value = false
    Settings.sharedInstance.uiDisplayDailyWaterIntakeInPercents.value = false
    Settings.sharedInstance.uiWritingReviewAlertSelection.value = .no
    Settings.sharedInstance.uiSelectedAlcoholicDrink.value = .wine
    Settings.sharedInstance.uiSelectedStatisticsPage.value = .month
  }
  
  fileprivate class func setupNotifications() {
    Settings.sharedInstance.notificationsEnabled.value = true
    Settings.sharedInstance.notificationsFrom.value = DateHelper.dateBySettingHour(9, minute: 0, second: 0, ofDate: Date())
    Settings.sharedInstance.notificationsTo.value = DateHelper.dateBySettingHour(18, minute: 0, second: 0, ofDate: Date())
    Settings.sharedInstance.notificationsInterval.value = Double(60 * 60 * 2)
    Settings.sharedInstance.notificationsSmart.value = true
    Settings.sharedInstance.notificationsLimit.value = true
  }
  
  fileprivate class func setupStatusBar() {
    #if DEBUG && AQUAZPRO
    SDStatusBarManager.sharedInstance().enableOverrides()
    #endif
  }

  fileprivate class func deactivateHelpTips() {
    Settings.sharedInstance.uiYearStatisticsPageHelpTipIsShown.value = true
    Settings.sharedInstance.uiMonthStatisticsPageHelpTipIsShown.value = true
    Settings.sharedInstance.uiWeekStatisticsPageHelpTipToShow.value = .none
    Settings.sharedInstance.uiDiaryPageHelpTipIsShown.value = true
    Settings.sharedInstance.uiDayPageAlcoholicDehydratrionHelpTipIsShown.value = true
    Settings.sharedInstance.uiDayPageHelpTipToShow.value = .none
  }
  
  fileprivate class func generateUserContent() {
    CoreDataStack.performOnPrivateContext { privateContext in
      removeAllExistingUserData(privateContext: privateContext)
      
      coreDataPrepopulation(privateContext: privateContext)
      
      generateHistoricalUserData(privateContext: privateContext)
      generateWaterGoalForToday(privateContext: privateContext)
      generateTodayIntakes(privateContext: privateContext)
      
      CoreDataStack.saveContext(privateContext)
    }
  }

  fileprivate class func removeAllExistingUserData(privateContext: NSManagedObjectContext) {
    do {
      let deleteIntakesRequest = NSBatchDeleteRequest(fetchRequest: NSFetchRequest(entityName: Intake.entityName))
      try privateContext.execute(deleteIntakesRequest)
      
      let deleteWaterGoalsRequest = NSBatchDeleteRequest(fetchRequest: NSFetchRequest(entityName: WaterGoal.entityName))
      try privateContext.execute(deleteWaterGoalsRequest)
    } catch {
      // Do nothing
    }
  }
  
  fileprivate class func coreDataPrepopulation(privateContext: NSManagedObjectContext) {
    if !CoreDataPrePopulation.isCoreDataPrePopulated(managedObjectContext: privateContext) {
      CoreDataPrePopulation.prePopulateCoreData(managedObjectContext: privateContext, saveContext: false)
    }
  }
  
  fileprivate class func generateHistoricalUserData(privateContext: NSManagedObjectContext) {
    #if DEBUG
      // Historical data is already generated in CoreDataPrePopulation.prePopulateCoreData()
    #else
      CoreDataPrePopulation.generateIntakes(managedObjectContext: privateContext)
      CoreDataPrePopulation.generateWaterGoals(managedObjectContext: privateContext)
    #endif
  }
  
  fileprivate class func generateWaterGoalForToday(privateContext: NSManagedObjectContext) {
    _ = WaterGoal.addEntity(date: Date(), baseAmount: Settings.sharedInstance.userDailyWaterIntake.value, isHotDay: true, isHighActivity: true, managedObjectContext: privateContext, saveImmediately: false)
  }
  
  fileprivate class func generateTodayIntakes(privateContext: NSManagedObjectContext) {
    guard let water = Drink.fetchDrinkByType(.water, managedObjectContext: privateContext) else {
      return
    }

    guard let coffee = Drink.fetchDrinkByType(.coffee, managedObjectContext: privateContext) else {
      return
    }

    guard let soda = Drink.fetchDrinkByType(.soda, managedObjectContext: privateContext) else {
      return
    }
    
    let date1 = DateHelper.dateBySettingHour(6, minute: 0, second: 0, ofDate: Date())
    _ = Intake.addEntity(drink: water, amount: 250, date: date1, managedObjectContext: privateContext, saveImmediately: false)

    let date2 = DateHelper.dateBySettingHour(7, minute: 10, second: 0, ofDate: Date())
    _ = Intake.addEntity(drink: coffee, amount: 210, date: date2, managedObjectContext: privateContext, saveImmediately: false)
    
    let date3 = DateHelper.dateBySettingHour(8, minute: 0, second: 0, ofDate: Date())
    _ = Intake.addEntity(drink: water, amount: 210, date: date3, managedObjectContext: privateContext, saveImmediately: false)
    
    let date4 = DateHelper.dateBySettingHour(9, minute: 30, second: 0, ofDate: Date())
    _ = Intake.addEntity(drink: soda, amount: 330, date: date4, managedObjectContext: privateContext, saveImmediately: false)
  }
 
}
