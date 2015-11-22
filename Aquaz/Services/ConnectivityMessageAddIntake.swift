//
//  ConnectivityAddIntake.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 20.10.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import Foundation

final class ConnectivityMessageAddIntake {
  
  // MARK: Types
  
  private struct Keys {
    static let drinkType = "drinkType"
    static let amount    = "amount"
    static let date      = "date"
  }
  
  private struct Constants {
    static let messageKey   = "message"
    static let messagevalue = "ConnectivityMessageAddIntake"
  }

  // MARK: Properties

  var drinkType: DrinkType
  var amount: Double
  var date: NSDate
  
  // MARK: Methods
  
  init(drinkType: DrinkType, amount: Double, date: NSDate) {
    self.drinkType = drinkType
    self.amount    = amount
    self.date      = date
  }
  
  init?(metadata: [String : AnyObject]) {
    guard
      let messageValue   = metadata[Constants.messageKey] as? String where messageValue == Constants.messagevalue,
      let drinkTypeIndex = metadata[Keys.drinkType] as? Int,
      let drinkType      = DrinkType(rawValue: drinkTypeIndex),
      let amount         = metadata[Keys.amount] as? Double,
      let date           = metadata[Keys.date] as? NSDate else
    {
      self.drinkType = .Water
      self.amount = 0
      self.date = NSDate()

      return nil
    }
    
    self.drinkType = drinkType
    self.amount    = amount
    self.date      = date
  }
  
  func composeMetadata() -> [String : AnyObject] {
    var metadata = [String : AnyObject]()
    
    metadata[Constants.messageKey] = Constants.messagevalue
    metadata[Keys.drinkType]       = drinkType.rawValue
    metadata[Keys.amount]          = amount
    metadata[Keys.date]            = date
    
    return metadata
  }
  
}