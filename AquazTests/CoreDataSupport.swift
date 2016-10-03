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
  
  fileprivate init() {
    Logger.setup(logLevel: .none, assertLevel: .none, consoleLevel: .warning, showLogLevel: true, showFileNames: true, showLineNumbers: true, showFunctionNames: true)
    
    // Create managed object context
    let model = NSManagedObjectModel.mergedModel(from: [Bundle.main])
    XCTAssert(model != nil, "Failed to create managed object model")
    
    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model!)
    let store = try? coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
    XCTAssert(store != nil, "Failed to create persistent store")
    
    managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = coordinator

    // Pre-populate core data
    managedObjectContext.performAndWait {
      CoreDataPrePopulation.prePopulateCoreData(managedObjectContext: self.managedObjectContext, saveContext: true)
    }
  }
  
}
