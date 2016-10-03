//
//  ConnectivityMessageCurrentState.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 20.10.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import Foundation

final class ConnectivityMessageCurrentState {

  // MARK: Types
  
  fileprivate struct Keys {
    static let messageDate           = "messageDate"
    static let hydrationAmount       = "hydrationAmount"
    static let dehydrationAmount     = "dehydrationAmount"
    static let dailyWaterGoal        = "dailyWaterGoal"
    static let isHighActivityEnabled = "isHighActivityEnabled"
    static let isHotWeatherEnabled   = "isHotWeatherEnabled"
  }
  
  fileprivate struct Constants {
    static let messageKey   = "message"
    static let messageValue = "ConnectivityMessageCurrentState"
  }

  // MARK: Properties

  var messageDate: Date
  var hydrationAmount: Double
  var dehydrationAmount: Double
  var dailyWaterGoal: Double
  var isHighActivityEnabled: Bool
  var isHotWeatherEnabled: Bool
  
  // MARK: Methods
  
  init(messageDate: Date, hydrationAmount: Double, dehydrationAmount: Double, dailyWaterGoal: Double, highPhysicalActivityModeEnabled: Bool, hotWeatherModeEnabled: Bool) {
    self.messageDate           = messageDate
    self.hydrationAmount       = hydrationAmount
    self.dehydrationAmount     = dehydrationAmount
    self.dailyWaterGoal        = dailyWaterGoal
    self.isHighActivityEnabled = highPhysicalActivityModeEnabled
    self.isHotWeatherEnabled   = hotWeatherModeEnabled
  }
  
  init?(metadata: [String : Any]) {
    guard
      let messageValue          = metadata[Constants.messageKey]       as? String , messageValue == Constants.messageValue,
      let messageDate           = metadata[Keys.messageDate]           as? Date,
      let hydrationAmount       = metadata[Keys.hydrationAmount]       as? Double,
      let dehydrationAmount     = metadata[Keys.dehydrationAmount]     as? Double,
      let dailyWaterGoal        = metadata[Keys.dailyWaterGoal]        as? Double,
      let isHighActivityEnabled = metadata[Keys.isHighActivityEnabled] as? Bool,
      let isHotWeatherEnabled   = metadata[Keys.isHotWeatherEnabled]   as? Bool else
    {
      self.messageDate = Date()
      self.hydrationAmount = 0
      self.dehydrationAmount = 0
      self.dailyWaterGoal = 0
      self.isHighActivityEnabled = false
      self.isHotWeatherEnabled = false
      
      return nil
    }
    
    self.messageDate           = messageDate
    self.hydrationAmount       = hydrationAmount
    self.dehydrationAmount     = dehydrationAmount
    self.dailyWaterGoal        = dailyWaterGoal
    self.isHighActivityEnabled = isHighActivityEnabled
    self.isHotWeatherEnabled   = isHotWeatherEnabled
  }
  
  func composeMetadata() -> [String : Any] {
    var metadata = [String : Any]()
    
    metadata[Constants.messageKey]       = Constants.messageValue
    metadata[Keys.messageDate]           = messageDate
    metadata[Keys.hydrationAmount]       = hydrationAmount
    metadata[Keys.dehydrationAmount]     = dehydrationAmount
    metadata[Keys.dailyWaterGoal]        = dailyWaterGoal
    metadata[Keys.isHighActivityEnabled] = isHighActivityEnabled
    metadata[Keys.isHotWeatherEnabled]   = isHotWeatherEnabled
    
    return metadata
  }
  
}
