//
//  LoggedActions.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 09.03.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData

public class LoggedActions {
  
  public class func instantiateViewController<ViewControllerType>(#storyboard: UIStoryboard?, storyboardID: String) -> ViewControllerType? {
    let viewController = storyboard?.instantiateViewControllerWithIdentifier(storyboardID) as? ViewControllerType
    Logger.checkViewController(viewController != nil, storyboardID: storyboardID)
    return viewController
  }

  public class func insertNewObjectForEntity<Entity: NamedEntity>(entityType: Entity.Type, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> Entity? {
    let entity = NSEntityDescription.insertNewObjectForEntityForName(entityType.entityName, inManagedObjectContext: managedObjectContext) as? Entity
    let logDetails = [Logger.Attributes.entity: entityType.entityName]
    Logger.logSevere(entity != nil, Logger.Messages.failedToInsertNewObjectForEntity, logDetails: logDetails)
    return entity
  }
  
  public class func entityDescriptionForEntity<Entity: NamedEntity>(entityType: Entity.Type, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
    let entityDescription = NSEntityDescription.entityForName(entityType.entityName, inManagedObjectContext: managedObjectContext)
    let logDetails = [Logger.Attributes.entity: entityType.entityName]
    Logger.logSevere(entityDescription != nil, Logger.Messages.failedToCreateEntityDescription, logDetails: logDetails)
    return entityDescription
  }
  
  // Hiding initializer to prevent class creation
  private init() { }
  
}