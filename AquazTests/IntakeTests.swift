//
//  IntakeTests.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 12.02.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData
import XCTest
@testable import Aquaz

class IntakeTests: XCTestCase {

  func testAddEntity() {
    deleteAllIntakes()

    let startDate = Date()
    let intakeCount = 1000
    let timeIntervalForWeek: TimeInterval = 60 * 60 * 24 * 7

    let generatedIntakes = generateIntakes(intakeCount: intakeCount, startDate: startDate, endTimeInterval: timeIntervalForWeek)

    let fetchedIntakes = Intake.fetchManagedObjects(managedObjectContext: managedObjectContext)
    
    let areEqual = areArraysHaveTheSameIntakes(generatedIntakes, fetchedIntakes)
    XCTAssert(areEqual, "Fetched intakes are not equal to generated intakes")
  }
  
  func testFetchIntake() {
    deleteAllIntakes()
    
    let startDate = Date()
    let intakeCount = 1000
    let timeIntervalForWeek: TimeInterval = 60 * 60 * 24 * 7
    
    let generatedIntakes = generateIntakes(intakeCount: intakeCount, startDate: startDate, endTimeInterval: timeIntervalForWeek)
    
    let from = Int(Double(intakeCount) * 0.2)
    let to = Int(Double(intakeCount) * 0.8)
    var intakesForCheck = Array(generatedIntakes[from..<to])
    
    let fetchedIntakes = Intake.fetchIntakes(beginDate: intakesForCheck.first!.date, endDate: intakesForCheck.last!.date, managedObjectContext: managedObjectContext)
    
    // Delete the last intake, because fetchIntakes does not include an intake for the end date
    intakesForCheck.removeLast()
    
    let areEqual = areArraysHaveTheSameIntakes(intakesForCheck, fetchedIntakes)
    XCTAssert(areEqual, "Fetched intakes are not equal to generated intakes")
  }
  
  func testFetchIntakesForDay() {
    deleteAllIntakes()
    
    let startDate = Date()
    let intakeCount = 1000
    let timeIntervalForWeek: TimeInterval = 60 * 60 * 24 * 7

    let generatedIntakes = generateIntakes(intakeCount: intakeCount, startDate: startDate, endTimeInterval: timeIntervalForWeek)
    
    let dateForCheck = DateHelper.nextDayFrom(startDate)
    
    let generatedIntakesForDay = generatedIntakes.filter() {
      DateHelper.areEqualDays($0.date, dateForCheck)
    }
    
    let fetchedIntakesForDay = Intake.fetchIntakesForDay(dateForCheck, dayOffsetInHours: 0, managedObjectContext: managedObjectContext)
    
    let areEqual = areArraysHaveTheSameIntakes(generatedIntakesForDay, fetchedIntakesForDay)
    XCTAssert(areEqual, "Fetched intakes are not equal to generated intakes")
  }
  
  func testFetchWaterIntakeGroupedByDaysRandom() {
    deleteAllIntakes()
    
    let beginDate = DateHelper.startOfDay(Date())
    let endDate = DateHelper.addToDate(beginDate, years: 0, months: 0, days: 30)
    let intakeCountPerDayRange: Range<Int> = 5..<51
    let amountOfIntakeRange: Range<Int> = 100..<2001

    // Generate intakes and calculate water intakes
    var waterBalances: [Double] = []
    var date = beginDate
    
    while date.isEarlierThan(endDate) {
      let intakesPerDay = getRandomInRange(intakeCountPerDayRange)
      var waterBalance: Double = 0
      
      for i in 0..<intakesPerDay {
        let amount = getRandomInRange(amountOfIntakeRange)
        let drinkIndex = Int(arc4random_uniform(UInt32(Drink.getDrinksCount())))
        let drink = Drink.fetchDrinkByIndex(drinkIndex, managedObjectContext: managedObjectContext)!
        let intakeDate = DateHelper.dateBySettingHour(0, minute: 0, second: i, ofDate: date)
        
        let intake = Intake.addEntity(drink: drink, amount: Double(amount), date: intakeDate, managedObjectContext: managedObjectContext, saveImmediately: true)!
        
        waterBalance += intake.waterBalance
      }
      
      waterBalances.append(waterBalance)
      
      date = DateHelper.nextDayFrom(date)
    }
    
    // Fetch grouped hydration amounts and check them
    let fetchedAmountPartsList = Intake.fetchIntakeAmountPartsGroupedBy(.day,
      beginDate: beginDate,
      endDate: endDate,
      dayOffsetInHours: 0,
      aggregateFunction: .summary,
      managedObjectContext: managedObjectContext)

    let fetchedWaterBalances = fetchedAmountPartsList.map { (hydration, dehydration) -> Double in
      return hydration - dehydration
    }

    // It's wrong to compare arrays of doubles in a standard way because doubles values
    // calculated as a result of the same arithmetical operation
    // can have slightly different values (observed in unsignificant last decimals)
    // depending on order of these operations in a particular case.
    // Taking this into account, arrays of doubles are compared using a special function.
    XCTAssert(areArraysOfDoublesAreEqual(waterBalances, fetchedWaterBalances), "Fetching is wrong for intake water balances grouped by days")
  }

  func testFetchWaterBalancesGroupedByDays() {
    deleteAllIntakes()
    
    // Add intakes
    var waterBalances: [Double] = []
    
    typealias IntakeInfo = (textDate: String, drinkType: DrinkType, amount: Double)
    
    func addGroupedIntakes(_ intakes: [IntakeInfo]) {
      var waterBalance: Double = 0
      for intake in intakes {
        _ = self.addIntake(intake.textDate, intake.drinkType, intake.amount, &waterBalance)
      }
      waterBalances.append(waterBalance)
    }
    
    // Out of check
    _ = addIntake("01.01.2014 10:00:00", .water,  1000)
    _ = addIntake("01.01.2015 20:59:59", .juice,  2000)
    _ = addIntake("01.01.2015 23:59:59", .coffee, 500)
    
    // 2 January
    addGroupedIntakes([
      ("02.01.2015 00:00:00", .beer, 1000),
      ("02.01.2015 16:59:59", .milk, 1000),
      ("02.01.2015 23:59:59", .tea,  200)])


    // 3 January - no intakes
    addGroupedIntakes([])
    
    // 4 January
    addGroupedIntakes([
      ("04.01.2015 00:00:00", .soda,  1000),
      ("04.01.2015 12:00:00", .water, 1000),
      ("04.01.2015 23:59:58", .milk,  200)])
    
    // 5 January
    addGroupedIntakes([
      ("05.01.2015 01:00:01", .beer,       1000),
      ("05.01.2015 15:15:14", .wine,       1000),
      ("05.01.2015 20:00:10", .hardLiquor, 2000)])
    
    // Out of check
    _ = addIntake("06.01.2015 00:00:00", .water, 1000)
    _ = addIntake("05.01.2016 00:00:00", .juice, 2000)
    
    
    // Fetch grouped water balances and check them
    let beginDate = dateFromString("02.01.2015")
    let endDate = dateFromString("06.01.2015")
    
    let fetchedAmountPartsList = Intake.fetchIntakeAmountPartsGroupedBy(.day,
      beginDate: beginDate,
      endDate: endDate,
      dayOffsetInHours: 0,
      aggregateFunction: .summary,
      managedObjectContext: managedObjectContext)
    
    let fetchedWaterBalances = fetchedAmountPartsList.map { (hydration, dehydration) -> Double in
      return hydration - dehydration
    }
    
    // It's wrong to compare arrays of doubles in a standard way because doubles values
    // calculated as a result of the same arithmetical operation
    // can have slightly different values (observed in unsignificant last decimals)
    // depending on order of these operations in a particular case.
    // Taking this into account, arrays of doubles are compared using a special function.
    XCTAssert(areArraysOfDoublesAreEqual(waterBalances, fetchedWaterBalances), "Fetching is wrong for intake water balances grouped by days")
  }

  func testFetchWaterBalancesGroupedByMonts() {
    deleteAllIntakes()

    // Add intakes
    var waterBalances: [Double] = []
    var averageWaterBalances: [Double] = []
    
    typealias IntakeInfo = (textDate: String, drinkType: DrinkType, amount: Double)
    
    func addGroupedIntakes(_ daysInMonth: Int, _ intakes: [IntakeInfo]) {
      var waterBalance: Double = 0
      for intake in intakes {
        _ = self.addIntake(intake.textDate, intake.drinkType, intake.amount, &waterBalance)
      }
      waterBalances.append(waterBalance)
      averageWaterBalances.append(waterBalance / Double(daysInMonth))
    }
    
    // Out of check
    _ = addIntake("01.01.2015", .water,  1000)
    _ = addIntake("03.01.2015", .juice,  2000)
    _ = addIntake("05.01.2015", .coffee, 500)
    
    // February
    addGroupedIntakes(28, [
      ("01.02.2015", .water,  1000),
      ("01.02.2015", .water,  1000),
      ("03.02.2015", .juice,  2000),
      ("05.02.2015", .coffee, 500),
      ("28.02.2015", .tea,    200)])

    // March - no intakes
    addGroupedIntakes(31, [])
   
    // April
    addGroupedIntakes(30, [
      ("01.04.2015", .water, 1000),
      ("01.04.2015", .water, 1000),
      ("03.04.2015", .juice, 2000),
      ("15.04.2015", .sport, 500),
      ("30.04.2015", .milk,  200)])

    // May
    addGroupedIntakes(31, [
      ("10.05.2015", .beer,       1000),
      ("01.05.2015", .wine,       1000),
      ("03.05.2015", .hardLiquor, 2000),
      ("15.05.2015", .energy,     500),
      ("30.05.2015", .soda,       200)])

    // Out of check
    _ = addIntake("01.06.2015", .water,  1000)
    _ = addIntake("03.07.2015", .juice,  2000)
    _ = addIntake("05.08.2015", .coffee, 500)
    _ = addIntake("01.09.2015", .water,  1000)
    _ = addIntake("03.10.2015", .juice,  2000)
    _ = addIntake("05.11.2015", .coffee, 500)
    _ = addIntake("01.12.2015", .water,  1000)
    
    _ = addIntake("03.07.2016", .juice,  2000)
    _ = addIntake("05.08.2013", .coffee, 500)
    
    
    // Fetch water balances and compare them to original ones
    let beginDate = dateFromString("01.02.2015")
    let endDate = dateFromString("01.06.2015")
    
    let fetchedAmountPartsList = Intake.fetchIntakeAmountPartsGroupedBy(.month,
      beginDate: beginDate,
      endDate: endDate,
      dayOffsetInHours: 0,
      aggregateFunction: .summary,
      managedObjectContext: managedObjectContext)
    
    let fetchedAverageAmountPartsList = Intake.fetchIntakeAmountPartsGroupedBy(.month,
      beginDate: beginDate,
      endDate: endDate,
      dayOffsetInHours: 0,
      aggregateFunction: .average,
      managedObjectContext: managedObjectContext)
    
    let fetchedWaterBalances = fetchedAmountPartsList.map { (hydration, dehydration) -> Double in
      return hydration - dehydration
    }

    let fetchedAverageWaterBalances = fetchedAverageAmountPartsList.map { (hydration, dehydration) -> Double in
      return hydration - dehydration
    }

    // It's wrong to compare arrays of doubles in a standard way because doubles values
    // calculated as a result of the same arithmetical operation
    // can have slightly different values (observed in unsignificant last decimals)
    // depending on order of these operations in a particular case.
    // Taking this into account, arrays of doubles are compared using a special function.
    XCTAssert(areArraysOfDoublesAreEqual(waterBalances, fetchedWaterBalances), "Fetching is wrong for water balances grouped by days")
    XCTAssert(areArraysOfDoublesAreEqual(averageWaterBalances, fetchedAverageWaterBalances), "Fetching is wrong for average water balances grouped by days")
  }

  fileprivate func addIntake(_ textDate: String, _ drinkType: DrinkType, _ amount: Double) -> Intake {
    var waterIntake: Double = 0
    return addIntake(textDate, drinkType, amount, &waterIntake)
  }

  fileprivate func addIntake(_ textDate: String, _ drinkType: DrinkType, _ amount: Double, _ waterBalance: inout Double) -> Intake {
    let drink = Drink.fetchDrinkByType(drinkType, managedObjectContext: managedObjectContext)!
    let date = dateFromString(textDate)
    let intake = Intake.addEntity(drink: drink, amount: amount, date: date, managedObjectContext: managedObjectContext, saveImmediately: true)!
    
    waterBalance += intake.waterBalance
    
    return intake
  }
  
  fileprivate func dateFromString(_ textDate: String) -> Date {
    let dateFormatter = DateFormatter()
    let range = textDate.range(of: ":", options: .caseInsensitive, range: nil, locale: nil)
    dateFormatter.dateFormat = range == nil ? "dd.MM.yyyy" : "dd.MM.yyyy HH:mm:ss"
    let date = dateFormatter.date(from: textDate)!
    return date
  }

  fileprivate func getRandomInRange(_ range: Range<Int>) -> Int {
    return range.lowerBound + Int(arc4random_uniform(UInt32(range.upperBound - 1 - range.lowerBound)))
  }
  
  fileprivate func deleteAllIntakes() {
    let intakes = Intake.fetchManagedObjects(managedObjectContext: managedObjectContext)
    
    for intake in intakes {
      managedObjectContext.delete(intake)
    }
    
    do {
      try managedObjectContext.save()
    } catch {
      XCTFail("Failed to save managed object context after deleting all intakes")
    }
  }
  
  fileprivate func generateIntakes(intakeCount: Int, startDate: Date, endTimeInterval: TimeInterval) -> [Intake] {
    
    var generatedIntakes: [Intake] = []

    if let drink = Drink.fetchDrinkByType(.water, managedObjectContext: managedObjectContext) {
      // Generate intakes
      let timeIntervalDelta = endTimeInterval / TimeInterval(intakeCount)
      for i in 0..<intakeCount {
        let timeInterval = TimeInterval(i) * timeIntervalDelta
        if let intake = Intake.addEntity(drink: drink, amount: Double(arc4random_uniform(2000)), date: Date(timeInterval: timeInterval, since: startDate), managedObjectContext: managedObjectContext, saveImmediately: true) {
          generatedIntakes.append(intake)
        } else {
          XCTFail("Failed to add an intake")
        }
      }
    } else {
      XCTFail("Failed to get a drink")
    }
    
    return generatedIntakes
  }

  fileprivate func areArraysHaveTheSameIntakes(_ array1: [Intake], _ array2: [Intake]) -> Bool {
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
  
  fileprivate func areArraysOfDoublesAreEqual(_ array1: [Double], _ array2: [Double]) -> Bool {
    if array1.count != array2.count {
      return false
    }
    
    for (index, item) in array1.enumerated() {
      if !areDoublesEqual(item, array2[index]) {
        return false
      }
    }
    
    return true
  }
  
  fileprivate func areDoublesEqual(_ value1: Double, _ value2: Double) -> Bool {
    return abs(value1 - value2) < DBL_MIN || abs(value1 - value2) < 100 * DBL_EPSILON * abs(value1 + value2)
  }
  
  fileprivate var managedObjectContext: NSManagedObjectContext { return CoreDataSupport.sharedInstance.managedObjectContext }

}
