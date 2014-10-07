//
//  Drink.swift
//  Water Me
//
//  Created by Sergey Balyakin on 07.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData

class Drink: NSManagedObject {

    @NSManaged var color: AnyObject
    @NSManaged var name: String
    @NSManaged var waterPercent: NSNumber
    @NSManaged var consumptions: NSSet
    @NSManaged var recentAmount: RecentAmount

}
