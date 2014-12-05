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
        Drink.addEntity(index: 0, name: "Water",   waterPercent: 1.00, color: UIColor.blueColor(),       recentAmount: 250, managedObjectContext: managedObjectContext)
        Drink.addEntity(index: 1, name: "Coffee",  waterPercent: 0.98,  color: UIColor.blackColor(),     recentAmount: 250, managedObjectContext: managedObjectContext)
        Drink.addEntity(index: 2, name: "Tea",     waterPercent: 0.98,  color: UIColor.brownColor(),     recentAmount: 250, managedObjectContext: managedObjectContext)

        Drink.addEntity(index: 3, name: "Soda",    waterPercent: 0.98,  color: UIColor.magentaColor(),   recentAmount: 250, managedObjectContext: managedObjectContext)
        Drink.addEntity(index: 4, name: "Juice",   waterPercent: 0.85,  color: UIColor.orangeColor(),    recentAmount: 250, managedObjectContext: managedObjectContext)
        Drink.addEntity(index: 5, name: "Milk",    waterPercent: 0.80,  color: UIColor.lightGrayColor(), recentAmount: 250, managedObjectContext: managedObjectContext)

        Drink.addEntity(index: 6, name: "Alcohol", waterPercent: 0.30,  color: UIColor.redColor(),       recentAmount: 250, managedObjectContext: managedObjectContext)
        Drink.addEntity(index: 7, name: "Sport",   waterPercent: 1.10, color: UIColor.cyanColor(),       recentAmount: 250, managedObjectContext: managedObjectContext)
        Drink.addEntity(index: 8, name: "Energy",  waterPercent: 0.95,  color: UIColor.yellowColor(),    recentAmount: 250, managedObjectContext: managedObjectContext)
        
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
        let drinkIndex = random() % 9
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
