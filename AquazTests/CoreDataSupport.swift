//
//  CoreDataSupport.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 12.02.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import XCTest
import CoreData
@testable import Aquaz

class CoreDataSupport {
  
  static let sharedInstance = CoreDataSupport()
  
  let managedObjectContext: NSManagedObjectContext
  
  private init() {
    Logger.setup(logLevel: .None, assertLevel: .None, consoleLevel: .Warning, showLogLevel: true, showFileNames: true, showLineNumbers: true, showFunctionNames: true)
    
    // Create managed object context
    let model = NSManagedObjectModel.mergedModelFromBundles([NSBundle.mainBundle()])
    XCTAssert(model != nil, "Failed to create managed object model")
    
    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model!)
    let store = try? coordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
    XCTAssert(store != nil, "Failed to create persistent store")
    
    managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = coordinator

    // Pre-populate core data
    managedObjectContext.performBlockAndWait {
      CoreDataPrePopulation.prePopulateCoreData(managedObjectContext: self.managedObjectContext, saveContext: true)
    }
  }
  
}