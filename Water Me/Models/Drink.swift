//
//  Drink.swift
//  Water Me
//
//  Created by Sergey Balyakin on 06.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData

class Drink: NSManagedObject {
  
  @NSManaged var name: String
  @NSManaged var color: AnyObject
  @NSManaged var waterPercent: NSNumber
  @NSManaged var recentAmount: RecentAmount
  @NSManaged var consumption: Consumption
  
}
