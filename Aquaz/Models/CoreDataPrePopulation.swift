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
  
  class func prePopulateCoreData(#model: String, managedObjectContext: NSManagedObjectContext) {
    switch model {
    case "Version 1.0":
      prePopulateCoreDataVersion1_0(managedObjectContext: managedObjectContext)
    default:
      assert(false, "Unsupported Core Data Model version (\(model))")
    }
  }
  
  private class func prePopulateCoreDataVersion1_0(#managedObjectContext: NSManagedObjectContext) {
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

    // Add preliminary consumption rate for today
    ConsumptionRate.addEntity(
      date: DateHelper.dateByClearingTime(ofDate: NSDate()),
      baseRateAmount: Settings.sharedInstance.userDailyWaterIntake.value,
      hotDateFraction: 0,
      highActivityFraction: 0,
      managedObjectContext: managedObjectContext)
    
    // TODO: Only for development
    generateConsumptions(managedObjectContext: managedObjectContext)
    generateConsumptionRates(managedObjectContext: managedObjectContext)
  }
  
  private class func generateConsumptions(#managedObjectContext: NSManagedObjectContext) {
    let secondsPerDay = 60 * 60 * 24
    let endDate = DateHelper.dateBySettingHour(0, minute: 0, second: 0, ofDate: NSDate())
    let beginDate = DateHelper.addToDate(endDate, years: -2, months: 0, days: 0)
    let minAmount = 50
    let maxAmount = 500
    let maxConsumptionsPerDay = 10
    
    for var currentDay = beginDate; currentDay.isEarlierThan(endDate); currentDay = currentDay.getNextDay() {
      let consumptionsCount = random() % maxConsumptionsPerDay
      for i in 0..<consumptionsCount {
        let drinkIndex = random() % Drink.getDrinksCount()
        if let drink = Drink.getDrinkByIndex(drinkIndex, managedObjectContext: managedObjectContext) {
          let amount = minAmount + random() % (maxAmount - minAmount)
          let timeInterval = NSTimeInterval(random() % secondsPerDay)
          let consumptionDate = NSDate(timeInterval: timeInterval, sinceDate: currentDay)
          Consumption.addEntity(drink: drink, amount: amount, date: consumptionDate, managedObjectContext: managedObjectContext, saveImmediately: false)
        }
      }
    }
    
    var error: NSError?
    if !managedObjectContext.save(&error) {
      assert(false, "Failed to save managed object context. Error: \(error?.localizedDescription ?? String())")
    }
  }
  
  private class func generateConsumptionRates(#managedObjectContext: NSManagedObjectContext) {
    let endDate = DateHelper.dateBySettingHour(0, minute: 0, second: 0, ofDate: NSDate())
    let beginDate = DateHelper.addToDate(endDate, years: -2, months: 0, days: 0)
    let minConsumptionRate = 1500
    let maxConsumptionRate = 2500
    let computeConsumptionRateChanceInPercents = 5
    let highActivityChanceInPercents = 10
    let hotDayChanceInPercents = 20
    
    var currentConsumptionRate = minConsumptionRate + random() % (maxConsumptionRate - minConsumptionRate)

    for var currentDay = beginDate; currentDay.isEarlierThan(endDate); currentDay = currentDay.getNextDay() {
      let needToComputeConsumptionRate = (random() % 100) < computeConsumptionRateChanceInPercents
      let enableHighActivity = (random() % 100) < highActivityChanceInPercents
      let enableHotDay = (random() % 100) < hotDayChanceInPercents
      
      if needToComputeConsumptionRate || enableHighActivity || enableHotDay {
        
        if needToComputeConsumptionRate {
          currentConsumptionRate = minConsumptionRate + random() % (maxConsumptionRate - minConsumptionRate)
        }
        
        ConsumptionRate.addEntity(
          date: currentDay,
          baseRateAmount: currentConsumptionRate,
          hotDateFraction: enableHotDay ? 1 : 0,
          highActivityFraction: enableHighActivity ? 1 : 0,
          managedObjectContext: managedObjectContext)
      }
    }
    
    var error: NSError?
    if !managedObjectContext.save(&error) {
      assert(false, "Failed to save managed object context. Error: \(error?.localizedDescription ?? String())")
    }
  }
}
