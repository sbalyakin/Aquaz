//
//  WaterGoal.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 06.10.14.
//  Copyright © 2014 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData

@objc(WaterGoal)
class WaterGoal: CodingManagedObject, NamedEntity {
  
  typealias EntityType = WaterGoal

  static var entityName = "WaterGoal"

  /// Date of water goal
  @NSManaged var date: Date
  
  /// Base water goal measured in millilitres
  @NSManaged var baseAmount: Double
  
  /// Is current date hot day? If so water goal will be increased according to corresponding setting.
  @NSManaged var isHotDay: Bool

  /// Is there high activity for current day? If so water goal will be increased according to corresponding setting.
  @NSManaged var isHighActivity: Bool
  
  var amount: Double {
    return baseAmount * (1 + hotDayFactor + highActivityFactor)
  }
  
  var hotDayFactor: Double {
    return isHotDay ? Settings.sharedInstance.generalHotDayExtraFactor.value : 0
  }
  
  var highActivityFactor: Double {
    return isHighActivity ? Settings.sharedInstance.generalHighActivityExtraFactor.value : 0
  }

  /// Adds a new water goal entity into Core Data. If a water goal with passed date is already exist, it will be returned as a result.
  class func addEntity(date: Date, baseAmount: Double, isHotDay: Bool, isHighActivity: Bool, managedObjectContext: NSManagedObjectContext, saveImmediately: Bool = true) -> WaterGoal {
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
  class func rawAddEntity(date: Date, baseAmount: Double, isHotDay: Bool, isHighActivity: Bool, managedObjectContext: NSManagedObjectContext, saveImmediately: Bool = true) -> WaterGoal {
    let waterGoal = insertNewObject(inManagedObjectContext: managedObjectContext)!
    waterGoal.date = DateHelper.startOfDay(date)
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
  class func fetchWaterGoalForDate(_ date: Date, managedObjectContext: NSManagedObjectContext) -> WaterGoal? {
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
  class func fetchWaterGoalAmounts(beginDate beginDateRaw: Date, endDate endDateRaw: Date, managedObjectContext: NSManagedObjectContext) -> [Double] {
    let beginDate = DateHelper.startOfDay(beginDateRaw)
    let endDate = DateHelper.startOfDay(endDateRaw)

    let waterGoals = fetchWaterGoalsForDateInterval(beginDate: beginDate, endDate: endDate, managedObjectContext: managedObjectContext)
    var earlierWaterGoal = fetchNearestWaterGoalForDateEarlierThanDate(beginDate, managedObjectContext: managedObjectContext)
    var laterWaterGoal = fetchNearestWaterGoalForDateLaterThanDate(endDate, managedObjectContext: managedObjectContext)
    
    var waterGoalAmounts: [Double] = []
    var waterGoalIndex = 0
    
    var currentDay = beginDate
    
    while currentDay.isEarlierThan(endDate) {
      let waterGoalAmount = findWaterGoalForDate(currentDay,
        waterGoals: waterGoals,
        managedObjectContext: managedObjectContext,
        waterGoalIndex: &waterGoalIndex,
        earlierWaterGoal: &earlierWaterGoal,
        laterWaterGoal: &laterWaterGoal)
      
      waterGoalAmounts.append(waterGoalAmount)
      
      currentDay = DateHelper.nextDayFrom(currentDay)
    }
    
    return waterGoalAmounts
  }
  
  /// Fetches average amounts of water goals related to a specified date period (beginDate..<endDate) grouped by months.
  /// Water goal searching for each date uses rules decribed for stages in fetchWaterGoalForDate function.
  /// Note: If there is no water goal's entity exist for an intermediate date,
  /// only base amount of fitting water goal's entity will be used.
  /// High activity and hot day factors will be skipped in such a case.
  class func fetchWaterGoalAmountsGroupedByMonths(beginDate beginDateRaw: Date, endDate endDateRaw: Date, managedObjectContext: NSManagedObjectContext) -> [Double] {
    let beginDate = DateHelper.startOfDay(beginDateRaw)
    let endDate = DateHelper.startOfDay(endDateRaw)
    
    let waterGoals = fetchWaterGoalsForDateInterval(beginDate: beginDate, endDate: endDate, managedObjectContext: managedObjectContext)
    var earlierWaterGoal = fetchNearestWaterGoalForDateEarlierThanDate(beginDate, managedObjectContext: managedObjectContext)
    var laterWaterGoal = fetchNearestWaterGoalForDateLaterThanDate(endDate, managedObjectContext: managedObjectContext)

    let calendar = Calendar.current

    var waterGoalAmounts: [Double] = []
    var waterGoalIndex = 0
    var daysInMonth: Int!
    var processedDaysCount = 0
    var overallWaterGoal: Double = 0

    let beginDayComponents = calendar.dateComponents([.day], from: beginDate)
    var currentDayIndex = beginDayComponents.day!

    var currentDay = beginDate
    
    while currentDay.isEarlierThan(endDate) {
      if daysInMonth == nil {
        daysInMonth = DateHelper.daysInMonth(date: currentDay)
      }

      let waterGoalAmount = findWaterGoalForDate(currentDay,
        waterGoals: waterGoals,
        managedObjectContext: managedObjectContext,
        waterGoalIndex: &waterGoalIndex,
        earlierWaterGoal: &earlierWaterGoal,
        laterWaterGoal: &laterWaterGoal)

      overallWaterGoal += waterGoalAmount
      processedDaysCount += 1
      currentDayIndex += 1
      
      if currentDayIndex > daysInMonth {
        let averageWaterGoal = overallWaterGoal / Double(processedDaysCount)
        waterGoalAmounts.append(averageWaterGoal)

        overallWaterGoal = 0
        currentDayIndex = 1
        processedDaysCount = 0
        daysInMonth = nil
      }
      
      currentDay = DateHelper.nextDayFrom(currentDay)
    }
    
    if processedDaysCount > 0 {
      let averageWaterGoal = overallWaterGoal / Double(processedDaysCount)
      waterGoalAmounts.append(averageWaterGoal)
    }
  
    return waterGoalAmounts
  }
  
  /// Fetches water goal strictly for a specified date (time part is skipped).
  class func fetchWaterGoalStrictlyForDate(_ date: Date, managedObjectContext: NSManagedObjectContext) -> WaterGoal? {
    let pureDate = DateHelper.startOfDay(date)
    let predicate = NSPredicate(format: "date = %@", argumentArray: [pureDate])
    return fetchManagedObject(managedObjectContext: managedObjectContext, predicate: predicate)
  }
  
  fileprivate class func findWaterGoalForDate(_ currentDay: Date, waterGoals: [WaterGoal], managedObjectContext: NSManagedObjectContext, waterGoalIndex: inout Int, earlierWaterGoal: inout WaterGoal?, laterWaterGoal: inout WaterGoal?) -> Double {
    var amount: Double!
    
    // Looking for a water goal's entity for the current day
    if waterGoalIndex < waterGoals.count {
      let waterGoal = waterGoals[waterGoalIndex]
      let waterGoalDate = waterGoal.date
      
      switch currentDay.compare(waterGoalDate) {
      case .orderedSame:
        // Use computed amount (taking into account high activity etc.)
        // only for a water goal's entity strictly related to the current day
        amount = waterGoal.amount
        earlierWaterGoal = waterGoal
        waterGoalIndex += 1
        
      case .orderedAscending: // date of current water goal is later than current day
        laterWaterGoal = waterGoal
        
      case .orderedDescending: // unreal case
        Logger.logError(Logger.Messages.logicalError, logDetails: ["currentDay": currentDay.description, "waterGoalDate": waterGoalDate.description])
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
  
  fileprivate class func fetchNearestWaterGoalForDateEarlierThanDate(_ date: Date, managedObjectContext: NSManagedObjectContext) -> WaterGoal? {
    let pureDate = DateHelper.startOfDay(date)
    let predicate = NSPredicate(format: "date < %@", argumentArray: [pureDate])
    let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
    return fetchManagedObject(managedObjectContext: managedObjectContext, predicate: predicate, sortDescriptors: [sortDescriptor])
  }
  
  fileprivate class func fetchNearestWaterGoalForDateLaterThanDate(_ date: Date, managedObjectContext: NSManagedObjectContext) -> WaterGoal? {
    let pureDate = DateHelper.startOfDay(date)
    let predicate = NSPredicate(format: "date >= %@", argumentArray: [pureDate])
    let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
    return fetchManagedObject(managedObjectContext: managedObjectContext, predicate: predicate, sortDescriptors: [sortDescriptor])
  }
  
  fileprivate class func fetchWaterGoalsForDateInterval(beginDate: Date, endDate: Date, managedObjectContext: NSManagedObjectContext) -> [WaterGoal] {
    let predicate = NSPredicate(format: "(date >= %@) AND (date < %@)", argumentArray: [beginDate, endDate])
    let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
    return fetchManagedObjects(managedObjectContext: managedObjectContext, predicate: predicate, sortDescriptors: [sortDescriptor])
  }
  
}
