//
//  SnapshotsInitializer.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 04.10.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData

@available(iOS 9.0, *)
final class SnapshotsInitializer {

  private class var managedObjectContext: NSManagedObjectContext {
    return CoreDataStack.privateContext
  }
  
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
  
  private class func setupGeneralSettings() {
    Settings.sharedInstance.generalFullVersion.value = true
    Settings.sharedInstance.generalVolumeUnits.value = .Millilitres
    Settings.sharedInstance.generalWeightUnits.value = .Kilograms
    Settings.sharedInstance.generalHeightUnits.value = .Centimeters
  }
  
  private class func setupUserPersonalInfo() {
    Settings.sharedInstance.userAge.value = 30
    Settings.sharedInstance.userGender.value = .Man
    Settings.sharedInstance.userHeight.value = 175
    Settings.sharedInstance.userWeight.value = 75
    Settings.sharedInstance.userPhysicalActivity.value = .Occasional
    Settings.sharedInstance.userDailyWaterIntake.value = Settings.calcUserDailyWaterIntakeSetting()
  }
  
  private class func setupExtraFactorsForWaterGoal() {
    Settings.sharedInstance.generalHighActivityExtraFactor.value = 0.1
    Settings.sharedInstance.generalHotDayExtraFactor.value = 0.1
  }
  
  private class func setupUI() {
    Settings.sharedInstance.uiUseCustomDateForDayView.value = false
    Settings.sharedInstance.uiDisplayDailyWaterIntakeInPercents.value = false
    Settings.sharedInstance.uiWritingReviewAlertSelection.value = .No
    Settings.sharedInstance.uiSelectedAlcoholicDrink.value = .Wine
    Settings.sharedInstance.uiSelectedStatisticsPage.value = .Month
  }
  
  private class func setupNotifications() {
    Settings.sharedInstance.notificationsEnabled.value = true
    Settings.sharedInstance.notificationsFrom.value = DateHelper.dateBySettingHour(9, minute: 0, second: 0, ofDate: NSDate())
    Settings.sharedInstance.notificationsTo.value = DateHelper.dateBySettingHour(18, minute: 0, second: 0, ofDate: NSDate())
    Settings.sharedInstance.notificationsInterval.value = 60 * 60 * 2
    Settings.sharedInstance.notificationsSmart.value = true
    Settings.sharedInstance.notificationsLimit.value = true
  }
  
  private class func setupStatusBar() {
    SDStatusBarManager.sharedInstance().enableOverrides()
  }

  private class func deactivateHelpTips() {
    Settings.sharedInstance.uiYearStatisticsPageHelpTipIsShown.value = true
    Settings.sharedInstance.uiMonthStatisticsPageHelpTipIsShown.value = true
    Settings.sharedInstance.uiWeekStatisticsPageHelpTipToShow.value = .None
    Settings.sharedInstance.uiDiaryPageHelpTipIsShown.value = true
    Settings.sharedInstance.uiDayPageAlcoholicDehydratrionHelpTipIsShown.value = true
    Settings.sharedInstance.uiDayPageHelpTipToShow.value = .None
  }
  
  private class func generateUserContent() {
    managedObjectContext.performBlockAndWaitUsingGroup {
      removeAllExistingUserData()
      
      coreDataPrepopulation()
      
      generateHistoricalUserData()
      generateWaterGoalForToday()
      generateTodayIntakes()
      
      CoreDataStack.saveContext(managedObjectContext)
    }
  }
  
  private class func coreDataPrepopulation() {
    CoreDataPrePopulation.prePopulateCoreData(managedObjectContext: managedObjectContext, saveContext: false)
  }
  
  private class func generateHistoricalUserData() {
    #if DEBUG
      // Historical data is already generatd in CoreDataPrePopulation.prePopulateCoreData()
    #else
      CoreDataPrePopulation.generateIntakes(managedObjectContext: managedObjectContext)
      CoreDataPrePopulation.generateWaterGoals(managedObjectContext: managedObjectContext)
    #endif
  }
  
  private class func removeAllExistingUserData() {
    do {
      let deleteIntakesRequest = NSBatchDeleteRequest(fetchRequest: NSFetchRequest(entityName: Intake.entityName))
      try managedObjectContext.executeRequest(deleteIntakesRequest)
      
      let deleteWaterGoalsRequest = NSBatchDeleteRequest(fetchRequest: NSFetchRequest(entityName: WaterGoal.entityName))
      try managedObjectContext.executeRequest(deleteWaterGoalsRequest)
    } catch {
      // Do nothing
    }
  }
  
  private class func generateWaterGoalForToday() {
    WaterGoal.addEntity(date: NSDate(), baseAmount: Settings.sharedInstance.userDailyWaterIntake.value, isHotDay: true, isHighActivity: true, managedObjectContext: managedObjectContext, saveImmediately: false)
  }
  
  private class func generateTodayIntakes() {
    guard let water = Drink.fetchDrinkByType(.Water, managedObjectContext: managedObjectContext) else {
      return
    }

    guard let coffee = Drink.fetchDrinkByType(.Coffee, managedObjectContext: managedObjectContext) else {
      return
    }

    guard let soda = Drink.fetchDrinkByType(.Soda, managedObjectContext: managedObjectContext) else {
      return
    }
    
    let date1 = DateHelper.dateBySettingHour(6, minute: 0, second: 0, ofDate: NSDate())
    Intake.addEntity(drink: water, amount: 250, date: date1, managedObjectContext: managedObjectContext, saveImmediately: false)

    let date2 = DateHelper.dateBySettingHour(7, minute: 10, second: 0, ofDate: NSDate())
    Intake.addEntity(drink: coffee, amount: 210, date: date2, managedObjectContext: managedObjectContext, saveImmediately: false)
    
    let date3 = DateHelper.dateBySettingHour(8, minute: 0, second: 0, ofDate: NSDate())
    Intake.addEntity(drink: water, amount: 210, date: date3, managedObjectContext: managedObjectContext, saveImmediately: false)
    
    let date4 = DateHelper.dateBySettingHour(9, minute: 30, second: 0, ofDate: NSDate())
    Intake.addEntity(drink: soda, amount: 330, date: date4, managedObjectContext: managedObjectContext, saveImmediately: false)
  }
 
}