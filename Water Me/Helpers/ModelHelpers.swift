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

func fetchManagedObjects<EntityType: NSManagedObject where EntityType: NamedEntity>(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, managedObjectContext: NSManagedObjectContext) -> [EntityType]? {
  let entityDescription = NSEntityDescription.entityForName(EntityType.getEntityName(), inManagedObjectContext: managedObjectContext)
  let fetchRequest = NSFetchRequest()
  fetchRequest.entity = entityDescription
  fetchRequest.sortDescriptors = sortDescriptors
  fetchRequest.predicate = predicate
  
  var error: NSError? = nil
  let fetchResults = managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as [EntityType]?
  
  if fetchResults == nil {
    NSLog("executeFetchRequest failed for entity \"\(EntityType.getEntityName())\" with error: \(error!.localizedDescription)")
  }
  
  return fetchResults
}
