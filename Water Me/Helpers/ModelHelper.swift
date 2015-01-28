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
    (predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, limit: Int? = nil) -> [EntityType] {
    let entityDescription = NSEntityDescription.entityForName(EntityType.getEntityName(), inManagedObjectContext: managedObjectContext)
    let fetchRequest = NSFetchRequest()
    fetchRequest.entity = entityDescription
    fetchRequest.sortDescriptors = sortDescriptors
    fetchRequest.predicate = predicate
    if let fetchLimit = limit {
      fetchRequest.fetchLimit = fetchLimit
    }
    
    var error: NSError?
    let fetchResults = managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as [EntityType]?
    
    if fetchResults == nil {
      NSLog("fetchManagedObjects failed for entity \"\(EntityType.getEntityName())\" with error: \(error?.localizedDescription ?? String())")
      return []
    }
    
    return fetchResults!
  }
  
  /// Fetches a managed object from Core Data taking into account specified predicate and sort descriptors
  func fetchManagedObject<EntityType: NSManagedObject where EntityType: NamedEntity>
    (predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> EntityType? {
    let entities: [EntityType] = fetchManagedObjects(predicate: predicate, sortDescriptors: sortDescriptors, limit: 1)
    return entities.first
  }
  
  func save() {
    var error: NSError?
    if !managedObjectContext.save(&error) {
      assert(false, "Failed to save managed object context. Error: \(error?.localizedDescription ?? String())")
    }
  }
  
  let managedObjectContext: NSManagedObjectContext!

  // Hide initializer, clients should use sharedInstance property to get instance of ModelHelper
  private init() {
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    managedObjectContext = appDelegate.managedObjectContext!
  }
  
}