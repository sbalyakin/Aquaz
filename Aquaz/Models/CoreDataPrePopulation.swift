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
  
  class func isCoreDataPrePopulated(managedObjectContext: NSManagedObjectContext) -> Bool {
    return Drink.fetchDrinkByIndex(0, managedObjectContext: managedObjectContext) != nil
  }
  
  class func prePopulateCoreData(managedObjectContext: NSManagedObjectContext, saveContext: Bool) {
    _ = Drink.addEntity(
      index: DrinkType.water.rawValue,
      name: "Water",
      hydrationFactor: DrinkType.water.hydrationFactor,
      dehydrationFactor: DrinkType.water.dehydrationFactor,
      recentAmount: 250,
      managedObjectContext: managedObjectContext,
      saveImmediately: false)
    
    _ = Drink.addEntity(
      index: DrinkType.coffee.rawValue,
      name: "Coffee",
      hydrationFactor: DrinkType.coffee.hydrationFactor,
      dehydrationFactor: DrinkType.coffee.dehydrationFactor,
      recentAmount: 250,
      managedObjectContext: managedObjectContext,
      saveImmediately: false)
    
    _ = Drink.addEntity(
      index: DrinkType.tea.rawValue,
      name: "Tea",
      hydrationFactor: DrinkType.tea.hydrationFactor,
      dehydrationFactor: DrinkType.tea.dehydrationFactor,
      recentAmount: 250,
      managedObjectContext: managedObjectContext,
      saveImmediately: false)

    _ = Drink.addEntity(
      index: DrinkType.soda.rawValue,
      name: "Soda",
      hydrationFactor: DrinkType.soda.hydrationFactor,
      dehydrationFactor: DrinkType.soda.dehydrationFactor,
      recentAmount: 250,
      managedObjectContext: managedObjectContext,
      saveImmediately: false)
    
    _ = Drink.addEntity(
      index: DrinkType.juice.rawValue,
      name: "Juice",
      hydrationFactor: DrinkType.juice.hydrationFactor,
      dehydrationFactor: DrinkType.juice.dehydrationFactor,
      recentAmount: 250,
      managedObjectContext: managedObjectContext,
      saveImmediately: false)
    
    _ = Drink.addEntity(
      index: DrinkType.milk.rawValue,
      name: "Milk",
      hydrationFactor: DrinkType.milk.hydrationFactor,
      dehydrationFactor: DrinkType.milk.dehydrationFactor,
      recentAmount: 250,
      managedObjectContext: managedObjectContext,
      saveImmediately: false)

    _ = Drink.addEntity(
      index: DrinkType.sport.rawValue,
      name: "Sport",
      hydrationFactor: DrinkType.sport.hydrationFactor,
      dehydrationFactor: DrinkType.sport.dehydrationFactor,
      recentAmount: 250,
      managedObjectContext: managedObjectContext,
      saveImmediately: false)
    
    _ = Drink.addEntity(
      index: DrinkType.energy.rawValue,
      name: "Energy",
      hydrationFactor: DrinkType.energy.hydrationFactor,
      dehydrationFactor: DrinkType.energy.dehydrationFactor,
      recentAmount: 250,
      managedObjectContext: managedObjectContext,
      saveImmediately: false)

    _ = Drink.addEntity(
      index: DrinkType.beer.rawValue,
      name: "Beer",
      hydrationFactor: DrinkType.beer.hydrationFactor,
      dehydrationFactor: DrinkType.beer.dehydrationFactor,
      recentAmount: 250,
      managedObjectContext: managedObjectContext,
      saveImmediately: false)
    
    _ = Drink.addEntity(
      index: DrinkType.wine.rawValue,
      name: "Wine",
      hydrationFactor: DrinkType.wine.hydrationFactor,
      dehydrationFactor: DrinkType.wine.dehydrationFactor,
      recentAmount: 250,
      managedObjectContext: managedObjectContext,
      saveImmediately: false)
    
    _ = Drink.addEntity(
      index: DrinkType.hardLiquor.rawValue,
      name: "HardLiquor",
      hydrationFactor: DrinkType.hardLiquor.hydrationFactor,
      dehydrationFactor: DrinkType.hardLiquor.dehydrationFactor,
      recentAmount: 250,
      managedObjectContext: managedObjectContext,
      saveImmediately: false)

    _ = WaterGoal.addEntity(
      date: Date(),
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
  
  class func generateIntakes(managedObjectContext: NSManagedObjectContext) {
    let secondsPerDay = 60 * 60 * 24
    let endDate = DateHelper.startOfDay(Date())
    let beginDate = DateHelper.addToDate(endDate, years: -2, months: 0, days: 0)
    let minAmount = 50
    let maxAmount = 500
    let maxIntakesPerDay = 10
    
    let drinks = Drink.fetchAllDrinksIndexed(managedObjectContext: managedObjectContext)
    
    var currentDay = beginDate
    
    while currentDay.isEarlierThan(endDate) {
      let intakesCount = Int(arc4random_uniform(UInt32(maxIntakesPerDay)))
      for _ in 0..<intakesCount {
        let drinkIndex = Int(arc4random_uniform(UInt32(Drink.getDrinksCount())))
        
        if let drink = drinks[drinkIndex] {
          let amount = Double(minAmount + Int(arc4random_uniform(UInt32(maxAmount - minAmount))))
          let timeInterval = TimeInterval(Int(arc4random_uniform(UInt32(secondsPerDay))))
          let intakeDate = Date(timeInterval: timeInterval, since: currentDay)
          _ = Intake.addEntity(drink: drink, amount: amount, date: intakeDate, managedObjectContext: managedObjectContext, saveImmediately: false)
        }
      }
      
      currentDay = DateHelper.nextDayFrom(currentDay)
    }
  }
  
  class func generateWaterGoals(managedObjectContext: NSManagedObjectContext) {
    let endDate = DateHelper.startOfDay(Date())
    let beginDate = DateHelper.addToDate(endDate, years: -2, months: 0, days: 0)
    let minWaterGoal = 1500
    let maxWaterGoal = 2500
    let computeWaterGoalChanceInPercents = 5
    let highActivityChanceInPercents = 10
    let hotDayChanceInPercents = 20
    
    var currentWaterGoal = Double(minWaterGoal + Int(arc4random_uniform(UInt32(maxWaterGoal - minWaterGoal))))
    
    var currentDay = beginDate

    while currentDay.isEarlierThan(endDate) {
      let needToComputeWaterGoal = Int(arc4random_uniform(100)) < computeWaterGoalChanceInPercents
      let enableHighActivity = Int(arc4random_uniform(100)) < highActivityChanceInPercents
      let enableHotDay = Int(arc4random_uniform(100)) < hotDayChanceInPercents
      
      if needToComputeWaterGoal || enableHighActivity || enableHotDay {
        
        if needToComputeWaterGoal {
          currentWaterGoal = Double(minWaterGoal + Int(arc4random_uniform(UInt32(maxWaterGoal - minWaterGoal))))
        }
        
        _ = WaterGoal.rawAddEntity(
          date: currentDay,
          baseAmount: currentWaterGoal,
          isHotDay: enableHotDay,
          isHighActivity: enableHighActivity,
          managedObjectContext: managedObjectContext,
          saveImmediately: false)
      }
      
      currentDay = DateHelper.nextDayFrom(currentDay)
    }
  }
}
