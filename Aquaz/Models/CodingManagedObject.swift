//
//  CodingManagedObject.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 10.04.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData

class CodingManagedObject: NSManagedObject, NSCoding {
  
  fileprivate static let encodeKey = "URIRepresentation"
  
  override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
    super.init(entity: entity, insertInto: context)
  }
  
  // It's a fake initializer, real decoding will be made in awakeAfterUsingCoder
  convenience required init?(coder aDecoder: NSCoder) {
    if let managedObject = CodingManagedObject.getExistingManagedObject(aDecoder) {
      self.init(entity: managedObject.entity, insertInto: nil)
    } else {
      return nil
    }
  }
  
  override func awakeAfter(using aDecoder: NSCoder) -> Any? {
    return CodingManagedObject.getExistingManagedObject(aDecoder)
  }
  
  fileprivate class func getExistingManagedObject(_ aDecoder: NSCoder) -> NSManagedObject? {
    var managedObject: NSManagedObject?
    
    CoreDataStack.performOnPrivateContextAndWait { privateContext in
      if let coordinator = privateContext.persistentStoreCoordinator,
         let url = aDecoder.decodeObject(forKey: encodeKey) as? URL,
         let managedObjectID = coordinator.managedObjectID(forURIRepresentation: url)
      {
        managedObject = try? privateContext.existingObject(with: managedObjectID)
      }
    }
    
    return managedObject
  }
  
  func encode(with aCoder: NSCoder) {
    aCoder.encode(objectID.uriRepresentation(), forKey: CodingManagedObject.encodeKey)
  }
  
}
