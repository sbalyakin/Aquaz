//
//  CoreDataStack.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 06.04.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack: NSObject {

  static let sharedInstance = CoreDataStack()
  
  override init() {
    super.init()
    
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "contextDidSaveContext:",
      name: NSManagedObjectContextDidSaveNotification,
      object: nil)
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  // MARK: - Notifications
  
  func contextDidSaveContext(notification: NSNotification) {
    if mainContextIsInitialized && notification.object !== mainContext {
      mainContext.performBlock {
        self.mainContext.mergeChangesFromContextDidSaveNotification(notification)
        NSNotificationCenter.defaultCenter().postNotificationName(GlobalConstants.notificationManagedObjectContextWasMerged, object: self.mainContext)
      }
    }
    
    if privateContextIsInitialized && notification.object !== privateContext {
      privateContext.performBlock {
        self.privateContext.mergeChangesFromContextDidSaveNotification(notification)
        NSNotificationCenter.defaultCenter().postNotificationName(GlobalConstants.notificationManagedObjectContextWasMerged, object: self.privateContext)
      }
    }
  }
  

  // MARK: - Instance variables

  lazy var containerURL: NSURL = {
    return NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(GlobalConstants.appGroupName)!
  }()

  lazy var managedObjectModel: NSManagedObjectModel = {
    let modelURL = NSBundle.mainBundle().URLForResource("Aquaz", withExtension: "momd")!
    return NSManagedObjectModel(contentsOfURL: modelURL)!
  }()
  
  lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
    let url = self.containerURL.URLByAppendingPathComponent("Aquaz.sqlite")

    let store: NSPersistentStore?
    do {
      store = try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
    } catch var error as NSError {
      var dict: [NSObject: AnyObject] = [:]
      dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
      dict[NSLocalizedFailureReasonErrorKey] = "There was an error creating or loading the application's saved data."
      dict[NSUnderlyingErrorKey] = error
      error = NSError(domain: "com.devmanifest.Aquaz", code: 9999, userInfo: dict)
      Logger.logError("Core Data initialization error", error: error)
      fatalError()
    } catch {
      Logger.logError("Core Data initialization error")
      fatalError()
    }
    
    return coordinator
  }()

  func saveAllContexts() {
    if mainContextIsInitialized {
      CoreDataStack.saveContext(mainContext)
    }

    if privateContextIsInitialized {
      CoreDataStack.saveContext(privateContext)
    }
  }
  
  func mergeAllContextsWithNotification(notification: NSNotification) {
    if mainContextIsInitialized && notification.object !== mainContext {
      mainContext.performBlock {
        self.mainContext.mergeChangesFromContextDidSaveNotification(notification)
        NSNotificationCenter.defaultCenter().postNotificationName(GlobalConstants.notificationManagedObjectContextWasMerged, object: self.mainContext)
      }
    }
    
    if privateContextIsInitialized && notification.object !== privateContext {
      privateContext.performBlock {
        self.privateContext.mergeChangesFromContextDidSaveNotification(notification)
        NSNotificationCenter.defaultCenter().postNotificationName(GlobalConstants.notificationManagedObjectContextWasMerged, object: self.privateContext)
      }
    }
  }
  
  private var mainContextIsInitialized = false
  private var privateContextIsInitialized = false
  
  /// Managed object context using the main queue
  lazy var mainContext: NSManagedObjectContext = {
    let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    context.persistentStoreCoordinator = self.persistentStoreCoordinator
    self.mainContextIsInitialized = true
    return context
  }()

  /// Managed object context using a private queue
  lazy var privateContext: NSManagedObjectContext = {
    let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
    context.persistentStoreCoordinator = self.persistentStoreCoordinator
    self.privateContextIsInitialized = true
    return context
  }()

  // MARK: - Core Data Saving support
  
  class func saveContext(managedObjectContext: NSManagedObjectContext) {
    if !managedObjectContext.hasChanges {
      return
    }
    
    managedObjectContext.performBlock {
      do {
        try managedObjectContext.save()
      } catch let error as NSError {
        Logger.logError(Logger.Messages.failedToSaveManagedObjectContext, error: error)
      } catch {
        Logger.logError(Logger.Messages.failedToSaveManagedObjectContext)
        fatalError()
      }
    }
  }
  
  class func saveAllContexts() {
    sharedInstance.saveAllContexts()
  }
  
  class func mergeAllContextsWithNotification(notification: NSNotification) {
    sharedInstance.mergeAllContextsWithNotification(notification)
  }
  
  // MARK: - Convenient accessors to the shared instance's stuff
  
  static var managedObjectModel: NSManagedObjectModel { return sharedInstance.managedObjectModel }
  static var persistentStoreCoordinator: NSPersistentStoreCoordinator { return sharedInstance.persistentStoreCoordinator }
  static var mainContext: NSManagedObjectContext { return sharedInstance.mainContext }
  static var privateContext: NSManagedObjectContext { return sharedInstance.privateContext }

}
