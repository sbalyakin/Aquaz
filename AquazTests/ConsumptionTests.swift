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
  
  func testFetchWaterIntakeGroupedByDaysRandom() {
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

  func testFetchWaterIntakeGroupedByDays() {
    deleteAllConsumptions()
    
    // Add consumptions
    var waterIntakes: [Double] = []
    var waterIntake: Double
    
    typealias ConsumptionInfo = (textDate: String, drinkType: Drink.DrinkType, amount: Double)
    
    func addGroupedConsumptions(consumptions: [ConsumptionInfo]) {
      var waterIntake: Double = 0
      for consumption in consumptions {
        addConsumption(consumption.textDate, consumption.drinkType, consumption.amount, &waterIntake)
      }
      waterIntakes.append(waterIntake)
    }
    
    // Out of check
    addConsumption("01.01.2014 10:00:00", .Water, 1000)
    addConsumption("01.01.2015 20:59:59", .Juice, 2000)
    addConsumption("01.01.2015 23:59:59", .Coffee, 500)
    
    // 2 January
    addGroupedConsumptions([
      ("02.01.2015 00:00:00", .Beer, 1000),
      ("02.01.2015 16:59:59", .Milk, 1000),
      ("02.01.2015 23:59:59", .Tea,  200)])


    // 3 January - no consumptions
    addGroupedConsumptions([])
    
    // 4 January
    addGroupedConsumptions([
      ("04.01.2015 00:00:00", .Soda,  1000),
      ("04.01.2015 12:00:00", .Water, 1000),
      ("04.01.2015 23:59:58", .Milk,  200)])
    
    // 5 January
    addGroupedConsumptions([
      ("05.01.2015 01:00:01", .Beer,         1000),
      ("05.01.2015 15:15:14", .Wine,         1000),
      ("05.01.2015 20:00:10", .StrongLiquor, 2000)])
    
    // Out of check
    addConsumption("06.01.2015 00:00:00", .Water, 1000)
    addConsumption("05.01.2016 00:00:00", .Juice, 2000)
    
    
    // Fetch grouped consumptions and check
    let beginDate = dateFromString("02.01.2015")
    let endDate = dateFromString("06.01.2015")
    let fetchedWaterIntakes = Consumption.fetchGroupedWaterIntake(beginDate: beginDate, endDate: endDate, dayOffsetInHours: 0, groupingUnit: .Day, aggregateFunction: .Summary, managedObjectContext: managedObjectContext)
    
    // It's wrong to compare arrays of doubles in a standard way because doubles values
    // calculated as a result of the same arithmetical operation
    // can have slightly different values (observed in unsignificant last decimals)
    // depending on order of these operations in a particular case.
    // Taking this into account, arrays of doubles are compared using a special function.
    XCTAssert(areArraysOfDoublesAreEqual(waterIntakes, fetchedWaterIntakes), "Fetching for water intakes grouped by days works unproperly")
  }

  func testFetchWaterIntakeGroupedByMonts() {
    deleteAllConsumptions()

    // Add consumptions
    var waterIntakes: [Double] = []
    var waterIntakesAverage: [Double] = []
    var waterIntake: Double
    
    typealias ConsumptionInfo = (textDate: String, drinkType: Drink.DrinkType, amount: Double)
    
    func addGroupedConsumptions(daysInMonth: Int, consumptions: [ConsumptionInfo]) {
      var waterIntake: Double = 0
      for consumption in consumptions {
        addConsumption(consumption.textDate, consumption.drinkType, consumption.amount, &waterIntake)
      }
      waterIntakes.append(waterIntake)
      waterIntakesAverage.append(waterIntake / Double(daysInMonth))
    }
    
    // Out of check
    addConsumption("01.01.2015", .Water, 1000)
    addConsumption("03.01.2015", .Juice, 2000)
    addConsumption("05.01.2015", .Coffee, 500)
    
    // February
    addGroupedConsumptions(28, [
      ("01.02.2015", .Water,  1000),
      ("01.02.2015", .Water,  1000),
      ("03.02.2015", .Juice,  2000),
      ("05.02.2015", .Coffee, 500),
      ("28.02.2015", .Tea,    200)])

    // March - no consumptions
    addGroupedConsumptions(31, [])
   
    // April
    addGroupedConsumptions(30, [
      ("01.04.2015", .Water, 1000),
      ("01.04.2015", .Water, 1000),
      ("03.04.2015", .Juice, 2000),
      ("15.04.2015", .Sport, 500),
      ("30.04.2015", .Milk,  200)])

    // May
    addGroupedConsumptions(31, [
      ("10.05.2015", .Beer,         1000),
      ("01.05.2015", .Wine,         1000),
      ("03.05.2015", .StrongLiquor, 2000),
      ("15.05.2015", .Energy,       500),
      ("30.05.2015", .Soda,         200)])

    // Out of check
    addConsumption("01.06.2015", .Water, 1000)
    addConsumption("03.07.2015", .Juice, 2000)
    addConsumption("05.08.2015", .Coffee, 500)
    addConsumption("01.09.2015", .Water, 1000)
    addConsumption("03.10.2015", .Juice, 2000)
    addConsumption("05.11.2015", .Coffee, 500)
    addConsumption("01.12.2015", .Water, 1000)
    
    addConsumption("03.07.2016", .Juice, 2000)
    addConsumption("05.08.2013", .Coffee, 500)
    
    
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

  private func addConsumption(textDate: String, _ drinkType: Drink.DrinkType, _ amount: Double) -> Consumption {
    var waterIntake: Double = 0
    return addConsumption(textDate, drinkType, amount, &waterIntake)
  }

  private func addConsumption(textDate: String, _ drinkType: Drink.DrinkType, _ amount: Double, inout _ waterIntake: Double) -> Consumption {
    let drink = Drink.getDrinkByType(drinkType, managedObjectContext: managedObjectContext)!
    let date = dateFromString(textDate)
    let consumption = Consumption.addEntity(drink: drink, amount: amount, date: date, managedObjectContext: managedObjectContext, saveImmediately: true)!
    
    waterIntake += consumption.waterIntake
    
    return consumption
  }
  
  private func dateFromString(textDate: String) -> NSDate {
    let dateFormatter = NSDateFormatter()
    let range = textDate.rangeOfString(":", options: .CaseInsensitiveSearch, range: nil, locale: nil)
    dateFormatter.dateFormat = range == nil ? "dd.MM.yyyy" : "dd.MM.yyyy HH:mm:ss"
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
