//
//  Settings.swift
//  Water Me
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
    }
  }
  
  init(key: String, initialValue: ValueType, userDefaults: NSUserDefaults) {
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
  
  override init(key: String, initialValue: T, userDefaults: NSUserDefaults) {
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

  override init(key: String, initialValue: T, userDefaults: NSUserDefaults) {
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
  
  lazy var generalWeightUnits: SettingsEnumItem<Units.Weight> = SettingsEnumItem(
    key: "General - Weight units",initialValue: .Kilograms, userDefaults: self.standardUserDefaults)
  
  lazy var generalHeightUnits: SettingsEnumItem<Units.Length> = SettingsEnumItem(
    key: "General - Height units", initialValue: .Centimeters, userDefaults: self.standardUserDefaults)
  
  lazy var generalVolumeUnits: SettingsEnumItem<Units.Volume> = SettingsEnumItem(
    key: "General - Volume units", initialValue: .Millilitres, userDefaults: self.standardUserDefaults)
  
  lazy var generalExtraConsumptionHot: SettingsOrdinalItem<Double> = SettingsOrdinalItem(
    key: "General - Extra consumption hot", initialValue: 0.5, userDefaults: self.standardUserDefaults)
  
  lazy var generalExtraConsumptionHighActivity: SettingsOrdinalItem<Double> = SettingsOrdinalItem(
    key: "General - Extra consumption high activity", initialValue: 0.5, userDefaults: self.standardUserDefaults)
  
  lazy var userHeight: SettingsOrdinalItem<Double> = SettingsOrdinalItem(
    key: "User - Height", initialValue: 170, userDefaults: self.standardUserDefaults)
  
  lazy var userWeight: SettingsOrdinalItem<Double> = SettingsOrdinalItem(
    key: "User - Weight", initialValue: 70, userDefaults: self.standardUserDefaults)
  
  lazy var userPhysicalActivity: SettingsEnumItem<PhysicalActivity> = SettingsEnumItem(
    key: "User - Physical activity", initialValue: .Occasional, userDefaults: self.standardUserDefaults)
  
  lazy var userGender: SettingsEnumItem<Gender> = SettingsEnumItem(
    key: "User - Gender", initialValue: .Man, userDefaults: self.standardUserDefaults)
  
  lazy var userAge: SettingsOrdinalItem<Int> = SettingsOrdinalItem(
    key: "User - Age", initialValue: 30, userDefaults: self.standardUserDefaults)
  
  lazy var userDailyWaterIntake: SettingsOrdinalItem<Double> = SettingsOrdinalItem(
    key: "User - Daily water intake", initialValue: 2000.0, userDefaults: self.standardUserDefaults)

  lazy var uiDisplayDaySelection: SettingsOrdinalItem<Bool> = SettingsOrdinalItem(
    key: "UI - Display day selection", initialValue: false, userDefaults: self.standardUserDefaults)

  lazy var uiSelectedStatisticsPage: SettingsEnumItem<StatisticsViewController.ViewControllerType> = SettingsEnumItem(
    key: "UI - Selected statistics page", initialValue: .Week, userDefaults: self.standardUserDefaults)

  lazy var uiWeekStatisticsDate: SettingsOrdinalItem<NSDate> = SettingsOrdinalItem(
    key: "UI - Week statistics date", initialValue: NSDate(), userDefaults: self.standardUserDefaults)

  lazy var uiMonthStatisticsDate: SettingsOrdinalItem<NSDate> = SettingsOrdinalItem(
    key: "UI - Month statistics date", initialValue: NSDate(), userDefaults: self.standardUserDefaults)
  
  lazy var uiYearStatisticsDate: SettingsOrdinalItem<NSDate> = SettingsOrdinalItem(
    key: "UI - Year statistics date", initialValue: NSDate(), userDefaults: self.standardUserDefaults)

  lazy var notificationsEnabled: SettingsOrdinalItem<Bool> = SettingsOrdinalItem(
    key: "Notifications - Enabled", initialValue: false, userDefaults: self.standardUserDefaults)

  lazy var notificationsFrom: SettingsOrdinalItem<NSDate> = SettingsOrdinalItem(
    key: "Notifications - From", initialValue: DateHelper.dateBySettingHour(9, minute: 0, second: 0, ofDate: NSDate()), userDefaults: self.standardUserDefaults)
  
  lazy var notificationsTo: SettingsOrdinalItem<NSDate> = SettingsOrdinalItem(
    key: "Notifications - To", initialValue: DateHelper.dateBySettingHour(21, minute: 0, second: 0, ofDate: NSDate()), userDefaults: self.standardUserDefaults)

  lazy var notificationsInterval: SettingsOrdinalItem<NSTimeInterval> = SettingsOrdinalItem(
    key: "Notifications - Interval", initialValue: 60 * 60 * 1.5, userDefaults: self.standardUserDefaults)

  lazy var notificationsSmart: SettingsOrdinalItem<Bool> = SettingsOrdinalItem(
    key: "Notifications - Smart", initialValue: true, userDefaults: self.standardUserDefaults)

  lazy var notificationsUseWaterIntake: SettingsOrdinalItem<Bool> = SettingsOrdinalItem(
    key: "Notifications - Use water intake", initialValue: true, userDefaults: self.standardUserDefaults)

  private let standardUserDefaults = NSUserDefaults.standardUserDefaults()
}
