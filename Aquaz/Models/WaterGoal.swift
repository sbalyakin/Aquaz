//
//  WaterGoal.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 06.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData

public class WaterGoal: NSManagedObject, NamedEntity {
  
  public static var entityName = "WaterGoal"

  /// Date of water goal
  @NSManaged public var date: NSDate
  
  /// Base water goal measured in millilitres
  @NSManaged public var baseAmount: NSNumber
  
  /// Extra water goal factor because of hot day. Should be specified as a fraction of base water goal
  @NSManaged public var hotDayFactor: NSNumber

  /// Extra water goal factor because of high user activity. Should be specified as a fraction of base water goal
  @NSManaged public var highActivityFactor: NSNumber
  
  public var amount: Double {
    return baseAmount.doubleValue * (1 + hotDayFactor.doubleValue + highActivityFactor.doubleValue)
  }

  /// Adds a new water goal entity into Core Data
  public class func addEntity(#date: NSDate, baseAmount: NSNumber, hotDayFactor: NSNumber, highActivityFactor: NSNumber, managedObjectContext: NSManagedObjectContext?, saveImmediately: Bool = true) -> WaterGoal? {
    if let managedObjectContext = managedObjectContext {
      if let waterGoal = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: managedObjectContext) as? WaterGoal {
        let pureDate = DateHelper.dateByClearingTime(ofDate: date)
        waterGoal.date = pureDate
        waterGoal.baseAmount = baseAmount
        waterGoal.hotDayFactor = hotDayFactor
        waterGoal.highActivityFactor = highActivityFactor
        
        if saveImmediately {
          var error: NSError?
          if !managedObjectContext.save(&error) {
            NSLog("Failed to save a new water intake goal for date \"\(pureDate)\". Error: \(error?.localizedDescription ?? String())")
            return nil
          }
        }
        
        return waterGoal
      } else {
        assert(false)
        return nil
      }
    } else {
      assert(false)
      return nil
    }
  }
  
  /// Fetches a water goal that suits for a specified date (time part is skipped).
  /// Searching constains 3 sequental stages.
  /// If water goal's entity is found for a certain stage, searching is done.
  /// Stage 1: The function looks for a water goal's entity with a date equals to the specified date.
  /// Stage 2: The function looks for a water goal's entity with a date earlier than the specified date.
  /// Stage 2: The function looks for a water goal's entity with a date later than the specified date.
  public class func fetchWaterGoalForDate(date: NSDate, managedObjectContext: NSManagedObjectContext?) -> WaterGoal? {
    if let waterGoal = fetchWaterGoalStrictlyForDate(date, managedObjectContext: managedObjectContext) {
      return waterGoal
    }
    
    if let waterGoal = fetchNearestWaterGoalForDateEarlierThanDate(date, managedObjectContext: managedObjectContext) {
      return waterGoal
    }
    
    if let waterGoal = fetchNearestWaterGoalForDateLaterThanDate(date, managedObjectContext: managedObjectContext) {
      return waterGoal
    }
    
    assert(false)
    return nil
  }
  
  /// Fetches amounts of water goals related to a specified date period (beginDate..<endDate).
  /// Water goal searching for each date uses rules decribed for stages in fetchWaterGoalForDate function.
  /// Note: If there is no water goal's entity exist for an intermediate date,
  /// only base amount of fitting water goal's entity will be used.
  /// High activity and hot day factors will be skipped in such a case.
  public class func fetchWaterGoalAmounts(beginDate beginDateRaw: NSDate, endDate endDateRaw: NSDate, managedObjectContext: NSManagedObjectContext?) -> [Double] {
    let beginDate = DateHelper.dateByClearingTime(ofDate: beginDateRaw)
    let endDate = DateHelper.dateByClearingTime(ofDate: endDateRaw)

    let waterGoals = fetchWaterGoalsForDateInterval(beginDate: beginDate, endDate: endDate, managedObjectContext: managedObjectContext)
    var earlierWaterGoal = fetchNearestWaterGoalForDateEarlierThanDate(beginDate, managedObjectContext: managedObjectContext)
    var laterWaterGoal = fetchNearestWaterGoalForDateLaterThanDate(endDate, managedObjectContext: managedObjectContext)
    
    var waterGoalAmounts: [Double] = []
    var waterGoalIndex = 0
    
    for var currentDay = beginDate; currentDay.isEarlierThan(endDate); currentDay = currentDay.getNextDay() {
      let waterGoalAmount = findWaterGoalForDate(currentDay,
        waterGoals: waterGoals,
        managedObjectContext: managedObjectContext,
        waterGoalIndex: &waterGoalIndex,
        earlierWaterGoal: &earlierWaterGoal,
        laterWaterGoal: &laterWaterGoal)
      
      waterGoalAmounts.append(waterGoalAmount)
    }
    
    return waterGoalAmounts
  }
  
  /// Fetches average amounts of water goals related to a specified date period (beginDate..<endDate) grouped by months.
  /// Water goal searching for each date uses rules decribed for stages in fetchWaterGoalForDate function.
  /// Note: If there is no water goal's entity exist for an intermediate date,
  /// only base amount of fitting water goal's entity will be used.
  /// High activity and hot day factors will be skipped in such a case.
  public class func fetchWaterGoalAmountsGroupedByMonths(beginDate beginDateRaw: NSDate, endDate endDateRaw: NSDate, managedObjectContext: NSManagedObjectContext?) -> [Double] {
    let beginDate = DateHelper.dateByClearingTime(ofDate: beginDateRaw)
    let endDate = DateHelper.dateByClearingTime(ofDate: endDateRaw)
    
    let waterGoals = fetchWaterGoalsForDateInterval(beginDate: beginDate, endDate: endDate, managedObjectContext: managedObjectContext)
    var earlierWaterGoal = fetchNearestWaterGoalForDateEarlierThanDate(beginDate, managedObjectContext: managedObjectContext)
    var laterWaterGoal = fetchNearestWaterGoalForDateLaterThanDate(endDate, managedObjectContext: managedObjectContext)

    let calendar = NSCalendar.currentCalendar()

    var waterGoalAmounts: [Double] = []
    var waterGoalIndex = 0
    var daysInMonth: Int!
    var processedDaysCount = 0
    var overallWaterGoal: Double = 0

    let beginDayComponents = calendar.components(.CalendarUnitDay, fromDate: beginDate)
    var currentDayIndex = beginDayComponents.day

    for var currentDay = beginDate; currentDay.isEarlierThan(endDate); currentDay = currentDay.getNextDay() {
      if daysInMonth == nil {
        daysInMonth = calendar.rangeOfUnit(.CalendarUnitDay, inUnit: .CalendarUnitMonth, forDate: currentDay).length
      }

      let waterGoalAmount = findWaterGoalForDate(currentDay,
        waterGoals: waterGoals,
        managedObjectContext: managedObjectContext,
        waterGoalIndex: &waterGoalIndex,
        earlierWaterGoal: &earlierWaterGoal,
        laterWaterGoal: &laterWaterGoal)

      overallWaterGoal += waterGoalAmount
      processedDaysCount++
      currentDayIndex++
      
      if currentDayIndex > daysInMonth {
        let averageWaterGoal = overallWaterGoal / Double(processedDaysCount)
        waterGoalAmounts.append(averageWaterGoal)

        overallWaterGoal = 0
        currentDayIndex = 1
        processedDaysCount = 0
        daysInMonth = nil
      }
    }
    
    if processedDaysCount > 0 {
      let averageWaterGoal = overallWaterGoal / Double(processedDaysCount)
      waterGoalAmounts.append(averageWaterGoal)
    }
  
    return waterGoalAmounts
  }
  
  /// Fetches water goal strictly for a specified date (time part is skipped).
  public class func fetchWaterGoalStrictlyForDate(date: NSDate, managedObjectContext: NSManagedObjectContext?) -> WaterGoal? {
    let pureDate = DateHelper.dateByClearingTime(ofDate: date)
    let predicate = NSPredicate(format: "date = %@", argumentArray: [pureDate])
    return ModelHelper.fetchManagedObject(managedObjectContext: managedObjectContext, predicate: predicate)
  }
  
  private class func findWaterGoalForDate(currentDay: NSDate, waterGoals: [WaterGoal], managedObjectContext: NSManagedObjectContext?, inout waterGoalIndex: Int, inout earlierWaterGoal: WaterGoal?, inout laterWaterGoal: WaterGoal?) -> Double {
    var amount: Double!
    
    // Looking for a water goal's entity for the current day
    if waterGoalIndex < waterGoals.count {
      let waterGoal = waterGoals[waterGoalIndex]
      let waterGoalDate = waterGoal.date
      
      switch currentDay.compare(waterGoalDate) {
      case .OrderedSame:
        // Use computed amount (taking into account high activity etc.)
        // only for a water goal's entity strictly related to the current day
        amount = waterGoal.amount
        earlierWaterGoal = waterGoal
        waterGoalIndex++
        
      case .OrderedAscending: // date of current water goal is later than current day
        laterWaterGoal = waterGoal
        
      case .OrderedDescending: // unreal case
        assert(false, "It's a logical error")
        earlierWaterGoal = waterGoal
      }
    }
    
    if amount == nil {
      if let earlierWaterGoal = earlierWaterGoal {
        amount = earlierWaterGoal.baseAmount.doubleValue
      } else if let laterWaterGoal = laterWaterGoal {
        amount = laterWaterGoal.baseAmount.doubleValue
      } else { // unreal case
        assert(false, "It's a logical error")
        amount = Settings.sharedInstance.userWaterGoal.value
      }
    }

    return amount
  }
  
  private class func fetchNearestWaterGoalForDateEarlierThanDate(date: NSDate, managedObjectContext: NSManagedObjectContext?) -> WaterGoal? {
    let pureDate = DateHelper.dateByClearingTime(ofDate: date)
    let predicate = NSPredicate(format: "date < %@", argumentArray: [pureDate])
    let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
    return ModelHelper.fetchManagedObject(managedObjectContext: managedObjectContext, predicate: predicate, sortDescriptors: [sortDescriptor])
  }
  
  private class func fetchNearestWaterGoalForDateLaterThanDate(date: NSDate, managedObjectContext: NSManagedObjectContext?) -> WaterGoal? {
    let pureDate = DateHelper.dateByClearingTime(ofDate: date)
    let predicate = NSPredicate(format: "date >= %@", argumentArray: [pureDate])
    let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
    return ModelHelper.fetchManagedObject(managedObjectContext: managedObjectContext, predicate: predicate, sortDescriptors: [sortDescriptor])
  }
  
  private class func fetchWaterGoalsForDateInterval(#beginDate: NSDate, endDate: NSDate, managedObjectContext: NSManagedObjectContext?) -> [WaterGoal] {
    let predicate = NSPredicate(format: "(date >= %@) AND (date < %@)", argumentArray: [beginDate, endDate])
    let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
    return ModelHelper.fetchManagedObjects(managedObjectContext: managedObjectContext, predicate: predicate, sortDescriptors: [sortDescriptor])
  }
  
}
