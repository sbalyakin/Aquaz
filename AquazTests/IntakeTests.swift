//
//  IntakeTests.swift
//  Aquaz
//
//  Created by Admin on 12.02.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData
import XCTest
import Aquaz

class IntakeTests: XCTestCase {

  func testAddEntity() {
    deleteAllIntakes()

    let startDate = NSDate()
    let intakeCount = 1000
    let timeIntervalForWeek: NSTimeInterval = 60 * 60 * 24 * 7

    let generatedIntakes = generateIntakes(intakeCount: intakeCount, startDate: startDate, endTimeInterval: timeIntervalForWeek)

    let fetchedIntakes: [Intake] = CoreDataHelper.fetchManagedObjects(managedObjectContext: managedObjectContext)
    
    
    let areEqual = areArraysHaveTheSameIntakes(generatedIntakes, fetchedIntakes)
    XCTAssert(areEqual, "Fetched intakes are not equal to generated intakes")
  }
  
  func testFetchIntake() {
    deleteAllIntakes()
    
    let startDate = NSDate()
    let intakeCount = 1000
    let timeIntervalForWeek: NSTimeInterval = 60 * 60 * 24 * 7
    
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
    
    let startDate = NSDate()
    let intakeCount = 1000
    let timeIntervalForWeek: NSTimeInterval = 60 * 60 * 24 * 7

    let generatedIntakes = generateIntakes(intakeCount: intakeCount, startDate: startDate, endTimeInterval: timeIntervalForWeek)
    
    let dateForCheck = startDate.getNextDay()
    
    let generatedIntakesForDay = generatedIntakes.filter() {
      DateHelper.areDatesEqualByDays($0.date, dateForCheck)
    }
    
    let fetchedIntakesForDay = Intake.fetchIntakesForDay(dateForCheck, dayOffsetInHours: 0, managedObjectContext: managedObjectContext)
    
    let areEqual = areArraysHaveTheSameIntakes(generatedIntakesForDay, fetchedIntakesForDay)
    XCTAssert(areEqual, "Fetched intakes are not equal to generated intakes")
  }
  
  func testFetchWaterIntakeGroupedByDaysRandom() {
    deleteAllIntakes()
    
    let beginDate = DateHelper.dateByClearingTime(ofDate: NSDate())
    let endDate = DateHelper.addToDate(beginDate, years: 0, months: 0, days: 30)
    let intakeCountPerDayRange = 5...50
    let amountOfIntakeRange = 100...2000

    // Generate intakes and calculate water intakes
    var waterBalances: [Double] = []
    
    for var date = beginDate; date.isEarlierThan(endDate); date = date.getNextDay() {
      let intakesPerDay = getRandomInRange(intakeCountPerDayRange)
      var waterBalance: Double = 0
      
      for i in 0..<intakesPerDay {
        let amount = getRandomInRange(amountOfIntakeRange)
        let drinkIndex = random() % Drink.getDrinksCount()
        let drink = Drink.fetchDrinkByIndex(drinkIndex, managedObjectContext: managedObjectContext)!
        let intakeDate = DateHelper.dateBySettingHour(0, minute: 0, second: i, ofDate: date)
        
        let intake = Intake.addEntity(drink: drink, amount: Double(amount), date: intakeDate, managedObjectContext: managedObjectContext, saveImmediately: true)!
        
        waterBalance += intake.waterBalance
      }
      
      waterBalances.append(waterBalance)
    }
    
    // Fetch grouped hydration amounts and check them
    let fetchedAmountPartsList = Intake.fetchIntakeAmountPartsGroupedBy(.Day,
      beginDate: beginDate,
      endDate: endDate,
      dayOffsetInHours: 0,
      aggregateFunction: .Summary,
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
    
    typealias IntakeInfo = (textDate: String, drinkType: Drink.DrinkType, amount: Double)
    
    func addGroupedIntakes(intakes: [IntakeInfo]) {
      var waterBalance: Double = 0
      for intake in intakes {
        self.addIntake(intake.textDate, intake.drinkType, intake.amount, &waterBalance)
      }
      waterBalances.append(waterBalance)
    }
    
    // Out of check
    addIntake("01.01.2014 10:00:00", .Water,  1000)
    addIntake("01.01.2015 20:59:59", .Juice,  2000)
    addIntake("01.01.2015 23:59:59", .Coffee, 500)
    
    // 2 January
    addGroupedIntakes([
      ("02.01.2015 00:00:00", .Beer, 1000),
      ("02.01.2015 16:59:59", .Milk, 1000),
      ("02.01.2015 23:59:59", .Tea,  200)])


    // 3 January - no intakes
    addGroupedIntakes([])
    
    // 4 January
    addGroupedIntakes([
      ("04.01.2015 00:00:00", .Soda,  1000),
      ("04.01.2015 12:00:00", .Water, 1000),
      ("04.01.2015 23:59:58", .Milk,  200)])
    
    // 5 January
    addGroupedIntakes([
      ("05.01.2015 01:00:01", .Beer,       1000),
      ("05.01.2015 15:15:14", .Wine,       1000),
      ("05.01.2015 20:00:10", .HardLiquor, 2000)])
    
    // Out of check
    addIntake("06.01.2015 00:00:00", .Water, 1000)
    addIntake("05.01.2016 00:00:00", .Juice, 2000)
    
    
    // Fetch grouped water balances and check them
    let beginDate = dateFromString("02.01.2015")
    let endDate = dateFromString("06.01.2015")
    
    let fetchedAmountPartsList = Intake.fetchIntakeAmountPartsGroupedBy(.Day,
      beginDate: beginDate,
      endDate: endDate,
      dayOffsetInHours: 0,
      aggregateFunction: .Summary,
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
    
    typealias IntakeInfo = (textDate: String, drinkType: Drink.DrinkType, amount: Double)
    
    func addGroupedIntakes(daysInMonth: Int, intakes: [IntakeInfo]) {
      var waterBalance: Double = 0
      for intake in intakes {
        self.addIntake(intake.textDate, intake.drinkType, intake.amount, &waterBalance)
      }
      waterBalances.append(waterBalance)
      averageWaterBalances.append(waterBalance / Double(daysInMonth))
    }
    
    // Out of check
    addIntake("01.01.2015", .Water,  1000)
    addIntake("03.01.2015", .Juice,  2000)
    addIntake("05.01.2015", .Coffee, 500)
    
    // February
    addGroupedIntakes(28, [
      ("01.02.2015", .Water,  1000),
      ("01.02.2015", .Water,  1000),
      ("03.02.2015", .Juice,  2000),
      ("05.02.2015", .Coffee, 500),
      ("28.02.2015", .Tea,    200)])

    // March - no intakes
    addGroupedIntakes(31, [])
   
    // April
    addGroupedIntakes(30, [
      ("01.04.2015", .Water, 1000),
      ("01.04.2015", .Water, 1000),
      ("03.04.2015", .Juice, 2000),
      ("15.04.2015", .Sport, 500),
      ("30.04.2015", .Milk,  200)])

    // May
    addGroupedIntakes(31, [
      ("10.05.2015", .Beer,       1000),
      ("01.05.2015", .Wine,       1000),
      ("03.05.2015", .HardLiquor, 2000),
      ("15.05.2015", .Energy,     500),
      ("30.05.2015", .Soda,       200)])

    // Out of check
    addIntake("01.06.2015", .Water,  1000)
    addIntake("03.07.2015", .Juice,  2000)
    addIntake("05.08.2015", .Coffee, 500)
    addIntake("01.09.2015", .Water,  1000)
    addIntake("03.10.2015", .Juice,  2000)
    addIntake("05.11.2015", .Coffee, 500)
    addIntake("01.12.2015", .Water,  1000)
    
    addIntake("03.07.2016", .Juice,  2000)
    addIntake("05.08.2013", .Coffee, 500)
    
    
    // Fetch water balances and compare them to original ones
    let beginDate = dateFromString("01.02.2015")
    let endDate = dateFromString("01.06.2015")
    
    let fetchedAmountPartsList = Intake.fetchIntakeAmountPartsGroupedBy(.Month,
      beginDate: beginDate,
      endDate: endDate,
      dayOffsetInHours: 0,
      aggregateFunction: .Summary,
      managedObjectContext: managedObjectContext)
    
    let fetchedAverageAmountPartsList = Intake.fetchIntakeAmountPartsGroupedBy(.Month,
      beginDate: beginDate,
      endDate: endDate,
      dayOffsetInHours: 0,
      aggregateFunction: .Average,
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

  private func addIntake(textDate: String, _ drinkType: Drink.DrinkType, _ amount: Double) -> Intake {
    var waterIntake: Double = 0
    return addIntake(textDate, drinkType, amount, &waterIntake)
  }

  private func addIntake(textDate: String, _ drinkType: Drink.DrinkType, _ amount: Double, inout _ waterBalance: Double) -> Intake {
    let drink = Drink.fetchDrinkByType(drinkType, managedObjectContext: managedObjectContext)!
    let date = dateFromString(textDate)
    let intake = Intake.addEntity(drink: drink, amount: amount, date: date, managedObjectContext: managedObjectContext, saveImmediately: true)!
    
    waterBalance += intake.waterBalance
    
    return intake
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
  
  private func deleteAllIntakes() {
    let intakes: [Intake] = CoreDataHelper.fetchManagedObjects(managedObjectContext: managedObjectContext)
    
    for intake in intakes {
      managedObjectContext.deleteObject(intake)
    }
    
    do {
      try managedObjectContext.save()
    } catch {
      XCTFail("Failed to save managed object context after deleting all intakes")
    }
  }
  
  private func generateIntakes(intakeCount intakeCount: Int, startDate: NSDate, endTimeInterval: NSTimeInterval) -> [Intake] {
    
    var generatedIntakes: [Intake] = []

    if let drink = Drink.fetchDrinkByType(.Water, managedObjectContext: managedObjectContext) {
      // Generate intakes
      let timeIntervalDelta = endTimeInterval / NSTimeInterval(intakeCount)
      for i in 0..<intakeCount {
        let timeInterval = NSTimeInterval(i) * timeIntervalDelta
        if let intake = Intake.addEntity(drink: drink, amount: Double(random() % 2000), date: NSDate(timeInterval: timeInterval, sinceDate: startDate), managedObjectContext: managedObjectContext, saveImmediately: true) {
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

  private func areArraysHaveTheSameIntakes(array1: [Intake], _ array2: [Intake]) -> Bool {
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
    
    for (index, item) in array1.enumerate() {
      if !areDoublesEqual(item, array2[index]) {
        return false
      }
    }
    
    return true
  }
  
  private func areDoublesEqual(value1: Double, _ value2: Double) -> Bool {
    return abs(value1 - value2) < DBL_MIN || abs(value1 - value2) < 100 * DBL_EPSILON * abs(value1 + value2)
  }
  
  private var managedObjectContext: NSManagedObjectContext { return CoreDataSupport.sharedInstance.managedObjectContext }

}
