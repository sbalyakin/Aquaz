//
//  ConsumptionTests.swift
//  Aquaz
//
//  Created by Admin on 12.02.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import Foundation
import UIKit
import XCTest
import Aquaz

class ConsumptionTests: XCTestCase {

  func testAddEntity() {
    deleteAllConsumptions()

    let startDate = NSDate()
    let consumptionCount = 1000
    let timeIntervalForWeek: NSTimeInterval = 60 * 60 * 24 * 7

    let generatedConsumptions = generateConsumptions(consumptionCount: consumptionCount, startDate: startDate, endTimeInterval: timeIntervalForWeek)

    let fetchedConsumptions: [Consumption] = ModelHelper.fetchManagedObjects(managedObjectContext: managedObjectContext)
    
    
    let areEqual = areArraysHaveTheSameConsumptions(generatedConsumptions, fetchedConsumptions)
    XCTAssert(areEqual, "Fetched consumptions are not equal to generated consumption")
  }
  
  func testFetchConsumption() {
    deleteAllConsumptions()
    
    let startDate = NSDate()
    let consumptionCount = 1000
    let timeIntervalForWeek: NSTimeInterval = 60 * 60 * 24 * 7
    
    let generatedConsumptions = generateConsumptions(consumptionCount: consumptionCount, startDate: startDate, endTimeInterval: timeIntervalForWeek)
    
    let from = Int(Double(consumptionCount) * 0.2)
    let to = Int(Double(consumptionCount) * 0.8)
    var consumptionsForCheck = Array(generatedConsumptions[from..<to])
    
    let fetchedConsumptions = Consumption.fetchConsumptions(beginDate: consumptionsForCheck.first!.date, endDate: consumptionsForCheck.last!.date, managedObjectContext: managedObjectContext)
    
    // Delete last consumption, because of fetchConsumption does not include a consumption for the end date
    consumptionsForCheck.removeLast()
    
    let areEqual = areArraysHaveTheSameConsumptions(consumptionsForCheck, fetchedConsumptions)
    XCTAssert(areEqual, "Fetched consumptions are not equal to generated consumption")
  }
  
  func testFetchConsumptionForDay() {
    deleteAllConsumptions()
    
    let startDate = NSDate()
    let consumptionCount = 1000
    let timeIntervalForWeek: NSTimeInterval = 60 * 60 * 24 * 7

    let generatedConsumptions = generateConsumptions(consumptionCount: consumptionCount, startDate: startDate, endTimeInterval: timeIntervalForWeek)
    
    let dateForCheck = startDate.getNextDay()
    
    let generatedConsumptionForDay = generatedConsumptions.filter() {
      DateHelper.areDatesEqualByDays(date1: $0.date, date2: dateForCheck)
    }
    
    let fetchedConsumptionsForDay = Consumption.fetchConsumptionsForDay(dateForCheck, dayOffsetInHours: 0, managedObjectContext: managedObjectContext)
    
    let areEqual = areArraysHaveTheSameConsumptions(generatedConsumptionForDay, fetchedConsumptionsForDay)
    XCTAssert(areEqual, "Fetched consumptions are not equal to generated consumption")
  }
  
  func testFetchWaterIntakeGroupedByDays() {
    deleteAllConsumptions()
    
    let startDate = DateHelper.dateByClearingTime(ofDate: NSDate())
    let endDate = DateHelper.addToDate(startDate, years: 0, months: 0, days: 30)
    let consumptionCountPerDayRange = 5...50
    let amountOfConsumptionRange = 100...2000

    // Generate consumptions and calculate water intakes
    var waterIntakes: [Double] = []
    
    for var date = startDate; date.isEarlierThan(endDate); date = date.getNextDay() {
      let consumptionsPerDay = getRandomInRange(consumptionCountPerDayRange)
      var waterIntake: Double = 0
      
      for i in 0..<consumptionsPerDay {
        let amount = getRandomInRange(amountOfConsumptionRange)
        let drinkIndex = random() % Drink.getDrinksCount()
        let drink = Drink.getDrinkByIndex(drinkIndex, managedObjectContext: managedObjectContext)!
        let consumptionDate = DateHelper.dateBySettingHour(0, minute: 0, second: i, ofDate: date)
        
        let consumption = Consumption.addEntity(drink: drink, amount: amount, date: consumptionDate, managedObjectContext: managedObjectContext, saveImmediately: true)!
        
        waterIntake += consumption.waterIntake
      }
      
      waterIntakes.append(waterIntake)
    }
    
    // Fetch grouped consumptions and check
    let fetchedWaterIntakes = Consumption.fetchGroupedWaterIntake(beginDate: startDate, endDate: endDate, dayOffsetInHours: 0, groupingUnit: .Day, aggregateFunction: .Summary, managedObjectContext: managedObjectContext)

    // It's wrong to compare arrays of doubles in a standard way because doubles values
    // calculated as a result of the same arithmetical operation
    // can have slightly different values (observed in unsignificant last decimals)
    // depending on order of these operations in a particular case.
    // Taking this into account, arrays of doubles are compared using a special function.
    XCTAssert(areArraysOfDoublesAreEqual(waterIntakes, fetchedWaterIntakes), "Wrong water intakes grouped by days are fetched")
  }

  func testFetchWaterIntakeGroupedByMonts() {
    deleteAllConsumptions()

    // Add consumptions
    
    // Out of check
    addConsumption(textDate: "01.01.2015", drinkType: .Water, amount: 1000)
    addConsumption(textDate: "03.01.2015", drinkType: .Juice, amount: 2000)
    addConsumption(textDate: "05.01.2015", drinkType: .Coffee, amount: 500)
    
    // For check
    var waterIntakes: [Double] = []
    var waterIntakesAverage: [Double] = []
    
    // February
    waterIntakes.append(0)
    addConsumption(textDate: "01.02.2015", drinkType: .Water,  amount: 1000, waterIntake: &waterIntakes[waterIntakes.count - 1])
    addConsumption(textDate: "01.02.2015", drinkType: .Water,  amount: 1000, waterIntake: &waterIntakes[waterIntakes.count - 1])
    addConsumption(textDate: "03.02.2015", drinkType: .Juice,  amount: 2000, waterIntake: &waterIntakes[waterIntakes.count - 1])
    addConsumption(textDate: "05.02.2015", drinkType: .Coffee, amount: 500,  waterIntake: &waterIntakes[waterIntakes.count - 1])
    addConsumption(textDate: "28.02.2015", drinkType: .Tea,    amount: 200,  waterIntake: &waterIntakes[waterIntakes.count - 1])
    let daysInFebruary2015: Double = 28
    waterIntakesAverage.append(waterIntakes.last! / daysInFebruary2015)

    // March - no consumptions
    waterIntakes.append(0)
    waterIntakesAverage.append(0)
   
    // April
    waterIntakes.append(0)
    addConsumption(textDate: "01.04.2015", drinkType: .Water, amount: 1000, waterIntake: &waterIntakes[waterIntakes.count - 1])
    addConsumption(textDate: "01.04.2015", drinkType: .Water, amount: 1000, waterIntake: &waterIntakes[waterIntakes.count - 1])
    addConsumption(textDate: "03.04.2015", drinkType: .Juice, amount: 2000, waterIntake: &waterIntakes[waterIntakes.count - 1])
    addConsumption(textDate: "15.04.2015", drinkType: .Sport, amount: 500,  waterIntake: &waterIntakes[waterIntakes.count - 1])
    addConsumption(textDate: "30.04.2015", drinkType: .Milk,  amount: 200,  waterIntake: &waterIntakes[waterIntakes.count - 1])
    let daysInApril: Double = 30
    waterIntakesAverage.append(waterIntakes.last! / daysInApril)

    // May
    waterIntakes.append(0)
    addConsumption(textDate: "10.05.2015", drinkType: .Beer,         amount: 1000, waterIntake: &waterIntakes[waterIntakes.count - 1])
    addConsumption(textDate: "01.05.2015", drinkType: .Wine,         amount: 1000, waterIntake: &waterIntakes[waterIntakes.count - 1])
    addConsumption(textDate: "03.05.2015", drinkType: .StrongLiquor, amount: 2000, waterIntake: &waterIntakes[waterIntakes.count - 1])
    addConsumption(textDate: "15.05.2015", drinkType: .Energy,       amount: 500,  waterIntake: &waterIntakes[waterIntakes.count - 1])
    addConsumption(textDate: "30.05.2015", drinkType: .Soda,         amount: 200,  waterIntake: &waterIntakes[waterIntakes.count - 1])
    let daysInMay: Double = 31
    waterIntakesAverage.append(waterIntakes.last! / daysInMay)

    // Out of check
    addConsumption(textDate: "01.06.2015", drinkType: .Water, amount: 1000)
    addConsumption(textDate: "03.07.2015", drinkType: .Juice, amount: 2000)
    addConsumption(textDate: "05.08.2015", drinkType: .Coffee, amount: 500)
    addConsumption(textDate: "01.09.2015", drinkType: .Water, amount: 1000)
    addConsumption(textDate: "03.10.2015", drinkType: .Juice, amount: 2000)
    addConsumption(textDate: "05.11.2015", drinkType: .Coffee, amount: 500)
    addConsumption(textDate: "01.12.2015", drinkType: .Water, amount: 1000)
    
    addConsumption(textDate: "03.07.2016", drinkType: .Juice, amount: 2000)
    addConsumption(textDate: "05.08.2013", drinkType: .Coffee, amount: 500)
    
    
    // Fetch grouped consumptions and check
    let beginDate = dateFromString("01.02.2015")
    let endDate = dateFromString("01.06.2015")
    let fetchedWaterIntakes = Consumption.fetchGroupedWaterIntake(beginDate: beginDate, endDate: endDate, dayOffsetInHours: 0, groupingUnit: .Month, aggregateFunction: .Summary, managedObjectContext: managedObjectContext)
    let fetchedWaterIntakesAverage = Consumption.fetchGroupedWaterIntake(beginDate: beginDate, endDate: endDate, dayOffsetInHours: 0, groupingUnit: .Month, aggregateFunction: .Average, managedObjectContext: managedObjectContext)
    
    // It's wrong to compare arrays of doubles in a standard way because doubles values
    // calculated as a result of the same arithmetical operation
    // can have slightly different values (observed in unsignificant last decimals)
    // depending on order of these operations in a particular case.
    // Taking this into account, arrays of doubles are compared using a special function.
    XCTAssert(areArraysOfDoublesAreEqual(waterIntakes, fetchedWaterIntakes), "Fetching for water intakes grouped by days works unproperly")
    XCTAssert(areArraysOfDoublesAreEqual(waterIntakesAverage, fetchedWaterIntakesAverage), "Fetching for average water intakes grouped by days works unproperly")
  }

  private func addConsumption(#textDate: String, drinkType: Drink.DrinkType, amount: Double) -> Consumption {
    var waterIntake: Double = 0
    return addConsumption(textDate: textDate, drinkType: drinkType, amount: amount, waterIntake: &waterIntake)
  }

  private func addConsumption(#textDate: String, drinkType: Drink.DrinkType, amount: Double, inout waterIntake: Double) -> Consumption {
    let drink = Drink.getDrinkByType(drinkType, managedObjectContext: managedObjectContext)!
    let date = dateFromString(textDate)
    let consumption = Consumption.addEntity(drink: drink, amount: amount, date: date, managedObjectContext: managedObjectContext, saveImmediately: true)!
    
    waterIntake += consumption.waterIntake
    
    return consumption
  }
  
  private func dateFromString(textDate: String) -> NSDate {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "dd.MM.yyyy"
    let date = dateFormatter.dateFromString(textDate)!
    return date
  }

  private func getRandomInRange(range: Range<Int>) -> Int {
    return range.startIndex + random() % (range.endIndex - 1 - range.startIndex)
  }
  
  private func deleteAllConsumptions() {
    let consumptions: [Consumption] = ModelHelper.fetchManagedObjects(managedObjectContext: managedObjectContext)
    
    for consumption in consumptions {
      managedObjectContext.deleteObject(consumption)
    }
    
    var error: NSError?
    if !managedObjectContext.save(&error) {
      XCTFail("Failed to save managed object context after deleting all consumptions")
    }
  }
  
  private func generateConsumptions(#consumptionCount: Int, startDate: NSDate, endTimeInterval: NSTimeInterval) -> [Consumption] {
    
    var generatedConsumptions: [Consumption] = []

    if let drink = Drink.getDrinkByType(.Water, managedObjectContext: managedObjectContext) {
      // Generate consumptions
      let timeIntervalDelta = endTimeInterval / NSTimeInterval(consumptionCount)
      for i in 0..<consumptionCount {
        let timeInterval = NSTimeInterval(i) * timeIntervalDelta
        if let consumption = Consumption.addEntity(drink: drink, amount: random() % 2000, date: NSDate(timeInterval: timeInterval, sinceDate: startDate), managedObjectContext: managedObjectContext, saveImmediately: true) {
          generatedConsumptions.append(consumption)
        } else {
          XCTFail("Failed to add consumption")
        }
      }
    } else {
      XCTFail("Failed to get drink")
    }
    
    return generatedConsumptions
  }

  private func areArraysHaveTheSameConsumptions(array1: [Consumption], _ array2: [Consumption]) -> Bool {
    if array1.count != array2.count {
      return false
    }
    
    for item1 in array1 {
      var found = false
      for item2 in array2 {
        if item1 === item2 {
          found = true
        }
      }
      if !found {
        return false
      }
    }
    
    return true
  }
  
  private func areArraysOfDoublesAreEqual(array1: [Double], _ array2: [Double]) -> Bool {
    if array1.count != array2.count {
      return false
    }
    
    for (index, item) in enumerate(array1) {
      if !areDoublesEqual(item, array2[index]) {
        return false
      }
    }
    
    return true
  }
  
  private func areDoublesEqual(value1: Double, _ value2: Double) -> Bool {
    return abs(value1 - value2) < DBL_MIN || abs(value1 - value2) < 10 * DBL_EPSILON * abs(value1 + value2)
  }
  
  private var managedObjectContext = CoreDataHelper.sharedInstance.managedObjectContext

}
