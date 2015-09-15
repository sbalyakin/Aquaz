//
//  Intake.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 07.10.14.
//  Copyright © 2014 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData

@objc(Intake)
class Intake: CodingManagedObject, NamedEntity {
  
  static var entityName = "Intake"

  /// Amount of intake in millilitres
  @NSManaged var amount: Double
  
  /// Date of intake
  @NSManaged var date: NSDate
  
  /// What drink was consumed
  @NSManaged var drink: Drink
  
  /// Water balance of the intake based on hydration and dehydration factors of the corresponding drink
  var waterBalance: Double {
    return amount * (drink.hydrationFactor - drink.dehydrationFactor)
  }

  /// Hydration amount of the intake based on a hydration factor of the corresponding drink
  var hydrationAmount: Double {
    return amount * drink.hydrationFactor
  }

  /// Dehydration amount of the intake based on a dehydration factor of the corresponding drink
  var dehydrationAmount: Double {
    return amount * drink.dehydrationFactor
  }

  /// Adds a new intake's entity into Core Data
  class func addEntity(drink drink: Drink, amount: Double, date: NSDate, managedObjectContext: NSManagedObjectContext, saveImmediately: Bool = true) -> Intake? {
    if let intake = LoggedActions.insertNewObjectForEntity(self, inManagedObjectContext: managedObjectContext) {
      intake.amount = amount
      intake.drink = drink
      intake.date = date

      if saveImmediately {
        CoreDataStack.saveContext(managedObjectContext)
      }

      return intake
    }
    
    return nil
  }

  /// Deletes the intake from Core Data
  func deleteEntity(saveImmediately saveImmediately: Bool = true) {
    if let managedObjectContext = managedObjectContext {
      managedObjectContext.deleteObject(self)
      
      if saveImmediately {
        CoreDataStack.saveContext(managedObjectContext)
      }
    } else {
      assert(false)
    }
  }
  
  /// Fetches all intakes for the specified date interval (beginDate..<endDate)
  class func fetchIntakes(beginDate beginDate: NSDate?, endDate: NSDate?, managedObjectContext: NSManagedObjectContext) -> [Intake] {
    var predicate: NSPredicate?
    
    if let beginDate = beginDate, let endDate = endDate {
      predicate = NSPredicate(format: "(date >= %@) AND (date < %@)", argumentArray: [beginDate, endDate])
    } else if let beginDate = beginDate {
      predicate = NSPredicate(format: "date >= %@", argumentArray: [beginDate])
    } else if let endDate = endDate {
      predicate = NSPredicate(format: "date < %@", argumentArray: [endDate])
    }
    
    let descriptor = NSSortDescriptor(key: "date", ascending: true)
    return CoreDataHelper.fetchManagedObjects(managedObjectContext: managedObjectContext, predicate: predicate, sortDescriptors: [descriptor])
  }

  /// Fetches all intakes for a day taken from the specified date.
  /// Start of the day is inclusively started from 0:00 + specified offset in hours.
  /// End of the day is exclusive ended with 0:00 of the next day + specified offset in hours.
  class func fetchIntakesForDay(date: NSDate, dayOffsetInHours: Int, managedObjectContext: NSManagedObjectContext) -> [Intake] {
    let beginDate = DateHelper.dateBySettingHour(dayOffsetInHours, minute: 0, second: 0, ofDate: date)
    let endDate = DateHelper.addToDate(beginDate, years: 0, months: 0, days: 1)
    return fetchIntakes(beginDate: beginDate, endDate: endDate, managedObjectContext: managedObjectContext)
  }

  /// Fetches overall hydration amounts of intakes grouped by drinks for passed date
  class func fetchHydrationAmountsGroupedByDrinksForDay(date: NSDate, dayOffsetInHours: Int, managedObjectContext: NSManagedObjectContext) -> [Drink: Double] {
    let beginDate = DateHelper.dateBySettingHour(dayOffsetInHours, minute: 0, second: 0, ofDate: date)
    let endDate = DateHelper.addToDate(beginDate, years: 0, months: 0, days: 1)
    let predicate = NSPredicate(format: "(date >= %@) AND (date < %@)", argumentArray: [beginDate, endDate])
    
    let expression = NSExpression(forFunction: "sum:", arguments: [NSExpression(forKeyPath: "amount")])
    
    let overallWaterAmount = NSExpressionDescription()
    overallWaterAmount.expression = expression
    overallWaterAmount.expressionResultType = .DoubleAttributeType
    overallWaterAmount.name = "overallWaterAmount"
    
    let fetchRequest = NSFetchRequest()
    fetchRequest.entity = LoggedActions.entityDescriptionForEntity(Intake.self, inManagedObjectContext: managedObjectContext)
    fetchRequest.predicate = predicate
    fetchRequest.propertiesToFetch = ["drink.index", overallWaterAmount]
    fetchRequest.propertiesToGroupBy = ["drink.index"]
    fetchRequest.resultType = .DictionaryResultType
    
    let drinks = Drink.fetchAllDrinksIndexed(managedObjectContext: managedObjectContext)
    
    do {
      let fetchResults = try managedObjectContext.executeFetchRequest(fetchRequest)
      var result = [Drink: Double]()
      for record in fetchResults as! [NSDictionary] {
        let drinkIndex = record["drink.index"] as! NSNumber
        let drink = drinks[drinkIndex.integerValue]!
        let amount = (record[overallWaterAmount.name] as! Double) * drink.hydrationFactor
        result[drink] = amount
      }
      return result
    } catch let error as NSError {
      Logger.logError(Logger.Messages.failedToExecuteFetchRequest, error: error)
      return [:]
    }
  }

  /// Fetches total dehydration amount based on intakes of a passed day
  class func fetchTotalDehydrationAmountForDay(date: NSDate, dayOffsetInHours: Int, managedObjectContext: NSManagedObjectContext) -> Double {
    let beginDate = DateHelper.dateBySettingHour(dayOffsetInHours, minute: 0, second: 0, ofDate: date)
    let endDate = DateHelper.addToDate(beginDate, years: 0, months: 0, days: 1)
    let predicate = NSPredicate(format: "(date >= %@) AND (date < %@) AND (drink.dehydrationFactor != 0)", argumentArray: [beginDate, endDate])
    
    let expression = NSExpression(forFunction: "sum:", arguments: [NSExpression(forKeyPath: "amount")])
    
    let overallWaterAmount = NSExpressionDescription()
    overallWaterAmount.expression = expression
    overallWaterAmount.expressionResultType = .DoubleAttributeType
    overallWaterAmount.name = "overallWaterAmount"
    
    let fetchRequest = NSFetchRequest()
    fetchRequest.entity = LoggedActions.entityDescriptionForEntity(Intake.self, inManagedObjectContext: managedObjectContext)
    fetchRequest.predicate = predicate
    fetchRequest.propertiesToFetch = ["drink.index", overallWaterAmount]
    fetchRequest.propertiesToGroupBy = ["drink.index"]
    fetchRequest.resultType = .DictionaryResultType
    
    let drinks = Drink.fetchAllDrinksIndexed(managedObjectContext: managedObjectContext)

    do {
      let fetchResults = try managedObjectContext.executeFetchRequest(fetchRequest)
      var totalDehydration: Double = 0
      
      for record in fetchResults as! [NSDictionary] {
        let drinkIndex = record["drink.index"] as! NSNumber
        let drink = drinks[drinkIndex.integerValue]!
        let dehydration = (record[overallWaterAmount.name] as! Double) * drink.dehydrationFactor
        totalDehydration = dehydration
      }
      
      return totalDehydration
    } catch let error as NSError {
      Logger.logError(Logger.Messages.failedToExecuteFetchRequest, error: error)
      return 0
    }
  }
  
  enum GroupingCalendarUnit {
    case Day
    case Month
    
    func getCalendarUnit() -> NSCalendarUnit {
      switch self {
      case .Day  : return .Day
      case .Month: return .Month
      }
    }
  }
  
  enum AggregateFunction {
    case Average
    case Summary
  }
  
  /// Fetches amounts of intakes (return both hydration and dehydration amounts)
  /// for passed time period (beginDate..<endDate) grouping results by passed calendar unit.
  /// It's also possible to specify aggregate function for grouping.
  /// Note: Average function calculates an average value taking into account ALL days in a specified calendar unit,
  /// not only days with intakes.
  class func fetchIntakeAmountPartsGroupedBy(
    groupingUnit: GroupingCalendarUnit,
    beginDate beginDateRaw: NSDate,
    endDate endDateRaw: NSDate,
    dayOffsetInHours: Int,
    aggregateFunction aggregateFunctionRaw: AggregateFunction,
    managedObjectContext: NSManagedObjectContext) -> [(hydration: Double, dehydration: Double)]
  {
    let beginDate = DateHelper.dateBySettingHour(dayOffsetInHours, minute: 0, second: 0, ofDate: beginDateRaw)
    let endDate = DateHelper.dateBySettingHour(dayOffsetInHours, minute: 0, second: 0, ofDate: endDateRaw)
    
    if endDate.isEarlierThan(beginDate) {
      return []
    }
    
    let intakes = fetchIntakes(beginDate: beginDate, endDate: endDate, managedObjectContext: managedObjectContext)

    // It's just an optimization. An algorithm below already groups intakes by days, so calculating the average is useless
    let aggregateFunction: AggregateFunction = (groupingUnit == .Day) ? .Summary : aggregateFunctionRaw
    
    let deltaMonths = groupingUnit == .Month ? 1 : 0
    let deltaDays   = groupingUnit == .Day   ? 1 : 0
    
    let calendarUnit = groupingUnit.getCalendarUnit()
    let calendar = NSCalendar.currentCalendar()
    
    var groupedAmountParts: [(hydration: Double, dehydration: Double)] = []
    var nextDate: NSDate!
    var intakeIndex = 0
    var daysInCalendarUnit = 0
    
    let nextDateComponents = calendar.components([.Year, .Month, .Day, .TimeZone, .Calendar], fromDate: beginDate)
    nextDateComponents.hour = 0
    nextDateComponents.minute = 0
    nextDateComponents.second = 0
    
    while true {
      if aggregateFunction == .Average {
        let currentDate = nextDate ?? beginDate
        daysInCalendarUnit = calendar.rangeOfUnit(.Day, inUnit: calendarUnit, forDate: currentDate).length
      }

      nextDateComponents.month += deltaMonths
      nextDateComponents.day += deltaDays
      nextDate = calendar.dateFromComponents(nextDateComponents)
      
      if nextDate.isLaterThan(endDate) {
        break
      }

      var hydrationAmountForUnit: Double = 0
      var dehydrationAmountForUnit: Double = 0

      for ; intakeIndex < intakes.count; intakeIndex++ {
        let intake = intakes[intakeIndex]
        
        if !intake.date.isEarlierThan(nextDate) {
          break
        }

        hydrationAmountForUnit += intake.hydrationAmount
        dehydrationAmountForUnit += intake.dehydrationAmount
      }
      
      if aggregateFunction == .Average {
        hydrationAmountForUnit /= Double(daysInCalendarUnit)
        dehydrationAmountForUnit /= Double(daysInCalendarUnit)
      }
      
      let amountPartsItem = (hydration: hydrationAmountForUnit, dehydration: dehydrationAmountForUnit)
      groupedAmountParts.append(amountPartsItem)
    }
    
    return groupedAmountParts
  }
  
}