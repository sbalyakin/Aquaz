//
//  CoreDataHelpers.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 08.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData

class CoreDataHelper {

  /// Fetches managed objects from Core Data taking into account specified predicate and sort descriptors
  class func fetchManagedObjects<EntityType: NSManagedObject where EntityType: NamedEntity>(managedObjectContext managedObjectContext: NSManagedObjectContext, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, fetchLimit: Int? = nil) -> [EntityType] {
    let fetchRequest = NSFetchRequest()
    fetchRequest.entity = LoggedActions.entityDescriptionForEntity(EntityType.self, inManagedObjectContext: managedObjectContext)
    fetchRequest.sortDescriptors = sortDescriptors
    fetchRequest.predicate = predicate
    fetchRequest.fetchLimit = fetchLimit ?? 0
    
    do {
      if let fetchResults = try managedObjectContext.executeFetchRequest(fetchRequest) as? [EntityType] {
        return fetchResults
      } else {
        return []
      }
    } catch let error as NSError {
      Logger.logError(Logger.Messages.failedToExecuteFetchRequest, error: error)
      return []
    }
  }
  
  /// Fetches a managed object from Core Data taking into account specified predicate and sort descriptors
  class func fetchManagedObject<EntityType: NSManagedObject where EntityType: NamedEntity>
    (managedObjectContext managedObjectContext: NSManagedObjectContext, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> EntityType? {
    let entities: [EntityType] = fetchManagedObjects(managedObjectContext: managedObjectContext, predicate: predicate, sortDescriptors: sortDescriptors, fetchLimit: 1)
    return entities.first
  }
  
  // Hide initializer, clients should use only class function of the class
  private init() {
  }
  
}