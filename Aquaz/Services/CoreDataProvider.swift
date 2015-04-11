//
//  CoreDataProvider.swift
//  Aquaz
//
//  Created by Admin on 06.04.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData

class CoreDataProvider {

  class var sharedInstance: CoreDataProvider {
    struct Static {
      static let instance = CoreDataProvider()
    }
    return Static.instance
  }
  
  private init() {
  }
  
  lazy var containerURL: NSURL = {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.devmanifest.Aquaz" in the application's documents Application Support directory.
    return NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(GlobalConstants.appGroupName)!
  }()

  lazy var managedObjectModel: NSManagedObjectModel = {
    // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
    let modelURL = NSBundle.mainBundle().URLForResource("Aquaz", withExtension: "momd")!
    return NSManagedObjectModel(contentsOfURL: modelURL)!
  }()
  
  lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
    // Create the coordinator and store
    var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
    let url = self.containerURL.URLByAppendingPathComponent("Aquaz.sqlite")
    var error: NSError?
    let failureReason = "There was an error creating or loading the application's saved data."
    if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
      coordinator = nil
      // Report any error we got.
      var dict: [NSObject: AnyObject] = [:]
      dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
      dict[NSLocalizedFailureReasonErrorKey] = failureReason
      dict[NSUnderlyingErrorKey] = error
      error = NSError(domain: "com.devmanifest.Aquaz", code: 9999, userInfo: dict)
      // Replace this with code to handle the error appropriately.
      // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      Logger.logError("Core Data initialization error", error: error)
      abort()
    }
    
    return coordinator
  }()
  
  lazy var managedObjectContext: NSManagedObjectContext? = {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
    let coordinator = self.persistentStoreCoordinator
    if coordinator == nil {
      return nil
    }
    var managedObjectContext = NSManagedObjectContext()
    managedObjectContext.persistentStoreCoordinator = coordinator
//    managedObjectContext.mergePolicy = NSMergePolicy(mergeType: NSMergePolicyType.MergeByPropertyObjectTrumpMergePolicyType)
    return managedObjectContext
  }()
  
  // MARK: - Core Data Saving support
  
  func saveContext(managedObjectContext: NSManagedObjectContext? = CoreDataProvider.sharedInstance.managedObjectContext) {
    var error: NSError?
    if let moc = managedObjectContext {
      if moc.hasChanges && !moc.save(&error) {
        Logger.logError(Logger.Messages.failedToSaveManagedObjectContext, error: error)
      }
    } else {
      assert(false)
    }
  }

}
