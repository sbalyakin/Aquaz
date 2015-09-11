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

class CoreDataPrePopulation {
  
  class func prePopulateCoreData(managedObjectContext managedObjectContext: NSManagedObjectContext) {
    managedObjectContext.performBlockAndWait {
      Drink.addEntity(
        index: Drink.DrinkType.Water.rawValue,
        name: "Water",
        hydrationFactor: 1.00,
        dehydrationFactor: 0,
        recentAmount: 250,
        managedObjectContext: managedObjectContext,
        saveImmediately: false)
      
      Drink.addEntity(
        index: Drink.DrinkType.Coffee.rawValue,
        name: "Coffee",
        hydrationFactor: 0.98,
        dehydrationFactor: 0,
        recentAmount: 250,
        managedObjectContext: managedObjectContext,
        saveImmediately: false)
      
      Drink.addEntity(
        index: Drink.DrinkType.Tea.rawValue,
        name: "Tea",
        hydrationFactor: 0.99,
        dehydrationFactor: 0,
        recentAmount: 250,
        managedObjectContext: managedObjectContext,
        saveImmediately: false)

      Drink.addEntity(
        index: Drink.DrinkType.Soda.rawValue,
        name: "Soda",
        hydrationFactor: 0.89,
        dehydrationFactor: 0,
        recentAmount: 250,
        managedObjectContext: managedObjectContext,
        saveImmediately: false)
      
      Drink.addEntity(
        index: Drink.DrinkType.Juice.rawValue,
        name: "Juice",
        hydrationFactor: 0.85,
        dehydrationFactor: 0,
        recentAmount: 250,
        managedObjectContext: managedObjectContext,
        saveImmediately: false)
      
      Drink.addEntity(
        index: Drink.DrinkType.Milk.rawValue,
        name: "Milk",
        hydrationFactor: 0.87,
        dehydrationFactor: 0,
        recentAmount: 250,
        managedObjectContext: managedObjectContext,
        saveImmediately: false)

      Drink.addEntity(
        index: Drink.DrinkType.Sport.rawValue,
        name: "Sport",
        hydrationFactor: 0.95,
        dehydrationFactor: 0,
        recentAmount: 250,
        managedObjectContext: managedObjectContext,
        saveImmediately: false)
      
      Drink.addEntity(
        index: Drink.DrinkType.Energy.rawValue,
        name: "Energy",
        hydrationFactor: 0.90,
        dehydrationFactor: 0,
        recentAmount: 250,
        managedObjectContext: managedObjectContext,
        saveImmediately: false)

      Drink.addEntity(
        index: Drink.DrinkType.Beer.rawValue,
        name: "Beer",
        hydrationFactor: 0.95,
        dehydrationFactor: 0.5,
        recentAmount: 250,
        managedObjectContext: managedObjectContext,
        saveImmediately: false)
      
      Drink.addEntity(
        index: Drink.DrinkType.Wine.rawValue,
        name: "Wine",
        hydrationFactor: 0.85,
        dehydrationFactor: 1.5,
        recentAmount: 250,
        managedObjectContext: managedObjectContext,
        saveImmediately: false)
      
      Drink.addEntity(
        index: Drink.DrinkType.HardLiquor.rawValue,
        name: "HardLiquor",
        hydrationFactor: 0.6,
        dehydrationFactor: 4,
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
      
      CoreDataStack.saveContext(managedObjectContext)
    }
  }
  
  private class func generateIntakes(managedObjectContext managedObjectContext: NSManagedObjectContext) {
    let secondsPerDay = 60 * 60 * 24
    let endDate = DateHelper.dateBySettingHour(0, minute: 0, second: 0, ofDate: NSDate())
    let beginDate = DateHelper.addToDate(endDate, years: -2, months: 0, days: 0)
    let minAmount = 50
    let maxAmount = 500
    let maxIntakesPerDay = 10
    
    let drinks = Drink.fetchAllDrinksIndexed(managedObjectContext: managedObjectContext)
    
    for var currentDay = beginDate; currentDay.isEarlierThan(endDate); currentDay = currentDay.getNextDay() {
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
    }
  }
  
  private class func generateWaterGoals(managedObjectContext managedObjectContext: NSManagedObjectContext) {
    let endDate = DateHelper.dateBySettingHour(0, minute: 0, second: 0, ofDate: NSDate())
    let beginDate = DateHelper.addToDate(endDate, years: -2, months: 0, days: 0)
    let minWaterGoal = 1500
    let maxWaterGoal = 2500
    let computeWaterGoalChanceInPercents = 5
    let highActivityChanceInPercents = 10
    let hotDayChanceInPercents = 20
    
    var currentWaterGoal = Double(minWaterGoal + random() % (maxWaterGoal - minWaterGoal))

    for var currentDay = beginDate; currentDay.isEarlierThan(endDate); currentDay = currentDay.getNextDay() {
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
    }
  }
}
