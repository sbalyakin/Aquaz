//
//  WormholeDataProvider.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 20.10.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData

final class WormholeDataProvider: NSObject {

  private var wormhole: MMWormhole!

  override init() {
    super.init()
    
    initWormhole()
    setupCoreDataSynchronization()
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  private func initWormhole() {
    wormhole = MMWormhole(applicationGroupIdentifier: GlobalConstants.appGroupName, optionalDirectory: GlobalConstants.wormholeOptionalDirectory)

    wormhole.listenForMessageWithIdentifier(GlobalConstants.wormholeMessageFromWidget) { [weak self] messageObject in
      if let notification = messageObject as? NSNotification {
        CoreDataStack.mergeAllContextsWithNotification(notification)
        self?.wormhole.clearMessageContentsForIdentifier(GlobalConstants.wormholeMessageFromWidget)
      }
    }
  }
  
  private func setupCoreDataSynchronization() {
    CoreDataStack.performOnPrivateContext { privateContext in
      NSNotificationCenter.defaultCenter().addObserver(
        self,
        selector: #selector(self.managedObjectContextDidSave(_:)),
        name: NSManagedObjectContextDidSaveNotification,
        object: privateContext)
    }
  }
  
  func managedObjectContextDidSave(notification: NSNotification) {
    wormhole.passMessageObject(notification, identifier: GlobalConstants.wormholeMessageFromAquaz)
  }
  
}