//
//  ModelHelpers.swift
//  Water Me
//
//  Created by Sergey Balyakin on 08.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import CoreData

class ModelHelper {

  class var sharedInstance: ModelHelper {
    struct Instance {
      static let instance = ModelHelper()
    }

    return Instance.instance
  }

  /// Fetches managed objects from Core Data taking into account specified predicate and sort descriptors
  func fetchManagedObjects<EntityType: NSManagedObject where EntityType: NamedEntity>
    (predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, limit: Int? = nil) -> [EntityType]? {
    let entityDescription = NSEntityDescription.entityForName(EntityType.getEntityName(), inManagedObjectContext: managedObjectContext)
    let fetchRequest = NSFetchRequest()
    fetchRequest.entity = entityDescription
    fetchRequest.sortDescriptors = sortDescriptors
    fetchRequest.predicate = predicate
    if let fetchLimit = limit {
      fetchRequest.fetchLimit = fetchLimit
    }
    
    var error: NSError? = nil
    let fetchResults = managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as [EntityType]?
    
    if fetchResults == nil {
      NSLog("executeFetchRequest failed for entity \"\(EntityType.getEntityName())\" with error: \(error!.localizedDescription)")
    }
    
    return fetchResults
  }
  
  /// Fetches a managed object from Core Data taking into account specified predicate and sort descriptors
  func fetchManagedObject<EntityType: NSManagedObject where EntityType: NamedEntity>
    (predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> EntityType? {
    let entities: [EntityType]? = fetchManagedObjects(predicate: predicate, sortDescriptors: sortDescriptors, limit: 1)
    if let fetchedEntities = entities {
      return fetchedEntities.first
    }
    return nil
  }
  
  // computeDrinkAmountsForInterval
  
  /// Computes amount of all drinked beverages grouped by drinks from start to end dates inclusive
  func computeDrinkAmountsForDateInterval(#startDate: NSDate, endDate: NSDate) -> [Drink: Double]? {
    // Fetch all consumptions for the specified date interval
    let predicate = NSPredicate(format: "(date >= %@) AND (date <= %@)", argumentArray: [startDate, endDate])
    let rawConsumptions: [Consumption]? = fetchManagedObjects(predicate: predicate)

    if rawConsumptions == nil {
      return nil
    }

    // Group consumptions by drinks
    var consumptionsMap: [Drink: Double] = [:]
    
    for consumption in rawConsumptions! {
      if let amount = consumptionsMap[consumption.drink] {
        consumptionsMap[consumption.drink] = amount + Double(consumption.amount)
      } else {
        consumptionsMap[consumption.drink] = Double(consumption.amount)
      }
    }
    
    return consumptionsMap
  }

  /// Computes amount of all drinked beverages grouped by drinks for whole day of the specified date
  func computeDrinkAmountsForDay(date: NSDate) -> [Drink: Double]? {
    // Determine start and end of specified day
    let calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)!
    NSCalendarUnit.DayCalendarUnit
    var dateComponents = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay, fromDate: date)
    dateComponents.hour = 0
    dateComponents.minute = 0
    dateComponents.second = 0
    let startDate = calendar.dateFromComponents(dateComponents)!
    dateComponents.hour = 23
    dateComponents.minute = 59
    dateComponents.second = 59
    let endDate = calendar.dateFromComponents(dateComponents)!
    
    // Fetch all consumptions for the day
    return computeDrinkAmountsForDateInterval(startDate: startDate, endDate: endDate)
  }
  
  let managedObjectContext: NSManagedObjectContext!

  // Hide initializer, clients should use sharedInstance property to get instance of ModelHelper
  private init() {
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    managedObjectContext = appDelegate.managedObjectContext!
  }
  
}