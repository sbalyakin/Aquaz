//
//  ModelHelpers.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 08.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData

public class ModelHelper {

  /// Fetches managed objects from Core Data taking into account specified predicate and sort descriptors
  public class func fetchManagedObjects<EntityType: NSManagedObject where EntityType: NamedEntity>(#managedObjectContext: NSManagedObjectContext?, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, limit: Int? = nil) -> [EntityType] {
    if let managedObjectContext = managedObjectContext, let entityDescription = LoggedActions.entityDescriptionForEntity(EntityType.self, inManagedObjectContext: managedObjectContext) {
      let fetchRequest = NSFetchRequest()
      fetchRequest.entity = entityDescription
      fetchRequest.sortDescriptors = sortDescriptors
      fetchRequest.predicate = predicate
      if let fetchLimit = limit {
        fetchRequest.fetchLimit = fetchLimit
      }
      
      var error: NSError?
      if let fetchResults = managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as? [EntityType] {
        return fetchResults
      } else {
        Logger.logError(Logger.Messages.failedToExecuteFetchRequest, error: error)
        return []
      }
    }
    
    assert(false)
    return []
  }
  
  /// Fetches a managed object from Core Data taking into account specified predicate and sort descriptors
  public class func fetchManagedObject<EntityType: NSManagedObject where EntityType: NamedEntity>
    (#managedObjectContext: NSManagedObjectContext?, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> EntityType? {
    let entities: [EntityType] = fetchManagedObjects(managedObjectContext: managedObjectContext, predicate: predicate, sortDescriptors: sortDescriptors, limit: 1)
    return entities.first
  }
  
  // Hide initializer, clients should use only class function of the class
  private init() {
  }
  
}