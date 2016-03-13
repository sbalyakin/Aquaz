//
//  CoreDataStack.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 06.04.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData
import Crashlytics

final class CoreDataStack: NSObject {

  static let sharedInstance = CoreDataStack()

  private let containerURL: NSURL
  private let managedObjectModel: NSManagedObjectModel
  private let persistentStoreCoordinator: NSPersistentStoreCoordinator
  private let mainContext: NSManagedObjectContext
  private let privateContext: NSManagedObjectContext
  private let queue: dispatch_queue_t
  
  override init() {
    if let containerURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(GlobalConstants.appGroupName) {
      self.containerURL = containerURL
    } else {
      CLSLogv("Core Data Stack initialization error: Failed to obtain the container URL", getVaList([]))
      fatalError()
    }
    
    guard let modelURL = NSBundle.mainBundle().URLForResource("Aquaz", withExtension: "momd") else {
      CLSLogv("Core Data Stack initialization error: Failed to obtain the model URL", getVaList([]))
      fatalError()
    }
    
    if let managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL) {
      self.managedObjectModel = managedObjectModel
    } else {
      CLSLogv("Core Data Stack initialization error: Failed to initialize the managed object model", getVaList([]))
      fatalError()
    }
    
    self.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
    
    self.mainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    self.mainContext.persistentStoreCoordinator = self.persistentStoreCoordinator
    
    self.privateContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
    self.privateContext.persistentStoreCoordinator = self.persistentStoreCoordinator
    
    let url = containerURL.URLByAppendingPathComponent("Aquaz.sqlite")
    
    self.queue = dispatch_queue_create("CoreDataStachSerialQueue", DISPATCH_QUEUE_SERIAL)

    super.init()

    // Add persistent store in a serial queue in order to not freeze the main UI queue
    dispatch_async(queue) {
      do {
        try self.persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
      } catch {
        CLSLogv("Core Data Stack initialization error: Failed to add the persistent store", getVaList([]))
        fatalError()
      }
    }

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
    dispatch_async(queue) {
      if notification.object !== self.mainContext {
        self.mainContext.performBlock {
          self.mainContext.mergeChangesFromContextDidSaveNotification(notification)
          NSNotificationCenter.defaultCenter().postNotificationName(GlobalConstants.notificationManagedObjectContextWasMerged, object: self.mainContext)
        }
      }
      
      if notification.object !== self.privateContext {
        self.privateContext.performBlock {
          self.privateContext.mergeChangesFromContextDidSaveNotification(notification)
          NSNotificationCenter.defaultCenter().postNotificationName(GlobalConstants.notificationManagedObjectContextWasMerged, object: self.privateContext)
        }
      }
    }
  }
  

  // MARK: - Functions

  private func printStack(stack: [String], depth: Int = -1) {
    if depth == -1 {
      for line in stack {
        print(line)
      }
    } else {
      for i in 0..<depth {
        print(stack[i])
      }
    }
  }
  
  func inMainContext(callback: NSManagedObjectContext -> Void) {
    // Dispatch the request to our serial queue first and then back to the context queue.
    // Since we set up the stack on this queue it will have succeeded or failed before
    // this block is executed.
    dispatch_async(queue) {
      self.mainContext.performBlock {
        callback(self.mainContext)
      }
    }
  }

  func inMainContextEx(callback: (NSManagedObjectContext, NSPersistentStoreCoordinator) -> Void) {
    // Dispatch the request to our serial queue first and then back to the context queue.
    // Since we set up the stack on this queue it will have succeeded or failed before
    // this block is executed.
    dispatch_async(queue) {
      self.mainContext.performBlock {
        callback(self.mainContext, self.persistentStoreCoordinator)
      }
    }
  }

  func inPrivateContext(callback: NSManagedObjectContext -> Void) {
    // Dispatch the request to our serial queue first and then back to the context queue.
    // Since we set up the stack on this queue it will have succeeded or failed before
    // this block is executed.
    dispatch_async(queue) {
      self.privateContext.performBlock {
        callback(self.privateContext)
      }
    }
  }

  func inPrivateContextEx(callback: (NSManagedObjectContext, NSPersistentStoreCoordinator) -> Void) {
    // Dispatch the request to our serial queue first and then back to the context queue.
    // Since we set up the stack on this queue it will have succeeded or failed before
    // this block is executed.
    dispatch_async(queue) {
      self.privateContext.performBlock {
        callback(self.privateContext, self.persistentStoreCoordinator)
      }
    }
  }
  
  func saveAllContexts() {
    dispatch_async(queue) {
      CoreDataStack.saveContext(self.mainContext)
      CoreDataStack.saveContext(self.privateContext)
    }
  }
  
  func mergeAllContextsWithNotification(notification: NSNotification) {
    dispatch_async(queue) {
      if notification.object !== self.mainContext {
        self.mainContext.performBlock {
          self.mainContext.mergeChangesFromContextDidSaveNotification(notification)
          NSNotificationCenter.defaultCenter().postNotificationName(GlobalConstants.notificationManagedObjectContextWasMerged, object: self.mainContext)
        }
      }
      
      if notification.object !== self.privateContext {
        self.privateContext.performBlock {
          self.privateContext.mergeChangesFromContextDidSaveNotification(notification)
          NSNotificationCenter.defaultCenter().postNotificationName(GlobalConstants.notificationManagedObjectContextWasMerged, object: self.privateContext)
        }
      }
    }
  }
  
  // MARK: - Core Data Saving support
  
  class func saveContext(managedObjectContext: NSManagedObjectContext) {
    if !managedObjectContext.hasChanges {
      return
    }
    
    do {
      try managedObjectContext.save()
    } catch {
      let nserror = error as NSError
      Logger.logError(Logger.Messages.failedToSaveManagedObjectContext, error: nserror)
      abort()
    }
  }
  
  class func saveAllContexts() {
    sharedInstance.saveAllContexts()
  }
  
  class func mergeAllContextsWithNotification(notification: NSNotification) {
    sharedInstance.mergeAllContextsWithNotification(notification)
  }

  // MARK: - Convenient methods
  
  class func inMainContext(callback: NSManagedObjectContext -> Void) {
    sharedInstance.inMainContext(callback)
  }
  
  class func inMainContextEx(callback: (NSManagedObjectContext, NSPersistentStoreCoordinator) -> Void) {
    sharedInstance.inMainContextEx(callback)
  }
  
  class func inPrivateContext(callback: NSManagedObjectContext -> Void) {
    sharedInstance.inPrivateContext(callback)
  }
  
  class func inPrivateContextEx(callback: (NSManagedObjectContext, NSPersistentStoreCoordinator) -> Void) {
    sharedInstance.inPrivateContextEx(callback)
  }

}
