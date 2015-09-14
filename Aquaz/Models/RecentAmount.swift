//
//  RecentAmount.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 07.10.14.
//  Copyright © 2014 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData

@objc(RecentAmount)
class RecentAmount: CodingManagedObject, NamedEntity {
  
  static var entityName = "RecentAmount"
  
  @NSManaged var amount: Double
  @NSManaged var drink: Drink
  
}
