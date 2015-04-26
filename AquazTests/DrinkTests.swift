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

  override func setUp() {
    super.setUp()
    Drink.cacheAllDrinks(managedObjectContext)
  }

  func testGetDrinkByIndex() {
    for drinkIndex in 0..<Drink.getDrinksCount() {
      if let drink = Drink.getDrinkByIndex(drinkIndex, managedObjectContext: managedObjectContext) {
        XCTAssert(drink.index == drinkIndex, "Wrong drink is get for index \(drinkIndex)")
      } else {
        XCTFail("Failed to get drink by index \(drinkIndex)")
      }
    }
  }
  
  func testGetDrinkByType() {
    for drinkIndex in 0..<Drink.getDrinksCount() {
      if let drinkType = Drink.DrinkType(rawValue: drinkIndex) {
        if let drink = Drink.getDrinkByType(drinkType, managedObjectContext: managedObjectContext) {
          XCTAssert(drink.drinkType == drinkType, "Wrong drink is get for type with index \(drinkType.rawValue)")
        } else {
          XCTFail("Failed to get drink by type with index \(drinkType.rawValue)")
        }
      } else {
        XCTFail("Failed to get drink type from index \(drinkIndex)")
      }
    }
  }
  
  func testPerformanceGetDrink() {
    measureBlock() {
      for i in 0..<10000 {
        let drinkIndex = i % Drink.getDrinksCount()
        let drink = Drink.getDrinkByIndex(drinkIndex, managedObjectContext: self.managedObjectContext)
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
          if let drink = Drink.getDrinkByIndex(drinkIndex, managedObjectContext: self.managedObjectContext) {
            drink.drawDrink(frame: frame)
          }
        }
      }
    }
    
    UIGraphicsEndImageContext()
  }
  
  private func drawDrinkWithType(drinkType: Drink.DrinkType, frame: CGRect) {
    let drink = Drink.getDrinkByType(drinkType, managedObjectContext: managedObjectContext)
    drink?.drawDrink(frame: frame)
  }

  private var managedObjectContext: NSManagedObjectContext { return CoreDataSupport.sharedInstance.managedObjectContext }

}
