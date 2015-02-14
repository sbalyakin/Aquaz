//
//  ConsumptionRateTests.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 14.02.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit
import XCTest
import Aquaz

class ConsumptionRateTests: XCTestCase {

  func testFetchConsumptionRateForDate() {
    deleteAllConsumptionRates()
    
    func testForExistance(textDate: String, expectedConsumptionRate: ConsumptionRate) {
      let fcr = fetchConsumptionRateForDate(textDate)

      XCTAssert(fcr != nil, "Consumption rate for a date (\(textDate)) should exist")
      
      if let fcr = fcr {
        XCTAssertEqual(fcr, expectedConsumptionRate, "Wrong consumption rate is fetched for a date (\(textDate)). Expected consumption rate for a date (\(stringFromDate(expectedConsumptionRate.date)))")
      }
    }

    let consumptionRate1 = addConsumptionRate("01.01.2015 00:00:00", 2000)
    let consumptionRate2 = addConsumptionRate("01.02.2015 00:00:00", 3000)
    
    testForExistance("01.01.2014 00:00:00", consumptionRate1)
    testForExistance("31.12.2014 23:59:59", consumptionRate1)
    testForExistance("01.01.2015 00:00:00", consumptionRate1)
    testForExistance("30.01.2015 23:59:59", consumptionRate1)

    testForExistance("01.02.2015 00:00:00", consumptionRate2)
    testForExistance("02.02.2015 00:00:00", consumptionRate2)
    testForExistance("01.01.2016 00:00:00", consumptionRate2)
  }

  func testFetchConsumptionRateStrictlyForDate() {
    deleteAllConsumptionRates()
    
    func testForExistance(textDate: String, expectedConsumptionRate: ConsumptionRate) {
      let fcr = fetchConsumptionRateStrictlyForDate(textDate)
      
      XCTAssert(fcr != nil, "Consumption rate strictly for a date (\(textDate)) should exist")
      
      if let fcr = fcr {
        XCTAssertEqual(fcr, expectedConsumptionRate, "Wrong consumption rate is fetched strictly for a date (\(textDate)). Expected consumption rate for a date (\(stringFromDate(expectedConsumptionRate.date)))")
      }
    }

    func testForNil(textDate: String) {
      let fcr = fetchConsumptionRateStrictlyForDate(textDate)
      XCTAssert(fcr == nil, "Consumption rate fetched strictly for a date (\(textDate)) should be nil")
    }

    let consumptionRate1 = addConsumptionRate("01.01.2015 00:00:00", 2000)
    let consumptionRate2 = addConsumptionRate("01.02.2015 00:00:00", 3000)
    
    testForExistance("01.01.2015 00:00:00", consumptionRate1)
    testForExistance("01.01.2015 23:59:59", consumptionRate1)
    
    testForExistance("01.02.2015 00:00:00", consumptionRate2)
    testForExistance("01.02.2015 23:59:59", consumptionRate2)

    testForNil("31.12.2014 23:59:59")
    testForNil("02.01.2015 00:00:00")
    
    testForNil("30.01.2015 23:59:59")
    testForNil("02.02.2015 00:00:00")
  }

  func testFetchConsumptionRateAmounts() {
    deleteAllConsumptionRates()
    
    let cr02 = addConsumptionRate("02.01.2015", 1000, 0, 0)
    let cr04 = addConsumptionRate("04.01.2015", 2000, 0, 0)
    let cr06 = addConsumptionRate("06.01.2015", 3000, 0.3, 0)
    let cr08 = addConsumptionRate("08.01.2015", 4000, 0, 0.2)
    let cr10 = addConsumptionRate("10.01.2015", 5000, 0.3, 0.2)

    // Expected consumption rates from 01.01.2015 to 11.01.2015
    let expectedAmounts = [
      cr02.baseRateAmount.doubleValue, // 01.01
      cr02.amount,                     // 02.01
      cr02.baseRateAmount.doubleValue, // 03.01
      cr04.amount,                     // 04.01
      cr04.baseRateAmount.doubleValue, // 05.01
      cr06.amount,                     // 06.01
      cr06.baseRateAmount.doubleValue, // 07.01
      cr08.amount,                     // 08.01
      cr08.baseRateAmount.doubleValue, // 09.01
      cr10.amount,                     // 10.01
      cr10.baseRateAmount.doubleValue] // 11.01
    
    let beginDate = dateFromString("01.01.2015")
    let endDate   = dateFromString("12.01.2015")
    let fetchedAmounts = ConsumptionRate.fetchConsumptionRateAmounts(beginDate: beginDate, endDate: endDate, managedObjectContext: managedObjectContext)

    XCTAssert(areArraysOfDoublesAreEqual(expectedAmounts, fetchedAmounts), "Fetched consumption rate amounts are not match to expected ones.\nExpected:\n\(expectedAmounts)\nFetched:\n\(fetchedAmounts)")
  }
  
  func testFetchConsumptionRateAmountsGroupedByMonths() {
    deleteAllConsumptionRates()
    
    let cr10_01 = addConsumptionRate("10.01.2015", 1000, 0.3, 0.2)
    let cr15_01 = addConsumptionRate("15.01.2015", 2000, 0,   0.2)
    let cr01_03 = addConsumptionRate("01.03.2015", 3000, 0.3, 0)

    let summary01 =
      cr10_01.baseRateAmount.doubleValue * 9 +
      cr10_01.amount +
      cr10_01.baseRateAmount.doubleValue * 4 +
      cr15_01.amount +
      cr15_01.baseRateAmount.doubleValue * 16
    let average01 = summary01 / 31
    
    let summary02 = cr15_01.baseRateAmount.doubleValue * 28
    let average02 = summary02 / 28
    
    let summary03 = cr01_03.amount + cr01_03.baseRateAmount.doubleValue * 30
    let average03 = summary03 / 31
    
    let expectedAmounts = [average01, average02, average03]
    
    let beginDate = dateFromString("01.01.2015")
    let endDate   = dateFromString("01.04.2015")
    let fetchedAmounts = ConsumptionRate.fetchConsumptionRateAmountsGroupedByMonths(beginDate: beginDate, endDate: endDate, managedObjectContext: managedObjectContext)
    
    XCTAssert(areArraysOfDoublesAreEqual(expectedAmounts, fetchedAmounts), "Fetched consumption rate amounts are not match to expected ones.\nExpected:\n\(expectedAmounts)\nFetched:\n\(fetchedAmounts)")
  }
  
  private func fetchConsumptionRateForDate(textDate: String) -> ConsumptionRate? {
    let date = dateFromString(textDate)
    return ConsumptionRate.fetchConsumptionRateForDate(date, managedObjectContext: managedObjectContext)
  }
  
  private func fetchConsumptionRateStrictlyForDate(textDate: String) -> ConsumptionRate? {
    let date = dateFromString(textDate)
    return ConsumptionRate.fetchConsumptionRateStrictlyForDate(date, managedObjectContext: managedObjectContext)
  }
  
  private func addConsumptionRate(textDate: String, _ baseRateAmount: Double, _ hotDayFraction: Double = 0, _ highActivityFration: Double = 0) -> ConsumptionRate {
    let date = dateFromString(textDate)
    let consumptionRate = ConsumptionRate.addEntity(date: date, baseRateAmount: baseRateAmount, hotDateFraction: hotDayFraction, highActivityFraction: highActivityFration, managedObjectContext: managedObjectContext, saveImmediately: true)
    return consumptionRate!
  }

  private func dateFromString(textDate: String) -> NSDate {
    let dateFormatter = NSDateFormatter()
    let range = textDate.rangeOfString(":", options: .CaseInsensitiveSearch, range: nil, locale: nil)
    dateFormatter.dateFormat = range == nil ? "dd.MM.yyyy" : "dd.MM.yyyy HH:mm:ss"
    let date = dateFormatter.dateFromString(textDate)!
    return date
  }
  
  private func stringFromDate(date: NSDate) -> String {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
    let textDate = dateFormatter.stringFromDate(date)
    return textDate
  }
  
  private func deleteAllConsumptionRates() {
    let consumptionRates: [ConsumptionRate] = ModelHelper.fetchManagedObjects(managedObjectContext: managedObjectContext)
    
    for consumptionRate in consumptionRates {
      managedObjectContext.deleteObject(consumptionRate)
    }
    
    var error: NSError?
    if !managedObjectContext.save(&error) {
      XCTFail("Failed to save managed object context after deleting all consumption rates")
    }
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
