//
//  CoreDataSupport.swift
//  Aquaz
//
//  Created by Admin on 12.02.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import CoreData
import Aquaz

class CoreDataSupport {
  
  static let sharedInstance = CoreDataSupport()
  
  let managedObjectContext: NSManagedObjectContext
  
  private init() {
    // Create managed object context
    let model = NSManagedObjectModel.mergedModelFromBundles(nil)
    assert(model != nil, "Failed to create managed object model")
    
    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model!)
    let store = try? coordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
    assert(store != nil, "Failed to create persistent store")
    
    managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = coordinator

    // Pre-populate core data
    CoreDataPrePopulation.prePopulateCoreData(managedObjectContext: managedObjectContext)
  }
  
}