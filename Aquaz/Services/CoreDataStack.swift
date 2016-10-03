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
  
  fileprivate var containerURL: URL!
  fileprivate var managedObjectModel: NSManagedObjectModel!
  fileprivate var persistentStoreCoordinator: NSPersistentStoreCoordinator!
//  private var mainContext: NSManagedObjectContext!
  fileprivate var privateContext: NSManagedObjectContext!
  fileprivate let queue = DispatchQueue(label: "com.devmanifest.Aquaz.CoreDataStack", attributes: [])
  
  override init() {
    super.init()
    
    // Use a serial queue in order to not freeze the main UI queue
    queue.async {
      if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: GlobalConstants.appGroupName) {
        self.containerURL = containerURL
      } else {
        CLSLogv("Core Data Stack initialization error: Failed to obtain the container URL", getVaList([]))
        fatalError()
      }
      
      guard let modelURL = Bundle.main.url(forResource: "Aquaz", withExtension: "momd") else {
        CLSLogv("Core Data Stack initialization error: Failed to obtain the model URL", getVaList([]))
        fatalError()
      }
      
      if let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) {
        self.managedObjectModel = managedObjectModel
      } else {
        CLSLogv("Core Data Stack initialization error: Failed to initialize the managed object model", getVaList([]))
        fatalError()
      }
      
      self.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
      
//      self.mainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
//      self.mainContext.persistentStoreCoordinator = self.persistentStoreCoordinator
      
      self.privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
      self.privateContext.persistentStoreCoordinator = self.persistentStoreCoordinator
      
      do {
        let url = self.containerURL.appendingPathComponent("Aquaz.sqlite")
        
        try self.persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
      } catch {
        let nserror = error as NSError
        CLSLogv("Core Data Stack initialization error: Failed to add the persistent store. Error: \(nserror.description)", getVaList([]))
        fatalError()
      }
    }
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.contextDidSaveContext(_:)),
      name: NSNotification.Name.NSManagedObjectContextDidSave,
      object: nil)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - Notifications
  
  func contextDidSaveContext(_ notification: Notification) {
    if let context = notification.object as? NSManagedObjectContext,
       context !== privateContext
    {
      queue.async {
        self.privateContext.perform {
          self.privateContext.mergeChanges(fromContextDidSave: notification)
          NotificationCenter.default.post(
            name: Notification.Name(rawValue: GlobalConstants.notificationManagedObjectContextWasMerged),
            object: self.privateContext,
            userInfo: (notification as NSNotification).userInfo)
        }
      }
    }
  }
  
  
  // MARK: - Functions
  
  fileprivate func printStack(_ stack: [String], depth: Int = -1) {
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
  
//  func inMainContext(callback: NSManagedObjectContext -> Void) {
//    // Dispatch the request to our serial queue first and then back to the context queue.
//    // Since we set up the stack on this queue it will have succeeded or failed before
//    // this block is executed.
//    dispatch_async(queue) {
//      self.mainContext.performBlock {
//        callback(self.mainContext)
//      }
//    }
//  }
//  
  func performOnPrivateContext(_ callback: @escaping (NSManagedObjectContext) -> Void) {
    // Dispatch the request to our serial queue first and then back to the context queue.
    // Since we set up the stack on this queue it will have succeeded or failed before
    // this block is executed.
    queue.async {
      self.privateContext.perform {
        callback(self.privateContext)
      }
    }
  }

  func performOnPrivateContextAndWait(_ callback: @escaping (NSManagedObjectContext) -> Void) {
    let dispatchGroup = DispatchGroup()
    dispatchGroup.enter()

    // Dispatch the request to our serial queue first and then back to the context queue.
    // Since we set up the stack on this queue it will have succeeded or failed before
    // this block is executed.
    queue.async {
      self.privateContext.perform {
        callback(self.privateContext)
        dispatchGroup.leave()
      }
    }
    
    _ = dispatchGroup.wait(timeout: DispatchTime.distantFuture)
  }

  func saveAllContexts() {
    queue.async {
//      CoreDataStack.saveContext(self.mainContext)
      CoreDataStack.saveContext(self.privateContext)
    }
  }
  
  func mergeAllContextsWithNotification(_ notification: Notification) {
    queue.async {
//      self.mainContext.performBlock {
//        self.mainContext.mergeChangesFromContextDidSaveNotification(notification)
//        NSNotificationCenter.defaultCenter().postNotificationName(
//          GlobalConstants.notificationManagedObjectContextWasMerged,
//          object: self.mainContext,
//          userInfo: notification.userInfo)
//      }
    
      self.privateContext.perform {
        self.privateContext.mergeChanges(fromContextDidSave: notification)
        NotificationCenter.default.post(
          name: Notification.Name(rawValue: GlobalConstants.notificationManagedObjectContextWasMerged),
          object: self.privateContext,
          userInfo: (notification as NSNotification).userInfo)
      }
    }
  }
  
  // MARK: - Core Data Saving support
  
  class func saveContext(_ managedObjectContext: NSManagedObjectContext) {
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
  
  class func mergeAllContextsWithNotification(_ notification: Notification) {
    sharedInstance.mergeAllContextsWithNotification(notification)
  }
  
  // MARK: - Convenient methods
  
//  class func inMainContext(callback: NSManagedObjectContext -> Void) {
//    sharedInstance.inMainContext(callback)
//  }
//  
  class func performOnPrivateContext(_ callback: @escaping (NSManagedObjectContext) -> Void) {
    sharedInstance.performOnPrivateContext(callback)
  }

  class func performOnPrivateContextAndWait(_ callback: @escaping (NSManagedObjectContext) -> Void) {
    sharedInstance.performOnPrivateContextAndWait(callback)
  }

}
