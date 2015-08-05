//
//  CodingManagedObject.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 10.04.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData

public class CodingManagedObject: NSManagedObject, NSCoding {
  
  private static let encodeKey = "URIRepresentation"
  
  public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
    super.init(entity: entity, insertIntoManagedObjectContext: context)
  }
  
  // It's a fake initializer, real decoding will be made in awakeAfterUsingCoder
  public convenience required init(coder aDecoder: NSCoder) {
    if let managedObject = CodingManagedObject.getExistingManagedObject(aDecoder) {
      self.init(entity: managedObject.entity, insertIntoManagedObjectContext: nil)
    } else {
      assert(false)
      self.init()
    }
  }
  
  public override func awakeAfterUsingCoder(aDecoder: NSCoder) -> AnyObject? {
    return CodingManagedObject.getExistingManagedObject(aDecoder)
  }
  
  private class func getExistingManagedObject(aDecoder: NSCoder) -> NSManagedObject? {
    if let url = aDecoder.decodeObjectForKey(encodeKey) as? NSURL,
       let managedObjectID = CoreDataStack.persistentStoreCoordinator.managedObjectIDForURIRepresentation(url)
    {
      let group = dispatch_group_create()
      dispatch_group_enter(group)

      var managedObject: NSManagedObject?

      CoreDataStack.privateContext.performBlock {
        managedObject = CoreDataStack.privateContext.existingObjectWithID(managedObjectID, error: nil)
        dispatch_group_leave(group)
      }

      dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
      
      return managedObject
    } else {
      return nil
    }
  }
  
  public func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(objectID.URIRepresentation(), forKey: CodingManagedObject.encodeKey)
  }
  
}