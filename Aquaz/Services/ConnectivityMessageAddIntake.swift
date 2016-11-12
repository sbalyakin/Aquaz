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
  
  fileprivate struct Keys {
    static let drinkType = "drinkType"
    static let amount    = "amount"
    static let date      = "date"
  }
  
  fileprivate struct Constants {
    static let messageKey   = "message"
    static let messageValue = "ConnectivityMessageAddIntake"
  }

  // MARK: Properties

  var drinkType: DrinkType
  var amount: Double
  var date: Date
  
  // MARK: Methods
  
  init(drinkType: DrinkType, amount: Double, date: Date) {
    self.drinkType = drinkType
    self.amount    = amount
    self.date      = date
  }
  
  init?(metadata: [String : Any]) {
    guard
      let messageValue   = metadata[Constants.messageKey] as? String , messageValue == Constants.messageValue,
      let drinkTypeIndex = metadata[Keys.drinkType] as? Int,
      let drinkType      = DrinkType(rawValue: drinkTypeIndex),
      let amount         = metadata[Keys.amount] as? Double,
      let date           = metadata[Keys.date] as? Date else
    {
      self.drinkType = .water
      self.amount = 0
      self.date = Date()

      return nil
    }
    
    self.drinkType = drinkType
    self.amount    = amount
    self.date      = date
  }
  
  func composeMetadata() -> [String : Any] {
    var metadata = [String : Any]()
    
    metadata[Constants.messageKey] = Constants.messageValue
    metadata[Keys.drinkType]       = drinkType.rawValue
    metadata[Keys.amount]          = amount
    metadata[Keys.date]            = date
    
    return metadata
  }
  
}
