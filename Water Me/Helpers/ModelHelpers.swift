//
//  ModelHelpers.swift
//  Water Me
//
//  Created by Sergey Balyakin on 08.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import CoreData

func getDefaultManagedObjectContext() -> NSManagedObjectContext {
  let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
  return appDelegate.managedObjectContext!
}

/// Fetches managed objects from Core Data taking into account specified predicate as sortDescriptors
func fetchManagedObjects<EntityType: NSManagedObject where EntityType: NamedEntity>
(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, managedObjectContext moc: NSManagedObjectContext? = nil, limit: Int? = nil) -> [EntityType]? {
  let managedObjectContext = moc == nil ? getDefaultManagedObjectContext() : moc!
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

/// Fetches a managed object from Core Data taking into account specified predicate as sortDescriptors
func fetchManagedObject<EntityType: NSManagedObject where EntityType: NamedEntity>
(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, managedObjectContext: NSManagedObjectContext? = nil) -> EntityType? {
  let entities: [EntityType]? = fetchManagedObjects(predicate: predicate, sortDescriptors: sortDescriptors, managedObjectContext: managedObjectContext, limit: 1)
  if let fetchedEntities = entities {
    return fetchedEntities.first
  }
  return nil
}