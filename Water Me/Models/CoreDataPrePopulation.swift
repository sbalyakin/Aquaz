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
        Drink.addEntity(index: 0, name: "Water",   waterPercent: 100, color: UIColor.blueColor(),      recentAmount: 250, managedObjectContext: managedObjectContext)
        Drink.addEntity(index: 1, name: "Coffee",  waterPercent: 98,  color: UIColor.blackColor(),     recentAmount: 250, managedObjectContext: managedObjectContext)
        Drink.addEntity(index: 2, name: "Tea",     waterPercent: 98,  color: UIColor.brownColor(),     recentAmount: 250, managedObjectContext: managedObjectContext)

        Drink.addEntity(index: 3, name: "Soda",    waterPercent: 98,  color: UIColor.magentaColor(),   recentAmount: 250, managedObjectContext: managedObjectContext)
        Drink.addEntity(index: 4, name: "Juice",   waterPercent: 85,  color: UIColor.orangeColor(),    recentAmount: 250, managedObjectContext: managedObjectContext)
        Drink.addEntity(index: 5, name: "Milk",    waterPercent: 80,  color: UIColor.lightGrayColor(), recentAmount: 250, managedObjectContext: managedObjectContext)

        Drink.addEntity(index: 6, name: "Alcohol", waterPercent: 30,  color: UIColor.redColor(),       recentAmount: 250, managedObjectContext: managedObjectContext)
        Drink.addEntity(index: 7, name: "Sport",   waterPercent: 110, color: UIColor.cyanColor(),      recentAmount: 250, managedObjectContext: managedObjectContext)
        Drink.addEntity(index: 8, name: "Energy",  waterPercent: 95,  color: UIColor.yellowColor(),    recentAmount: 250, managedObjectContext: managedObjectContext)
        
        // Add preliminary consumption rate for today
        ConsumptionRate.addEntity(
          date: DateHelper.dateByClearingTime(ofDate: NSDate()),
          baseRateAmount: Settings.sharedInstance.userDailyWaterIntake.value,
          hotDateFraction: 0,
          highActivityFraction: 0,
          managedObjectContext: managedObjectContext)
      }
    }
  }
}
