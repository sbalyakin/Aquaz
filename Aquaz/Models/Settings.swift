//
//  Settings.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 06.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

/// Generic class allows its clients to add/remove observers and notify them
class Observable<ValueType> {
  typealias ObserverFunction = (ValueType) -> Void
  
  /// Adds an observer and returns it unique identifier (in a scope of class instance)
  func addObserver(observerFunction: ObserverFunction) -> Int {
    observerFunctions[observerIdentitfer] = observerFunction
    return observerIdentitfer++
  }
  
  /// Removes an observer using its identifier
  func removeObserver(observerIdentifier: Int) {
    observerFunctions[observerIdentifier] = nil
  }
  
  /// Notifies all observers
  private func notify(value: ValueType) {
    for (_, observerFunction) in observerFunctions {
      observerFunction(value)
    }
  }
  
  private var observerIdentitfer = 0
  private var observerFunctions: [Int: ObserverFunction] = [:]
}

/// Generic class for settings item. Automatically writes changes of a value to user defaults. Provides possibility to observe changes of a value by observers.
class SettingsItemBase<ValueType>: Observable<ValueType> {

  let key: String
  let userDefaults: NSUserDefaults

  var value: ValueType {
    didSet {
      writeValue(value)
      notify(value)
      userDefaults.synchronize()
    }
  }
  
  init(key: String, initialValue: ValueType, userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()) {
    self.value = initialValue
    self.key = key
    self.userDefaults = userDefaults
    
    super.init()
    
    readFromUserDefaults()
  }

  /// Reads the value from user defaults
  func readFromUserDefaults() {
    readValue(&value)
  }
  
  /// Write the value to user defaults
  func writeToUserDefaults() {
    writeValue(value)
  }
  
  private func readValue(inout outValue: ValueType) {
    assert(false, "readValue function must be overriden")
  }
  
  private func writeValue(value: ValueType) {
    assert(false, "writeValue function must be overriden")
  }
  
}

/// Settings item class for enumerations
class SettingsEnumItem<T: RawRepresentable where T.RawValue == Int>: SettingsItemBase<T> {
  
  override init(key: String, initialValue: T, userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()) {
    super.init(key: key, initialValue: initialValue, userDefaults: userDefaults)
  }

  private override func readValue(inout outValue: T) {
    if let rawValue = userDefaults.objectForKey(key) as? T.RawValue {
      if let value = T(rawValue: rawValue) {
        outValue = value
      }
    }
  }
  
  private override func writeValue(value: T) {
    userDefaults.setInteger(value.rawValue, forKey: key)
  }
  
}

/// Settings item class for ordinal types (Int, Bool etc.)
class SettingsOrdinalItem<T>: SettingsItemBase<T> {

  override init(key: String, initialValue: T, userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()) {
    super.init(key: key, initialValue: initialValue, userDefaults: userDefaults)
  }

  private override func readValue(inout outValue: T) {
    if let value = userDefaults.objectForKey(key) as? T {
      outValue = value
    }
  }

  private override func writeValue(value: T) {
    if value is Float {
      userDefaults.setFloat(value as Float, forKey: key)
    } else if value is Double {
      userDefaults.setDouble(value as Double, forKey: key)
    } else if value is Int {
      userDefaults.setInteger(value as Int, forKey: key)
    } else if value is Bool {
      userDefaults.setBool(value as Bool, forKey: key)
    } else if value is String {
      userDefaults.setValue(value as String, forKey: key)
    } else if value is NSDate {
      userDefaults.setObject(value as NSDate, forKey: key)
    } else {
      super.writeValue(value)
    }
  }

}

class Settings {

  class var sharedInstance: Settings {
    struct Instance {
      static let instance = Settings()
    }
    return Instance.instance
  }
  
  enum Gender: Int {
    case Man = 0
    case Woman
    case PregnantFemale
    case BreastfeedingFemale
  }

  enum PhysicalActivity: Int {
    case Rare = 0
    case Occasional
    case Weekly
    case Daily
  }
  
  lazy var generalHasLaunchedOnce = SettingsOrdinalItem(
    key: "General - Has Launched Once", initialValue: false)

  lazy var generalWeightUnits = SettingsEnumItem(
    key: "General - Weight units",initialValue: Units.Weight.Kilograms)
  
  lazy var generalHeightUnits = SettingsEnumItem(
    key: "General - Height units", initialValue: Units.Length.Centimeters)
  
  lazy var generalVolumeUnits = SettingsEnumItem(
    key: "General - Volume units", initialValue: Units.Volume.Millilitres)
  
  lazy var generalExtraConsumptionHot = SettingsOrdinalItem<Double>(
    key: "General - Extra consumption hot", initialValue: 0.5)
  
  lazy var generalExtraConsumptionHighActivity = SettingsOrdinalItem<Double>(
    key: "General - Extra consumption high activity", initialValue: 0.5)
  
  lazy var userHeight = SettingsOrdinalItem<Double>(
    key: "User - Height", initialValue: 170)
  
  lazy var userWeight = SettingsOrdinalItem<Double>(
    key: "User - Weight", initialValue: 70)
  
  lazy var userPhysicalActivity = SettingsEnumItem(
    key: "User - Physical activity", initialValue: PhysicalActivity.Occasional)
  
  lazy var userGender = SettingsEnumItem(
    key: "User - Gender", initialValue: Gender.Man)
  
  lazy var userAge = SettingsOrdinalItem<Int>(
    key: "User - Age", initialValue: 30)
  
  lazy var userDailyWaterIntake = SettingsOrdinalItem<Double>(
    key: "User - Daily water intake", initialValue: 2000)

  lazy var uiUseCustomDateForDayView = SettingsOrdinalItem(
    key: "UI - Use custom day page date", initialValue: false)
  
  lazy var uiCustomDateForDayView = SettingsOrdinalItem(
    key: "UI - Day page date", initialValue: NSDate())

  lazy var uiDisplayDayConsumptionInPercents = SettingsOrdinalItem(
    key: "UI - Display day consumption in percents", initialValue: false)

  lazy var uiDisplayDaySelection = SettingsOrdinalItem(
    key: "UI - Display day selection", initialValue: false)

  lazy var uiSelectedStatisticsPage = SettingsEnumItem(
    key: "UI - Selected statistics page", initialValue: StatisticsViewController.ViewControllerType.Week)

  lazy var uiWeekStatisticsDate = SettingsOrdinalItem(
    key: "UI - Week statistics date", initialValue: NSDate())

  lazy var uiMonthStatisticsDate = SettingsOrdinalItem(
    key: "UI - Month statistics date", initialValue: NSDate())
  
  lazy var uiYearStatisticsDate = SettingsOrdinalItem(
    key: "UI - Year statistics date", initialValue: NSDate())

  lazy var uiSelectedAlcoholicDrink = SettingsEnumItem(
    key: "UI - Selected alcoholic drink", initialValue: Drink.DrinkType.Beer)

  lazy var notificationsEnabled = SettingsOrdinalItem(
    key: "Notifications - Enabled", initialValue: false)

  lazy var notificationsFrom = SettingsOrdinalItem(
    key: "Notifications - From", initialValue: DateHelper.dateBySettingHour(9, minute: 0, second: 0, ofDate: NSDate()))
  
  lazy var notificationsTo = SettingsOrdinalItem(
    key: "Notifications - To", initialValue: DateHelper.dateBySettingHour(21, minute: 0, second: 0, ofDate: NSDate()))

  lazy var notificationsInterval = SettingsOrdinalItem<NSTimeInterval>(
    key: "Notifications - Interval", initialValue: 60 * 60 * 1.5)
  
  lazy var notificationsSound = SettingsOrdinalItem(
    key: "Notifications - Sound", initialValue: "default.wav")
  
  lazy var notificationsSmart = SettingsOrdinalItem(
    key: "Notifications - Smart", initialValue: true)

  lazy var notificationsUseWaterIntake = SettingsOrdinalItem(
    key: "Notifications - Use water intake", initialValue: true)
}
