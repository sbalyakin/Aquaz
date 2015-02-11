//
//  ModelHelpers.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 08.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class ModelHelper {

  /// Fetches managed objects from Core Data taking into account specified predicate and sort descriptors
  class func fetchManagedObjects<EntityType: NSManagedObject where EntityType: NamedEntity>(#managedObjectContext: NSManagedObjectContext?, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, limit: Int? = nil) -> [EntityType] {
    if let managedObjectContext = managedObjectContext {
      if let entityDescription = NSEntityDescription.entityForName(EntityType.entityName, inManagedObjectContext: managedObjectContext) {
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
          NSLog("fetchManagedObjects failed for entity \"\(EntityType.entityName)\" with error: \(error?.localizedDescription ?? String())")
          return []
        }
      } else {
        assert(false)
        return []
      }
    } else {
      assert(false)
      return []
    }
  }
  
  /// Fetches a managed object from Core Data taking into account specified predicate and sort descriptors
  class func fetchManagedObject<EntityType: NSManagedObject where EntityType: NamedEntity>
    (#managedObjectContext: NSManagedObjectContext?, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> EntityType? {
    let entities: [EntityType] = fetchManagedObjects(managedObjectContext: managedObjectContext, predicate: predicate, sortDescriptors: sortDescriptors, limit: 1)
    return entities.first
  }
  
  class func save(#managedObjectContext: NSManagedObjectContext?) {
    var error: NSError?
    if let managedObjectContext = managedObjectContext {
      if !managedObjectContext.save(&error) {
        assert(false, "Failed to save managed object context. Error: \(error?.localizedDescription ?? String())")
      }
    } else {
      assert(false)
    }
  }
  
  // Hide initializer, clients should use sharedInstance property to get instance of ModelHelper
  private init() {
  }
  
}