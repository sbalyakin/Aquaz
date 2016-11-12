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
  
  private struct Keys {
    static let messageDate           = "messageDate"
    static let hydrationAmount       = "hydrationAmount"
    static let dehydrationAmount     = "dehydrationAmount"
    static let dailyWaterGoal        = "dailyWaterGoal"
    static let isHighActivityEnabled = "isHighActivityEnabled"
    static let isHotWeatherEnabled   = "isHotWeatherEnabled"
    static let volumeUnits           = "volumeUnits"
  }
  
  private struct Constants {
    static let messageKey   = "message"
    static let messageValue = "ConnectivityMessageCurrentState"
  }

  // MARK: Properties

  let messageDate: Date
  let hydrationAmount: Double
  let dehydrationAmount: Double
  let dailyWaterGoal: Double
  let isHighActivityEnabled: Bool
  let isHotWeatherEnabled: Bool
  let volumeUnits: Units.Volume
  
  // MARK: Methods
  
  init(messageDate: Date,
       hydrationAmount: Double,
       dehydrationAmount: Double,
       dailyWaterGoal: Double,
       highPhysicalActivityModeEnabled: Bool,
       hotWeatherModeEnabled: Bool,
       volumeUnits: Units.Volume) {
    self.messageDate           = messageDate
    self.hydrationAmount       = hydrationAmount
    self.dehydrationAmount     = dehydrationAmount
    self.dailyWaterGoal        = dailyWaterGoal
    self.isHighActivityEnabled = highPhysicalActivityModeEnabled
    self.isHotWeatherEnabled   = hotWeatherModeEnabled
    self.volumeUnits           = volumeUnits
  }
  
  init?(metadata: [String : Any]) {
    guard
      let messageValue          = metadata[Constants.messageKey]       as? String , messageValue == Constants.messageValue,
      let messageDate           = metadata[Keys.messageDate]           as? Date,
      let hydrationAmount       = metadata[Keys.hydrationAmount]       as? Double,
      let dehydrationAmount     = metadata[Keys.dehydrationAmount]     as? Double,
      let dailyWaterGoal        = metadata[Keys.dailyWaterGoal]        as? Double,
      let isHighActivityEnabled = metadata[Keys.isHighActivityEnabled] as? Bool,
      let isHotWeatherEnabled   = metadata[Keys.isHotWeatherEnabled]   as? Bool,
      let volumeUnitsRawValue   = metadata[Keys.volumeUnits]           as? Int,
      let volumeUnits           = Units.Volume(rawValue: volumeUnitsRawValue) else
    {
      return nil
    }
    
    self.messageDate           = messageDate
    self.hydrationAmount       = hydrationAmount
    self.dehydrationAmount     = dehydrationAmount
    self.dailyWaterGoal        = dailyWaterGoal
    self.isHighActivityEnabled = isHighActivityEnabled
    self.isHotWeatherEnabled   = isHotWeatherEnabled
    self.volumeUnits           = volumeUnits
  }
  
  func composeMetadata() -> [String : Any] {
    let metadata: [String : Any] = [
      Constants.messageKey      : Constants.messageValue,
      Keys.messageDate          : messageDate,
      Keys.hydrationAmount      : hydrationAmount,
      Keys.dehydrationAmount    : dehydrationAmount,
      Keys.dailyWaterGoal       : dailyWaterGoal,
      Keys.isHighActivityEnabled: isHighActivityEnabled,
      Keys.isHotWeatherEnabled  : isHotWeatherEnabled,
      Keys.volumeUnits          : volumeUnits.rawValue]
    
    return metadata
  }
  
}
