//
//  RecentAmount.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 07.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData

public class RecentAmount: NSManagedObject, NamedEntity {
  
  public static var entityName = "RecentAmount"
  
  @NSManaged public var amount: NSNumber
  @NSManaged public var drink: Drink
  
}
