//
//  DrinkTests.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 06.02.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit
import XCTest
import CoreData
import Aquaz

class DrinkTests: XCTestCase {

  override class func setUp() {
    super.setUp()
    setupManagedContext()
    prePopulateCoreData2()
  }
  
  func testGetDrink() {
    for drinkIndex in 0..<Drink.getDrinksCount() {
      let drink = Drink.getDrinkByIndex(drinkIndex, managedObjectContext: DrinkTests.managedObjectContext)
      XCTAssert(drink != nil, "Failed to get drink by index \(drinkIndex)")
      XCTAssert(drink?.index == drinkIndex, "Wrong drink is get for index \(drinkIndex)")
    }
  }
  
  func testPerformanceGetDrink() {
    measureBlock() {
      for i in 0..<10000 {
        let drinkIndex = i % Drink.getDrinksCount()
        let drink = Drink.getDrinkByIndex(drinkIndex, managedObjectContext: DrinkTests.managedObjectContext)
        XCTAssert(drink != nil, "Failed to get drink by index \(drinkIndex)")
      }
    }
  }
  
  func testPerformanceDrawDrinks() {
    let scaleFactor = UIScreen.mainScreen().scale
    let size = CGSize(width: 100, height: 100)
    UIGraphicsBeginImageContextWithOptions(size, false, scaleFactor)
    
    measureBlock() {
      for dimension in 1...100 {
        let frame = CGRect(x: 0, y: 0, width: dimension, height: dimension)
        for drinkIndex in 0..<Drink.getDrinksCount() {
          if let drink = Drink.getDrinkByIndex(drinkIndex, managedObjectContext: DrinkTests.managedObjectContext) {
            drink.drawDrink(frame: frame)
          }
        }
      }
    }
    
    UIGraphicsEndImageContext()
  }
  
  private func drawDrinkWithType(drinkType: Drink.DrinkType, frame: CGRect) {
    let drink = Drink.getDrinkByType(drinkType, managedObjectContext: DrinkTests.managedObjectContext)
    drink?.drawDrink(frame: frame)
  }

  private static var managedObjectContext: NSManagedObjectContext!
  
  private class func setupManagedContext() {
    let model = NSManagedObjectModel.mergedModelFromBundles(nil)
    XCTAssert(model != nil, "Failed to create managed object model")
    
    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model!)
    let store = coordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil, error: nil)
    XCTAssert(store != nil, "Failed to create persistent store")
    
    managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = coordinator
  }
  
  private class func prePopulateCoreData2() {
    CoreDataPrePopulation.prePopulateCoreData(model: "Version 1.0", managedObjectContext: DrinkTests.managedObjectContext)
  }

}
