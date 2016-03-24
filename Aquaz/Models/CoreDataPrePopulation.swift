//
//  CoreDataPrePopulation.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 07.10.14.
//  Copyright © 2014 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataPrePopulation {
  
  class func isCoreDataPrePopulated(managedObjectContext managedObjectContext: NSManagedObjectContext) -> Bool {
    return Drink.fetchDrinkByIndex(0, managedObjectContext: managedObjectContext) != nil
  }
  
  class func prePopulateCoreData(managedObjectContext managedObjectContext: NSManagedObjectContext, saveContext: Bool) {
    Drink.addEntity(
      index: DrinkType.Water.rawValue,
      name: "Water",
      hydrationFactor: DrinkType.Water.hydrationFactor,
      dehydrationFactor: DrinkType.Water.dehydrationFactor,
      recentAmount: 250,
      managedObjectContext: managedObjectContext,
      saveImmediately: false)
    
    Drink.addEntity(
      index: DrinkType.Coffee.rawValue,
      name: "Coffee",
      hydrationFactor: DrinkType.Coffee.hydrationFactor,
      dehydrationFactor: DrinkType.Coffee.dehydrationFactor,
      recentAmount: 250,
      managedObjectContext: managedObjectContext,
      saveImmediately: false)
    
    Drink.addEntity(
      index: DrinkType.Tea.rawValue,
      name: "Tea",
      hydrationFactor: DrinkType.Tea.hydrationFactor,
      dehydrationFactor: DrinkType.Tea.dehydrationFactor,
      recentAmount: 250,
      managedObjectContext: managedObjectContext,
      saveImmediately: false)

    Drink.addEntity(
      index: DrinkType.Soda.rawValue,
      name: "Soda",
      hydrationFactor: DrinkType.Soda.hydrationFactor,
      dehydrationFactor: DrinkType.Soda.dehydrationFactor,
      recentAmount: 250,
      managedObjectContext: managedObjectContext,
      saveImmediately: false)
    
    Drink.addEntity(
      index: DrinkType.Juice.rawValue,
      name: "Juice",
      hydrationFactor: DrinkType.Juice.hydrationFactor,
      dehydrationFactor: DrinkType.Juice.dehydrationFactor,
      recentAmount: 250,
      managedObjectContext: managedObjectContext,
      saveImmediately: false)
    
    Drink.addEntity(
      index: DrinkType.Milk.rawValue,
      name: "Milk",
      hydrationFactor: DrinkType.Milk.hydrationFactor,
      dehydrationFactor: DrinkType.Milk.dehydrationFactor,
      recentAmount: 250,
      managedObjectContext: managedObjectContext,
      saveImmediately: false)

    Drink.addEntity(
      index: DrinkType.Sport.rawValue,
      name: "Sport",
      hydrationFactor: DrinkType.Sport.hydrationFactor,
      dehydrationFactor: DrinkType.Sport.dehydrationFactor,
      recentAmount: 250,
      managedObjectContext: managedObjectContext,
      saveImmediately: false)
    
    Drink.addEntity(
      index: DrinkType.Energy.rawValue,
      name: "Energy",
      hydrationFactor: DrinkType.Energy.hydrationFactor,
      dehydrationFactor: DrinkType.Energy.dehydrationFactor,
      recentAmount: 250,
      managedObjectContext: managedObjectContext,
      saveImmediately: false)

    Drink.addEntity(
      index: DrinkType.Beer.rawValue,
      name: "Beer",
      hydrationFactor: DrinkType.Beer.hydrationFactor,
      dehydrationFactor: DrinkType.Beer.dehydrationFactor,
      recentAmount: 250,
      managedObjectContext: managedObjectContext,
      saveImmediately: false)
    
    Drink.addEntity(
      index: DrinkType.Wine.rawValue,
      name: "Wine",
      hydrationFactor: DrinkType.Wine.hydrationFactor,
      dehydrationFactor: DrinkType.Wine.dehydrationFactor,
      recentAmount: 250,
      managedObjectContext: managedObjectContext,
      saveImmediately: false)
    
    Drink.addEntity(
      index: DrinkType.HardLiquor.rawValue,
      name: "HardLiquor",
      hydrationFactor: DrinkType.HardLiquor.hydrationFactor,
      dehydrationFactor: DrinkType.HardLiquor.dehydrationFactor,
      recentAmount: 250,
      managedObjectContext: managedObjectContext,
      saveImmediately: false)

    WaterGoal.addEntity(
      date: NSDate(),
      baseAmount: Settings.sharedInstance.userDailyWaterIntake.value,
      isHotDay: false,
      isHighActivity: false,
      managedObjectContext: managedObjectContext,
      saveImmediately: false)
    
    #if DEBUG
    CoreDataPrePopulation.generateIntakes(managedObjectContext: managedObjectContext)
    CoreDataPrePopulation.generateWaterGoals(managedObjectContext: managedObjectContext)
    #endif
    
    if saveContext {
      CoreDataStack.saveContext(managedObjectContext)
    }
  }
  
  class func generateIntakes(managedObjectContext managedObjectContext: NSManagedObjectContext) {
    let secondsPerDay = 60 * 60 * 24
    let endDate = DateHelper.dateBySettingHour(0, minute: 0, second: 0, ofDate: NSDate())
    let beginDate = DateHelper.addToDate(endDate, years: -2, months: 0, days: 0)
    let minAmount = 50
    let maxAmount = 500
    let maxIntakesPerDay = 10
    
    let drinks = Drink.fetchAllDrinksIndexed(managedObjectContext: managedObjectContext)
    
    var currentDay = beginDate
    
    while currentDay.isEarlierThan(endDate) {
      let intakesCount = random() % maxIntakesPerDay
      for _ in 0..<intakesCount {
        let drinkIndex = random() % Drink.getDrinksCount()
        
        if let drink = drinks[drinkIndex] {
          let amount = Double(minAmount + random() % (maxAmount - minAmount))
          let timeInterval = NSTimeInterval(random() % secondsPerDay)
          let intakeDate = NSDate(timeInterval: timeInterval, sinceDate: currentDay)
          Intake.addEntity(drink: drink, amount: amount, date: intakeDate, managedObjectContext: managedObjectContext, saveImmediately: false)
        }
      }
      
      currentDay = currentDay.getNextDay()
    }
  }
  
  class func generateWaterGoals(managedObjectContext managedObjectContext: NSManagedObjectContext) {
    let endDate = DateHelper.dateBySettingHour(0, minute: 0, second: 0, ofDate: NSDate())
    let beginDate = DateHelper.addToDate(endDate, years: -2, months: 0, days: 0)
    let minWaterGoal = 1500
    let maxWaterGoal = 2500
    let computeWaterGoalChanceInPercents = 5
    let highActivityChanceInPercents = 10
    let hotDayChanceInPercents = 20
    
    var currentWaterGoal = Double(minWaterGoal + random() % (maxWaterGoal - minWaterGoal))
    
    var currentDay = beginDate

    while currentDay.isEarlierThan(endDate) {
      let needToComputeWaterGoal = (random() % 100) < computeWaterGoalChanceInPercents
      let enableHighActivity = (random() % 100) < highActivityChanceInPercents
      let enableHotDay = (random() % 100) < hotDayChanceInPercents
      
      if needToComputeWaterGoal || enableHighActivity || enableHotDay {
        
        if needToComputeWaterGoal {
          currentWaterGoal = Double(minWaterGoal + random() % (maxWaterGoal - minWaterGoal))
        }
        
        WaterGoal.rawAddEntity(
          date: currentDay,
          baseAmount: currentWaterGoal,
          isHotDay: enableHotDay,
          isHighActivity: enableHighActivity,
          managedObjectContext: managedObjectContext,
          saveImmediately: false)
      }
      
      currentDay = currentDay.getNextDay()
    }
  }
}
