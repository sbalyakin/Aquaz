//
//  CoreDataPrePopulation.swift
//  Water Me
//
//  Created by Sergey Balyakin on 07.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import CoreData

class CoreDataPrePopulation {
  
  class func prePopulateCoreData(model: String) {
    switch model {
    case "Version 1.0":
      prePopulateCoreDataVersion1_0()
    default:
      assert(false, "Unsupported Core Data Model version (\(model))")
    }
  }
  
  private class func prePopulateCoreDataVersion1_0() {
    if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
      if let managedObjectContext = appDelegate.managedObjectContext {
        // Add drinks
        Drink.addEntity(index: Drink.DrinkType.Water.rawValue,   name: "Water",   waterPercent: 1.00, recentAmount: 250, managedObjectContext: managedObjectContext)
        Drink.addEntity(index: Drink.DrinkType.Coffee.rawValue,  name: "Coffee",  waterPercent: 0.98, recentAmount: 250, managedObjectContext: managedObjectContext)
        Drink.addEntity(index: Drink.DrinkType.Tea.rawValue,     name: "Tea",     waterPercent: 0.99, recentAmount: 250, managedObjectContext: managedObjectContext)

        Drink.addEntity(index: Drink.DrinkType.Soda.rawValue,    name: "Soda",    waterPercent: 0.89, recentAmount: 250, managedObjectContext: managedObjectContext)
        Drink.addEntity(index: Drink.DrinkType.Juice.rawValue,   name: "Juice",   waterPercent: 0.85, recentAmount: 250, managedObjectContext: managedObjectContext)
        Drink.addEntity(index: Drink.DrinkType.Milk.rawValue,    name: "Milk",    waterPercent: 0.87, recentAmount: 250, managedObjectContext: managedObjectContext)

        Drink.addEntity(index: Drink.DrinkType.Alcohol.rawValue, name: "Alcohol", waterPercent: 0.30, recentAmount: 250, managedObjectContext: managedObjectContext)
        Drink.addEntity(index: Drink.DrinkType.Sport.rawValue,   name: "Sport",   waterPercent: 1.10, recentAmount: 250, managedObjectContext: managedObjectContext)
        Drink.addEntity(index: Drink.DrinkType.Energy.rawValue,  name: "Energy",  waterPercent: 0.9, recentAmount: 250, managedObjectContext: managedObjectContext)
        
        // Add preliminary consumption rate for today
        ConsumptionRate.addEntity(
          date: DateHelper.dateByClearingTime(ofDate: NSDate()),
          baseRateAmount: Settings.sharedInstance.userDailyWaterIntake.value,
          hotDateFraction: 0,
          highActivityFraction: 0,
          managedObjectContext: managedObjectContext)
        
        // TODO: Only for development
        generateConsumptions()
        generateConsumptionRates()
      }
    }
  }
  
  private class func generateConsumptions() {
    let secondsPerDay = 60 * 60 * 24
    let endDate = DateHelper.dateBySettingHour(0, minute: 0, second: 0, ofDate: NSDate())
    let beginDate = DateHelper.addToDate(endDate, years: -2, months: 0, days: 0)
    let minAmount = 50
    let maxAmount = 500
    let maxConsumptionsPerDay = 10
    
    let managedObjectContext = ModelHelper.sharedInstance.managedObjectContext
    
    for var currentDay = beginDate; currentDay.isEarlierThan(endDate); currentDay = currentDay.getNextDay() {
      let consumptionsCount = random() % maxConsumptionsPerDay
      for i in 0..<consumptionsCount {
        let drinkIndex = random() % Drink.getDrinksCount()
        let drink = Drink.getDrinkByIndex(drinkIndex)!
        let amount = minAmount + random() % (maxAmount - minAmount)
        let timeInterval = NSTimeInterval(random() % secondsPerDay)
        let consumptionDate = NSDate(timeInterval: timeInterval, sinceDate: currentDay)
        Consumption.addEntity(drink: drink, amount: amount, date: consumptionDate, managedObjectContext: managedObjectContext, saveImmediately: false)
      }
    }
    
    ModelHelper.sharedInstance.save()
  }
  
  private class func generateConsumptionRates() {
    let endDate = DateHelper.dateBySettingHour(0, minute: 0, second: 0, ofDate: NSDate())
    let beginDate = DateHelper.addToDate(endDate, years: -2, months: 0, days: 0)
    let minConsumptionRate = 1500
    let maxConsumptionRate = 2500
    let computeConsumptionRateChanceInPercents = 5
    let highActivityChanceInPercents = 10
    let hotDayChanceInPercents = 20
    
    let managedObjectContext = ModelHelper.sharedInstance.managedObjectContext
    
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
    
    ModelHelper.sharedInstance.save()
  }
}
