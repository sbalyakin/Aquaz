//
//  RecentAmount.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 07.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData

@objc(RecentAmount)
public class RecentAmount: CodingManagedObject, NamedEntity {
  
  public static var entityName = "RecentAmount"
  
  @NSManaged public var amount: Double
  @NSManaged public var drink: Drink
  
}
