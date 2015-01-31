//
//  RecentAmount.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 07.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData

class RecentAmount: NSManagedObject, NamedEntity {
  
  @NSManaged var amount: NSNumber
  @NSManaged var drink: Drink
  
  class func getEntityName() -> String {
    return "RecentAmount"
  }
}
