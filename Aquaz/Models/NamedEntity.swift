//
//  NamedEntity.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 08.10.14.
//  Copyright © 2014 Sergey Balyakin. All rights reserved.
//

import CoreData

protocol NamedEntity: class {
  
  static var entityName: String { get }
  
  associatedtype EntityType: NSFetchRequestResult
  
}

extension NamedEntity {
  
  static func createFetchRequest() -> NSFetchRequest<EntityType> {
    return NSFetchRequest<EntityType>(entityName: entityName)
  }
  
  static func insertNewObject(inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> EntityType? {
    let entity = NSEntityDescription.insertNewObject(forEntityName: entityName, into: managedObjectContext) as? EntityType
    Logger.logSevere(entity != nil, Logger.Messages.failedToInsertNewObjectForEntity, logDetails: [Logger.Attributes.entity: entityName])
    return entity
  }
  
  static func entityDescription(inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
    let entityDescription = NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
    Logger.logSevere(entityDescription != nil, Logger.Messages.failedToCreateEntityDescription, logDetails: [Logger.Attributes.entity: entityName])
    return entityDescription
  }
  
  /// Fetches managed objects from Core Data taking into account specified predicate and sort descriptors
  static func fetchManagedObjects(managedObjectContext: NSManagedObjectContext, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, fetchLimit: Int? = nil) -> [EntityType] {
    let fetchRequest = createFetchRequest()
    fetchRequest.entity = entityDescription(inManagedObjectContext: managedObjectContext)
    fetchRequest.sortDescriptors = sortDescriptors
    fetchRequest.predicate = predicate
    fetchRequest.fetchLimit = fetchLimit ?? 0
    
    do {
      return try managedObjectContext.fetch(fetchRequest)
    } catch let error as NSError {
      Logger.logError(Logger.Messages.failedToExecuteFetchRequest, error: error)
      return []
    }
  }
  
  /// Fetches a managed object from Core Data taking into account specified predicate and sort descriptors
  static func fetchManagedObject(managedObjectContext: NSManagedObjectContext, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> EntityType? {
    let entities = fetchManagedObjects(managedObjectContext: managedObjectContext, predicate: predicate, sortDescriptors: sortDescriptors, fetchLimit: 1)
    return entities.first
  }
  
}
