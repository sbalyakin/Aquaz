//
//  WormholeDataProvider.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 20.10.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData
import MMWormhole

final class WormholeDataProvider: NSObject {

  fileprivate var wormhole: MMWormhole!

  override init() {
    super.init()
    
    initWormhole()
    setupCoreDataSynchronization()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  fileprivate func initWormhole() {
    wormhole = MMWormhole(applicationGroupIdentifier: GlobalConstants.appGroupName, optionalDirectory: GlobalConstants.wormholeOptionalDirectory)

    wormhole.listenForMessage(withIdentifier: GlobalConstants.wormholeMessageFromWidget) { [weak self] messageObject in
      if let notification = messageObject as? Notification {
        CoreDataStack.mergeAllContextsWithNotification(notification)
        self?.wormhole.clearMessageContents(forIdentifier: GlobalConstants.wormholeMessageFromWidget)
      }
    }
  }
  
  fileprivate func setupCoreDataSynchronization() {
    CoreDataStack.performOnPrivateContext { privateContext in
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(self.managedObjectContextDidSave(_:)),
        name: NSNotification.Name.NSManagedObjectContextDidSave,
        object: privateContext)
    }
  }
  
  @objc func managedObjectContextDidSave(_ notification: Notification) {
    // By unknown reason existance of "managedObjectContext" key produces an exception during passing massage object through wormhole
    var clearedNotification = notification
    _ = clearedNotification.userInfo?.removeValue(forKey: "managedObjectContext")
    
    wormhole.passMessageObject(clearedNotification as NSCoding?, identifier: GlobalConstants.wormholeMessageFromAquaz)
  }
  
}
