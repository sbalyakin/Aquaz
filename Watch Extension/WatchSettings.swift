//
//  WatchSettings.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 15.11.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import Foundation

final class WatchSettings {
  
  static let sharedInstance = WatchSettings()
  
  static let userDefaults = UserDefaults(suiteName: GlobalConstants.appGroupName)!
  
  // MARK: Types
  
  class RecentDrinkAmounts {
    
    typealias SettingsType = SettingsOrdinalItem<Double>
    
    fileprivate var settingsItems = [SettingsType]()
    
    fileprivate init() {
      for index in 0..<DrinkType.count {
        let key = "Recent amount - Drink \(index)"
        let settingsItem = SettingsType(key: key, initialValue: 250, userDefaults: WatchSettings.userDefaults)
        settingsItems += [settingsItem]
      }
    }
    
    subscript (index: DrinkType) -> SettingsType {
      return settingsItems[index.rawValue]
    }
  }
  
  // MARK: General
  
  lazy var generalWeightUnits: SettingsEnumItem<Units.Weight> = SettingsEnumItem(
    key: "General - Weight units", initialValue: isMetric ? .kilograms : .pounds,
    userDefaults: userDefaults)
  
  lazy var generalHeightUnits: SettingsEnumItem<Units.Length> = SettingsEnumItem(
    key: "General - Height units", initialValue: isMetric ? .centimeters : .feet,
    userDefaults: userDefaults)
  
  lazy var generalVolumeUnits: SettingsEnumItem<Units.Volume> = SettingsEnumItem(
    key: "General - Volume units", initialValue: isMetric ? .millilitres : .fluidOunces,
    userDefaults: userDefaults)

  // MARK: Current state

  lazy var stateWaterGoal = SettingsOrdinalItem<Double>(
    key: "State - Water Goal", initialValue: 2100,
    userDefaults: userDefaults)

  lazy var stateHydration = SettingsOrdinalItem<Double>(
    key: "State - Hydration", initialValue: 0,
    userDefaults: userDefaults)
  
  lazy var stateCurrentDate = SettingsOrdinalItem<Date>(
    key: "State - Current Date", initialValue: DateHelper.startOfDay(Date()),
    userDefaults: userDefaults)
  
  // MARK: Intake parameters
  
  lazy var recentDrinkType = SettingsEnumItem<DrinkType>(
    key: "State - Recent Drink Type", initialValue: .water,
    userDefaults: userDefaults)
  
  lazy var recentAmounts = RecentDrinkAmounts()

  // MARK: Initializer
  
  fileprivate init() {
    // Hide initizalizer, sharedInstance should be used instead.
  }
  
  // MARK: Helpers
  
  fileprivate class var isMetric: Bool {
    return (Locale.current as NSLocale).object(forKey: NSLocale.Key.usesMetricSystem)! as! Bool
  }
  
}

extension Units.Length {
  static var settings: Units.Length {
    return WatchSettings.sharedInstance.generalHeightUnits.value
  }
}

extension Units.Volume {
  static var settings: Units.Volume {
    return WatchSettings.sharedInstance.generalVolumeUnits.value
  }
}

extension Units.Weight {
  static var settings: Units.Weight {
    return WatchSettings.sharedInstance.generalWeightUnits.value
  }
}
