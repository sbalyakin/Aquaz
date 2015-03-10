//
//  CoreDataPrePopulation.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 07.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData
import UIKit

public class CoreDataPrePopulation {
  
  public enum ModelVersion: String {
     case Version1_0 = "Version 1.0"
  }
  
  public class func prePopulateCoreData(#modelVersion: ModelVersion, managedObjectContext: NSManagedObjectContext, generateIntakesForTests: Bool = false, generateWaterGoalsForTests: Bool = false) {
    switch modelVersion {
    case .Version1_0: prePopulateCoreDataVersion1_0(managedObjectContext: managedObjectContext)
    }
  }
  
  private class func prePopulateCoreDataVersion1_0(#managedObjectContext: NSManagedObjectContext, generateIntakesForTests: Bool = false, generateWaterGoalsForTests: Bool = false) {
    // Add drinks
    Drink.addEntity(index: Drink.DrinkType.Water.rawValue,   name: "Water",   waterPercent: 1.00, recentAmount: 250, managedObjectContext: managedObjectContext)
    Drink.addEntity(index: Drink.DrinkType.Coffee.rawValue,  name: "Coffee",  waterPercent: 0.98, recentAmount: 250, managedObjectContext: managedObjectContext)
    Drink.addEntity(index: Drink.DrinkType.Tea.rawValue,     name: "Tea",     waterPercent: 0.99, recentAmount: 250, managedObjectContext: managedObjectContext)

    Drink.addEntity(index: Drink.DrinkType.Soda.rawValue,    name: "Soda",    waterPercent: 0.89, recentAmount: 250, managedObjectContext: managedObjectContext)
    Drink.addEntity(index: Drink.DrinkType.Juice.rawValue,   name: "Juice",   waterPercent: 0.85, recentAmount: 250, managedObjectContext: managedObjectContext)
    Drink.addEntity(index: Drink.DrinkType.Milk.rawValue,    name: "Milk",    waterPercent: 0.87, recentAmount: 250, managedObjectContext: managedObjectContext)

    Drink.addEntity(index: Drink.DrinkType.Sport.rawValue,   name: "Sport",   waterPercent: 1.10, recentAmount: 250, managedObjectContext: managedObjectContext)
    Drink.addEntity(index: Drink.DrinkType.Energy.rawValue,  name: "Energy",  waterPercent: 0.90, recentAmount: 250, managedObjectContext: managedObjectContext)

    Drink.addEntity(index: Drink.DrinkType.Beer.rawValue, name: "Beer", waterPercent: 0.95, recentAmount: 250, managedObjectContext: managedObjectContext)
    Drink.addEntity(index: Drink.DrinkType.Wine.rawValue, name: "Wine", waterPercent: 0.80, recentAmount: 250, managedObjectContext: managedObjectContext)
    Drink.addEntity(index: Drink.DrinkType.StrongLiquor.rawValue, name: "StrongLiquor", waterPercent: 0.60, recentAmount: 250, managedObjectContext: managedObjectContext)

    WaterGoal.addEntity(
      date: DateHelper.dateByClearingTime(ofDate: NSDate()),
      baseAmount: Settings.sharedInstance.userWaterGoal.value,
      hotDayFactor: 0,
      highActivityFactor: 0,
      managedObjectContext: managedObjectContext)
    
    if generateIntakesForTests {
      generateIntakes(managedObjectContext: managedObjectContext)
    }
    
    if generateWaterGoalsForTests {
      generateWaterGoals(managedObjectContext: managedObjectContext)
    }
  }
  
  private class func generateIntakes(#managedObjectContext: NSManagedObjectContext) {
    let secondsPerDay = 60 * 60 * 24
    let endDate = DateHelper.dateBySettingHour(0, minute: 0, second: 0, ofDate: NSDate())
    let beginDate = DateHelper.addToDate(endDate, years: -2, months: 0, days: 0)
    let minAmount = 50
    let maxAmount = 500
    let maxIntakesPerDay = 10
    
    for var currentDay = beginDate; currentDay.isEarlierThan(endDate); currentDay = currentDay.getNextDay() {
      let intakesCount = random() % maxIntakesPerDay
      for i in 0..<intakesCount {
        let drinkIndex = random() % Drink.getDrinksCount()
        if let drink = Drink.getDrinkByIndex(drinkIndex, managedObjectContext: managedObjectContext) {
          let amount = minAmount + random() % (maxAmount - minAmount)
          let timeInterval = NSTimeInterval(random() % secondsPerDay)
          let intakeDate = NSDate(timeInterval: timeInterval, sinceDate: currentDay)
          Intake.addEntity(drink: drink, amount: amount, date: intakeDate, managedObjectContext: managedObjectContext, saveImmediately: false)
        }
      }
    }
    
    var error: NSError?
    if !managedObjectContext.save(&error) {
      Logger.logError(Logger.Messages.failedToSaveManagedObjectContext, error: error)
    }
  }
  
  private class func generateWaterGoals(#managedObjectContext: NSManagedObjectContext) {
    let endDate = DateHelper.dateBySettingHour(0, minute: 0, second: 0, ofDate: NSDate())
    let beginDate = DateHelper.addToDate(endDate, years: -2, months: 0, days: 0)
    let minWaterGoal = 1500
    let maxWaterGoal = 2500
    let computeWaterGoalChanceInPercents = 5
    let highActivityChanceInPercents = 10
    let hotDayChanceInPercents = 20
    
    var currentWaterGoal = minWaterGoal + random() % (maxWaterGoal - minWaterGoal)

    for var currentDay = beginDate; currentDay.isEarlierThan(endDate); currentDay = currentDay.getNextDay() {
      let needToComputeWaterGoal = (random() % 100) < computeWaterGoalChanceInPercents
      let enableHighActivity = (random() % 100) < highActivityChanceInPercents
      let enableHotDay = (random() % 100) < hotDayChanceInPercents
      
      if needToComputeWaterGoal || enableHighActivity || enableHotDay {
        
        if needToComputeWaterGoal {
          currentWaterGoal = minWaterGoal + random() % (maxWaterGoal - minWaterGoal)
        }
        
        WaterGoal.addEntity(
          date: currentDay,
          baseAmount: currentWaterGoal,
          hotDayFactor: enableHotDay ? 1 : 0,
          highActivityFactor: enableHighActivity ? 1 : 0,
          managedObjectContext: managedObjectContext)
      }
    }
    
    var error: NSError?
    if !managedObjectContext.save(&error) {
      Logger.logError(Logger.Messages.failedToSaveManagedObjectContext, error: error)
    }
  }
}
