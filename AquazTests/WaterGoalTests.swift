//
//  WaterGoalTests.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 14.02.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData
import XCTest
@testable import Aquaz

class WaterGoalTests: XCTestCase {

  func testFetchWaterGoalForDate() {
    deleteAllWaterGoals()
    
    func testForExistance(_ textDate: String, _ expectedWaterGoal: WaterGoal) {
      let fcr = self.fetchWaterGoalForDate(textDate)

      XCTAssert(fcr != nil, "Water goal fitting for a date (\(textDate)) should exist")
      
      if let fcr = fcr {
        XCTAssertEqual(fcr, expectedWaterGoal, "Wrong water goal is fetched for a date (\(textDate)). Expected water goal for a date (\(self.stringFromDate(expectedWaterGoal.date)))")
      }
    }

    let waterGoal1 = addWaterGoal("01.01.2015 00:00:00", 2000)
    let waterGoal2 = addWaterGoal("01.02.2015 00:00:00", 3000)
    
    testForExistance("01.01.2014 00:00:00", waterGoal1)
    testForExistance("31.12.2014 23:59:59", waterGoal1)
    testForExistance("01.01.2015 00:00:00", waterGoal1)
    testForExistance("30.01.2015 23:59:59", waterGoal1)

    testForExistance("01.02.2015 00:00:00", waterGoal2)
    testForExistance("02.02.2015 00:00:00", waterGoal2)
    testForExistance("01.01.2016 00:00:00", waterGoal2)
  }

  func testFetchWaterGoalStrictlyForDate() {
    deleteAllWaterGoals()
    
    func testForExistance(_ textDate: String, _ expectedWaterGoal: WaterGoal) {
      let fcr = self.fetchWaterGoalStrictlyForDate(textDate)
      
      XCTAssert(fcr != nil, "Water goal strictly matching for a date (\(textDate)) should exist")
      
      if let fcr = fcr {
        XCTAssertEqual(fcr, expectedWaterGoal, "Wrong water goal is fetched strictly for a date (\(textDate)). Expected water goal for a date (\(self.stringFromDate(expectedWaterGoal.date)))")
      }
    }

    func testForNil(_ textDate: String) {
      let fcr = self.fetchWaterGoalStrictlyForDate(textDate)
      XCTAssert(fcr == nil, "Water goal fetched strictly for a date (\(textDate)) should be nil")
    }

    let waterGoal1 = addWaterGoal("01.01.2015 00:00:00", 2000)
    let waterGoal2 = addWaterGoal("01.02.2015 00:00:00", 3000)
    
    testForExistance("01.01.2015 00:00:00", waterGoal1)
    testForExistance("01.01.2015 23:59:59", waterGoal1)
    
    testForExistance("01.02.2015 00:00:00", waterGoal2)
    testForExistance("01.02.2015 23:59:59", waterGoal2)

    testForNil("31.12.2014 23:59:59")
    testForNil("02.01.2015 00:00:00")
    
    testForNil("30.01.2015 23:59:59")
    testForNil("02.02.2015 00:00:00")
  }

  func testFetchWaterGoalAmounts() {
    deleteAllWaterGoals()
    
    let cr02 = addWaterGoal("02.01.2015", 1000, false, false)
    let cr04 = addWaterGoal("04.01.2015", 2000, false, false)
    let cr06 = addWaterGoal("06.01.2015", 3000, true, false)
    let cr08 = addWaterGoal("08.01.2015", 4000, false, true)
    let cr10 = addWaterGoal("10.01.2015", 5000, true, true)

    // Expected water goals from 01.01.2015 to 11.01.2015
    let expectedAmounts = [
      cr02.baseAmount, // 01.01
      cr02.amount,     // 02.01
      cr02.baseAmount, // 03.01
      cr04.amount,     // 04.01
      cr04.baseAmount, // 05.01
      cr06.amount,     // 06.01
      cr06.baseAmount, // 07.01
      cr08.amount,     // 08.01
      cr08.baseAmount, // 09.01
      cr10.amount,     // 10.01
      cr10.baseAmount] // 11.01
    
    let beginDate = dateFromString("01.01.2015")
    let endDate   = dateFromString("12.01.2015")
    let fetchedAmounts = WaterGoal.fetchWaterGoalAmounts(beginDate: beginDate, endDate: endDate, managedObjectContext: managedObjectContext)

    XCTAssert(areArraysOfDoublesAreEqual(expectedAmounts, fetchedAmounts), "Fetched water goal amounts are not match to expected ones.\nExpected:\n\(expectedAmounts)\nFetched:\n\(fetchedAmounts)")
  }
  
  func testFetchWaterGoalAmountsGroupedByMonths() {
    deleteAllWaterGoals()
    
    let cr10_01 = addWaterGoal("10.01.2015", 1000, true, true)
    let cr15_01 = addWaterGoal("15.01.2015", 2000, false, true)
    let cr01_03 = addWaterGoal("01.03.2015", 3000, true, false)

    let summary01 =
      cr10_01.baseAmount * 9 +
      cr10_01.amount +
      cr10_01.baseAmount * 4 +
      cr15_01.amount +
      cr15_01.baseAmount * 16
    let average01 = summary01 / 31
    
    let summary02 = cr15_01.baseAmount * 28
    let average02 = summary02 / 28
    
    let summary03 = cr01_03.amount + cr01_03.baseAmount * 30
    let average03 = summary03 / 31
    
    let expectedAmounts = [average01, average02, average03]
    
    let beginDate = dateFromString("01.01.2015")
    let endDate   = dateFromString("01.04.2015")
    let fetchedAmounts = WaterGoal.fetchWaterGoalAmountsGroupedByMonths(beginDate: beginDate, endDate: endDate, managedObjectContext: managedObjectContext)
    
    XCTAssert(areArraysOfDoublesAreEqual(expectedAmounts, fetchedAmounts), "Fetched water goal amounts are not match to expected ones.\nExpected:\n\(expectedAmounts)\nFetched:\n\(fetchedAmounts)")
  }
  
  fileprivate func fetchWaterGoalForDate(_ textDate: String) -> WaterGoal? {
    let date = dateFromString(textDate)
    return WaterGoal.fetchWaterGoalForDate(date, managedObjectContext: managedObjectContext)
  }
  
  fileprivate func fetchWaterGoalStrictlyForDate(_ textDate: String) -> WaterGoal? {
    let date = dateFromString(textDate)
    return WaterGoal.fetchWaterGoalStrictlyForDate(date, managedObjectContext: managedObjectContext)
  }
  
  fileprivate func addWaterGoal(_ textDate: String, _ baseAmount: Double, _ isHotDay: Bool = false, _ isHighActivity: Bool = false) -> WaterGoal {
    let date = dateFromString(textDate)
    let waterGoal = WaterGoal.addEntity(date: date, baseAmount: baseAmount, isHotDay: isHotDay, isHighActivity: isHighActivity, managedObjectContext: managedObjectContext, saveImmediately: true)
    return waterGoal
  }

  fileprivate func dateFromString(_ textDate: String) -> Date {
    let dateFormatter = DateFormatter()
    let range = textDate.range(of: ":", options: .caseInsensitive, range: nil, locale: nil)
    dateFormatter.dateFormat = range == nil ? "dd.MM.yyyy" : "dd.MM.yyyy HH:mm:ss"
    let date = dateFormatter.date(from: textDate)!
    return date
  }
  
  fileprivate func stringFromDate(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
    let textDate = dateFormatter.string(from: date)
    return textDate
  }
  
  fileprivate func deleteAllWaterGoals() {
    let waterGoals = WaterGoal.fetchManagedObjects(managedObjectContext: managedObjectContext)
    
    for waterGoal in waterGoals {
      managedObjectContext.delete(waterGoal)
    }
    
    do {
      try managedObjectContext.save()
    } catch {
      XCTFail("Failed to save managed object context after deleting all water goals")
    }
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
    return abs(value1 - value2) < DBL_MIN || abs(value1 - value2) < 10 * DBL_EPSILON * abs(value1 + value2)
  }
  
  fileprivate var managedObjectContext: NSManagedObjectContext { return CoreDataSupport.sharedInstance.managedObjectContext }

}
