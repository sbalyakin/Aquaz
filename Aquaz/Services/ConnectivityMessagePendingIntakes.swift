//
//  ConnectivityMessagePendingIntakes.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 08.11.16.
//  Copyright © 2016 Sergey Balyakin. All rights reserved.
//

import Foundation

final class ConnectivityMessagePendingIntakes {
  
  // MARK: Types
  
  fileprivate struct Keys {
    static let drinkType = "drinkType"
    static let amount    = "amount"
    static let date      = "date"
  }
  
  fileprivate struct Constants {
    static let messageKey   = "message"
    static let messageValue = "ConnectivityMessagePendingIntakes"
    static let dataKey      = "data"
  }
  
  // MARK: Properties
  
  var pendingIntakes = [(drinkType: DrinkType, amount: Double, date: Date)]()
  
  // MARK: Methods
  
  init() {
  }
  
  init?(metadata: [String : Any]) {
    guard let messageValue = metadata[Constants.messageKey] as? String, messageValue == Constants.messageValue,
          let data = metadata[Constants.dataKey] as? [[String: Any]] else
    {
      return nil
    }
    
    for intakeInfo in data {
      if let drinkTypeIndex = intakeInfo[Keys.drinkType] as? Int,
         let drinkType = DrinkType(rawValue: drinkTypeIndex),
         let amount = intakeInfo[Keys.amount] as? Double,
         let date = intakeInfo[Keys.date] as? Date
      {
        pendingIntakes.append((drinkType: drinkType, amount: amount, date: date))
      }
    }
    
    if pendingIntakes.count == 0 {
      return nil
    }
  }
  
  func addIntake(drinkType: DrinkType, amount: Double, date: Date) {
    pendingIntakes.append((drinkType: drinkType, amount: amount, date: date))
  }
  
  func clear() {
    pendingIntakes.removeAll(keepingCapacity: false)
  }
  
  func composeMetadata() -> [String : Any]? {
    if pendingIntakes.count == 0 {
      return nil
    }
    
    var intakesData = [[String: Any]]()
    
    for intake in pendingIntakes {
      let intakeInfo: [String: Any] = [
        Keys.drinkType: intake.drinkType.rawValue,
        Keys.amount: intake.amount,
        Keys.date: intake.date]
      intakesData.append(intakeInfo)
    }

    var metadata = [String : Any]()
    
    metadata[Constants.messageKey] = Constants.messageValue
    metadata[Constants.dataKey] = intakesData

    return metadata
  }
  
}
