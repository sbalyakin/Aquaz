//
//  Consumption.swift
//  Water Me
//
//  Created by Sergey Balyakin on 06.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData

class Consumption: NSManagedObject {
  
  @NSManaged var date: NSDate
  @NSManaged var amount: NSNumber
  @NSManaged var drink: NSManagedObject
  
}
