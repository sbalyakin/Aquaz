//
//  WaterGoal.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 06.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData

@objc(WaterGoal)
public class WaterGoal: CodingManagedObject, NamedEntity {
  
  public static var entityName = "WaterGoal"

  /// Date of water goal
  @NSManaged public var date: NSDate
  
  /// Base water goal measured in millilitres
  @NSManaged public var baseAmount: Double
  
  /// Is current date hot day? If so water goal will be increased according to corresponding setting.
  @NSManaged public var isHotDay: Bool

  /// Is there high activity for current day? If so water goal will be increased according to corresponding setting.
  @NSManaged public var isHighActivity: Bool
  
  public var amount: Double {
    return baseAmount * (1 + hotDayFactor + highActivityFactor)
  }
  
  public var hotDayFactor: Double {
    return isHotDay ? Settings.sharedInstance.generalHotDayExtraFactor.value : 0
  }
  
  public var highActivityFactor: Double {
    return isHighActivity ? Settings.sharedInstance.generalHighActivityExtraFactor.value : 0
  }

  /// Adds a new water goal entity into Core Data. If a water goal with passed date is already exist, it will be returned as a result.
  public class func addEntity(#date: NSDate, baseAmount: Double, isHotDay: Bool, isHighActivity: Bool, managedObjectContext: NSManagedObjectContext, saveImmediately: Bool = true) -> WaterGoal {
    if let waterGoal = self.fetchWaterGoalStrictlyForDate(date, managedObjectContext: managedObjectContext) {
      waterGoal.baseAmount = baseAmount
      waterGoal.isHotDay = isHotDay
      waterGoal.isHighActivity = isHighActivity
      if saveImmediately {
        CoreDataStack.saveContext(managedObjectContext)
      }
      return waterGoal
    } else {
      return WaterGoal.rawAddEntity(
        date: date,
        baseAmount: baseAmount,
        isHotDay: isHotDay,
        isHighActivity: isHighActivity,
        managedObjectContext: managedObjectContext,
        saveImmediately: saveImmediately)
    }
  }

  /// Adds a new water goal entity into Core Data without any checks for water goal existance for passed date
  class func rawAddEntity(#date: NSDate, baseAmount: Double, isHotDay: Bool, isHighActivity: Bool, managedObjectContext: NSManagedObjectContext, saveImmediately: Bool = true) -> WaterGoal {
    let waterGoal = LoggedActions.insertNewObjectForEntity(self, inManagedObjectContext: managedObjectContext)!
    waterGoal.date = DateHelper.dateByClearingTime(ofDate: date)
    waterGoal.baseAmount = baseAmount
    waterGoal.isHotDay = isHotDay
    waterGoal.isHighActivity = isHighActivity
    
    if saveImmediately {
      CoreDataStack.saveContext(managedObjectContext)
    }
    
    return waterGoal
  }
  
  /// Fetches a water goal that suits for a specified date (time part is skipped).
  /// Searching constains 3 sequental stages.
  /// If water goal's entity is found for a certain stage, searching is done.
  /// Stage 1: The function looks for a water goal's entity with a date equals to the specified date.
  /// Stage 2: The function looks for a water goal's entity with a date earlier than the specified date.
  /// Stage 3: The function looks for a water goal's entity with a date later than the specified date.
  public class func fetchWaterGoalForDate(date: NSDate, managedObjectContext: NSManagedObjectContext) -> WaterGoal? {
    if let waterGoal = fetchWaterGoalStrictlyForDate(date, managedObjectContext: managedObjectContext) {
      return waterGoal
    }
    
    if let waterGoal = fetchNearestWaterGoalForDateEarlierThanDate(date, managedObjectContext: managedObjectContext) {
      return waterGoal
    }
    
    if let waterGoal = fetchNearestWaterGoalForDateLaterThanDate(date, managedObjectContext: managedObjectContext) {
      return waterGoal
    }
    
    Logger.logError("Failed to fetch water goal", logDetails: [Logger.Attributes.date: date.description])
    return nil
  }
  
  /// Fetches amounts of water goals related to a specified date period (beginDate..<endDate).
  /// Water goal searching for each date uses rules decribed for stages in fetchWaterGoalForDate function.
  /// Note: If there is no water goal's entity exist for an intermediate date,
  /// only base amount of fitting water goal's entity will be used.
  /// High activity and hot day factors will be skipped in such a case.
  public class func fetchWaterGoalAmounts(beginDate beginDateRaw: NSDate, endDate endDateRaw: NSDate, managedObjectContext: NSManagedObjectContext) -> [Double] {
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
  public class func fetchWaterGoalAmountsGroupedByMonths(beginDate beginDateRaw: NSDate, endDate endDateRaw: NSDate, managedObjectContext: NSManagedObjectContext) -> [Double] {
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
  public class func fetchWaterGoalStrictlyForDate(date: NSDate, managedObjectContext: NSManagedObjectContext) -> WaterGoal? {
    let pureDate = DateHelper.dateByClearingTime(ofDate: date)
    let predicate = NSPredicate(format: "date = %@", argumentArray: [pureDate])
    return CoreDataHelper.fetchManagedObject(managedObjectContext: managedObjectContext, predicate: predicate)
  }
  
  private class func findWaterGoalForDate(currentDay: NSDate, waterGoals: [WaterGoal], managedObjectContext: NSManagedObjectContext, inout waterGoalIndex: Int, inout earlierWaterGoal: WaterGoal?, inout laterWaterGoal: WaterGoal?) -> Double {
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
        Logger.logError(Logger.Messages.logicalError)
        earlierWaterGoal = waterGoal
      }
    }
    
    if amount == nil {
      if let earlierWaterGoal = earlierWaterGoal {
        amount = earlierWaterGoal.baseAmount
      } else if let laterWaterGoal = laterWaterGoal {
        amount = laterWaterGoal.baseAmount
      } else { // unreal case
        Logger.logError(Logger.Messages.logicalError)
        amount = Settings.sharedInstance.userDailyWaterIntake.value
      }
    }

    return amount
  }
  
  private class func fetchNearestWaterGoalForDateEarlierThanDate(date: NSDate, managedObjectContext: NSManagedObjectContext) -> WaterGoal? {
    let pureDate = DateHelper.dateByClearingTime(ofDate: date)
    let predicate = NSPredicate(format: "date < %@", argumentArray: [pureDate])
    let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
    return CoreDataHelper.fetchManagedObject(managedObjectContext: managedObjectContext, predicate: predicate, sortDescriptors: [sortDescriptor])
  }
  
  private class func fetchNearestWaterGoalForDateLaterThanDate(date: NSDate, managedObjectContext: NSManagedObjectContext) -> WaterGoal? {
    let pureDate = DateHelper.dateByClearingTime(ofDate: date)
    let predicate = NSPredicate(format: "date >= %@", argumentArray: [pureDate])
    let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
    return CoreDataHelper.fetchManagedObject(managedObjectContext: managedObjectContext, predicate: predicate, sortDescriptors: [sortDescriptor])
  }
  
  private class func fetchWaterGoalsForDateInterval(#beginDate: NSDate, endDate: NSDate, managedObjectContext: NSManagedObjectContext) -> [WaterGoal] {
    let predicate = NSPredicate(format: "(date >= %@) AND (date < %@)", argumentArray: [beginDate, endDate])
    let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
    return CoreDataHelper.fetchManagedObjects(managedObjectContext: managedObjectContext, predicate: predicate, sortDescriptors: [sortDescriptor])
  }
  
}
