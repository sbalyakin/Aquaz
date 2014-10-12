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
        addNewDrink(0, name: "Water",   waterPercent: 100, color: UIColor.blueColor(),      recentAmount: 250, managedObjectContext: managedObjectContext)
        addNewDrink(1, name: "Coffee",  waterPercent: 98,  color: UIColor.blackColor(),     recentAmount: 250, managedObjectContext: managedObjectContext)
        addNewDrink(2, name: "Tea",     waterPercent: 98,  color: UIColor.brownColor(),     recentAmount: 250, managedObjectContext: managedObjectContext)

        addNewDrink(3, name: "Soda",    waterPercent: 98,  color: UIColor.magentaColor(),   recentAmount: 250, managedObjectContext: managedObjectContext)
        addNewDrink(4, name: "Juice",   waterPercent: 85,  color: UIColor.orangeColor(),    recentAmount: 250, managedObjectContext: managedObjectContext)
        addNewDrink(5, name: "Milk",    waterPercent: 80,  color: UIColor.lightGrayColor(), recentAmount: 250, managedObjectContext: managedObjectContext)

        addNewDrink(6, name: "Alcohol", waterPercent: 30,  color: UIColor.redColor(),       recentAmount: 250, managedObjectContext: managedObjectContext)
        addNewDrink(7, name: "Sport",   waterPercent: 110, color: UIColor.cyanColor(),      recentAmount: 250, managedObjectContext: managedObjectContext)
        addNewDrink(8, name: "Energy",  waterPercent: 95,  color: UIColor.yellowColor(),    recentAmount: 250, managedObjectContext: managedObjectContext)
      }
    }
  }
  
  private class func addNewDrink(index: Int, name: String, waterPercent: NSNumber, color: UIColor, recentAmount amount: NSNumber, managedObjectContext: NSManagedObjectContext) {
    var drink = NSEntityDescription.insertNewObjectForEntityForName("Drink", inManagedObjectContext: managedObjectContext) as Drink
    drink.index = index
    drink.name = name
    drink.waterPercent = waterPercent
    drink.color = color
    
    var recentAmount = NSEntityDescription.insertNewObjectForEntityForName("RecentAmount", inManagedObjectContext: managedObjectContext) as RecentAmount
    recentAmount.drink = drink
    recentAmount.amount = amount

    var error: NSError? = nil
    if !managedObjectContext.save(&error) {
      assert(false, "Failed to add new drink named \"\(name)\"")
    }
  }
}
