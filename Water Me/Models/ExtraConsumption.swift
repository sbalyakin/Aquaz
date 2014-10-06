//
//  ExtraConsumption.swift
//  Water Me
//
//  Created by Sergey Balyakin on 06.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData

class ExtraConsumption: NSManagedObject {
  
  @NSManaged var date: NSDate
  @NSManaged var hot: NSNumber
  @NSManaged var highActivity: NSNumber
  
}
