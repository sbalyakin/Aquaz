//
//  DrinkTests.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 06.02.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit
import XCTest
import CoreData
@testable import Aquaz

class DrinkTests: XCTestCase {

  func testFetchDrinkByIndex() {
    for drinkIndex in 0..<Drink.getDrinksCount() {
      if let drink = Drink.fetchDrinkByIndex(drinkIndex, managedObjectContext: managedObjectContext) {
        XCTAssert(drink.index.intValue == drinkIndex, "Wrong drink is get for index \(drinkIndex)")
      } else {
        XCTFail("Failed to get drink by index \(drinkIndex)")
      }
    }
  }
  
  func testFetchDrinkByType() {
    for drinkIndex in 0..<Drink.getDrinksCount() {
      if let drinkType = DrinkType(rawValue: drinkIndex) {
        if let drink = Drink.fetchDrinkByType(drinkType, managedObjectContext: managedObjectContext) {
          XCTAssert(drink.drinkType == drinkType, "Wrong drink is get for type with index \(drinkType.rawValue)")
        } else {
          XCTFail("Failed to get drink by type with index \(drinkType.rawValue)")
        }
      } else {
        XCTFail("Failed to get drink type from index \(drinkIndex)")
      }
    }
  }
  
  func testFetchAllDrinksIndexed() {
    let drinks = Drink.fetchAllDrinksIndexed(managedObjectContext: managedObjectContext)
    XCTAssert(drinks.count == Drink.getDrinksCount(), "Number of fetched drinks (\(drinks.count)) is incorrect (expected \(Drink.getDrinksCount()))")
  }

  fileprivate func drawDrinkWithType(_ drinkType: DrinkType, frame: CGRect) {
    let drink = Drink.fetchDrinkByType(drinkType, managedObjectContext: managedObjectContext)
    drink?.drawDrink(frame: frame)
  }

  fileprivate var managedObjectContext: NSManagedObjectContext { return CoreDataSupport.sharedInstance.managedObjectContext }

}
