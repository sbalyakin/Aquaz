//
//  SettingItems.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 04.02.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import Foundation

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
public class SettingsItemBase<ValueType>: Observable<ValueType> {
  
  let key: String
  let userDefaults: NSUserDefaults
  let initialValue: ValueType
  
  public var value: ValueType {
    didSet {
      writeValue(value)
      notify(value)
      userDefaults.synchronize()
    }
  }
  
  public convenience init(key: String, initialValue: ValueType) {
    self.init(key: key, initialValue: initialValue, userDefaults: NSUserDefaults.standardUserDefaults())
  }
  
  public init(key: String, initialValue: ValueType, userDefaults: NSUserDefaults) {
    self.value = initialValue
    self.key = key
    self.initialValue = initialValue
    self.userDefaults = userDefaults
    
    super.init()
    
    readFromUserDefaults()
  }
  
  /// Reads the value from user defaults
  public func readFromUserDefaults() {
    readValue(&value)
  }
  
  /// Write the value to user defaults
  public func writeToUserDefaults() {
    writeValue(value)
  }
  
  /// Removes the value from user defaults
  public func removeFromUserDefaults() {
    userDefaults.removeObjectForKey(key)
    value = initialValue
  }
  
  private func readValue(inout outValue: ValueType) {
    assert(false, "readValue function must be overriden")
  }
  
  private func writeValue(value: ValueType) {
    assert(false, "writeValue function must be overriden")
  }
  
}

/// Settings item class for enumerations
public class SettingsEnumItem<T: RawRepresentable where T.RawValue == Int>: SettingsItemBase<T> {
  
  public convenience init(key: String, initialValue: T) {
    self.init(key: key, initialValue: initialValue, userDefaults: NSUserDefaults.standardUserDefaults())
  }
  
  public override init(key: String, initialValue: T, userDefaults: NSUserDefaults) {
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
public class SettingsOrdinalItem<T>: SettingsItemBase<T> {
  
  public convenience init(key: String, initialValue: T) {
    self.init(key: key, initialValue: initialValue, userDefaults: NSUserDefaults.standardUserDefaults())
  }
  
  public override init(key: String, initialValue: T, userDefaults: NSUserDefaults) {
    super.init(key: key, initialValue: initialValue, userDefaults: userDefaults)
  }
  
  private override func readValue(inout outValue: T) {
    if let value = userDefaults.objectForKey(key) as? T {
      outValue = value
    }
  }
  
  private override func writeValue(value: T) {
    switch value {
    case let value as Float:  userDefaults.setFloat  (value, forKey: key)
    case let value as Double: userDefaults.setDouble (value, forKey: key)
    case let value as Int:    userDefaults.setInteger(value, forKey: key)
    case let value as Bool:   userDefaults.setBool   (value, forKey: key)
    case let value as String: userDefaults.setValue  (value, forKey: key)
    case let value as NSDate: userDefaults.setObject (value, forKey: key)
    default: super.writeValue(value)
    }
  }
  
}