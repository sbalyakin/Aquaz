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

  typealias EntityType = Intake

  /// Amount of intake in millilitres
  @NSManaged var amount: Double
  
  /// Date of intake
  @NSManaged var date: Date
  
  /// What drink was consumed
  @NSManaged var drink: Drink
  
  /// Water balance of the intake based on hydration and dehydration factors of the corresponding drink
  var waterBalance: Double {
    return amount * (drink.drinkType.hydrationFactor - drink.drinkType.dehydrationFactor)
  }

  /// Hydration amount of the intake based on a hydration factor of the corresponding drink
  var hydrationAmount: Double {
    return amount * drink.drinkType.hydrationFactor
  }

  /// Dehydration amount of the intake based on a dehydration factor of the corresponding drink
  var dehydrationAmount: Double {
    return amount * drink.drinkType.dehydrationFactor
  }

  /// Caffeine amount in milligrams of the intake based on a caffeine factor of the corresponding drink
  var caffeineAmount: Double {
    return amount * drink.drinkType.caffeineGramPerLiter
  }
  
  /// Adds a new intake's entity into Core Data
  class func addEntity(drink: Drink, amount: Double, date: Date, managedObjectContext: NSManagedObjectContext, saveImmediately: Bool = true) -> Intake? {
    if let intake = insertNewObject(inManagedObjectContext: managedObjectContext) {
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
  func deleteEntity(saveImmediately: Bool = true) {
    if let managedObjectContext = managedObjectContext {
      managedObjectContext.delete(self)
      
      if saveImmediately {
        CoreDataStack.saveContext(managedObjectContext)
      }
    } else {
      assert(false)
    }
  }
  
  /// Fetches all intakes for the specified date interval (beginDate..<endDate)
  class func fetchIntakes(beginDate: Date?, endDate: Date?, managedObjectContext: NSManagedObjectContext) -> [Intake] {
    var predicate: NSPredicate?
    
    if let beginDate = beginDate, let endDate = endDate {
      predicate = NSPredicate(format: "(date >= %@) AND (date < %@)", argumentArray: [beginDate, endDate])
    } else if let beginDate = beginDate {
      predicate = NSPredicate(format: "date >= %@", argumentArray: [beginDate])
    } else if let endDate = endDate {
      predicate = NSPredicate(format: "date < %@", argumentArray: [endDate])
    }
    
    let descriptor = NSSortDescriptor(key: "date", ascending: true)
    return fetchManagedObjects(managedObjectContext: managedObjectContext, predicate: predicate, sortDescriptors: [descriptor])
  }

  /// Fetches an intake for specified date, drinkType and amount.
  /// Used in ConnectivityProvider to prevent double intakes coming from Apple Watch by unknown reason.
  class func fetchParticularIntake(date: Date, drinkType: DrinkType, amount: Double, managedObjectContext: NSManagedObjectContext) -> Intake? {
    let predicate = NSPredicate(format: "(date == %@) AND (drink.index == %@) AND (amount == %@)", argumentArray: [date, drinkType.rawValue, amount])
    
    return fetchManagedObject(managedObjectContext: managedObjectContext, predicate: predicate)
  }

  /// Fetches all intakes for a day taken from the specified date.
  /// Start of the day is inclusively started from 0:00 + specified offset in hours.
  /// End of the day is exclusive ended with 0:00 of the next day + specified offset in hours.
  class func fetchIntakesForDay(_ date: Date, dayOffsetInHours: Int, managedObjectContext: NSManagedObjectContext) -> [Intake] {
    let beginDate = DateHelper.dateBySettingHour(dayOffsetInHours, minute: 0, second: 0, ofDate: date)
    let endDate = DateHelper.nextDayFrom(beginDate)
    return fetchIntakes(beginDate: beginDate, endDate: endDate, managedObjectContext: managedObjectContext)
  }

  /// Fetches overall hydration amounts of intakes grouped by drinks for passed date
  class func fetchHydrationAmountsGroupedByDrinksForDay(_ date: Date, dayOffsetInHours: Int, managedObjectContext: NSManagedObjectContext) -> [DrinkType: Double] {
    let beginDate = DateHelper.dateBySettingHour(dayOffsetInHours, minute: 0, second: 0, ofDate: date)
    let endDate = DateHelper.nextDayFrom(beginDate)
    let predicate = NSPredicate(format: "(date >= %@) AND (date < %@)", argumentArray: [beginDate, endDate])
    
    let expression = NSExpression(forFunction: "sum:", arguments: [NSExpression(forKeyPath: "amount")])
    
    let overallWaterAmount = NSExpressionDescription()
    overallWaterAmount.expression = expression
    overallWaterAmount.expressionResultType = .doubleAttributeType
    overallWaterAmount.name = "overallWaterAmount"
    
    let fetchRequest = NSFetchRequest<NSDictionary>()
    fetchRequest.entity = Intake.entityDescription(inManagedObjectContext: managedObjectContext)
    fetchRequest.predicate = predicate
    fetchRequest.propertiesToFetch = ["drink.index", overallWaterAmount]
    fetchRequest.propertiesToGroupBy = ["drink.index"]
    fetchRequest.resultType = .dictionaryResultType
    
    do {
      let fetchResults = try managedObjectContext.fetch(fetchRequest)
      var result = [DrinkType: Double]()
      
      for record in fetchResults {
        let drinkIndex = record["drink.index"] as! NSNumber
        let drinkType = DrinkType(rawValue: drinkIndex.intValue)!
        let amount = (record[overallWaterAmount.name] as! Double) * drinkType.hydrationFactor
        result[drinkType] = amount
      }
      return result
    } catch let error as NSError {
      Logger.logError(Logger.Messages.failedToExecuteFetchRequest, error: error)
      return [:]
    }
  }

  /// Fetches total dehydration amount based on intakes of a passed day
  class func fetchTotalDehydrationAmountForDay(_ date: Date, dayOffsetInHours: Int, managedObjectContext: NSManagedObjectContext) -> Double {
    let beginDate = DateHelper.dateBySettingHour(dayOffsetInHours, minute: 0, second: 0, ofDate: date)
    let endDate = DateHelper.nextDayFrom(beginDate)
    let predicate = NSPredicate(format: "(date >= %@) AND (date < %@) AND (drink.dehydrationFactor != 0)", argumentArray: [beginDate, endDate])
    
    let expression = NSExpression(forFunction: "sum:", arguments: [NSExpression(forKeyPath: "amount")])
    
    let overallWaterAmount = NSExpressionDescription()
    overallWaterAmount.expression = expression
    overallWaterAmount.expressionResultType = .doubleAttributeType
    overallWaterAmount.name = "overallWaterAmount"
    
    let fetchRequest = NSFetchRequest<NSDictionary>()
    fetchRequest.entity = Intake.entityDescription(inManagedObjectContext: managedObjectContext)
    fetchRequest.predicate = predicate
    fetchRequest.propertiesToFetch = ["drink.index", overallWaterAmount]
    fetchRequest.propertiesToGroupBy = ["drink.index"]
    fetchRequest.resultType = .dictionaryResultType
    
    do {
      let fetchResults = try managedObjectContext.fetch(fetchRequest)
      var totalDehydration: Double = 0
      
      for record in fetchResults {
        let drinkIndex = record["drink.index"] as! NSNumber
        let drinkType = DrinkType(rawValue: drinkIndex.intValue)!
        let dehydration = (record[overallWaterAmount.name] as! Double) * drinkType.dehydrationFactor
        totalDehydration += dehydration
      }
      
      return totalDehydration
    } catch let error as NSError {
      Logger.logError(Logger.Messages.failedToExecuteFetchRequest, error: error)
      return 0
    }
  }
  
  /// Fetches total hydration amount based on intakes of a passed day
  class func fetchTotalHydrationAmountForDay(_ date: Date, dayOffsetInHours: Int, managedObjectContext: NSManagedObjectContext) -> Double {
    let beginDate = DateHelper.dateBySettingHour(dayOffsetInHours, minute: 0, second: 0, ofDate: date)
    let endDate = DateHelper.nextDayFrom(beginDate)
    let predicate = NSPredicate(format: "(date >= %@) AND (date < %@) AND (drink.hydrationFactor != 0)", argumentArray: [beginDate, endDate])
    
    let expression = NSExpression(forFunction: "sum:", arguments: [NSExpression(forKeyPath: "amount")])
    
    let overallWaterAmount = NSExpressionDescription()
    overallWaterAmount.expression = expression
    overallWaterAmount.expressionResultType = .doubleAttributeType
    overallWaterAmount.name = "overallWaterAmount"
    
    let fetchRequest = NSFetchRequest<NSDictionary>()
    fetchRequest.entity = Intake.entityDescription(inManagedObjectContext: managedObjectContext)
    fetchRequest.predicate = predicate
    fetchRequest.propertiesToFetch = ["drink.index", overallWaterAmount]
    fetchRequest.propertiesToGroupBy = ["drink.index"]
    fetchRequest.resultType = .dictionaryResultType
    
    do {
      let fetchResults = try managedObjectContext.fetch(fetchRequest)
      var totalHydration: Double = 0
      
      for record in fetchResults {
        let drinkIndex = record["drink.index"] as! NSNumber
        let drinkType = DrinkType(rawValue: drinkIndex.intValue)!
        let hydration = (record[overallWaterAmount.name] as! Double) * drinkType.hydrationFactor
        totalHydration += hydration
      }
      
      return totalHydration
    } catch let error as NSError {
      Logger.logError(Logger.Messages.failedToExecuteFetchRequest, error: error)
      return 0
    }
  }
  
  enum GroupingCalendarUnit {
    case day
    case month
    
    func getCalendarComponent() -> Calendar.Component {
      switch self {
      case .day  : return .day
      case .month: return .month
      }
    }
  }
  
  enum AggregateFunction {
    case average
    case summary
  }
  
  /// Fetches amounts of intakes (return both hydration and dehydration amounts)
  /// for passed time period (beginDate..<endDate) grouping results by passed calendar unit.
  /// It's also possible to specify aggregate function for grouping.
  /// Note: Average function calculates an average value taking into account ALL days in a specified calendar unit,
  /// not only days with intakes.
  class func fetchIntakeAmountPartsGroupedBy(
    _ groupingUnit: GroupingCalendarUnit,
    beginDate beginDateRaw: Date,
    endDate endDateRaw: Date,
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
    let aggregateFunction: AggregateFunction = (groupingUnit == .day) ? .summary : aggregateFunctionRaw
    
    let deltaMonths = groupingUnit == .month ? 1 : 0
    let deltaDays   = groupingUnit == .day   ? 1 : 0
    
    let calendarComponent = groupingUnit.getCalendarComponent()
    let calendar = Calendar.current
    
    var groupedAmountParts: [(hydration: Double, dehydration: Double)] = []
    var nextDate: Date!
    var intakeIndex = 0
    var daysInCalendarUnit = 0
    
    var nextDateComponents = calendar.dateComponents([.year, .month, .day], from: beginDate)
    
    while true {
      if aggregateFunction == .average {
        let currentDate = nextDate ?? beginDate
        daysInCalendarUnit = Calendar.current.range(of: .day, in: calendarComponent, for: currentDate)!.count
      }

      nextDateComponents.month = nextDateComponents.month! + deltaMonths
      nextDateComponents.day = nextDateComponents.day! + deltaDays
      nextDate = calendar.date(from: nextDateComponents)
      
      if nextDate.isLaterThan(endDate) {
        break
      }

      var hydrationAmountForUnit: Double = 0
      var dehydrationAmountForUnit: Double = 0

      while intakeIndex < intakes.count {
        let intake = intakes[intakeIndex]
        
        if !intake.date.isEarlierThan(nextDate) {
          break
        }

        hydrationAmountForUnit += intake.hydrationAmount
        dehydrationAmountForUnit += intake.dehydrationAmount
        
        intakeIndex += 1
      }
      
      if aggregateFunction == .average {
        hydrationAmountForUnit /= Double(daysInCalendarUnit)
        dehydrationAmountForUnit /= Double(daysInCalendarUnit)
      }
      
      let amountPartsItem = (hydration: hydrationAmountForUnit, dehydration: dehydrationAmountForUnit)
      groupedAmountParts.append(amountPartsItem)
    }
    
    return groupedAmountParts
  }
  
}
